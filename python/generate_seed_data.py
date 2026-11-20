# confirm that NumPy and pandas work in the current Python setup
from pathlib import Path

import numpy as np
import pandas as pd

SEED = 2026
rng = np.random.default_rng(SEED)

OUTPUT_DIR = Path("seed_csvs")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

print(f"NumPy: {np.__version__}")
print(f"pandas: {pd.__version__}")
print(f"Random seed: {SEED}")
print(f"Seed CSV folder: {OUTPUT_DIR.resolve()}")

# Core Salesforce seed records
# creates small import files with stable source keys.

customer_names = [
    "Luzon Neighborhood Grocer",
    "Mindanao Community Retailer",
    "Luzon Foodservice Supplier",
    "Mindanao Regional Markets",
    "Visayas Foodservice Group",
    "Visayas Grocery Network",
]

customers = pd.DataFrame({
    "Customer Source Key": [f"CUST_{i:03d}" for i in range(1, 7)],
    "Account Name": customer_names,
    "Customer Segment": rng.permutation([
        "Independent Retail",
        "Independent Retail",
        "Regional Chain",
        "Regional Chain",
        "Foodservice",
        "Foodservice",
    ]),
    "Region": rng.permutation([
        "Luzon", "Luzon",
        "Visayas", "Visayas",
        "Mindanao", "Mindanao",
    ]),
})

products = pd.DataFrame([
    {
        "Product Source Key": "PROD_001",
        "Product Name": "Sunvale Long-Grain Rice 25 kg",
        "Product Code": "SKU-001",
        "Product Category": "Staples",
        "Brand": "Sunvale",
        "Unit of Measure": "Sack",
        "Active": True,
    },
    {
        "Product Source Key": "PROD_002",
        "Product Name": "Clearbrook Dishwashing Liquid 1 L",
        "Product Code": "SKU-002",
        "Product Category": "Household Cleaning",
        "Brand": "Clearbrook",
        "Unit of Measure": "Bottle",
        "Active": True,
    },
    {
        "Product Source Key": "PROD_003",
        "Product Name": "Daycrest Shampoo 400 mL",
        "Product Code": "SKU-003",
        "Product Category": "Personal Care",
        "Brand": "Daycrest",
        "Unit of Measure": "Bottle",
        "Active": True,
    },
])

sales_channels = pd.DataFrame([
    {
        "Channel Source Key": "CHN_001",
        "Sales Channel Name": "Sari-sari & Neighborhood Retail",
        "Channel Group": "Traditional Trade",
    },
    {
        "Channel Source Key": "CHN_002",
        "Sales Channel Name": "Supermarket & Grocery Chains",
        "Channel Group": "Modern Trade",
    },
])

seed_files = [
    ("customers_seed_for_salesforce.csv", customers),
    ("products_seed_for_salesforce.csv", products),
    ("sales_channels_seed_for_salesforce.csv", sales_channels),
]

for filename, dataframe in seed_files:
    output_path = OUTPUT_DIR / filename
    dataframe.to_csv(output_path, index=False)
    print(f"Saved {filename}: {len(dataframe)} rows")

print("\nCustomer records:")
print(customers.to_string(index=False))
print("\nProduct records:")
print(products.to_string(index=False))
print("\nSales channel records:")
print(sales_channels.to_string(index=False))


# reads the Salesforce exports, matches them to the seed records by source key, and saves crosswalks containing the real Salesforce IDs

RAW_DIR = Path.cwd().parent / "02_Salesforce_Exports_Raw"
CROSSWALK_DIR = OUTPUT_DIR / "salesforce_id_crosswalks"
CROSSWALK_DIR.mkdir(parents=True, exist_ok=True)

sf_accounts = pd.read_csv(RAW_DIR / "accounts_raw.csv", dtype=str)
sf_products = pd.read_csv(RAW_DIR / "products_raw.csv", dtype=str)
sf_channels = pd.read_csv(RAW_DIR / "sales_channels_raw.csv", dtype=str)

