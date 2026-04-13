select
    id,
    dt,
    count(*) as row_count
from {{ ref('stg_fact_staff_movements') }}
group by id, dt
having count(*) > 1
