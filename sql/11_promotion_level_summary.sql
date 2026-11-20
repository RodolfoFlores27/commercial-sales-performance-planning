SELECT
  p.Promotion_Source_Key__c,
  p.Name AS promotion_name,
  p.Promotion_Type__c,
  ROUND(p.Planned_Discount__c * 100, 2) AS planned_discount_pct,
  p.Start_Date__c,
  p.End_Date__c,
  pr.Name AS product_name,
  ch.Name AS sales_channel_name,
  COUNT(*) AS customer_month_rows,
  COUNT(DISTINCT a.Customer__c) AS customers_covered,
  ROUND(SUM(a.Gross_Sales__c), 2) AS gross_sales_php,
  ROUND(SUM(a.Discount_Amount__c), 2) AS discount_amount_php,
  ROUND(
    SAFE_DIVIDE(SUM(a.Discount_Amount__c), SUM(a.Gross_Sales__c)) * 100,
    2
  ) AS realized_discount_pct,
  ROUND(SUM(a.Gross_Sales__c - a.Discount_Amount__c), 2)
    AS actual_net_sales_php,
  ROUND(SUM(t.Target_Net_Sales__c), 2) AS target_net_sales_php,
  ROUND(
    SAFE_DIVIDE(
      SUM(a.Gross_Sales__c - a.Discount_Amount__c),
      SUM(t.Target_Net_Sales__c)
    ) * 100,
    2
  ) AS target_attainment_pct,
  ROUND(
    SAFE_DIVIDE(
      SUM(a.Gross_Sales__c - a.Discount_Amount__c - a.Cost_of_Goods_Sold__c),
      SUM(a.Gross_Sales__c - a.Discount_Amount__c)
    ) * 100,
    2
  ) AS gross_margin_pct
FROM `project2_sales_performance.monthly_sales_actuals` AS a
JOIN `project2_sales_performance.promotions` AS p
  ON a.Promotion__c = p.Id
JOIN `project2_sales_performance.monthly_sales_targets` AS t
  ON a.Customer__c = t.Customer__c
  AND a.Product__c = t.Product__c
  AND a.Sales_Channel__c = t.Sales_Channel__c
  AND a.Sales_Month__c = t.Target_Month__c
JOIN `project2_sales_performance.products` AS pr
  ON p.Product__c = pr.Id
JOIN `project2_sales_performance.sales_channels` AS ch
  ON p.Sales_Channel__c = ch.Id
GROUP BY
  p.Promotion_Source_Key__c,
  p.Name,
  p.Promotion_Type__c,
  p.Planned_Discount__c,
  p.Start_Date__c,
  p.End_Date__c,
  pr.Name,
  ch.Name
ORDER BY p.Start_Date__c, p.Promotion_Source_Key__c;