{{ config(
    unique_key=['staff_id', 'work_date']
) }}

with times as (
    select
        staff_id,
        date(dt) as work_date,
        config_name,
        dt
    from {{ source('stg_source', 'stg_fact_staff_movements') }}
    where config_name in ('Вход на завод', 'Выход с завода')
),
entries as (
    select
        staff_id,
        work_date,
        max(case when config_name like '%Вход%' then dt end) as entry_time,
        max(case when config_name like '%Выход%' then dt end) as exit_time
    from times
    group by staff_id, work_date
)
select
    staff_id,
    work_date,
    coalesce(
        floor(extract(epoch from (exit_time - entry_time)) / 3600),
        0
    )::int as hours,
    coalesce(
        floor(extract(epoch from (exit_time - entry_time)) / 60)::bigint % 60,
        0
    )::bigint as minutes,
    current_timestamp as load_dttm
from entries
where entry_time is not null
  and exit_time is not null
