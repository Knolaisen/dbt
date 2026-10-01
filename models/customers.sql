with customers as (
    select
        c_custkey as customer_id,
        c_name as first_name,
        c_nationkey as last_name -- change columns as appropriate!
    from {{ source('snowflake_sample_data', 'CUSTOMER') }}
),

orders as (
    select
        o_orderkey as order_id,
        o_custkey as customer_id,
        o_orderdate as order_date,
        o_orderstatus as status
    from {{ source('snowflake_sample_data', 'ORDERS') }}
),

customer_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders
    from orders
    group by 1
),

final as (
    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders
    from customers
    left join customer_orders using (customer_id)
)

select * from final