account_lookup = sf_accounts[
    ["Customer_Source_Key__c", "Id"]
].rename(columns={
    "Customer_Source_Key__c": "Customer Source Key",
    "Id": "Account Salesforce ID",
})

product_lookup = sf_products[
    ["Product_Source_Key__c", "Id"]
].rename(columns={
    "Product_Source_Key__c": "Product Source Key",
    "Id": "Product Salesforce ID",
})

channel_lookup = sf_channels[
    ["Channel_Source_Key__c", "Id"]
].rename(columns={
    "Channel_Source_Key__c": "Channel Source Key",
    "Id": "Sales Channel Salesforce ID",
})

account_crosswalk = customers.merge(
    account_lookup, on="Customer Source Key",
    how="left", validate="one_to_one", indicator=True
)
product_crosswalk = products.merge(
    product_lookup, on="Product Source Key",
    how="left", validate="one_to_one", indicator=True
)
channel_crosswalk = sales_channels.merge(
    channel_lookup, on="Channel Source Key",
    how="left", validate="one_to_one", indicator=True
)

crosswalks = [
    ("Accounts", account_crosswalk, 6),
    ("Products", product_crosswalk, 3),
    ("Sales Channels", channel_crosswalk, 2),
]

for label, dataframe, expected_rows in crosswalks:
    matched = int((dataframe["_merge"] == "both").sum())
    missing_ids = int(dataframe.filter(like="Salesforce ID").isna().any(axis=1).sum())
    print(f"{label}: {matched}/{expected_rows} matched; missing ID rows: {missing_ids}")
    if matched != expected_rows or missing_ids:
        raise ValueError(f"{label} crosswalk did not match all expected Salesforce records.")

account_crosswalk[
    ["Customer Source Key", "Account Salesforce ID", "Account Name"]
].to_csv(CROSSWALK_DIR / "customers_salesforce_crosswalk.csv", index=False)

product_crosswalk[
    ["Product Source Key", "Product Salesforce ID", "Product Name", "Product Code"]
].to_csv(CROSSWALK_DIR / "products_salesforce_crosswalk.csv", index=False)

channel_crosswalk[
    ["Channel Source Key", "Sales Channel Salesforce ID", "Sales Channel Name", "Channel Group"]
].to_csv(CROSSWALK_DIR / "sales_channels_salesforce_crosswalk.csv", index=False)

# pick 24 distinct Product–Channel–Month combinations and use the Salesforce IDs from the crosswalks

# Create 24 monthly promotion records

months = pd.date_range("2024-01-01", periods=24, freq="MS")

promotion_candidates = pd.DataFrame([
    {
        "Product Source Key": product_key,
        "Channel Source Key": channel_key,
        "Promotion Month": month,
    }
    for product_key in products["Product Source Key"]
    for channel_key in sales_channels["Channel Source Key"]
    for month in months
])

selected_indices = rng.choice(
    promotion_candidates.index.to_numpy(),
    size=24,
    replace=False,
)

promotions = (
    promotion_candidates.loc[selected_indices]
    .sort_values(["Promotion Month", "Product Source Key", "Channel Source Key"])
    .reset_index(drop=True)
)

product_id_lookup = product_crosswalk.set_index(
    "Product Source Key"
)["Product Salesforce ID"]

channel_id_lookup = channel_crosswalk.set_index(
    "Channel Source Key"
)["Sales Channel Salesforce ID"]

promotions["Promotion_Source_Key__c"] = [
    f"PROMO_{i:03d}" for i in range(1, 25)
]

PH_PROMOTION_OCCASIONS = {
    1: "New Year Stock-Up",
    2: "Household Replenishment",
    3: "Household Replenishment",
    4: "Summer Essentials",
    5: "Summer Essentials",
    6: "Midyear Household Stock-Up",
    7: "Midyear Household Stock-Up",
    8: "Midyear Household Stock-Up",
    9: "Household Value Offer",
    10: "Household Value Offer",
    11: "Year-End Stock-Up",
    12: "Holiday Stock-Up",
}

