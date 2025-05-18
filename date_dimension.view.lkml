##date_dimension.view.lkml


view: date_dimension {
  derived_table: {
    sql: SELECT
          FORMAT_DATE('%Y%m%d', d) AS date_id,
          FORMAT_DATE('%Y-%m-%d', d) AS date,
          DATE_SUB(d, INTERVAL 1 YEAR) AS last_year_date,
          EXTRACT(DAY FROM d) AS day_of_month,
          FORMAT_DATE('%A', d) AS day_name,
          EXTRACT(DAYOFWEEK FROM d) AS day_of_week,
          CASE
            WHEN EXTRACT(DAYOFWEEK FROM d) IN (1, 7) THEN 'Weekend'
            ELSE 'Weekday'
          END AS weekend_flag,
          EXTRACT(WEEK FROM d) AS week,
          FORMAT_DATE('%Y-W%U', d) AS year_week,
          EXTRACT(MONTH FROM d) AS month,
          FORMAT_DATE('%B', d) AS month_name,
          FORMAT_DATE('%Y-%m', d) AS year_month,
          FORMAT_DATE('%Y-%b', d) AS year_month_name,
          EXTRACT(QUARTER FROM d) AS qtr,
          FORMAT_DATE('%Y-Q%Q', d) AS year_qtr,
          EXTRACT(YEAR FROM d) AS year,
          FORMAT_DATE('%Y-%m-%d', d) AS iso_date,
          EXTRACT(ISOWEEK FROM d) AS iso_week,
          FORMAT_DATE('%Y-W%V', d) AS iso_year_week,
          CASE
            WHEN EXTRACT(DAY FROM d) = 1 THEN 'Y'
            ELSE 'N'
          END AS first_day_of_month,
          CASE
            WHEN EXTRACT(DAY FROM d) = EXTRACT(DAY FROM LAST_DAY(d)) THEN 'Y'
            ELSE 'N'
          END AS last_day_of_month
        FROM UNNEST(GENERATE_DATE_ARRAY('2014-01-01', '2050-01-01', INTERVAL 1 DAY)) AS d
        ORDER BY d ;;
    persist_for: "24 hours"
  }

  dimension: date_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.date_id ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: last_year_date {
    type: date
    sql: ${TABLE}.last_year_date ;;
  }

  dimension: day_of_month {
    type: number
    sql: ${TABLE}.day_of_month ;;
  }

  dimension: day_name {
    type: string
    sql: ${TABLE}.day_name ;;
  }

  dimension: day_of_week {
    type: number
    sql: ${TABLE}.day_of_week ;;
  }

  dimension: weekend_flag {
    type: string
    sql: ${TABLE}.weekend_flag ;;
  }

  dimension: week {
    type: number
    sql: ${TABLE}.week ;;
  }

  dimension: year_week {
    type: string
    sql: ${TABLE}.year_week ;;
  }

  dimension: month {
    type: number
    sql: ${TABLE}.month ;;
  }

  dimension: month_name {
    type: string
    sql: ${TABLE}.month_name ;;
  }

  dimension: year_month {
    type: string
    sql: ${TABLE}.year_month ;;
  }

  dimension: year_month_name {
    type: string
    sql: ${TABLE}.year_month_name ;;
  }

  dimension: qtr {
    type: number
    sql: ${TABLE}.qtr ;;
  }

  dimension: year_qtr {
    type: string
    sql: ${TABLE}.year_qtr ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}.year ;;
  }

  dimension: iso_date {
    type: date
    sql: ${TABLE}.iso_date ;;
  }

  dimension: iso_week {
    type: number
    sql: ${TABLE}.iso_week ;;
  }

  dimension: iso_year_week {
    type: string
    sql: ${TABLE}.iso_year_week ;;
  }

  dimension: first_day_of_month {
    type: string
    sql: ${TABLE}.first_day_of_month ;;
  }

  dimension: last_day_of_month {
    type: string
    sql: ${TABLE}.last_day_of_month ;;
  }
}
