"""Password hashing tuned for the deployment this service actually runs on."""
from django.contrib.auth.hashers import PBKDF2PasswordHasher


class TunedPBKDF2Hasher(PBKDF2PasswordHasher):
    """PBKDF2-SHA256 at the iteration count OWASP recommends.

    Django's own default is higher, which is the right call on capable
    hardware. On the small shared CPU this service is deployed to, that default
    adds several seconds to every sign-in, and a login that appears to hang is
    a real usability failure rather than a theoretical one.

    600,000 is OWASP's current recommendation for PBKDF2-HMAC-SHA256, so this
    is a deliberate, documented operating point rather than a shortcut. Django
    upgrades any password stored at a different cost automatically the next
    time its owner signs in.
    """

    iterations = 600_000
