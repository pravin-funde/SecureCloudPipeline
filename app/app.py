from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from SecureCloudPipeline (Flask)"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000) #0.0.0.0 allows Docker to expose the app to the outside on port 5000
