import os
from datetime import datetime, timezone, timedelta
from models import db, User

def cleanup_unverified_users() -> int:
    """
    Zmaže neoverených userov starších než UNVERIFIED_DELETE_HOURS.
    Vracia počet zmazaných záznamov.
    """
    try:
        hours = int(os.getenv("UNVERIFIED_DELETE_HOURS", "24"))
    except ValueError:
        hours = 24

    cutoff = datetime.now(timezone.utc) - timedelta(hours=hours)

    # created_at môže byť naive, ale v tvojom modeli je timezone-aware default,
    # takže to bude väčšinou OK.
    q = User.query.filter(User.email_verified == False, User.created_at < cutoff)

    count = q.count()
    if count > 0:
        q.delete(synchronize_session=False)
        db.session.commit()

    return count
