import re

def validate_password(pw: str):
    """
    Returns: (ok: bool, message: str)

    Password policy:
      - min 8 characters
      - at least 1 lowercase letter
      - at least 1 uppercase letter
      - at least 1 digit
      - at least 1 special character
      - no spaces
    """

    if not isinstance(pw, str):
        return False, "Invalid password."

    if len(pw) < 8:
        return False, "Password must be at least 8 characters long."
    if " " in pw:
        return False, "Password must not contain spaces."
    if not re.search(r"[a-z]", pw):
        return False, "Password must contain at least one lowercase letter."
    if not re.search(r"[A-Z]", pw):
        return False, "Password must contain at least one uppercase letter."
    if not re.search(r"\d", pw):
        return False, "Password must contain at least one number."
    if not re.search(r"[^\w\s]", pw):
        return False, "Password must contain at least one special character (e.g. !@#?)."

    return True, "OK"
