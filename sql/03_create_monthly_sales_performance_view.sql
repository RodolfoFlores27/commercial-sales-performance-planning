CREATE OR REPLACE VIEW
  `project2_sales_performance.vw_monthly_sales_performance` AS

WITH matched AS (
  SELECT
    a.Sales_Actual_Source_Key__c AS actual_source_key,
    t.Target_Source_Key__c AS target_source_key,
    a.Sales_Month__c AS sales_month,

    c.Customer_Source_Key__c AS customer_source_key,
    c.Name AS customer_name,
    c.Customer_Segment__c AS customer_segment,
    c.Region__c AS region,

    p.Product_Source_Key__c AS product_source_key,
    p.Name AS product_name,
    p.Product_Category__c AS product_category,

    ch.Channel_Source_Key__c AS channel_source_key,
    ch.Name AS sales_channel_name,
    ch.Channel_Group__c AS channel_group,

    a.Units_Sold__c AS units_sold,
    a.Gross_Sales__c AS gross_sales_php,
    a.Discount_Amount__c AS discount_amount_php,
    a.Gross_Sales__c - a.Discount_Amount__c AS actual_net_sales_php,
    a.Cost_of_Goods_Sold__c AS cost_of_goods_sold_php,
    t.Target_Net_Sales__c AS target_net_sales_php,

    a.Promotion_Link_Status AS promotion_link_status,
    pr.Name AS promotion_name,
    pr.Promotion_Type__c AS promotion_type,
    a.Financial_Check AS financial_check

  FROM `project2_sales_performance.monthly_sales_actuals` AS a
  INNER JOIN `project2_sales_performance.monthly_sales_targets` AS t
    ON a.Customer__c = t.Customer__c
    AND a.Product__c = t.Product__c
    AND a.Sales_Channel__c = t.Sales_Channel__c
    AND a.Sales_Month__c = t.Target_Month__c
  LEFT JOIN `project2_sales_performance.accounts` AS c
    ON a.Customer__c = c.Id
  LEFT JOIN `project2_sales_performance.products` AS p
    ON a.Product__c = p.Id
  LEFT JOIN `project2_sales_performance.sales_channels` AS ch
    ON a.Sales_Channel__c = ch.Id
  LEFT JOIN `project2_sales_performance.promotions` AS pr
    ON a.Promotion__c = pr.Id
)

SELECT
  *,
  actual_net_sales_php - target_net_sales_php AS variance_to_target_php,
  SAFE_DIVIDE(actual_net_sales_php, target_net_sales_php) * 100
    AS target_attainment_pct,
  actual_net_sales_php - cost_of_goods_sold_php AS gross_margin_php,
  SAFE_DIVIDE(
    actual_net_sales_php - cost_of_goods_sold_php,
    actual_net_sales_php
  ) * 100 AS gross_margin_pct
FROM matched;