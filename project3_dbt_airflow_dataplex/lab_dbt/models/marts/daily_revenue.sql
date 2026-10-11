{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by={'field': 'order_date', 'data_type': 'date'},
    cluster_by=['category']
) }}

select
    date(oi.created_at) as order_date,
    p.category,
    count(distinct oi.order_id) as orders,
    count(*) as items_sold,
    sum(oi.sale_price) as revenue
from {{ ref('stg_order_items') }} oi
join {{ ref('stg_products') }} p
    on oi.product_id = p.product_id
where oi.status not in ('Cancelled', 'Returned')
{% if is_incremental() %}
  and date(oi.created_at) >= date_sub(date(_dbt_max_partition), interval 3 day)
{% endif %}
group by 1, 2
