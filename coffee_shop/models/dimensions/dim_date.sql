SELECT 
    date_day,
    dayofweek(date_day) day_of_week,
    monthname(date_day) month_name,
    year(date_day) year_num
FROM ({{ dbt_utils.date_spine(
    datepart = "day",
    start_date="cast('2022-01-01' as date)",
    end_date = "cast('2026-01-01' as date)"
) }} )