SELECT
  product_name,
  sales_channel_name,
  promotion_link_status,
  COUNT(*) AS customer_month_rows,
  COUNT(DISTINCT sales_month) AS months_covered,
  ROUND(AVG(actual_net_sales_php), 2) AS avg_net_sales_per_customer_month_php,
  ROUND(SUM(actual_net_sales_php), 2) AS total_net_sales_php,
  ROUND(
    SAFE_DIVIDE(SUM(actual_net_sales_php), SUM(target_net_sales_php)) * 100,
    2
  ) AS target_attainment_pct,
  ROUND(SUM(discount_amount_php), 2) AS total_discount_amount_php,
  ROUND(
    SAFE_DIVIDE(SUM(gross_margin_php), SUM(actual_net_sales_php)) * 100,
    2
  ) AS gross_margin_pct
FROM `project2_sales_performance.vw_monthly_sales_performance`
GROUP BY product_name, sales_channel_name, promotion_link_status
ORDER BY product_name, sales_channel_name, promotion_link_status;