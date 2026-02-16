{{ config(materialized='table') }}

with trips as (
    select *
    from {{ ref('fct_trips') }}
),

monthly as (
    select
        date_trunc(pickup_datetime, month) as month,
        pickup_borough,
        pickup_zone,
        pickup_service_zone,

        -- metrics
        sum(total_amount) as revenue_monthly_total_amount,
        count(*) as total_monthly_trips

    from trips
    group by 1,2,3,4
)

select *
from monthly
order by month, pickup_zone
