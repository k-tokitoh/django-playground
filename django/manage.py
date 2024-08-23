#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys


def main():
    """Run administrative tasks."""
    # DJANGO_SETTINGS_MODULE という環境変数で、どの設定ファイルを利用するか指定するが、未指定の場合のデフォルト値を以下にする
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "mysite.settings.development")
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()
