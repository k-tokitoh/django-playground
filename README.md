### サーバ起動

- 同梱された簡易サーバ
  - `python manage.py runserver`
- gunicorn
  - `gunicorn wsgi`

### パッケージ追加

- requirements.in に追記
- `pip-compile requirements.in`
- `pip install -r requirements.txt`
