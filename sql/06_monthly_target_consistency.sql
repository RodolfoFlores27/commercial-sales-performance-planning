WITH monthly AS (
  SELECT
    sales_month,
    product_name,
    sales_channel_name,
    SUM(actual_net_sales_php) AS actual_net_sales_php,
    SUM(target_net_sales_php) AS target_net_sales_php,
    SAFE_DIVIDE(
      SUM(actual_net_sales_php),
      SUM(target_net_sales_php)
    ) * 100 AS monthly_attainment_pct
  FROM `project2_sales_performance.vw_monthly_sales_performance`
  GROUP BY sales_month, product_name, sales_channel_name
)
SELECT
  product_name,
  sales_channel_name,
  COUNT(*) AS months_in_scope,
  COUNTIF(actual_net_sales_php >= target_net_sales_php) AS months_met_or_exceeded,
  COUNTIF(actual_net_sales_php < target_net_sales_php) AS months_below,
  ROUND(MIN(monthly_attainment_pct), 2) AS lowest_monthly_attainment_pct,
  ROUND(MAX(monthly_attainment_pct), 2) AS highest_monthly_attainment_pct,
  ROUND(AVG(monthly_attainment_pct), 2) AS average_monthly_attainment_pct
FROM monthly
GROUP BY product_name, sales_channel_name
ORDER BY average_monthly_attainment_pct DESC;