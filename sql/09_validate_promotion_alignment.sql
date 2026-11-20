SELECT
  COUNT(*) AS linked_actual_rows,
  COUNTIF(a.Product__c != p.Product__c) AS product_mismatch_rows,
  COUNTIF(a.Sales_Channel__c != p.Sales_Channel__c) AS channel_mismatch_rows,
  COUNTIF(
    a.Sales_Month__c < p.Start_Date__c
    OR a.Sales_Month__c > p.End_Date__c
  ) AS month_outside_promotion_rows
FROM `project2_sales_performance.monthly_sales_actuals` AS a
JOIN `project2_sales_performance.promotions` AS p
  ON a.Promotion__c = p.Id;