from fastapi import FastAPI

app = FastAPI(title="Semantic Video Indexing API")

@app.get("/")
def health_check():
    return {
        "status": "ok",
        "message": "Semantic Video Indexing API is running"
    }