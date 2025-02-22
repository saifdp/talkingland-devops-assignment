# app/app.py
from flask import Flask
import time
import os

app = Flask(__name__)

@app.route('/')
def hello():
    # Simulate some CPU load (adjust the sleep time as needed)
    time.sleep(0.01)
    hostname = os.getenv('HOSTNAME', 'Unknown Host')
    return f'Hello from {hostname}!\n'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)