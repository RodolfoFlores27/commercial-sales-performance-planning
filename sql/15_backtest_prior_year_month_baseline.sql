WITH monthly_sales AS (
  SELECT
    Product__c AS product_id,
    Sales_Channel__c AS sales_channel_id,
    Sales_Month__c AS sales_month,
    SUM(Gross_Sales__c - Discount_Amount__c) AS actual_net_sales_php
  FROM `rodpersonal-513113.project2_sales_performance.monthly_sales_actuals`
  GROUP BY product_id, sales_channel_id, sales_month
),
comparison AS (
  SELECT
    current_year.product_id,
    current_year.sales_channel_id,
    current_year.sales_month,
    current_year.actual_net_sales_php,
    prior_year.actual_net_sales_php AS baseline_forecast_php,
    current_year.actual_net_sales_php
      - prior_year.actual_net_sales_php AS forecast_error_php
  FROM monthly_sales current_year
  JOIN monthly_sales prior_year
    ON current_year.product_id = prior_year.product_id
   AND current_year.sales_channel_id = prior_year.sales_channel_id
   AND DATE_SUB(current_year.sales_month, INTERVAL 1 YEAR)
       = prior_year.sales_month
  WHERE current_year.sales_month >= DATE '2025-01-01'
    AND current_year.sales_month < DATE '2026-01-01'
)
SELECT
  p.Name AS product_name,
  ch.Name AS sales_channel_name,
  COUNT(*) AS backtest_months,
  ROUND(SUM(actual_net_sales_php), 2) AS actual_2025_net_sales_php,
  ROUND(SUM(baseline_forecast_php), 2) AS baseline_forecast_php,
  ROUND(AVG(ABS(forecast_error_php)), 2) AS mean_absolute_error_php,
  ROUND(
    SAFE_DIVIDE(
      SUM(ABS(forecast_error_php)),
      SUM(actual_net_sales_php)
    ) * 100,
    2
  ) AS weighted_absolute_percentage_error_pct,
  ROUND(
    SAFE_DIVIDE(
      SUM(baseline_forecast_php - actual_net_sales_php),
      SUM(actual_net_sales_php)
    ) * 100,
    2
  ) AS forecast_bias_pct
FROM comparison c
JOIN `rodpersonal-513113.project2_sales_performance.products` p
  ON c.product_id = p.Id
JOIN `rodpersonal-513113.project2_sales_performance.sales_channels` ch
  ON c.sales_channel_id = ch.Id
GROUP BY product_name, sales_channel_name
ORDER BY product_name, sales_channel_name;