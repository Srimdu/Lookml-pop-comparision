## date_dimension.view.lkml

view: date_dimension {
  derived_table: {
    sql: SELECT
          FORMAT_DATE('%Y-%m-%d', d) AS date,
          FORMAT_DATE('%Y-W%U', d) AS week, -- e.g. 2024-W23
          FORMAT_DATE('%Y-%b', d) AS month, -- e.g. 2024-Jun
          FORMAT_DATE('%Y-Q%Q', d) AS quarter, -- e.g. 2024-Q2
          CONCAT(EXTRACT(YEAR FROM d), '-H', CAST(CEIL(EXTRACT(MONTH FROM d)/6) AS STRING)) AS half_year, -- e.g. 2024-H1
          EXTRACT(YEAR FROM d) AS year,
          DATE_ADD(d, INTERVAL (7 - EXTRACT(DAYOFWEEK FROM d)) DAY) AS week_ending_dt,
          LAST_DAY(d) AS month_ending_dt,
          LAST_DAY(DATE_ADD(DATE_TRUNC(d, QUARTER), INTERVAL 2 MONTH)) AS quarter_ending_dt,
          CASE
            WHEN EXTRACT(MONTH FROM d) <= 6 THEN DATE(EXTRACT(YEAR FROM d), 6, 30)
            ELSE DATE(EXTRACT(YEAR FROM d), 12, 31)
          END AS half_year_ending_dt,
          DATE(EXTRACT(YEAR FROM d), 12, 31) AS year_ending_dt,
          DATE_SUB(d, INTERVAL 1 YEAR) AS ly_date,
          DATE_SUB(DATE_ADD(d, INTERVAL (7 - EXTRACT(DAYOFWEEK FROM d)) DAY), INTERVAL 1 YEAR) AS ly_week_ending_dt,
          DATE_SUB(LAST_DAY(d), INTERVAL 1 YEAR) AS ly_month_ending_dt,
          DATE_SUB(LAST_DAY(DATE_ADD(DATE_TRUNC(d, QUARTER), INTERVAL 2 MONTH)), INTERVAL 1 YEAR) AS ly_quarter_ending_dt,
          DATE_SUB(
            CASE
              WHEN EXTRACT(MONTH FROM d) <= 6 THEN DATE(EXTRACT(YEAR FROM d), 6, 30)
              ELSE DATE(EXTRACT(YEAR FROM d), 12, 31)
            END, 
            INTERVAL 1 YEAR
          ) AS ly_half_year_ending_dt,
          DATE(EXTRACT(YEAR FROM d) - 1, 12, 31) AS ly_year_ending_dt
        FROM UNNEST(GENERATE_DATE_ARRAY('2020-01-01', '2025-12-31', INTERVAL 1 DAY)) AS d
        ORDER BY d ;;
    persist_for: "24 hours"
  }

  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: week {
    type: string
    sql: ${TABLE}.week ;;
  }

  dimension: month {
    type: string
    sql: ${TABLE}.month ;;
  }

  dimension: quarter {
    type: string
    sql: ${TABLE}.quarter ;;
  }

  dimension: half_year {
    type: string
    sql: ${TABLE}.half_year ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}.year ;;
  }

  dimension: week_ending_dt {
    type: date
    sql: ${TABLE}.week_ending_dt ;;
  }

  dimension: month_ending_dt {
    type: date
    sql: ${TABLE}.month_ending_dt ;;
  }

  dimension: quarter_ending_dt {
    type: date
    sql: ${TABLE}.quarter_ending_dt ;;
  }

  dimension: half_year_ending_dt {
    type: date
    sql: ${TABLE}.half_year_ending_dt ;;
  }

  dimension: year_ending_dt {
    type: date
    sql: ${TABLE}.year_ending_dt ;;
  }

  dimension: ly_date {
    type: date
    sql: ${TABLE}.ly_date ;;
  }
  
  dimension: ly_week_ending_dt {
    type: date
    sql: ${TABLE}.ly_week_ending_dt ;;
  }

  dimension: ly_month_ending_dt {
    type: date
    sql: ${TABLE}.ly_month_ending_dt ;;
  }

  dimension: ly_quarter_ending_dt {
    type: date
    sql: ${TABLE}.ly_quarter_ending_dt ;;
  }

  dimension: ly_half_year_ending_dt {
    type: date
    sql: ${TABLE}.ly_half_year_ending_dt ;;
  }

  dimension: ly_year_ending_dt {
    type: date
    sql: ${TABLE}.ly_year_ending_dt ;;
  }
}