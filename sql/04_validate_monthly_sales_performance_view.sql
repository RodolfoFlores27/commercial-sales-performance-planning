SELECT
  COUNT(*) AS row_count,
  COUNT(DISTINCT actual_source_key) AS distinct_actuals,
  COUNTIF(customer_name IS NULL) AS missing_customer_names,
  COUNTIF(product_name IS NULL) AS missing_product_names,
  COUNTIF(sales_channel_name IS NULL) AS missing_channel_names,
  COUNTIF(target_net_sales_php IS NULL) AS missing_targets,
  COUNTIF(actual_net_sales_php IS NULL) AS missing_actual_net_sales,
  COUNTIF(target_attainment_pct IS NULL) AS missing_target_attainment,
  COUNTIF(financial_check != 'Pass') AS nonpassing_financial_checks,
  COUNTIF(promotion_link_status = 'No promotion') AS no_promotion_rows,
  COUNTIF(promotion_link_status = 'Promotion linked') AS promotion_linked_rows
FROM `project2_sales_performance.vw_monthly_sales_performance`;