promotions["Name"] = [
    f"Philippines {PH_PROMOTION_OCCASIONS[month.month]} - {promo_key}"
    for month, promo_key in zip(
        promotions["Promotion Month"],
        promotions["Promotion_Source_Key__c"],
    )
]
promotions["Product__c"] = promotions["Product Source Key"].map(product_id_lookup)
promotions["Sales_Channel__c"] = promotions["Channel Source Key"].map(channel_id_lookup)

promotions["Start_Date__c"] = promotions["Promotion Month"].dt.strftime("%Y-%m-%d")
promotions["End_Date__c"] = (
    promotions["Promotion Month"] + pd.offsets.MonthEnd(0)
).dt.strftime("%Y-%m-%d")

promotions["Promotion_Type__c"] = rng.choice(
    ["Price Reduction", "Bundle Offer", "Display Support", "Seasonal Promotion"],
    size=24,
)

# Salesforce Percent fields use fractions: 0.15 represents 15%.
promotions["Planned_Discount__c"] = rng.choice(
    [0.05, 0.08, 0.10, 0.12, 0.15, 0.18, 0.20],
    size=24,
)

promotion_import = promotions[
    [
        "Name",
        "Promotion_Source_Key__c",
        "Product__c",
        "Sales_Channel__c",
        "Start_Date__c",
        "End_Date__c",
        "Promotion_Type__c",
        "Planned_Discount__c",
    ]
]

sf_promotions = pd.read_csv(
    RAW_DIR / "promotions_raw.csv",
    dtype=str,
)[["Id", "Promotion_Source_Key__c"]]

promotion_update = promotion_import.merge(
    sf_promotions,
    on="Promotion_Source_Key__c",
    how="left",
    validate="one_to_one",
)

if len(promotion_update) != 24 or promotion_update["Id"].isna().any():
    raise ValueError("Promotion IDs did not match all 24 existing Salesforce records.")

update_path = OUTPUT_DIR / "promotions_name_update.csv"
promotion_update[["Id", "Name"]].to_csv(update_path, index=False)

print(f"Promotion name updates: {len(promotion_update)}")
print(f"Rows missing Salesforce IDs: {promotion_update['Id'].isna().sum()}")
print(f"Saved temporary update file: {update_path}")

promotion_import.to_csv(
    OUTPUT_DIR / "promotions_seed_for_salesforce.csv",
    index=False,
)

print(f"Promotion rows: {len(promotion_import)}")
print(f"Unique promotion keys: {promotion_import['Promotion_Source_Key__c'].nunique()}")
print(f"Rows missing Product ID: {promotion_import['Product__c'].isna().sum()}")
print(f"Rows missing Channel ID: {promotion_import['Sales_Channel__c'].isna().sum()}")
print(promotion_import.head(5).to_string(index=False))

# generate the Monthly Sales Actuals seed file

# Monthly Sales Actuals seed file
# One row per customer, product, channel, and month.
# All monetary values are synthetic Philippine peso amounts.

sf_promotions_for_actuals = pd.read_csv(
    RAW_DIR / "promotions_raw.csv",
    dtype=str,
)

sf_promotions_for_actuals["Promotion Month"] = (
    pd.to_datetime(sf_promotions_for_actuals["Start_Date__c"])
    .dt.to_period("M")
)

promotion_lookup = {}
for promo in sf_promotions_for_actuals.to_dict("records"):
    key = (
        promo["Product__c"],
        promo["Sales_Channel__c"],
        promo["Promotion Month"],
    )
    promotion_lookup[key] = promo

account_id_lookup = account_crosswalk.set_index(
    "Customer Source Key"
)["Account Salesforce ID"]

product_id_lookup = product_crosswalk.set_index(
    "Product Source Key"
)["Product Salesforce ID"]

