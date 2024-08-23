"""
ASGI config for mysite project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/howto/deployment/asgi/
"""

import os

from django.core.asgi import get_asgi_application

# DJANGO_SETTINGS_MODULE という環境変数で、どの設定ファイルを利用するか指定するが、未指定の場合のデフォルト値を以下にする
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "mysite.settings.development")

application = get_asgi_application()
