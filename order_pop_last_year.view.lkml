## order_pop_last_year.view.lkml


view: order_pop_last_year {
  derived_table: {
    sql:
      SELECT
        DATE(created_at) order_date_ly,
        DATE_ADD(DATE(created_at), INTERVAL 1 YEAR) AS order_date_py_ref_ly,
        SUM(sale_price) AS last_year_revenue
      FROM `cloud-training-demos.looker_ecomm.order_items`
      GROUP BY 1,2
    ;;
  }

  dimension: order_date_ly {
    type: date
    sql: ${TABLE}.order_date_ly ;;
  }

  dimension: order_date_py_ref_ly {
    type:  date
    sql: ${TABLE}.order_date_py_ref_ly ;;
  }

  measure: last_year_revenue {
    type: sum
    sql: ${TABLE}.last_year_revenue ;;
    value_format_name: usd
  }
}
