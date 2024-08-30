import os

from .base import *

DEBUG = False

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

STORAGES = {
    "staticfiles": {
        # django.contrib.staticfiles の collectstatic コマンドは、staticファイルを1ヶ所にまとめたうえで、開発用サーバ以外の場合にはディスクに配置する
        # そのディスクへの配置の際にstorage APIを利用するが、どのstorage実装を利用するかを以下で指定する
        # S3ManifestStaticStorageは、S3にアップロードしつつhash値を付加してくれる
        "BACKEND": "storages.backends.s3.S3ManifestStaticStorage",
        "OPTIONS": {
            "bucket_name": "djangoplayground-dev-static-rbctek",
            "file_overwrite": False,
            "location": "static/production",
            "custom_domain": os.getenv("DOMAIN"),
        },
    }
}

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
        },
    },
    "root": {
        "handlers": ["console"],
        "level": "DEBUG",
    },
    "loggers": {
        "django": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
    },
}