channel_id_lookup = channel_crosswalk.set_index(
    "Channel Source Key"
)["Sales Channel Salesforce ID"]

base_units_by_product = {
    "PROD_001": 35,   # 25 kg rice sacks
    "PROD_002": 80,   # 1 L dishwashing liquid bottles
    "PROD_003": 65,   # 400 mL shampoo bottles
}

unit_price_php = {
    "PROD_001": 1450.00,
    "PROD_002": 95.00,
    "PROD_003": 165.00,
}

unit_cost_php = {
    "PROD_001": 1175.00,
    "PROD_002": 70.00,
    "PROD_003": 120.00,
}

segment_factor = {
    "Independent Retail": 0.8,
    "Regional Chain": 1.4,
    "Foodservice": 1.0,
}

channel_factor = {
    "Traditional Trade": 0.9,
    "Modern Trade": 1.2,
}

# Synthetic scenario pattern; these are not measured market estimates.
month_factor = {
    1: 1.05, 2: 0.98, 3: 1.00, 4: 1.04,
    5: 1.07, 6: 1.03, 7: 1.00, 8: 0.98,
    9: 1.00, 10: 1.03, 11: 1.10, 12: 1.18,
}

actual_rows = []

for customer in customers.to_dict("records"):
    customer_key = customer["Customer Source Key"]
    customer_id = account_id_lookup[customer_key]

    for product in products.to_dict("records"):
        product_key = product["Product Source Key"]
        product_id = product_id_lookup[product_key]

        for channel in sales_channels.to_dict("records"):
            channel_key = channel["Channel Source Key"]
            channel_id = channel_id_lookup[channel_key]

            for month in months:
                month_period = month.to_period("M")
                promotion = promotion_lookup.get(
                    (product_id, channel_id, month_period)
                )

                expected_units = (
                    base_units_by_product[product_key]
                    * segment_factor[customer["Customer Segment"]]
                    * channel_factor[channel["Channel Group"]]
                    * month_factor[month.month]
                )
                units_sold = max(1, int(rng.poisson(expected_units)))

                annual_factor = 1.0 + 0.02 * (month.year - 2024)
                gross_sales = round(
                    units_sold * unit_price_php[product_key] * annual_factor,
                    2,
                )
                cost_of_goods_sold = round(
                    units_sold * unit_cost_php[product_key] * annual_factor,
                    2,
                )

                if promotion is not None:
                    planned_rate = float(promotion["Planned_Discount__c"])
                    discount_rate = planned_rate * rng.uniform(0.80, 1.00)
                    promotion_id = promotion["Id"]
                else:
                    discount_rate = float(rng.choice([0.00, 0.01, 0.02]))
                    promotion_id = ""

                discount_amount = round(gross_sales * discount_rate, 2)

                actual_rows.append({
                    "Sales_Actual_Source_Key__c":
                        f"ACT_{customer_key}_{product_key}_{channel_key}_{month:%Y%m}",
                    "Sales_Month__c": month.strftime("%Y-%m-%d"),
                    "Customer__c": customer_id,
                    "Product__c": product_id,
                    "Sales_Channel__c": channel_id,
                    "Promotion__c": promotion_id,
                    "Units_Sold__c": units_sold,
                    "Gross_Sales__c": gross_sales,
                    "Discount_Amount__c": discount_amount,
                    "Cost_of_Goods_Sold__c": cost_of_goods_sold,
                })

monthly_sales_actuals = pd.DataFrame(actual_rows)

if len(monthly_sales_actuals) != 864:
    raise ValueError(f"Expected 864 actual rows; found {len(monthly_sales_actuals)}.")

if monthly_sales_actuals["Sales_Actual_Source_Key__c"].nunique() != 864:
    raise ValueError("Monthly Sales Actual source keys are not unique.")

core_lookup_fields = ["Customer__c", "Product__c", "Sales_Channel__c"]
missing_core_ids = int(monthly_sales_actuals[core_lookup_fields].isna().any(axis=1).sum())

