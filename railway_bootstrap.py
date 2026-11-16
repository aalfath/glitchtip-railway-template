# Runs inside `manage.py shell`: creates the first GlitchTip superuser from
# GLITCHTIP_ADMIN_EMAIL / GLITCHTIP_ADMIN_PASSWORD if that user doesn't exist.
import os

from django.contrib.auth import get_user_model

User = get_user_model()
email = os.environ.get("GLITCHTIP_ADMIN_EMAIL", "").strip().lower()
password = os.environ.get("GLITCHTIP_ADMIN_PASSWORD", "")

if User.objects.filter(email__iexact=email).exists():
    print(f"[railway] admin {email} already exists, left unchanged")
elif len(password) < 12:
    raise SystemExit("[railway] GLITCHTIP_ADMIN_PASSWORD must be at least 12 characters")
else:
    User.objects.create_superuser(email=email, password=password)
    print(f"[railway] created admin {email}")
