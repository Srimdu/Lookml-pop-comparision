view: adaptive_date_fields {
 derived_table: {
  sql:

-- This is a calendar exploder, which generates one row per date, starting from 2013-01-01. You can adjust the start date in line 12 if necessary. Uses Trino syntax.
        SELECT
          CAST(date_column AS DATE) AS calendar_date 
        , CONCAT(CAST(date_column as VARCHAR),'T00:00:00Z') AS calendar_dt
        , DATE_TRUNC('quarter', CAST(date_column AS DATE)) AS calendar_qtr
        , DATE_TRUNC('month', CAST(date_column AS DATE)) AS calendar_month
        FROM
          (VALUES (SEQUENCE(CAST('2013-01-01' AS date), CAST(NOW() AS date) + INTERVAL '3' month, INTERVAL '1' day))) AS t1(date_array)
        CROSS JOIN UNNEST(date_array) AS t2(date_column)
   ;;
 }

#### Parameters ####

# Selects which day of the week will be the new starting point for the week_start_adjusted dimension
# Hidden, because this field is made redundant by last trailing n window
  parameter: week_start_param {
    type: unquoted
    hidden:  yes
    label: "Week Start Filter 📅"
    description: "Select the day of the week you would like the week to start on"
    default_value: "1"
    allowed_value: {
      label: "Monday"
      value: "1"
    }
    allowed_value: {
      label: "Tuesday"
      value: "2"
    }
    allowed_value: {
      label: "Wednesday"
      value: "3"
    }
    allowed_value: {
      label: "Thursday"
      value: "4"
    }
    allowed_value: {
      label: "Friday"
      value: "5"
    }
    allowed_value: {
      label: "Saturday"
      value: "6"
    }
    allowed_value: {
      label: "Sunday"
      value: "7"
    }
  }

  # rolling_n_param allows the user to choose the number of units per time frame e.g. Rolling 7 day buckets, where n = 7
  parameter: rolling_n_param {
    label: "N 📅"
    description: "Group dates into n buckets. E.g., in a rolling 7 day bucket, {N} = 7. Use with the 'Last Trailing n Window' field."
    type: number
    default_value: "1"
  }

   # rolling_n_start_param allows the user to choose when the rolling window starts. e.g. Rolling 7 day buckets looking back from 2025-02-18
  parameter: rolling_n_start_param {
    label: "Lookback Anchor Date 📅"
    description: "Populate with the most recent date in your date filter. Chooses a date to lookback from for the 'Last Trailing n Window' and 'Period-to-Date Match 📅."
    type: date
  }

    # rolling_n_timeframe allows users to choose the interval of time the bucket covers. e.g. Rolling 7 day/week/etc. buckets,
    # where rolling_timeframe = day/week/month
  parameter: rolling_n_timeframe {
    label: "Date Granularity 📅"
    type: string
    description: "Choose the granularity/interval for your 'Last Trailing n __' or 'Dynamic To-Date Match 📅' fields. E.g., in a rolling 7 day bucket, {Date Granularity Selector} = days"
    default_value: "week"
    allowed_value: {
      label: "Days"
      value: "day"
     }
    allowed_value: {
      label: "Weeks"
      value: "week"
    }
    allowed_value: {
      label: "Months"
      value: "month"
    }
    allowed_value: {
      label: "Quarters"
      value: "quarter"
    }
    allowed_value: {
      label: "Years"
      value: "year"
    }
  }


#### dimensions ####

  dimension_group: event {
    group_label: " Timestamp"
    hidden: yes
    label: ""
    type: time
    timeframes: [
      date,
      day_of_week,
      week,
      month,
      day_of_month,
      quarter,
      day_of_year
    ]

    sql:
    ${TABLE}.calendar_date
    ;;
  }

  # Hidden because made redundant by Last Trailing n Window field
  # shifts the start of the week to the DOW value chose in week_start_param.
  # groups dates to the most recent AND previous occurrence of the DOW value selected in week_start_param
  # uses mod 7 to ensure dates are grouped to the correct week
  dimension: week_start_adjusted {
    label: "Dynamic Week Start 📅"
    hidden: yes
    description: "Allows for week over week grouping using a week which starts on --> 'Week Start Filter' "
    sql: date_add('day', - ((EXTRACT(DOW FROM ${TABLE}.calendar_date) + 7 - {{ week_start_param._parameter_value }} ) % 7), ${TABLE}.calendar_date) ;;
  }


  # This field returns the minimum date of a rolling lookback period by first calculating the number of complete lookback intervals between the calendar date and the rolling start date using a FLOOR division of their date difference.
  # A "lookback period" is the combination of the rolling_n_timeframe parameter value (days, weeks, months, etc.) and the rolling_n_param parameter value (a number 1,2,3, etc.) These parameters are selected by the user
  # the rolling start date (rolling_n_start_param parameter value) is a user selected date, which designates the start of the lookback period.
  # It then subtracts the corresponding interval (in units such as weeks) from the rolling start date and adds one day, returning the bucket’s earliest date
  # All values greater than the rolling_n_start_param parameter value are nulled out.

  dimension: rolling_n {
    label: "Last Trailing n Window 📅️"
    label_from_parameter: rolling_n_timeframe
    description: "Creates date groups of days/weeks/months/quarters/years using your input from --> 'Lookback Anchor Date' 'N' and 'Date Granularity' E.g., Rolling 3 week buckets trailing from 2025-02-15. Where {Date Granularity} is 'weeks', {N} = '3', and the {Lookback Anchor Date} is '2025-02-15"
    required_fields: [rolling_n_param, rolling_n_start_param, rolling_n_timeframe]
    sql:
CAST(
  CASE
    WHEN ${TABLE}.calendar_date > {{ rolling_n_start_param._parameter_value }} THEN NULL
    ELSE DATE_ADD(
      'day',
      1,
      DATE_ADD(
        {{ rolling_n_timeframe._parameter_value }},
        -1 * (
          (FLOOR(
            DATE_DIFF(
              {{ rolling_n_timeframe._parameter_value }},
              ${TABLE}.calendar_date,
              {{ rolling_n_start_param._parameter_value }}
            ) / {{ rolling_n_param._parameter_value }}
          ) + 1) * {{ rolling_n_param._parameter_value }}
        ),
        {{ rolling_n_start_param._parameter_value }}
      )
    )
  END AS DATE
)


;;


  }


  # calculates number of days elapsed from lookback start parameter to beginning of most recent timeframe parameter, and compares against number of days elapsed from date to beginning of most recent timeframe parameter. if date --> timeframe is greater than lookback start --> timeframe, then NULL. Otherwise, date_trunc(timeframe, date)
  dimension: lxtd_comparison {
    label: "Period-to-Date Match 📅️"
    label_from_parameter: rolling_n_timeframe
    description: "Last X to Date comparison. Creates equivalent 'to-date' date buckets over a chosen date granularity (Month, quarter, etc. from 'Date Granularity' filter) originating from a date of your choice (from 'Lookback Anchor Date' filter). I.e., 46 days have elapsed between the anchor date and the beginning of the quarter. How does this compare to the first 46 days of the previous quarter, and the one before that?"
    required_fields: [rolling_n_start_param, rolling_n_timeframe]
    sql:
    CASE WHEN date_diff(
  'day',
  date_add(
    'day',
    -1,
    date_trunc(
      {{ rolling_n_timeframe._parameter_value }},
      ${TABLE}.calendar_date
    )
  ),
  ${TABLE}.calendar_date
) > date_diff(
  'day',
  date_add(
    'day',
    -1,
    date_trunc(
      {{ rolling_n_timeframe._parameter_value }},
      {{ rolling_n_start_param._parameter_value }}
    )
  ),
  {{ rolling_n_start_param._parameter_value }}
) THEN NULL ELSE date_trunc(
  {{ {rolling_n_timeframe._parameter_value }},
  ${TABLE}.calendar_date
) END

    ;;
  }





}
