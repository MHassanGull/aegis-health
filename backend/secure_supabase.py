"""Lock down the Supabase public API.

Supabase auto-exposes every table in the `public` schema through its PostgREST
API (usable with the anon/publishable key). This app talks to Postgres directly
via Django (as the `postgres` role, which bypasses RLS), so we can safely:

  1. ENABLE Row-Level Security on every public table  -> with no policies, the
     anon/authenticated API roles get ZERO access (deny by default).
  2. REVOKE table privileges from anon/authenticated  -> defense in depth.

Django (postgres role) is unaffected and keeps full read/write.

Run:  python secure_supabase.py
"""
import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")


def main():
    django.setup()
    from django.db import connection

    if "postgresql" not in connection.settings_dict["ENGINE"]:
        print("Not on PostgreSQL/Supabase (using SQLite) — nothing to do.")
        return

    with connection.cursor() as cur:
        cur.execute(
            "select tablename from pg_tables where schemaname = 'public';")
        tables = [r[0] for r in cur.fetchall()]

        for t in tables:
            cur.execute(f'ALTER TABLE public."{t}" ENABLE ROW LEVEL SECURITY;')

        # Defense in depth: strip the auto-API roles of all table access.
        cur.execute(
            "REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated;")
        cur.execute(
            "REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon, authenticated;")

    print(f"RLS enabled + API access revoked on {len(tables)} public tables:")
    for t in tables:
        print("   -", t)

    # Prove Django still works (postgres role bypasses RLS).
    from django.contrib.auth.models import User
    print(f"\nDjango can still read the DB — users: {User.objects.count()}")
    print("Done. The public REST API is now locked; Django is unaffected.")


if __name__ == "__main__":
    main()
