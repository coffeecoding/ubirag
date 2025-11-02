from fastapi import FastAPI
from config import settings
import importlib.metadata

app = FastAPI(title=settings.service_name)

# Get version from package metadata
try:
    __version__ = importlib.metadata.version("template-service")
except importlib.metadata.PackageNotFoundError:
    __version__ = "0.1.0"  # Fallback version


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "ok",
        "service": settings.service_name,
        "version": __version__
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=settings.service_port,
        reload=True
    )
