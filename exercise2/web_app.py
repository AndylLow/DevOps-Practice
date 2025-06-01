# app.py
import os
from flask import Flask

app = Flask(__name__)

PORT = int(os.environ.get("PORT", 5000))  # default to 5000

@app.route('/')
def index():
    return f"Server started in port {PORT}"

if __name__ == '__main__':
    print(f"Server started in port {PORT}")
    app.run(host='0.0.0.0', port=PORT)
