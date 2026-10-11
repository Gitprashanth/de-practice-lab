select
    id as order_item_id,
    order_id,
    user_id,
    product_id,
    status,
    created_at,
    sale_price
from {{ source('silver', 'order_items') }}
where created_at >= timestamp('{{ var("earliest_date") }}')
