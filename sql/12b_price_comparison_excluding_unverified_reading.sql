WITH our_prices AS (
  SELECT
    Product__c AS product_id,
    Sales_Channel__c AS sales_channel_id,
    Sales_Month__c AS sales_month,
    SUM(Units_Sold__c) AS units_sold,
    SAFE_DIVIDE(SUM(Gross_Sales__c), SUM(Units_Sold__c))
      AS gross_price_per_unit_php,
    SAFE_DIVIDE(
      SUM(Gross_Sales__c - Discount_Amount__c),
      SUM(Units_Sold__c)
    ) AS net_price_per_unit_php
  FROM `rodpersonal-513113.project2_sales_performance.monthly_sales_actuals`
  GROUP BY product_id, sales_channel_id, sales_month
),
competitor_prices AS (
  SELECT
    Product__c AS product_id,
    Sales_Channel__c AS sales_channel_id,
    Price_Month__c AS price_month,
    AVG(Competitor_Unit_Price__c) AS avg_competitor_price_php,
    COUNT(Competitor_Unit_Price__c) AS competitor_readings
  FROM `rodpersonal-513113.project2_sales_performance.competitor_price_observations`
  WHERE Observation_Source_Key__c != 'OBS_COMP_002_PROD_003_CHN_001_202503'
  GROUP BY product_id, sales_channel_id, price_month
)
SELECT
  o.sales_month,
  p.Name AS product_name,
  ch.Name AS sales_channel_name,
  o.units_sold,
  ROUND(o.gross_price_per_unit_php, 2) AS gross_price_per_unit_php,
  ROUND(o.net_price_per_unit_php, 2) AS net_price_per_unit_php,
  ROUND(c.avg_competitor_price_php, 2) AS avg_competitor_price_php,
  c.competitor_readings,
  ROUND(
    SAFE_DIVIDE(o.net_price_per_unit_php, c.avg_competitor_price_php) * 100,
    2
  ) AS net_price_index_pct
FROM our_prices o
JOIN competitor_prices c
  ON o.product_id = c.product_id
 AND o.sales_channel_id = c.sales_channel_id
 AND o.sales_month = c.price_month
JOIN `rodpersonal-513113.project2_sales_performance.products` p
  ON o.product_id = p.Id
JOIN `rodpersonal-513113.project2_sales_performance.sales_channels` ch
  ON o.sales_channel_id = ch.Id
ORDER BY o.sales_month, product_name, sales_channel_name;