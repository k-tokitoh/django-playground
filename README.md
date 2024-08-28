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

- `docker compose up`

## deploy

- main ブランチに push すると Github Actions でデプロイ処理が走ります

# infrastructure

See [README](./terraform/README.md)
