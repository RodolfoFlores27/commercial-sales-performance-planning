SELECT
  customer_source_key,
  customer_name,
  customer_segment,
  region,
  COUNT(*) AS months_in_scope,
  COUNTIF(actual_net_sales_php >= target_net_sales_php) AS months_met_or_exceeded,
  COUNTIF(actual_net_sales_php < target_net_sales_php) AS months_below,
  ROUND(SUM(actual_net_sales_php), 2) AS actual_net_sales_php,
  ROUND(SUM(target_net_sales_php), 2) AS target_net_sales_php,
  ROUND(SUM(variance_to_target_php), 2) AS variance_to_target_php,
  ROUND(
    SAFE_DIVIDE(SUM(actual_net_sales_php), SUM(target_net_sales_php)) * 100,
    2
  ) AS target_attainment_pct
FROM `project2_sales_performance.vw_monthly_sales_performance`
WHERE product_name = 'Clearbrook Dishwashing Liquid 1 L'
  AND sales_channel_name = 'Supermarket & Grocery Chains'
GROUP BY customer_source_key, customer_name, customer_segment, region
ORDER BY target_attainment_pct ASC;