if missing_core_ids:
    raise ValueError(f"Found {missing_core_ids} rows missing a core Salesforce ID.")

actuals_path = OUTPUT_DIR / "monthly_sales_actuals_seed_for_salesforce.csv"
monthly_sales_actuals.to_csv(actuals_path, index=False)

print(f"Monthly Sales Actual rows: {len(monthly_sales_actuals)}")
print(f"Unique source keys: {monthly_sales_actuals['Sales_Actual_Source_Key__c'].nunique()}")
print(f"Rows missing core Salesforce IDs: {missing_core_ids}")
print(f"Promotion-linked rows: {monthly_sales_actuals['Promotion__c'].ne('').sum()}")
print(f"Saved {actuals_path}")

# Monthly Sales Targets seed file
# Targets are generated from planning assumptions, independently of actual results.

target_rows = []

for customer in customers.to_dict("records"):
    customer_key = customer["Customer Source Key"]
    customer_id = account_id_lookup[customer_key]

    for product in products.to_dict("records"):
        product_key = product["Product Source Key"]
        product_id = product_id_lookup[product_key]

        for channel in sales_channels.to_dict("records"):
            channel_key = channel["Channel Source Key"]
            channel_id = channel_id_lookup[channel_key]

            for month in months:
                expected_units = (
                    base_units_by_product[product_key]
                    * segment_factor[customer["Customer Segment"]]
                    * channel_factor[channel["Channel Group"]]
                    * month_factor[month.month]
                )

                annual_factor = 1.0 + 0.02 * (month.year - 2024)
                planning_factor = rng.uniform(0.96, 1.12)

                target_net_sales = (
                    expected_units
                    * unit_price_php[product_key]
                    * annual_factor
                    * planning_factor
                )

                # Round planned amounts to a practical PHP increment.
                target_net_sales = round(target_net_sales / 10) * 10

                target_rows.append({
                    "Target_Source_Key__c":
                        f"TGT_{customer_key}_{product_key}_{channel_key}_{month:%Y%m}",
                    "Target_Month__c": month.strftime("%Y-%m-%d"),
                    "Customer__c": customer_id,
                    "Product__c": product_id,
                    "Sales_Channel__c": channel_id,
                    "Target_Net_Sales__c": target_net_sales,
                })

monthly_sales_targets = pd.DataFrame(target_rows)

if len(monthly_sales_targets) != 864:
    raise ValueError(f"Expected 864 target rows; found {len(monthly_sales_targets)}.")

if monthly_sales_targets["Target_Source_Key__c"].nunique() != 864:
    raise ValueError("Monthly Sales Target source keys are not unique.")

target_lookup_fields = ["Customer__c", "Product__c", "Sales_Channel__c"]
missing_target_ids = int(
    monthly_sales_targets[target_lookup_fields].isna().any(axis=1).sum()
)

if missing_target_ids:
    raise ValueError(f"Found {missing_target_ids} rows missing a Salesforce lookup ID.")

targets_path = OUTPUT_DIR / "monthly_sales_targets_seed_for_salesforce.csv"
monthly_sales_targets.to_csv(targets_path, index=False)

print(f"Monthly Sales Target rows: {len(monthly_sales_targets)}")
print(f"Unique target source keys: {monthly_sales_targets['Target_Source_Key__c'].nunique()}")
print(f"Rows missing Salesforce lookup IDs: {missing_target_ids}")
print(f"Saved {targets_path}")

# Competitor Price Observations seed file
# Synthetic Philippine peso prices, comparable to each product's unit of measure.

competitors = [
    ("COMP_001", "Synthetic PH Competitor A", 0.98),
    ("COMP_002", "Synthetic PH Competitor B", 1.04),
]

competitor_channel_factor = {
    "Traditional Trade": 1.00,
    "Modern Trade": 1.02,
}

competitor_rows = []

