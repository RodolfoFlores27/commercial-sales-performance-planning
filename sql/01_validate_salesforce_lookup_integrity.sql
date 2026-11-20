SELECT 'actuals → accounts' AS relationship,
       COUNTIF(a.Customer__c IS NOT NULL AND c.Id IS NULL) AS unmatched_rows
FROM `project2_sales_performance.monthly_sales_actuals` AS a
LEFT JOIN `project2_sales_performance.accounts` AS c
  ON a.Customer__c = c.Id

UNION ALL
SELECT 'actuals → products',
       COUNTIF(a.Product__c IS NOT NULL AND p.Id IS NULL)
FROM `project2_sales_performance.monthly_sales_actuals` AS a
LEFT JOIN `project2_sales_performance.products` AS p
  ON a.Product__c = p.Id

UNION ALL
SELECT 'actuals → sales channels',
       COUNTIF(a.Sales_Channel__c IS NOT NULL AND s.Id IS NULL)
FROM `project2_sales_performance.monthly_sales_actuals` AS a
LEFT JOIN `project2_sales_performance.sales_channels` AS s
  ON a.Sales_Channel__c = s.Id

UNION ALL
SELECT 'actuals → promotions',
       COUNTIF(NULLIF(TRIM(a.Promotion__c), '') IS NOT NULL AND p.Id IS NULL)
FROM `project2_sales_performance.monthly_sales_actuals` AS a
LEFT JOIN `project2_sales_performance.promotions` AS p
  ON a.Promotion__c = p.Id

UNION ALL
SELECT 'targets → accounts',
       COUNTIF(t.Customer__c IS NOT NULL AND c.Id IS NULL)
FROM `project2_sales_performance.monthly_sales_targets` AS t
LEFT JOIN `project2_sales_performance.accounts` AS c
  ON t.Customer__c = c.Id

UNION ALL
SELECT 'targets → products',
       COUNTIF(t.Product__c IS NOT NULL AND p.Id IS NULL)
FROM `project2_sales_performance.monthly_sales_targets` AS t
LEFT JOIN `project2_sales_performance.products` AS p
  ON t.Product__c = p.Id

UNION ALL
SELECT 'targets → sales channels',
       COUNTIF(t.Sales_Channel__c IS NOT NULL AND s.Id IS NULL)
FROM `project2_sales_performance.monthly_sales_targets` AS t
LEFT JOIN `project2_sales_performance.sales_channels` AS s
  ON t.Sales_Channel__c = s.Id

UNION ALL
SELECT 'promotions → products',
       COUNTIF(pr.Product__c IS NOT NULL AND p.Id IS NULL)
FROM `project2_sales_performance.promotions` AS pr
LEFT JOIN `project2_sales_performance.products` AS p
  ON pr.Product__c = p.Id

UNION ALL
SELECT 'promotions → sales channels',
       COUNTIF(pr.Sales_Channel__c IS NOT NULL AND s.Id IS NULL)
FROM `project2_sales_performance.promotions` AS pr
LEFT JOIN `project2_sales_performance.sales_channels` AS s
  ON pr.Sales_Channel__c = s.Id

UNION ALL
SELECT 'competitor prices → products',
       COUNTIF(cp.Product__c IS NOT NULL AND p.Id IS NULL)
FROM `project2_sales_performance.competitor_price_observations` AS cp
LEFT JOIN `project2_sales_performance.products` AS p
  ON cp.Product__c = p.Id

UNION ALL
SELECT 'competitor prices → sales channels',
       COUNTIF(cp.Sales_Channel__c IS NOT NULL AND s.Id IS NULL)
FROM `project2_sales_performance.competitor_price_observations` AS cp
LEFT JOIN `project2_sales_performance.sales_channels` AS s
  ON cp.Sales_Channel__c = s.Id

ORDER BY relationship;