from fastapi import FastAPI
from config import settings
import tomllib
from pathlib import Path

app = FastAPI(title=settings.service_name)

# Get version from pyproject.toml
def get_version() -> str:
    try:
        pyproject_path = Path(__file__).parent / "pyproject.toml"
        with open(pyproject_path, "rb") as f:
            pyproject_data = tomllib.load(f)
        return pyproject_data.get("project", {}).get("version", "unknown")
    except Exception:
        return "unknown"

__version__ = get_version()


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
