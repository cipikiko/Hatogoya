import os
import smtplib
from email.message import EmailMessage


def _smtp_send(msg: EmailMessage) -> None:
    smtp_host = os.getenv("SMTP_HOST")
    smtp_port = int(os.getenv("SMTP_PORT", "465"))
    smtp_user = os.getenv("SMTP_USER")
    smtp_pass = os.getenv("SMTP_PASS")

    if not smtp_host or not smtp_user or not smtp_pass:
        raise RuntimeError("SMTP not configured (missing SMTP_HOST/SMTP_USER/SMTP_PASS).")

    with smtplib.SMTP_SSL(smtp_host, smtp_port) as server:
        server.login(smtp_user, smtp_pass)
        server.send_message(msg)


def send_password_reset_email(to_email: str, token: str) -> None:
    base_url = os.getenv("PUBLIC_BASE_URL", "http://localhost:5000").rstrip("/")
    reset_link = f"{base_url}/reset-password?token={token}"

    app_name = os.getenv("APP_NAME", "Botanical Garden")
    from_email = os.getenv("SMTP_FROM", os.getenv("SMTP_USER", "no-reply@example.com"))

    subject = f"Password reset – {app_name}"
    preheader = "Click the button to set a new password."

    text_body = (
        f"Hello,\n\n"
        f"You requested a password reset for {app_name}.\n"
        f"This link is time-limited:\n{reset_link}\n\n"
        f"If you did not request this, you can ignore this email.\n"
    )

    html_body = f"""\
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"></head>
<body style="margin:0;padding:0;background:#f3f4f6;">
  <div style="display:none;max-height:0;overflow:hidden;opacity:0;color:transparent;">{preheader}</div>

  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f3f4f6;padding:24px 0;">
    <tr><td align="center" style="padding:0 14px;">
      <table role="presentation" width="600" cellpadding="0" cellspacing="0"
        style="max-width:600px;width:100%;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #e5e7eb;">
        <tr>
          <td style="padding:18px 22px;background:linear-gradient(90deg,#0ea5e9,#10b981);color:#fff;">
            <div style="font-family:Arial,sans-serif;font-size:16px;font-weight:700;">{app_name}</div>
            <div style="font-family:Arial,sans-serif;font-size:12px;opacity:.95;margin-top:4px;">Password reset</div>
          </td>
        </tr>

        <tr><td style="padding:22px;">
          <div style="font-family:Arial,sans-serif;font-size:18px;font-weight:700;color:#111827;">
            Set a new password
          </div>
          <div style="font-family:Arial,sans-serif;font-size:14px;color:#374151;line-height:1.6;margin-top:10px;">
            If you requested a password reset, click the button below.
          </div>

          <div style="margin-top:18px;">
            <a href="{reset_link}"
              style="display:inline-block;background:#10b981;color:#ffffff;text-decoration:none;
                     font-family:Arial,sans-serif;font-size:14px;font-weight:700;
                     padding:12px 18px;border-radius:10px;">
              Reset password
            </a>
          </div>

          <div style="font-family:Arial,sans-serif;font-size:13px;color:#6b7280;line-height:1.6;margin-top:16px;">
            If the button does not work, copy this link into your browser:
          </div>
          <div style="margin-top:8px;padding:12px;border-radius:10px;background:#f9fafb;border:1px solid #e5e7eb;">
            <div style="font-family:monospace;font-size:12px;color:#111827;word-break:break-all;">
              {reset_link}
            </div>
          </div>

          <div style="font-family:Arial,sans-serif;font-size:12px;color:#6b7280;line-height:1.6;margin-top:16px;">
            If you did not request this, you can safely ignore this email.
          </div>
        </td></tr>

        <tr><td style="padding:14px 22px;background:#f9fafb;border-top:1px solid #e5e7eb;">
          <div style="font-family:Arial,sans-serif;font-size:12px;color:#6b7280;">
            This email was sent automatically. Please do not reply.
          </div>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>
"""

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = from_email
    msg["To"] = to_email
    msg.set_content(text_body)
    msg.add_alternative(html_body, subtype="html")

    _smtp_send(msg)


