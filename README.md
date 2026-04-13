# dbt project

Репозиторий содержит `dbt`-модели и тесты для PostgreSQL.

Проект используется как отдельный слой SQL-трансформаций. Запуск моделей выполняется из `Dagster`, а сам код моделей и тестов хранится в этом репозитории.

## Назначение репозитория

Репозиторий нужен для:
- хранения SQL-моделей `dbt`
- хранения тестов качества данных
- сопровождения настроек подключения `dbt`
- версионирования изменений через GitLab

## Общая схема работы

Процесс работы с проектом выглядит так:
- разработчик вносит изменения в модели или тесты
- изменения коммитятся и отправляются в GitLab
- GitLab CI обновляет локальную копию проекта на сервере
- `Dagster` при следующем запуске использует актуальную версию `dbt`-проекта

Таким образом:
- GitLab отвечает за хранение и версионирование кода
- GitLab CI отвечает за доставку новой версии проекта на сервер
- `dbt` отвечает за SQL-трансформации и тесты поверх уже загруженных staging-таблиц
- `Dagster` отвечает за orchestration и запуск


## Роль dbt в пайплайне

Проект не выполняет межсерверную загрузку данных.

Ожидается, что staging-таблицы уже заполнены внешним пайплайном, например через `Dagster`. После этого `dbt` использует эти таблицы как source и строит следующий слой моделей.

## Структура проекта

- `models/` — SQL-модели и их `yml`-описания
- `tests/` — кастомные SQL-тесты
- `profiles/` — профиль подключения `dbt`
- `requirements.txt` — зависимости Python
- `.gitlab-ci.yml` — автоматическое обновление проекта на сервере

## Локальный запуск

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
set -a && source .env && set +a
dbt debug --profiles-dir profiles
dbt build --profiles-dir profiles
```

## GitLab CI

Для автоматического обновления проекта на сервере используется `.gitlab-ci.yml`.

Pipeline выполняет следующие действия:
- обновляет локальную директорию проекта на сервере
- активирует `venv`
- загружает переменные из `.env`
- обновляет зависимости проекта

После этого `Dagster` использует уже актуальную версию `dbt`-кода.

## Ручное обновление проекта на сервере

Этот сценарий нужен как резервный вариант, если автодеплой временно недоступен или проект нужно обновить вручную.

Команда `git pull` должна выполняться для той ветки, которая развёрнута в нужной среде.

Примеры:

```bash
cd /srv/dbt
git pull origin master
source .venv/bin/activate
set -a && source .env && set +a
pip install -r requirements.txt
```

```bash
cd /srv/dbt
git pull origin dev
source .venv/bin/activate
set -a && source .env && set +a
pip install -r requirements.txt
```

```bash
cd /srv/dbt
git pull origin tnn
source .venv/bin/activate
set -a && source .env && set +a
pip install -r requirements.txt
```

## Подключение к PostgreSQL

Подключение `dbt` к PostgreSQL настраивается в `profiles/profiles.yml`.

Реальные параметры подключения не хранятся в `profiles.yml` напрямую, а передаются через переменные окружения:
- `DBT_POSTGRES_HOST`
- `DBT_POSTGRES_PORT`
- `DBT_POSTGRES_USER`
- `DBT_POSTGRES_PASSWORD`
- `DBT_POSTGRES_DB`
- `DBT_TARGET_SCHEMA`
- `DBT_SOURCE_SCHEMA`

Перед локальным запуском `dbt` переменные должны быть загружены из `.env`:

```bash
set -a && source .env && set +a
```

Если `dbt` запускается из `Dagster`, эти же переменные должны быть доступны в окружении, где выполняется `Dagster`.

## Изменение моделей

При изменении только SQL-моделей, `yml`-описаний или тестов переустанавливать `venv` не требуется.

Обычный цикл разработки:

```bash
source .venv/bin/activate
set -a && source .env && set +a
dbt build --profiles-dir profiles
```

Если изменились зависимости проекта, необходимо дополнительно выполнить:

```bash
pip install -r requirements.txt
```
