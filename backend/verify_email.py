import os
from datetime import datetime, timezone, timedelta
from flask import Blueprint, request

from models import db, User

verify_bp = Blueprint("verify", __name__)

def _token_ttl_minutes() -> int:
    try:
        return int(os.getenv("VERIFICATION_TOKEN_TTL_MINUTES", "30"))
    except ValueError:
        return 30

def _page(title: str, emoji: str, headline: str, message_html: str, actions_html: str = "") -> str:
    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>{title}</title>
  <style>
    :root {{
      --bg: #0b1220;
      --card: #111827;
      --border: #1f2937;
      --text: #e5e7eb;
      --muted: #cbd5e1;
      --muted2: #94a3b8;
      --brand1: #0ea5e9;
      --brand2: #10b981;
      --btn: #10b981;
      --btn2: #334155;
      --danger: #ef4444;
      --warn: #f59e0b;
    }}
    * {{ box-sizing: border-box; }}
    body {{
      margin: 0;
      font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
      background: radial-gradient(1200px 600px at 50% -100px, rgba(14,165,233,.20), transparent 60%),
                  radial-gradient(900px 500px at 20% 0px, rgba(16,185,129,.18), transparent 55%),
                  var(--bg);
      color: var(--text);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 28px 16px;
    }}
    .card {{
      width: 100%;
      max-width: 560px;
      background: linear-gradient(180deg, rgba(255,255,255,.03), transparent 22%), var(--card);
      border: 1px solid var(--border);
      border-radius: 18px;
      overflow: hidden;
      box-shadow: 0 20px 60px rgba(0,0,0,.45);
    }}
    .topbar {{
      padding: 14px 18px;
      background: linear-gradient(90deg, rgba(14,165,233,.95), rgba(16,185,129,.95));
      color: #062014;
      font-weight: 800;
      letter-spacing: .2px;
    }}
    .content {{
      padding: 20px 20px 16px 20px;
    }}
    .badge {{
      display: inline-flex;
      align-items: center;
      gap: 10px;
      padding: 8px 12px;
      border-radius: 999px;
      background: rgba(148,163,184,.12);
      border: 1px solid rgba(148,163,184,.20);
      color: var(--muted);
      font-size: 13px;
      margin-bottom: 14px;
    }}
    .emoji {{
      font-size: 18px;
    }}
    h1 {{
      margin: 0 0 10px 0;
      font-size: 22px;
      line-height: 1.25;
    }}
    p {{
      margin: 10px 0;
      color: var(--muted);
      line-height: 1.6;
      font-size: 14px;
    }}
    code {{
      color: #93c5fd;
      background: rgba(147,197,253,.10);
      border: 1px solid rgba(147,197,253,.18);
      padding: 2px 6px;
      border-radius: 8px;
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
      font-size: 12px;
      word-break: break-all;
    }}
    .actions {{
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      margin-top: 14px;
    }}
    .btn {{
      display: inline-block;
      padding: 11px 14px;
      border-radius: 12px;
      text-decoration: none;
      font-weight: 800;
      font-size: 14px;
      background: var(--btn);
      color: #062014;
      border: 1px solid rgba(16,185,129,.35);
    }}
    .btn.secondary {{
      background: transparent;
      color: var(--text);
      border: 1px solid rgba(148,163,184,.25);
    }}
    .btn.warn {{
      background: rgba(245,158,11,.18);
      color: #fff7ed;
      border: 1px solid rgba(245,158,11,.35);
    }}
    .footer {{
      padding: 12px 20px 18px 20px;
      border-top: 1px solid rgba(148,163,184,.12);
      color: var(--muted2);
      font-size: 12px;
    }}
  </style>
</head>
<body>
  <div class="card">
    <div class="topbar">Botanical Garden • Account Verification</div>
    <div class="content">
      <div class="badge"><span class="emoji">{emoji}</span><span>{headline}</span></div>
      {message_html}
      {actions_html}
    </div>
    <div class="footer">
      If nothing happens, go back to the app and try again or resend the verification email.
    </div>
  </div>
</body>
</html>"""

def _success_page() -> str:
    return _page(
        title="Email verified",
        emoji="✅",
        headline="Email successfully verified",
        message_html="""
          <h1>All set.</h1>
          <p>You can now return to the app and log in.</p>
        """,
    )

def _expired_page(email: str) -> str:
    return _page(
        title="Verification link expired",
        emoji="⏳",
        headline="Verification link expired",
        message_html=f"""
          <h1>This link has expired.</h1>
          <p>For account <code>{email}</code>, you can request a new verification email.</p>
        """,
        actions_html=f"""
          <div class="actions">
            <a class="btn warn" href="/resend-verification-web?email={email}">Resend verification email</a>
          </div>
        """,
    )

def _invalid_page() -> str:
    return _page(
        title="Invalid link",
        emoji="❌",
        headline="Invalid or already used link",
        message_html="""
          <h1>This link is no longer valid.</h1>
          <p>It may have already been used or replaced by a newer one.</p>
          <p>Please open the most recent email or resend verification from the app.</p>
        """,
    )

def _sent_page() -> str:
    return _page(
        title="Email sent",
        emoji="📨",
        headline="A new email has been sent",
        message_html="""
          <h1>Check your inbox/spam.</h1>
          <p>Open the most recent email and click the verification link.</p>
        """,
    )

def _already_verified_page() -> str:
    return _page(
        title="Already verified",
        emoji="✅",
        headline="Account already verified",
        message_html="""
          <h1>You’re good.</h1>
          <p>This email is already verified. You can log in.</p>
        """,
    )

def _send_failed_page() -> str:
    return _page(
        title="Email sending failed",
        emoji="⚠️",
        headline="Could not send email",
        message_html="""
          <h1>Please try again later.</h1>
          <p>If the issue persists, use resend from within the app.</p>
        """,
    )

@verify_bp.route("/verify-email", methods=["GET"])
def verify_email():
    token = request.args.get("token")
    if not token:
        return _invalid_page(), 400

    user = User.query.filter_by(verification_token=token).first()
    if not user or not user.verification_sent_at:
        return _invalid_page(), 400

    ttl = timedelta(minutes=_token_ttl_minutes())
    now = datetime.now(timezone.utc)

    sent_at = user.verification_sent_at
    if sent_at.tzinfo is None:
        sent_at = sent_at.replace(tzinfo=timezone.utc)

    if now - sent_at > ttl:
        return _expired_page(user.email), 400

    user.email_verified = True
    user.verification_token = None
    user.verification_sent_at = None
    db.session.commit()

    return _success_page(), 200


# Web resend endpoint (no deep-links)
@verify_bp.route("/resend-verification-web", methods=["GET"])
def resend_verification_web():
    from datetime import datetime, timezone
    import secrets
    from email_utils import send_verification_email

    email = request.args.get("email", "").strip()
    if not email:
        return _invalid_page(), 400

    user = User.query.filter_by(email=email).first()

    # Security: same response even if account doesn't exist
    if not user:
        return _sent_page(), 200

    if user.email_verified:
        return _already_verified_page(), 200

    token = secrets.token_urlsafe(32)
    user.verification_token = token
    user.verification_sent_at = datetime.now(timezone.utc)
    db.session.commit()

    try:
        send_verification_email(user.email, token)
    except Exception:
        return _send_failed_page(), 500

    return _sent_page(), 200
