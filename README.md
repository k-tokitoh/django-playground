### サーバ起動

- 同梱された簡易サーバ
  - `python manage.py runserver`
- gunicorn
  - `gunicorn wsgi`

### パッケージ追加

- requirements.in に追記
- `pip-compile requirements.in`
- `pip install -r requirements.txt`

### deploy

- build image
  - `docker build -t xxx.dkr.ecr.ap-northeast-1.amazonaws.com/django-playground:latest .`
- push
  - `docker push xxx.dkr.ecr.ap-northeast-1.amazonaws.com/django-playground:latest`
- ECS のサービスで「サービスを更新 > 新しいデプロイの強制」
