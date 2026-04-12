select
    event_date,
    product_id,
    count(*) as row_count
from {{ ref('sales_agg') }}
group by event_date, product_id
having count(*) > 1
