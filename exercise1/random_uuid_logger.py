"""A script that generates a UUID once at startup and logs it with a timestamp every 5 seconds."""

import uuid
import time
from datetime import datetime, timezone

# Generate and store the UUID once at startup
RANDOM_STRING = str(uuid.uuid4())

def log_string():
    """Logs the stored UUID along with the current UTC timestamp in ISO 8601 format."""
    timestamp = datetime.now(timezone.utc).isoformat()
    print(f"{timestamp}: {RANDOM_STRING}")

# Initial log
log_string()

# Log every 5 seconds
while True:
    time.sleep(5)
    log_string()
