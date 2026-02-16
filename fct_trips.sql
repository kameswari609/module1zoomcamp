with base as (

    -- 1. Start from the unioned trips
    select
        *,
        {{ get_vendor_name('vendor_id') }} as vendor_name,
        timestamp_diff(dropoff_datetime, pickup_datetime, minute) as trip_duration_minutes
    from {{ ref('int_trips_unioned') }}

),

-- 2. Deduplicate trips using row_number()
deduped as (
    select
        *,
        row_number() over (
            partition by vendor_id, pickup_datetime, dropoff_datetime,
                         pickup_location_id, dropoff_location_id, total_amount
            order by pickup_datetime
        ) as rn
    from base
),

-- 3. Keep only the first occurrence of each duplicate group
cleaned as (
    select *
    from deduped
    where rn = 1
),

-- 4. Add a surrogate primary key
with_keys as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'vendor_id',
            'pickup_datetime',
            'dropoff_datetime',
            'pickup_location_id',
            'dropoff_location_id',
            'total_amount'
        ]) }} as trip_id,
        *
    from cleaned
),

-- 5. Load payment type seed
payment_lookup as (
    select *
    from {{ ref('payment_type_lookup') }}
),

-- 6. Zone lookups
pickup_zones as (
    select
        location_id,
        borough as pickup_borough,
        zone as pickup_zone,
        service_zone as pickup_service_zone
    from {{ ref('dim_zones') }}
),

dropoff_zones as (
    select
        location_id,
        borough as dropoff_borough,
        zone as dropoff_zone,
        service_zone as dropoff_service_zone
    from {{ ref('dim_zones') }}
)

-- 7. Final fact table
select
    w.trip_id,
    w.vendor_id,
    w.vendor_name,
    w.ratecode_id,
    w.pickup_location_id,
    w.dropoff_location_id,
    w.pickup_datetime,
    w.dropoff_datetime,
    w.store_and_fwd_flag,
    w.passenger_count,
    w.trip_distance,
    w.trip_type,
    w.ehail_fee,
    w.fare_amount,
    w.extra,
    w.mta_tax,
    w.tip_amount,
    w.tolls_amount,
    w.improvement_surcharge,
    w.total_amount,
    w.payment_type,
    p.payment_type_description,
    w.service_type,
    w.trip_duration_minutes,

    -- pickup zone enrichment
    pu.pickup_borough,
    pu.pickup_zone,
    pu.pickup_service_zone,

    -- dropoff zone enrichment
    do.dropoff_borough,
    do.dropoff_zone,
    do.dropoff_service_zone

from with_keys w
left join {{ ref('dim_payment_types') }} p
    on w.payment_type = p.payment_type
left join pickup_zones pu
    on w.pickup_location_id = pu.location_id
left join dropoff_zones do
    on w.dropoff_location_id = do.location_id
