SELECT
  Observation_Source_Key__c,
  Competitor_Key__c,
  Competitor_Name_Standardized,
  Price_Month__c,
  Competitor_Unit_Price__c,
  Price_Data_Status
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
AND Competitor_Key__c = 'COMP_002'
ORDER BY Price_Month__c;