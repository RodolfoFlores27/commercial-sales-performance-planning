WITH annual AS (
  SELECT
    product_name,
    sales_channel_name,
    EXTRACT(YEAR FROM sales_month) AS sales_year,
    SUM(actual_net_sales_php) AS net_sales_php,
    SUM(gross_margin_php) AS gross_margin_php,
    SAFE_DIVIDE(
      SUM(gross_margin_php),
      SUM(actual_net_sales_php)
    ) * 100 AS gross_margin_pct
  FROM `project2_sales_performance.vw_monthly_sales_performance`
  GROUP BY product_name, sales_channel_name, sales_year
),
annual_pivot AS (
  SELECT
    product_name,
    sales_channel_name,
    SUM(IF(sales_year = 2024, net_sales_php, 0)) AS net_sales_2024_php,
    SUM(IF(sales_year = 2025, net_sales_php, 0)) AS net_sales_2025_php,
    SUM(IF(sales_year = 2024, gross_margin_php, 0)) AS gross_margin_2024_php,
    SUM(IF(sales_year = 2025, gross_margin_php, 0)) AS gross_margin_2025_php,
    MAX(IF(sales_year = 2024, gross_margin_pct, NULL)) AS gross_margin_pct_2024,
    MAX(IF(sales_year = 2025, gross_margin_pct, NULL)) AS gross_margin_pct_2025
  FROM annual
  GROUP BY product_name, sales_channel_name
)
SELECT
  product_name,
  sales_channel_name,
  ROUND(net_sales_2024_php, 2) AS net_sales_2024_php,
  ROUND(net_sales_2025_php, 2) AS net_sales_2025_php,
  ROUND(
    SAFE_DIVIDE(net_sales_2025_php - net_sales_2024_php, net_sales_2024_php) * 100,
    2
  ) AS net_sales_growth_pct,
  ROUND(gross_margin_2024_php, 2) AS gross_margin_2024_php,
  ROUND(gross_margin_2025_php, 2) AS gross_margin_2025_php,
  ROUND(gross_margin_pct_2024, 2) AS gross_margin_pct_2024,
  ROUND(gross_margin_pct_2025, 2) AS gross_margin_pct_2025,
  ROUND(gross_margin_pct_2025 - gross_margin_pct_2024, 2) AS margin_change_pp
FROM annual_pivot
ORDER BY net_sales_growth_pct DESC;