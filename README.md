# E-Commerce Sales & Customer Analytics

An end-to-end e-commerce analytics project covering **data cleaning, exploratory analysis, customer analytics, SQL business analysis, and interactive Tableau dashboards**.

The project follows a realistic analytics workflow:

**Raw CSV data → Python cleaning & EDA → MySQL data model → SQL analysis → Tableau dashboards → Business insights**

---

## Dashboard

### Tableau Public

**E-Commerce Sales & Customer Analytics**  
https://public.tableau.com/app/profile/dhruv.singh4740/viz/ECommerceSalesCustomerAnalytics/ExecutiveOverview

The Tableau workbook contains three connected dashboards:

1. **Executive Overview** — sales, profitability, orders, AOV, returns, monthly trends, categories and channels
2. **Customer & Product Analytics** — one-time vs repeat customers, customer revenue distribution, top products, category margins and product profitability
3. **Marketing & Returns** — marketing spend, conversion rate, monthly spend, return reasons, category return rates and return-reason patterns

---

## Business Objective

Analyze e-commerce performance across **sales, customers, products, marketing and returns** to answer questions such as:

- How much revenue and profit is being generated?
- How are sales and profit changing over time?
- Which categories, products and channels contribute the most revenue and profit?
- How large is the repeat-customer base?
- How is customer revenue distributed?
- Which products generate high revenue but comparatively lower margins?
- What are the most common return reasons?
- How do return rates vary by category?
- How are marketing channels performing in terms of spend and conversion rate?

---

## Key KPIs

| KPI | Result |
|---|---:|
| Revenue | ₹295.49M |
| Profit | ₹130.32M |
| Profit Margin | 44.10% |
| Delivered Orders | 17,440 |
| Units Sold | 47,365 |
| Unique Customers | 4,861 |
| Average Order Value | ₹16,943.39 |
| Return Rate | 9.00% |

**Profit definition:** revenue less product cost. It does not represent operating or net profit after overheads.

---

## Key Findings

### Sales & profitability

- **Electronics** is the largest category, generating approximately **₹194.53M revenue** and **₹85.65M profit**.
- Monthly sales and profit fluctuate across the 2024–2025 period, with **May 2025** representing the strongest month in the analysis.
- Overall margins remain relatively stable around the mid-40% range, making revenue volume and order value important drivers of monthly performance.

### Products

- **Monitor 20006** is the highest-revenue product in the analysis, while not being the highest-profit product.
- Several products combine high revenue with comparatively lower margins, making product-level profitability important rather than relying on revenue rankings alone.

### Customers

- The delivered-order customer base contains **4,861 unique customers**.
- **4,323** customers are classified as repeat customers and **538** as one-time customers in the customer analysis.
- Customer revenue is highly concentrated toward lower-value customer bands, with progressively fewer customers at higher revenue levels.

### Channels

- **Organic** is the largest sales channel by revenue and profit among the recorded sales channels.
- Sales-channel profit margins are relatively close to one another, so volume contributes substantially to differences in channel revenue and profit.

### Returns

- Overall return rate is approximately **9.00%**.
- **Size Issue** is the most common return reason with **481 returns**, followed by **Quality Issue** with **407**.
- Size and quality issues together account for **56.60%** of recorded returns.
- Category return rates are tightly grouped, ranging from approximately **8.86% to 9.07%**.

### Marketing

Marketing data is analyzed independently using spend, impressions, clicks and conversions. The dataset does **not contain a customer/order attribution key connecting marketing conversions to individual sales orders**, so marketing conversion metrics should not be interpreted as directly attributed sales revenue.

---

## Data

The project contains seven source tables:

| Table | Description |
|---|---|
| `customers` | Customer demographics, location, signup date and segment |
| `orders` | Order dates, customer IDs, sales channels and order status |
| `order_items` | Product-level order quantities, prices, discounts and costs |
| `products` | Product catalog, category, subcategory, price and cost |
| `payments` | Payment method, amount and payment status |
| `returns` | Returned orders, reasons, refund status and refund amount |
| `marketing` | Monthly campaign/channel spend, impressions, clicks and conversions |

### Dataset size

- Customers: **5,000**
- Orders: **18,000**
- Order items: **35,427**
- Products: **250**
- Payments: **18,000**
- Returns: **1,569**
- Marketing records: **168**
- Analytical sales fact table: **34,356 delivered order-item rows**

The raw and processed datasets are included in the repository.

---

## Data Cleaning & Preparation

Python was used for data understanding, cleaning, validation and analytical preparation.

Key preparation steps included:

- Parsing date fields with error handling
- Handling missing demographic and categorical values
- Imputing the missing product price using a same-subcategory markup-based approach
- Inferring a missing order-item quantity from the transaction values
- Checking referential integrity across customers, orders, order items, products, payments and returns
- Validating quantities, prices, costs and discount values
- Separating delivered orders for sales-performance analysis
- Building `sales_analysis.csv` as the curated analytical fact table
- Calculating revenue, profit and profit margin at the transaction level

For sales analysis:

```text
Revenue = Gross Amount - Discount Amount
Profit  = Revenue - (Quantity × Unit Cost)
Margin  = Profit / Revenue
```

