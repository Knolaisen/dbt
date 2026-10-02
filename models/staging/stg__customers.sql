select
    c_custkey as customer_id,
    c_name as first_name,
    c_nationkey as last_name,
    c_phone as phone_number
from {{ source('snowflake_sample_data', 'CUSTOMER') }}