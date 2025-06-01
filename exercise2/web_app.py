"""
Simple Flask web server that outputs the port it is running on.

The port can be specified using the PORT environment variable.
If not specified, it defaults to 5000.
"""

import os
from flask import Flask

app = Flask(__name__)

# Default port if not specified by environment variable
DEFAULT_PORT = 5000
PORT = int(os.environ.get("PORT", DEFAULT_PORT))


@app.route('/')
def index():
    """
    Root route that returns the current running port as a string.

    Returns:
        str: Message stating the server's running port.
    """
    return f"Server started in port {PORT}"


if __name__ == '__main__':
    print(f"Server started in port {PORT}")
    app.run(host='0.0.0.0', port=PORT)