for competitor_key, competitor_name, competitor_factor in competitors:
    for product in products.to_dict("records"):
        product_key = product["Product Source Key"]

        for channel in sales_channels.to_dict("records"):
            channel_key = channel["Channel Source Key"]
            channel_id = channel_id_lookup[channel_key]

            for month in months:
                product_id = product_id_lookup[product_key]
                annual_factor = 1.0 + 0.02 * (month.year - 2024)
                market_variation = max(0.90, rng.normal(1.0, 0.025))

                competitor_price = (
                    unit_price_php[product_key]
                    * competitor_factor
                    * competitor_channel_factor[channel["Channel Group"]]
                    * annual_factor
                    * market_variation
                )

                competitor_rows.append({
                    "Observation_Source_Key__c":
                        f"OBS_{competitor_key}_{product_key}_{channel_key}_{month:%Y%m}",
                    "Competitor_Key__c": competitor_key,
                    "Competitor_Name__c": competitor_name,
                    "Price_Month__c": month.strftime("%Y-%m-%d"),
                    "Competitor_Unit_Price__c": round(competitor_price, 2),
                    "Product__c": product_id,
                    "Sales_Channel__c": channel_id,
                })

competitor_prices = pd.DataFrame(competitor_rows)

# Controlled source-data variation for the later profiling stage.
# Keep source keys and Salesforce lookup IDs unchanged.
quality_rng = np.random.default_rng(SEED + 901)
quality_order = quality_rng.permutation(competitor_prices.index.to_numpy())

name_rows = quality_order[:6]
date_rows = quality_order[6:14]
price_rows = quality_order[14:18]

for index in name_rows[:3]:
    competitor_prices.loc[index, "Competitor_Name__c"] = (
        " " + competitor_prices.loc[index, "Competitor_Name__c"].lower() + " "
    )

for index in name_rows[3:]:
    competitor_prices.loc[index, "Competitor_Name__c"] = (
        competitor_prices.loc[index, "Competitor_Name__c"] + " - PH"
    )

price_months = pd.to_datetime(competitor_prices["Price_Month__c"])
price_months.loc[date_rows] = price_months.loc[date_rows] + pd.Timedelta(days=14)
competitor_prices["Price_Month__c"] = price_months.dt.strftime("%Y-%m-%d")

competitor_prices.loc[price_rows[:3], "Competitor_Unit_Price__c"] = np.nan

competitor_prices.loc[price_rows[3], "Competitor_Unit_Price__c"] = (
    competitor_prices.loc[price_rows[3], "Competitor_Unit_Price__c"] * 8
)

#validation checks
if len(competitor_prices) != 288:
    raise ValueError(f"Expected 288 competitor price rows; found {len(competitor_prices)}.")

if competitor_prices["Observation_Source_Key__c"].nunique() != 288:
    raise ValueError("Competitor observation source keys are not unique.")

competitor_lookup_fields = ["Product__c", "Sales_Channel__c"]
missing_competitor_ids = int(
    competitor_prices[competitor_lookup_fields].isna().any(axis=1).sum()
)

if missing_competitor_ids:
    raise ValueError(
        f"Found {missing_competitor_ids} rows missing a Salesforce lookup ID."
    )

if (competitor_prices["Competitor_Unit_Price__c"] <= 0).any():
    raise ValueError("Found a non-positive competitor unit price.")

competitor_path = OUTPUT_DIR / "competitor_price_observations_seed_for_salesforce.csv"
competitor_prices.to_csv(competitor_path, index=False)

print(f"Competitor Price Observation rows: {len(competitor_prices)}")
print(
    "Unique observation source keys: "
    f"{competitor_prices['Observation_Source_Key__c'].nunique()}"
)
print(f"Rows missing Salesforce lookup IDs: {missing_competitor_ids}")
print(
    "Non-positive competitor prices: "
    f"{(competitor_prices['Competitor_Unit_Price__c'] <= 0).sum()}"
)
print(f"Saved {competitor_path}")