def send_verification_email(to_email: str, token: str) -> None:
    base_url = os.getenv("PUBLIC_BASE_URL", "http://localhost:5000").rstrip("/")
    verify_link = f"{base_url}/verify-email?token={token}"

    app_name = os.getenv("APP_NAME", "Botanical Garden")
    from_email = os.getenv("SMTP_FROM", os.getenv("SMTP_USER", "no-reply@example.com"))

    subject = f"Verify your email – {app_name}"
    preheader = "Click the button to complete your registration."

    text_body = (
        f"Hello,\n\n"
        f"To complete your registration in {app_name}, please verify your email:\n"
        f"{verify_link}\n\n"
        f"If you did not create an account, you can ignore this email.\n"
    )

    html_body = f"""\
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{subject}</title>
</head>
<body style="margin:0;padding:0;background:#f3f4f6;">
  <div style="display:none;max-height:0;overflow:hidden;opacity:0;color:transparent;">
    {preheader}
  </div>

  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f3f4f6;padding:24px 0;">
    <tr>
      <td align="center" style="padding:0 14px;">
        <table role="presentation" width="600" cellpadding="0" cellspacing="0"
               style="max-width:600px;width:100%;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #e5e7eb;">
          <tr>
            <td style="padding:18px 22px;background:linear-gradient(90deg,#0ea5e9,#10b981);color:#fff;">
              <div style="font-family:Arial,sans-serif;font-size:16px;font-weight:700;">
                {app_name}
              </div>
              <div style="font-family:Arial,sans-serif;font-size:12px;opacity:.95;margin-top:4px;">
                Email verification
              </div>
            </td>
          </tr>

          <tr>
            <td style="padding:22px;">
              <div style="font-family:Arial,sans-serif;font-size:18px;font-weight:700;color:#111827;">
                Verify your email
              </div>

              <div style="font-family:Arial,sans-serif;font-size:14px;color:#374151;line-height:1.6;margin-top:10px;">
                Hello,<br>
                click the button below to complete your registration.
              </div>

              <div style="margin-top:18px;">
                <a href="{verify_link}"
                   style="display:inline-block;background:#10b981;color:#ffffff;text-decoration:none;
                          font-family:Arial,sans-serif;font-size:14px;font-weight:700;
                          padding:12px 18px;border-radius:10px;">
                  Verify email
                </a>
              </div>

              <div style="font-family:Arial,sans-serif;font-size:13px;color:#6b7280;line-height:1.6;margin-top:16px;">
                If the button does not work, copy this link into your browser:
              </div>
              <div style="margin-top:8px;padding:12px;border-radius:10px;background:#f9fafb;border:1px solid #e5e7eb;">
                <div style="font-family:monospace;font-size:12px;color:#111827;word-break:break-all;">
                  {verify_link}
                </div>
              </div>

              <div style="font-family:Arial,sans-serif;font-size:12px;color:#6b7280;line-height:1.6;margin-top:16px;">
                If you did not create an account, you can safely ignore this email.
              </div>
            </td>
          </tr>

          <tr>
            <td style="padding:14px 22px;background:#f9fafb;border-top:1px solid #e5e7eb;">
              <div style="font-family:Arial,sans-serif;font-size:12px;color:#6b7280;">
                This email was sent automatically. Please do not reply.
              </div>
            </td>
          </tr>

        </table>

        <div style="font-family:Arial,sans-serif;font-size:11px;color:#9ca3af;margin-top:12px;">
          © {app_name}
        </div>
      </td>
    </tr>
  </table>
</body>
</html>
"""

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = from_email
    msg["To"] = to_email
    msg.set_content(text_body)
    msg.add_alternative(html_body, subtype="html")

    _smtp_send(msg)
