select
    id as user_id,
    age,
    gender,
    state,
    city,
    country,
    traffic_source,
    created_at
from {{ source('silver', 'users') }}
