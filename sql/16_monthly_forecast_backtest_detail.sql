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
    prior_year.actual_net_sales_php AS baseline_forecast_php
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
  c.sales_month,
  p.Name AS product_name,
  ch.Name AS sales_channel_name,
  ROUND(c.actual_net_sales_php, 2) AS actual_net_sales_php,
  ROUND(c.baseline_forecast_php, 2) AS baseline_forecast_php,
  ROUND(c.actual_net_sales_php - c.baseline_forecast_php, 2)
    AS actual_minus_forecast_php,
  ROUND(
    SAFE_DIVIDE(
      ABS(c.actual_net_sales_php - c.baseline_forecast_php),
      c.actual_net_sales_php
    ) * 100,
    2
  ) AS absolute_percentage_error_pct
FROM comparison c
JOIN `rodpersonal-513113.project2_sales_performance.products` p
  ON c.product_id = p.Id
JOIN `rodpersonal-513113.project2_sales_performance.sales_channels` ch
  ON c.sales_channel_id = ch.Id
ORDER BY c.sales_month, product_name, sales_channel_name;