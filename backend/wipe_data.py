"""Wipe user-generated data from the database.

Deletes every assessment, chat message and profile, plus all non-superuser
accounts. The superuser is kept so Django admin access is not lost.

DESTRUCTIVE AND IRREVERSIBLE. It prints what it is about to remove and waits
for you to type YES before touching anything.

Run from the backend/ folder:
    python wipe_data.py

By default it targets whatever DATABASE_URL points at in backend/.env — that
is the LIVE Supabase database. To wipe only the local SQLite file instead:
    DATABASE_URL= python wipe_data.py          (bash)
    $env:DATABASE_URL=""; python wipe_data.py  (PowerShell)
"""
import os
import sys

import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from django.contrib.auth.models import User          # noqa: E402
from django.db import connection                     # noqa: E402
from predictions.models import Assessment            # noqa: E402
from chat.models import ChatMessage                  # noqa: E402
from profiles.models import UserProfile              # noqa: E402


def counts():
    return {
        "users (non-admin)": User.objects.filter(is_superuser=False).count(),
        "assessments": Assessment.objects.count(),
        "chat messages": ChatMessage.objects.count(),
        "profiles": UserProfile.objects.count(),
    }


def main():
    host = connection.settings_dict.get("HOST") or "local sqlite"
    print("=" * 60)
    print(f" TARGET DATABASE: {host}")
    print("=" * 60)

    before = counts()
    for k, v in before.items():
        print(f"  {k:<20} {v}")

    if not any(before.values()):
        print("\nNothing to delete. Database is already clean.")
        return

    kept = list(
        User.objects.filter(is_superuser=True).values_list("username", flat=True)
    )
    print(f"\n  Superuser account(s) KEPT: {kept or 'none'}")
    print("\nThis cannot be undone.")

    if input('Type YES to delete: ').strip() != "YES":
        print("Aborted. Nothing was deleted.")
        sys.exit(0)

    # Order matters only for readability; cascades handle the rest.
    print("\n  assessments  ->", Assessment.objects.all().delete()[0], "removed")
    print("  chat msgs    ->", ChatMessage.objects.all().delete()[0], "removed")
    print("  profiles     ->", UserProfile.objects.all().delete()[0], "removed")
    print("  users        ->",
          User.objects.filter(is_superuser=False).delete()[0], "removed")

    print("\nAFTER")
    for k, v in counts().items():
        print(f"  {k:<20} {v}")
    print("\nDone. Register a fresh account in the app.")


if __name__ == "__main__":
    main()
