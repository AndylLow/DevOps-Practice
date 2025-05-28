import uuid
import time
from datetime import datetime, timezone

# Generate and store the UUID once at startup
random_string = str(uuid.uuid4())

def log_string():
    # Get the current time in ISO 8601 format with UTC 'Z' suffix
    timestamp = datetime.now(timezone.utc).isoformat()
    print(f"{timestamp}: {random_string}")

# Initial log
log_string()

# Log every 5 seconds
while True:
    time.sleep(5)
    log_string()
