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
