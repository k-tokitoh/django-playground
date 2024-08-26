import os

from .base import *

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.mysql",
        # docker-compose.ymlでの設定と一致させる
        "HOST": os.getenv("DATABASE_HOST"),
        "PORT": os.getenv("DATABASE_PORT"),
        "NAME": os.getenv("DATABASE_NAME"),
        "USER": os.getenv("DATABASE_USERNAME"),
        "PASSWORD": os.getenv("DATABASE_PASSWORD"),
    }
}
