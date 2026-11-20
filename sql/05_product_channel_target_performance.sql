SELECT
  product_name,
  product_category,
  sales_channel_name,
  channel_group,
  SUM(units_sold) AS total_units_sold,
  ROUND(SUM(actual_net_sales_php), 2) AS actual_net_sales_php,
  ROUND(SUM(target_net_sales_php), 2) AS target_net_sales_php,
  ROUND(SUM(variance_to_target_php), 2) AS variance_to_target_php,
  ROUND(
    SAFE_DIVIDE(SUM(actual_net_sales_php), SUM(target_net_sales_php)) * 100,
    2
  ) AS target_attainment_pct,
  ROUND(SUM(gross_margin_php), 2) AS gross_margin_php,
  ROUND(
    SAFE_DIVIDE(SUM(gross_margin_php), SUM(actual_net_sales_php)) * 100,
    2
  ) AS gross_margin_pct
FROM `project2_sales_performance.vw_monthly_sales_performance`
GROUP BY
  product_name,
  product_category,
  sales_channel_name,
  channel_group
ORDER BY variance_to_target_php DESC;