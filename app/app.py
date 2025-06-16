from flask import Flask
import os
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from SecureCloudPipeline (Flask)"

if __name__ == "__main__":
    host = os.getenv("FLASK_RUN_HOST","127.0.0.1")
    port = int(os.getenv("FLASK_RUN_PORT",5000))
    app.run(host=host, port=port) #0.0.0.0 allows Docker to expose the app to the outside on port 5000

# Trigger workflow test
