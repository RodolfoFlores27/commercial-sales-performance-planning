WITH actual_grain AS (
  SELECT
    Customer__c AS customer_id,
    Product__c AS product_id,
    Sales_Channel__c AS channel_id,
    Sales_Month__c AS sales_month,
    COUNT(*) AS actual_rows
  FROM `project2_sales_performance.monthly_sales_actuals`
  GROUP BY 1, 2, 3, 4
),
target_grain AS (
  SELECT
    Customer__c AS customer_id,
    Product__c AS product_id,
    Sales_Channel__c AS channel_id,
    Target_Month__c AS sales_month,
    COUNT(*) AS target_rows
  FROM `project2_sales_performance.monthly_sales_targets`
  GROUP BY 1, 2, 3, 4
)
SELECT
  COUNT(*) AS total_grain_combinations,
  COUNTIF(a.actual_rows IS NOT NULL AND t.target_rows IS NOT NULL) AS matched_combinations,
  COUNTIF(a.actual_rows IS NULL) AS target_only_combinations,
  COUNTIF(t.target_rows IS NULL) AS actual_only_combinations,
  COUNTIF(a.actual_rows > 1) AS duplicate_actual_grains,
  COUNTIF(t.target_rows > 1) AS duplicate_target_grains
FROM actual_grain AS a
FULL OUTER JOIN target_grain AS t
  ON a.customer_id = t.customer_id
  AND a.product_id = t.product_id
  AND a.channel_id = t.channel_id
  AND a.sales_month = t.sales_month;