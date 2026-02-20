from flask import Flask
import os

app = Flask(__name__)

@app.get("/")
def hello():
    return {"message": "Hello from Cloud Run!", "env": os.getenv("ENV", "unknown")}

if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    app.run(host="0.0.0.0", port=port)
