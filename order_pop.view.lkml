##order_pop.view.lkml


view: order_pop {
  sql_table_name: `cloud-training-demos.looker_ecomm.order_items`
    ;;

  parameter: time_grain_filter {
    type: string
    default_value: "month"
    allowed_value: { label: "Week" value: "week" }
    allowed_value:  { label: "Month" value: "month" }
    allowed_value:  { label: "Quarter" value: "quarter" }
    allowed_value:  { label: "Year" value: "year" }
  }

  dimension: relative_timeframe_dim_dd {
    type: string
    sql:
      CASE
        WHEN {% parameter time_grain_filter %} = "day" THEN FORMAT_DATE('%Y-%m-%d', ${date_dimension.date})
        WHEN {% parameter time_grain_filter %} = "week" THEN ${date_dimension.year_week}
        WHEN {% parameter time_grain_filter %} = "month" THEN ${date_dimension.year_month}
        WHEN {% parameter time_grain_filter %} = "quarter" THEN ${date_dimension.year_qtr}
        WHEN {% parameter time_grain_filter %} = "year" THEN CAST(${date_dimension.year} AS STRING)
      END ;;
  }


  dimension: order_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: sale_price_dim {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: time_bucket_not_working {
    type: string
    sql:
    CASE
      WHEN ${created_date} BETWEEN DATE_TRUNC(CURRENT_DATE(), WEEK) AND CURRENT_DATE() THEN FORMAT_DATE('%Y-%U', ${created_date})
      WHEN ${created_date} BETWEEN DATE_TRUNC(CURRENT_DATE(), MONTH) AND CURRENT_DATE() THEN FORMAT_DATE('%Y-%m', ${created_date})
      WHEN ${created_date} BETWEEN DATE_TRUNC(CURRENT_DATE(), QUARTER) AND CURRENT_DATE() THEN CONCAT(CAST(EXTRACT(YEAR FROM ${created_date}) AS STRING), '-Q', CAST(EXTRACT(QUARTER FROM ${created_date}) AS STRING))
      ELSE FORMAT_DATE('%Y', ${created_date})
    END ;;
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd_0
  }

  measure: order_item_count {
    type: count
  }

  measure: order_count {
    type: count_distinct
    sql: ${order_id} ;;
  }

  measure: total_revenue {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }
  
  measure: revenue_last_year {
    type: sum
    sql: ${order_pop_last_year.sale_price} ;;
    value_format_name: usd
  }


  measure: total_revenue_last_year_relative {
    type: sum
    sql: ${sale_price} ;;
    filters: [created_date: "365 days ago"]
    value_format_name: usd
  }

  measure: total_revenue_from_completed_orders {
    type: sum
    sql: ${sale_price} ;;
    filters: [status: "Complete"]
    value_format_name: usd
  }

  # dimension: relative_timeframe_dim{
  #   type: string
  #   sql:
  #   CASE
  #     WHEN {% parameter time_grain_filter %} = "day" THEN FORMAT_DATE('%Y-%m-%d', ${created_date})
  #     WHEN {% parameter time_grain_filter %} = "week" THEN FORMAT_DATE('%Y-%W', ${created_date})
  #     WHEN {% parameter time_grain_filter %} = "month" THEN FORMAT_DATE('%Y-%m', ${created_date})
  #     WHEN {% parameter time_grain_filter %} = "quarter" THEN CONCAT(CAST(EXTRACT(YEAR FROM ${created_date}) AS STRING), '-Q', CAST(CEIL(EXTRACT(MONTH FROM ${created_date}) / 3.0) AS STRING))
  #     WHEN {% parameter time_grain_filter %} = "year" THEN CAST(EXTRACT(YEAR FROM ${created_date}) AS STRING)
  #   END ;;
  # }

}
