import os
from functools import lru_cache


class Config:
    POSTGRES_DB = os.environ.get("POSTGRES_DB", "lovecraft_db")
    POSTGRES_USER = os.environ.get("POSTGRES_USER", "postgres")
    POSTGRES_PASSWORD = os.environ.get("POSTGRES_PASSWORD", "postgres")
    POSTGRES_HOST = os.environ.get("POSTGRES_HOST", "localhost")
    POSTGRES_PORT = os.environ.get("POSTGRES_PORT", 5432)


@lru_cache
def get_config() -> Config:
    return Config()
