# development

## prerequisites

### python バージョンの指定

- `brew install pyenv`
- `pyenv install x.x.x`
- `pyenv local x.x.x`

### python 仮想環境の作成

- `python -m venv .venv`
- `source .venv/bin/activate`

## add packages

- （初回及び追加時のみ）
- requirements.in に追記
- `pip-compile requirements.in`
- `pip install -r requirements.txt`

## migration

- （初回及び追加時のみ）
- `docker run {WEB_CONTAINER_NAME} python manage.py migrate`

## run server

- デフォルト開発サーバー
  - 手順
    - `docker compose up`
    - browse on `http://localhost:8000`
- nginx + gunicorn
  - 説明
    - nginx は前段で static ファイルの配信、gunicorn が後段で django を動作させる wsgi サーバ
    - 実際つかうことは基本的になさそう
    - static ファイルの配信周りを整える際に少し本番に近い動作を見たかったのでつくっただけ
  - 手順
    - static ファイルを収集する
      - `python manage.py collectstatic`
    - `docker compose -f docker-compose.yml -f docker-compose.nginx.yml up`
    - browse on `http://localhost:80`

## deploy

- main ブランチに push すると Github Actions でデプロイ処理が走ります

# infrastructure

See [README](./terraform/README.md)
