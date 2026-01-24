from __future__ import annotations

from functools import wraps
from typing import Any, Callable, TypeVar, cast

from flask import request, jsonify

from models import User

T = TypeVar("T")


def _extract_bearer_token() -> str | None:
    """Read Authorization: Bearer <token>. Returns token or None."""
    auth = request.headers.get("Authorization", "")
    if not auth:
        return None

    parts = auth.split(" ", 1)
    if len(parts) != 2:
        return None

    scheme, token = parts[0].strip(), parts[1].strip()
    if scheme.lower() != "bearer" or not token:
        return None

    return token


def get_current_user() -> User | None:
    """Resolve a User from the bearer token.

    NOTE: Your current frontend stores either a real JWT (future) or a fallback
    token (username / DEV_TOKEN). For now we support:
      - DEV_TOKEN -> first user in DB (or None if empty)
      - <username> -> User with that username
    """
    token = _extract_bearer_token()
    if not token:
        return None

    if token == "DEV_TOKEN":
        return User.query.order_by(User.id.asc()).first()

    return User.query.filter_by(username=token).first()


def auth_required(fn: Callable[..., T]) -> Callable[..., Any]:
    """Small auth decorator based on Authorization: Bearer <token>.

    Returns 401 if user can't be resolved.
    """

    @wraps(fn)
    def wrapper(*args: Any, **kwargs: Any):
        user = get_current_user()
        if not user:
            return jsonify({"message": "Unauthorized"}), 401
        # pass user to endpoint
        return fn(user, *args, **kwargs)

    return cast(Callable[..., Any], wrapper)
