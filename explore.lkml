connection: "bigquery_public_data_looker"

# include all the views
include: "/views/*.view"
include: "/z_tests/*.lkml"
include: "/**/*.dashboard"
fiscal_month_offset: 6

datagroup: training_ecommerce_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "24 hour"
}

persist_with: training_ecommerce_default_datagroup

label: "E-Commerce Training"

explore: order_items {
  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: events {
  join: event_session_facts {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_facts.session_id} ;;
    relationship: many_to_one
  }
  join: event_session_funnel {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_funnel.session_id} ;;
    relationship: many_to_one
  }
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}


# explore: order_pop {
#   join: order_pop_last_year {
#     type: left_outer
#     sql_on: ${order_pop.created_date} = ${order_pop_last_year.order_date_py_ref_ly} ;;
#     relationship: many_to_many
#   }
# }

explore: order_pop {
  join: date_dimension {
    type: left_outer
    sql_on: ${order_pop.created_date} = ${date_dimension.date} ;;
    relationship: many_to_one
  }
  join: order_pop_last_year {
    from: order_pop
    sql_on: ${order_pop.created_date} = ${order_pop_last_year.created_date} + INTERVAL 1 YEAR ;;
    relationship: one_to_one
  }
}
