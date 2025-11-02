from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Service configuration loaded from environment variables"""
    
    service_name: str = "template-service"
    service_port: int = 7000
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
