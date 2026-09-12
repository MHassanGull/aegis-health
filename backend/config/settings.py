"""Django settings for AI Medical Assist backend.

Development configuration: SQLite + permissive CORS so the Flutter app can
connect during testing. For production, switch to PostgreSQL, set DEBUG=False,
restrict ALLOWED_HOSTS/CORS, and load SECRET_KEY from the environment.
"""
from pathlib import Path
from datetime import timedelta
import os

BASE_DIR = Path(__file__).resolve().parent.parent


def _load_env(path: Path):
    """Tiny .env reader (KEY=VALUE per line) so no extra dependency is needed."""
    if not path.exists():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, val = line.split("=", 1)
        os.environ.setdefault(key.strip(), val.strip().strip('"').strip("'"))


_load_env(BASE_DIR / ".env")

SECRET_KEY = os.environ.get(
    "DJANGO_SECRET_KEY", "dev-insecure-key-change-me-in-production"
)
DEBUG = os.environ.get("DJANGO_DEBUG", "1") == "1"

# Hosts: wide open only in DEBUG; locked to an explicit list in production.
if DEBUG:
    ALLOWED_HOSTS = ["*"]
else:
    ALLOWED_HOSTS = [h.strip() for h in
                     os.environ.get("DJANGO_ALLOWED_HOSTS", "").split(",") if h.strip()]
    # Render injects the service's public hostname; add it so a forgotten
    # DJANGO_ALLOWED_HOSTS can never take the whole API down with a 400.
    _render_host = os.environ.get("RENDER_EXTERNAL_HOSTNAME", "").strip()
    if _render_host and _render_host not in ALLOWED_HOSTS:
        ALLOWED_HOSTS.append(_render_host)
    if not ALLOWED_HOSTS:
        ALLOWED_HOSTS = ["*"]

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    # third-party
    "rest_framework",
    "corsheaders",
    # local
    "accounts",
    "predictions",
    "profiles",
    "chat",
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.security.SecurityMiddleware",
    # WhiteNoise serves static files (Django admin CSS) straight from gunicorn,
    # so no separate web server or CDN is needed in production.
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"
TEMPLATES = [{
    "BACKEND": "django.template.backends.django.DjangoTemplates",
    "DIRS": [],
    "APP_DIRS": True,
    "OPTIONS": {"context_processors": [
        "django.template.context_processors.request",
        "django.contrib.auth.context_processors.auth",
        "django.contrib.messages.context_processors.messages",
    ]},
}]
WSGI_APPLICATION = "config.wsgi.application"

# Database — SQLite by default (bulletproof for local demos). Set DATABASE_URL
# in backend/.env to switch to a hosted PostgreSQL (e.g. Supabase) with zero
# code changes — Twelve-Factor style. Example Supabase URL:
#   DATABASE_URL=postgresql://postgres.<ref>:<password>@<host>.pooler.supabase.com:6543/postgres
# (needs:  pip install psycopg2-binary)
_DB_URL = os.environ.get("DATABASE_URL", "").strip()
if _DB_URL:
    from urllib.parse import urlparse, unquote
    u = urlparse(_DB_URL)
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "NAME": (u.path or "/postgres").lstrip("/"),
            "USER": unquote(u.username or ""),
            "PASSWORD": unquote(u.password or ""),
            "HOST": u.hostname or "",
            "PORT": str(u.port or 5432),
            "CONN_MAX_AGE": 600,
            # Ping a reused connection before each request and reconnect if the
            # Supabase pooler dropped it — prevents intermittent 500s on the
            # first request after an idle gap.
            "CONN_HEALTH_CHECKS": True,
            "OPTIONS": {"sslmode": "require"},   # Supabase requires SSL
        }
    }
else:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / "db.sqlite3",
        }
    }

# Password hashing cost.
#
# Django 6 defaults PBKDF2 to 1,200,000 iterations. That is excellent on real
# hardware, but this service runs on a 0.1-CPU instance where it costs several
# seconds of every sign-in, which users read as "the app is broken".
#
# 600,000 is the figure OWASP recommends for PBKDF2-HMAC-SHA256, so this stays
# within current guidance while halving the wait. Existing hashes keep working:
# Django re-hashes each password transparently on the owner's next sign-in.
PASSWORD_HASHERS = [
    "accounts.hashers.TunedPBKDF2Hasher",
    "django.contrib.auth.hashers.PBKDF2PasswordHasher",
    "django.contrib.auth.hashers.PBKDF2SHA1PasswordHasher",
    "django.contrib.auth.hashers.Argon2PasswordHasher",
    "django.contrib.auth.hashers.BCryptSHA256PasswordHasher",
    "django.contrib.auth.hashers.ScryptPasswordHasher",
]

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True
STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "staticfiles"          # collectstatic target (WhiteNoise)
STORAGES = {
    "default": {"BACKEND": "django.core.files.storage.FileSystemStorage"},
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage"
    },
}
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.IsAuthenticated",
    ),
    # Rate-limit to blunt brute-force / abuse (login & register are anon).
    "DEFAULT_THROTTLE_CLASSES": (
        "rest_framework.throttling.AnonRateThrottle",
        "rest_framework.throttling.UserRateThrottle",
    ),
    "DEFAULT_THROTTLE_RATES": {
        "anon": "30/min", "user": "300/min",
        "login": "8/min", "register": "5/min",   # tight brute-force guards
    },
}

SIMPLE_JWT = {
    # Longer-lived so a demo session doesn't silently expire mid-use.
    "ACCESS_TOKEN_LIFETIME": timedelta(days=7),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=30),
}

# CORS: open only in DEBUG; explicit allow-list in production.
if DEBUG:
    CORS_ALLOW_ALL_ORIGINS = True
else:
    CORS_ALLOWED_ORIGINS = [o.strip() for o in
        os.environ.get("CORS_ALLOWED_ORIGINS", "").split(",") if o.strip()]

# Production hardening (auto-enabled when DJANGO_DEBUG=0).
if not DEBUG:
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    SECURE_HSTS_SECONDS = 60 * 60 * 24 * 30
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

# --------------------------------------------------------------------------- AI chat
# Swap the chat brain by changing LLM_PROVIDER (gemini | claude | ollama).
LLM_PROVIDER = os.environ.get("LLM_PROVIDER", "gemini")
# Gemini (used now) — get a free key at https://aistudio.google.com (no billing).
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")
GEMINI_MODEL = os.environ.get("GEMINI_MODEL", "gemini-2.0-flash")
# Claude (active) — Anthropic Messages API powers the AI Assistant.
ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
CLAUDE_MODEL = os.environ.get("CLAUDE_MODEL", "claude-haiku-4-5")
# Ollama (future) — local 7B model on the laptop.
OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
OLLAMA_MODEL = os.environ.get("OLLAMA_MODEL", "llama3")
