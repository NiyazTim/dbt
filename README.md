# dbt sales demo

Локальный dbt-проект для сценария:

- source table: `sales_facts`
- target model: `sales_agg`
- database: PostgreSQL

## Быстрый старт

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
cp profiles/profiles.yml.example profiles/profiles.yml
set -a && source .env && set +a
dbt debug --profiles-dir profiles
dbt build --profiles-dir profiles
```

## Что делает проект

- читает `public.sales_facts` как source
- строит `sales_agg` как dbt model
- запускает schema tests и кастомный тест на уникальность ключа `(event_date, product_id)`

## Git workflow

```bash
git init
git add .
git commit -m "Инициализирован dbt-проект для sales aggregation"
git remote add origin https://github.com/NiyazTim/dbt.git
git branch -M main
git push -u origin main
```
