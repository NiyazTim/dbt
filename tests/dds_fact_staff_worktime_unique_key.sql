select
    staff_id,
    work_date,
    count(*) as row_count
from {{ ref('dds_fact_staff_worktime') }}
group by staff_id, work_date
having count(*) > 1
