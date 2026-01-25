import os
import secrets
from datetime import datetime, timezone, timedelta

from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash

from models import db, User
from email_utils import send_password_reset_email
from password_policy import validate_password
from rate_limit import allow, retry_after_seconds

reset_bp = Blueprint("reset", __name__)


def _ttl_minutes() -> int:
    try:
        return int(os.getenv("RESET_TOKEN_TTL_MINUTES", "30"))
    except ValueError:
        return 30


def _page(title: str, badge: str, html: str) -> str:
    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>{title}</title>
  <style>
    :root {{
      --bg:#0b1220; --card:#111827; --border:#1f2937;
      --text:#e5e7eb; --muted:#cbd5e1; --muted2:#94a3b8;
      --btn:#10b981; --btnText:#062014;
      --danger:#ef4444; --warn:#f59e0b;
      --ok:#22c55e;
    }}
    *{{box-sizing:border-box}}
    body{{margin:0;font-family:system-ui,Segoe UI,Roboto,Arial;background:var(--bg);color:var(--text);
         min-height:100vh;display:flex;align-items:center;justify-content:center;padding:28px 16px;}}
    .card{{width:100%;max-width:560px;background:var(--card);border:1px solid var(--border);
          border-radius:18px;overflow:hidden;box-shadow:0 20px 60px rgba(0,0,0,.45);}}
    .top{{padding:14px 18px;background:linear-gradient(90deg,#0ea5e9,#10b981);color:var(--btnText);font-weight:900;}}
    .c{{padding:20px}}
    .badge{{display:inline-flex;gap:10px;align-items:center;padding:8px 12px;border-radius:999px;
          background:rgba(148,163,184,.12);border:1px solid rgba(148,163,184,.20);color:var(--muted);
          font-size:13px;margin-bottom:14px;}}
    h1{{margin:0 0 10px 0;font-size:22px}}
    p{{margin:10px 0;color:var(--muted);line-height:1.6;font-size:14px}}
    label{{display:block;margin-top:12px;color:var(--muted);font-size:13px}}
    input{{width:100%;margin-top:6px;padding:12px;border-radius:12px;border:1px solid rgba(148,163,184,.25);
          background:#0b1220;color:var(--text);font-size:14px;outline:none}}
    input:focus{{border-color:rgba(16,185,129,.6)}}
    button{{margin-top:14px;width:100%;padding:12px;border-radius:12px;border:0;background:var(--btn);
           color:var(--btnText);font-weight:900;font-size:14px;cursor:pointer}}
    button:disabled{{opacity:.45;cursor:not-allowed}}
    .small{{margin-top:12px;color:var(--muted2);font-size:12px}}
    .rules{{margin:14px 0 0 0;padding:0;list-style:none}}
    .rule{{display:flex;align-items:center;gap:10px;padding:8px 10px;border-radius:12px;
           border:1px solid rgba(148,163,184,.14);background:rgba(148,163,184,.06);margin-top:8px}}
    .dot{{width:10px;height:10px;border-radius:999px;background:rgba(239,68,68,.95)}}
    .rule.ok .dot{{background:rgba(34,197,94,.95)}}
    .rule span{{color:var(--muted);font-size:13px}}
    .hint{{margin-top:10px;color:var(--muted2);font-size:12px;line-height:1.55}}
    .error{{margin-top:12px;padding:10px 12px;border-radius:12px;border:1px solid rgba(239,68,68,.35);
            background:rgba(239,68,68,.12);color:#fecaca;font-size:13px;line-height:1.5}}
  </style>
</head>
<body>
  <div class="card">
    <div class="top">Botanical Garden • Password Reset</div>
    <div class="c">
      <div class="badge">{badge}</div>
      {html}
      <div class="small">If you did not request a password reset, you can safely ignore this page.</div>
    </div>
  </div>
</body>
</html>"""


def _expired_page() -> str:
    return _page(
        "Reset link expired",
        "⏳ Reset link expired",
        "<h1>Reset link expired</h1>"
        "<p>Please request a new password reset from the application.</p>",
    )


def _invalid_page() -> str:
    return _page(
        "Invalid reset link",
        "❌ Invalid link",
        "<h1>Invalid or already used link</h1>"
        "<p>Please request a new password reset from the application.</p>",
    )


def _success_page() -> str:
    return _page(
        "Password changed",
        "✅ Success",
        "<h1>Password successfully changed</h1>"
        "<p>You can now return to the app and log in with your new password.</p>",
    )


@reset_bp.route("/request-password-reset", methods=["POST"])
def request_password_reset():
    data = request.json or {}
    email = (data.get("email") or "").strip()

    if not email:
        return jsonify({"message": "Email is required."}), 400

    # ✅ Rate-limit: 1 request per 60s per (IP + email)
    ip = request.headers.get("X-Forwarded-For", request.remote_addr) or "unknown"
    key = f"pwreset:{ip}:{email.lower()}"
    limit = 1
    window = 60

    if not allow(key, limit=limit, window_seconds=window):
        ra = retry_after_seconds(key, window_seconds=window)
        return jsonify({"message": f"Too many requests. Please try again in {ra} seconds."}), 429

    user = User.query.filter_by(email=email).first()

    # Security: do not reveal whether the account exists
    if not user:
        return jsonify({"message": "If the account exists, a reset email has been sent."}), 200

    token = secrets.token_urlsafe(32)
    user.reset_token = token
    user.reset_sent_at = datetime.now(timezone.utc)
    db.session.commit()

    try:
        send_password_reset_email(email, token)
    except Exception:
        return jsonify({"message": "Failed to send reset email. Please try again later."}), 500

    return jsonify({"message": "If the account exists, a reset email has been sent."}), 200


@reset_bp.route("/reset-password", methods=["GET"])
def reset_password_form():
    token = request.args.get("token")
    if not token:
        return _invalid_page(), 400

    user = User.query.filter_by(reset_token=token).first()
    if not user or not user.reset_sent_at:
        return _invalid_page(), 400

    now = datetime.now(timezone.utc)
    sent_at = user.reset_sent_at
    if sent_at.tzinfo is None:
        sent_at = sent_at.replace(tzinfo=timezone.utc)

    if now - sent_at > timedelta(minutes=_ttl_minutes()):
        return _expired_page(), 400

    html = f"""
      <h1>Create a new password</h1>
      <p>Type your new password below. The button will unlock when all rules are met.</p>

      <form method="POST" action="/reset-password" id="resetForm">
        <input type="hidden" name="token" value="{token}" />

        <label>New password</label>
        <input id="password" name="password" type="password" autocomplete="new-password" required />
        <div id="inlineMsg" class="hint" style="margin-top:8px;"></div>

        <label>Confirm password</label>
        <input id="password2" name="password2" type="password" autocomplete="new-password" required />

        <div id="ready"
             style="display:none;margin-top:12px;padding:10px 12px;border-radius:12px;
                    border:1px solid rgba(34,197,94,.35);background:rgba(34,197,94,.12);
                    color:#bbf7d0;font-size:13px;font-weight:900;">
          ✅ Ready to submit
        </div>

        <ul class="rules" id="rules">
          <li class="rule" id="r_len"><div class="dot"></div><span>At least 8 characters</span></li>
          <li class="rule" id="r_upper"><div class="dot"></div><span>One uppercase letter (A–Z)</span></li>
          <li class="rule" id="r_lower"><div class="dot"></div><span>One lowercase letter (a–z)</span></li>
          <li class="rule" id="r_num"><div class="dot"></div><span>One number (0–9)</span></li>
          <li class="rule" id="r_special"><div class="dot"></div><span>One special character (e.g. !@#$)</span></li>
          <li class="rule" id="r_space"><div class="dot"></div><span>No spaces</span></li>
          <li class="rule" id="r_match"><div class="dot"></div><span>Passwords match</span></li>
        </ul>

        <button id="submitBtn" type="submit" disabled>Change password</button>
      </form>

      <script>
        const pw = document.getElementById("password");
        const pw2 = document.getElementById("password2");
        const btn = document.getElementById("submitBtn");
        const form = document.getElementById("resetForm");
        const inline = document.getElementById("inlineMsg");
        const ready = document.getElementById("ready");

        function setRule(id, ok) {{
          const el = document.getElementById(id);
          if (!el) return;
          if (ok) el.classList.add("ok");
          else el.classList.remove("ok");
        }}

        function hasUpper(v) {{ return /[A-Z]/.test(v); }}
        function hasLower(v) {{ return /[a-z]/.test(v); }}
        function hasNum(v) {{ return /[0-9]/.test(v); }}
        function hasSpecial(v) {{ return /[^A-Za-z0-9]/.test(v); }}
        function hasNoSpaces(v) {{ return !/\\s/.test(v); }}

        function update() {{
          const v = pw.value || "";
          const v2 = pw2.value || "";

          const okLen = v.length >= 8;
          const okUpper = hasUpper(v);
          const okLower = hasLower(v);
          const okNum = hasNum(v);
          const okSpecial = hasSpecial(v);
          const okSpace = hasNoSpaces(v);
          const okMatch = v.length > 0 && v === v2;

          setRule("r_len", okLen);
          setRule("r_upper", okUpper);
          setRule("r_lower", okLower);
          setRule("r_num", okNum);
          setRule("r_special", okSpecial);
          setRule("r_space", okSpace);
          setRule("r_match", okMatch);

          const missing = [];
          if (!okLen) missing.push("at least 8 characters");
          if (!okUpper) missing.push("uppercase letter");
          if (!okLower) missing.push("lowercase letter");
          if (!okNum) missing.push("number");
          if (!okSpecial) missing.push("special character");
          if (!okSpace) missing.push("no spaces");

          // ✅ FIX: never show "Missing: ." when confirm is empty
          if (v2.length === 0) missing.push("confirm password");
          else if (!okMatch) missing.push("passwords must match");

          const allOk = okLen && okUpper && okLower && okNum && okSpecial && okSpace && okMatch;

          btn.disabled = !allOk;
          ready.style.display = allOk ? "block" : "none";

          if (allOk) {{
            inline.textContent = "Looks good.";
            inline.style.color = "#bbf7d0";
          }} else {{
            if (v.length === 0) {{
              inline.textContent = "Start typing a password to see requirements.";
              inline.style.color = "";
            }} else {{
              inline.textContent = "Missing: " + missing.join(", ") + ".";
              inline.style.color = "#fecaca";
            }}
          }}
        }}

        pw.addEventListener("input", update);
        pw2.addEventListener("input", update);

        form.addEventListener("submit", function(e) {{
          if (btn.disabled) {{
            e.preventDefault();
            update();
          }}
        }});

        update();
      </script>
    """

    return _page("Set new password", "🔐 Set new password", html), 200


@reset_bp.route("/reset-password", methods=["POST"])
def reset_password_submit():
    token = (request.form.get("token") or "").strip()
    password = request.form.get("password") or ""
    password2 = request.form.get("password2") or ""

    if not token:
        return _invalid_page(), 400

    user = User.query.filter_by(reset_token=token).first()
    if not user or not user.reset_sent_at:
        return _invalid_page(), 400

    now = datetime.now(timezone.utc)
    sent_at = user.reset_sent_at
    if sent_at.tzinfo is None:
        sent_at = sent_at.replace(tzinfo=timezone.utc)

    if now - sent_at > timedelta(minutes=_ttl_minutes()):
        return _expired_page(), 400

    ok, msg = validate_password(password)
    if not ok:
        return (
            _page(
                "Weak password",
                "⚠️ Weak password",
                f"<h1>Password does not meet requirements</h1><p>{msg}</p>"
                "<div class='hint'>Please go back and adjust your password, then submit again.</div>",
            ),
            400,
        )

    if password != password2:
        return (
            _page(
                "Passwords do not match",
                "⚠️ Mismatch",
                "<h1>Passwords do not match</h1><p>Please go back and try again.</p>",
            ),
            400,
        )

    user.password_hash = generate_password_hash(password, method="pbkdf2:sha256")
    user.reset_token = None
    user.reset_sent_at = None
    db.session.commit()

    return _success_page(), 200
