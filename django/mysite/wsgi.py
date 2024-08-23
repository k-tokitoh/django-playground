"""
WSGI config for mysite project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/howto/deployment/wsgi/
"""

import os

from django.core.wsgi import get_wsgi_application

# DJANGO_SETTINGS_MODULE という環境変数で、どの設定ファイルを利用するか指定するが、未指定の場合のデフォルト値を以下にする
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "mysite.settings.development")

application = get_wsgi_application()
