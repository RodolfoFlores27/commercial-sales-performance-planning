# Commercial Sales Performance & Planning — Case Study

> This project uses synthetic, Philippines-based data for a fictional distributor. Its results demonstrate an analytics workflow; they do not establish real business outcomes or cause and effect.

## Project Overview

I built an end-to-end sales analytics project to examine performance against targets, changes in sales and gross margin, promotion discount execution, competitor price observations, and a simple sales forecast baseline.

The 2024–2025 datasets represent a fictional food and household-products distributor. I set up the initial account and sales-channel records with Salesforce’s Data Import Wizard. I used Salesforce Data Loader for later bulk imports and a promotion update, then exported the Salesforce records to CSV. I then profiled and cleaned the exports with Excel Power Query, used Excel VBA to run quality checks and export the cleaned tables, analyzed those tables with SQL in BigQuery, and presented selected results in Tableau Public.

This case study explains the main workflow, decisions, checks, and outputs. The project README provides the shorter overview and links to the dashboard and supporting files.

## 1. Generate the Seed Records

- **Goal:** Create a small, consistent set of fictional customers, products, and sales channels to establish the project’s Salesforce records and relationships.
- **What I did:** Used Python with NumPy and pandas to generate six customers, three products, and two sales channels. Stable source keys helped identify the same records across files. After loading the base records into Salesforce, I used Salesforce record IDs when preparing related promotions and sales data.
- **Key check:** Confirmed the expected record counts and matched the source keys to Salesforce IDs before preparing related records.
- **Output:** Salesforce records and related synthetic data for the fictional distributor. The seed files supported the Salesforce setup; the analytical input files were later exported from Salesforce.

## 2. Set Up the Salesforce Data

- **Goal:** Store the fictional distributor’s records in Salesforce and connect related information.
- **What I did:** In Salesforce Developer Edition, I set up records for customers, products, sales channels, promotions, monthly sales, monthly targets, and competitor price observations. I used the Data Import Wizard for the initial account and sales-channel imports, then used Data Loader for later bulk imports and the promotion update. I added lookup fields so related records could be connected.
- **Key check:** Checked the import results and record counts: 6 customers, 3 products, 2 sales channels, 24 promotions, 864 monthly sales records, 864 monthly target records, and 288 competitor price observations.
- **Output:** Connected Salesforce records that I later exported as the source files for the analysis.

## 3. Export the Salesforce Data

- **Goal:** Create the source files for cleaning and analysis while retaining the links between records.
- **What I did:** Used Salesforce Data Loader to export seven record groups to CSV: accounts, products, sales channels, promotions, monthly sales actuals, monthly sales targets, and competitor price observations. I saved the files in data/salesforce-exports/.
- **Key check:** Confirmed the export row counts matched the Salesforce records and that the files retained the IDs used to connect related records.
- **Output:** Seven raw Salesforce export files for Power Query. The Python seed files supported the Salesforce setup; they were not the files loaded into BigQuery.

## 4. Profile and Clean the Salesforce Exports

- **Goal:** Understand the exported data before changing it, then correct issues that could affect the analysis.
- **What I did:** Loaded the seven Salesforce CSV exports into Excel Power Query. I checked row counts, data types, missing values, key uniqueness, date ranges, and relationships. The checks revealed six different competitor-name spellings for two competitors and three missing competitor prices. I standardized the names and kept the prices blank because there was no evidence to replace them with reliable values. I also confirmed that blank promotion links on monthly sales records meant “no promotion,” rather than missing sales data.
- **Key check:** Confirmed that the cleaned tables retained their expected row counts and that the promotion-link status showed 720 records with no promotion and 144 linked to a promotion.
- **Output:** Seven cleaned tables, with the missing competitor prices preserved for review rather than filled with guesses.

## 5. Check and Export the Clean Tables with VBA

- **Goal:** Confirm that all seven cleaned tables were complete and ready to load into BigQuery.
- **What I did:** Updated an Excel VBA macro to refresh the Power Query results, compare actual row counts and unique keys with the expected values, run project-specific checks, and export the tables as CSV files to `data/power-query-cleaned/`.
- **Key check:** The QA summary reported PASS for all seven tables. It also confirmed that all 864 monthly sales records passed the financial check, 720 had no promotion and 144 were promotion-linked, and the competitor data contained three missing prices and two standardized competitor names.
- **Output:** Seven cleaned CSV files, ready for BigQuery.

## 6. Load and Validate the Clean Tables in BigQuery

- **Goal:** Confirm that the cleaned Salesforce exports loaded correctly and that the related records still matched.
- **What I did:** Created the project dataset in BigQuery Sandbox and loaded the seven cleaned CSV files as tables. I checked the table fields and row counts, then used SQL to check unique keys, missing links, and whether monthly sales and target records matched on customer, product, sales channel, and month.
- **Key check:** All seven tables had the expected row counts and unique keys. The relationship checks found no unmatched records, and all 864 sales records matched a target at the same customer, product, channel, and month.
- **Output:** Validated BigQuery tables ready for analysis.