Historical transaction-level `order_items.unit_price` values are retained as the source of truth where they differ from current catalog prices.

---

## SQL Analysis

The MySQL layer is organized into five analysis scripts:

### `01_schema.sql`

Creates the relational data model and performs initial table-level validation.

### `02_cleaning.sql`

Performs data-quality checks including:

- orphan records
- null checks
- invalid quantities/prices/costs
- invalid discounts
- status validation

### `03_kpis.sql`

Calculates:

- revenue
- profit
- delivered orders
- units sold
- unique customers
- AOV
- profit margin
- monthly performance
- category/subcategory performance
- product rankings
- channel performance
- returns
- marketing channel metrics

### `04_customer_analysis.sql`

Covers:

- one-time vs repeat customers
- customer value distribution
- top customers by revenue and profit
- order frequency
- RFM base table
- RFM segmentation
- customer activity status

### `05_advanced_analysis.sql`

Covers:

- monthly revenue growth
- revenue vs profit by product
- high-revenue/low-margin products
- repeat-customer rate
- discount impact
- payment vs order status
- order-status summary
- channel revenue share
- category profitability
- return analysis

---

## Tableau Dashboard Structure

### 1. Executive Overview

<img width="2408" height="1600" alt="image" src="https://github.com/user-attachments/assets/6b505a5f-cd49-481d-8428-584fbaa74519" />

Provides the high-level business view with KPI cards, monthly sales/profit trends, category performance and channel performance.

### 2. Customer & Product Analytics

<img width="2412" height="1602" alt="image" src="https://github.com/user-attachments/assets/f0517113-84bf-450c-943c-57aa74fddcec" />

Focuses on customer composition, customer value distribution, top products, category profitability and product-level revenue vs profit.

### 3. Marketing & Returns

<img width="2402" height="1608" alt="image" src="https://github.com/user-attachments/assets/c6e39230-0ae2-4f78-9071-6807de5f9879" />

Combines marketing-channel performance with return reasons, category return rates and a return-reason/category heatmap.

---

## Project Structure

```text
E-Commerce-Sales-Customer-Analytics/
│
├── data/
│   ├── raw/
│   │   ├── customers.csv
│   │   ├── orders.csv
│   │   ├── order_items.csv
│   │   ├── products.csv
│   │   ├── payments.csv
│   │   ├── returns.csv
│   │   └── marketing.csv
│   │
│   └── processed/
│       ├── customers.csv
│       ├── orders.csv
│       ├── order_items.csv
│       ├── products.csv
│       ├── payments.csv
│       ├── returns.csv
│       ├── marketing.csv
│       ├── sales_analysis.csv
│       └── customer_analysis.csv
│
├── Python/
│   ├── 01_data_exploration_cleaning.ipynb
│   ├── 02_eda.ipynb
│   └── 03_customer_analysis.ipynb
│
├── SQL/
│   ├── 01_schema.sql
│   ├── 02_cleaning.sql
│   ├── 03_kpis.sql
│   ├── 04_customer_analysis.sql
│   └── 05_advanced_analysis.sql
│
├── database/
│   └── ecommerce_analytics.sql
│
├── tableau/
│   └── E-Commerce-Sales-Customer-Analytics.twbx
│
├── screenshots/
│   ├── executive-overview.png
│   ├── customer-product-analytics.png
│   └── marketing-returns.png
│
├── .gitignore
├── requirements.txt
└── README.md
```

---

## How to Reproduce

### 1. Python analysis

Create a virtual environment and install the Python dependencies:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Open the notebooks in the `Python/` directory and run them in sequence.

### 2. MySQL

Create the database and import the included dump:

```sql
CREATE DATABASE ecommerce_analytics;
```

Then import:

```bash
mysql -u root -p ecommerce_analytics < database/ecommerce_analytics.sql
```

The SQL scripts in `SQL/` can then be reviewed or executed against the database.

### 3. Tableau

Open the packaged Tableau workbook:

```text
tableau/E-Commerce-Sales-Customer-Analytics.twbx
```

The workbook contains the three completed dashboards and navigation between them.

---

## Tools & Technologies

- **Python** — pandas, NumPy, Matplotlib
- **MySQL** — relational data model and analytical SQL
- **Tableau Public** — interactive dashboards and data visualization
- **Jupyter Notebook** — analysis workflow
- **Git/GitHub** — project versioning and portfolio presentation

---

## Analytical Notes & Limitations

- Profit is defined as revenue minus product cost and should not be interpreted as net operating profit.
- Marketing conversions are not directly attributable to individual orders because no order/customer attribution key exists in the marketing data.
- Category-level order counts can overlap when a single order contains products from multiple categories.
- RFM segmentation uses the SQL implementation provided in `04_customer_analysis.sql`; SQL and Python segmentation methods may differ because of their respective ranking/binning approaches.

---

## Author

**Dhruv Singh**  
Data Analytics | SQL | Python | Power BI | Tableau

---

## Project Status

**Completed** — Python analysis, MySQL database, SQL analytics and Tableau dashboards are included.
