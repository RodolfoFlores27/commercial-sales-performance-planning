SELECT *
FROM `rodpersonal-513113.project2_sales_performance.competitor_price_observations`
WHERE Product__c = (
  SELECT Id
  FROM `rodpersonal-513113.project2_sales_performance.products`
  WHERE Name = 'Daycrest Shampoo 400 mL'
)
AND Sales_Channel__c = (
  SELECT Id
  FROM `rodpersonal-513113.project2_sales_performance.sales_channels`
  WHERE Name = 'Sari-sari & Neighborhood Retail'
)
AND Price_Month__c = DATE '2025-03-01'
ORDER BY Competitor_Key__c;