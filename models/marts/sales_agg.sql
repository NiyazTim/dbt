select
    event_date,
    product_id,
    cast(sum(amount) as numeric(12, 2)) as total_revenue,
    sum(quantity)::integer as total_quantity,
    count(*)::integer as orders_count
from {{ source('sales_source', 'sales_facts') }}
group by event_date, product_id
