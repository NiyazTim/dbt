select
    id,
    staff_id,
    dt,
    type_pass,
    area_id,
    area_name,
    config_name,
    processed,
    created_at,
    identifier,
    original_staff_id,
    current_timestamp as load_dttm
from {{ source('staff_movements_source', 'movements') }}
where dt >= current_timestamp - interval '2 day'
