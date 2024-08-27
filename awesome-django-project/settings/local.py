from .base import *

DEBUG = True

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.mysql",
        # docker-compose.ymlでの設定と一致させる
        "NAME": "database",
        "USER": "django",
        "PASSWORD": "django",
        "HOST": "db",
        "PORT": "3306",
    }
}
