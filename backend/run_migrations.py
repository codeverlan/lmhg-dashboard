import os
from logging.config import fileConfig
from alembic import command
from alembic.config import Config

alembic_cfg = Config(os.path.join(os.path.dirname(__file__), 'alembic.ini'))
# override sqlalchemy.url with environment variable
db_url = os.environ.get('DATABASE_URL')
if not db_url:
    raise SystemExit('DATABASE_URL not set')
alembic_cfg.set_main_option('sqlalchemy.url', db_url)

# run upgrade
command.upgrade(alembic_cfg, 'head')
print('Migrations applied')
