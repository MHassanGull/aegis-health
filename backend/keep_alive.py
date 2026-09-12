"""Keep the Supabase project awake.

Runs one tiny query against the database so Supabase counts it as activity and
does NOT auto-pause the free-tier project after 7 idle days.

Run it on a schedule (Windows Task Scheduler or GitHub Actions) — see the
comment at the bottom. Safe to run manually any time:  python keep_alive.py
"""
import os
import sys
import datetime
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")


def main():
    django.setup()
    from django.db import connection
    try:
        with connection.cursor() as cur:
            cur.execute("SELECT 1;")
            cur.fetchone()
        host = connection.settings_dict.get("HOST", "?")
        print(f"[{datetime.datetime.now():%Y-%m-%d %H:%M}] keep-alive OK -> {host}")
    except Exception as exc:  # noqa: BLE001
        print(f"keep-alive FAILED: {type(exc).__name__}: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()

# ── How to schedule (pick one) ───────────────────────────────────────────────
# Windows Task Scheduler (runs when the laptop is on):
#   schtasks /create /tn "AegisSupabaseKeepAlive" /sc DAILY /mo 2 /st 12:00 /f ^
#     /tr "cmd /c cd /d d:\fyp\Rohan_Hassan\backend && python keep_alive.py"
#
# GitHub Actions (runs in the cloud even when the laptop is off) — best:
#   put this repo on GitHub, add DATABASE_URL as a repo secret, and add
#   .github/workflows/keepalive.yml (see the one generated alongside this file).
