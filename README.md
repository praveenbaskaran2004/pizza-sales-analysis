# Pizza Sales Analysis — Excel + SQL

## Project overview
This project analyzes pizza sales to understand revenue, order volume, product demand, and sales patterns. The Excel workbook contains a KPI sheet, trends, category percentages, best/worst sellers, the source data, and a dashboard.

## Tools
- Microsoft Excel: KPI reporting, pivot-table analysis, trends, and dashboard
- MySQL 8.0+: SQL-based data exploration and business analysis

## Questions answered
- What are total revenue, total orders, pizzas sold, average order value, and average pizzas per order?
- Which weekdays and months have the strongest sales?
- Which pizza categories and sizes contribute the most revenue?
- Which pizzas are the best and worst sellers?
- At what hours are orders most common?
- How do categories perform across pizza sizes?

## Files
- `pizza_sales_analysis.sql` — SQL queries for data checks, KPIs, trend analysis, category/size analysis, product rankings, conditional aggregation, and window functions.
- `pizza sales project.xlsx` — Excel analysis and dashboard workbook (upload this workbook to your repository as well).

## Run the SQL script
1. Create a database in MySQL Workbench.
2. Import the `pizza_sales` worksheet into a table named `pizza_sales`.
3. Check the imported column names and data types. Use `DATE` for `order_date` and `TIME` for `order_time`.
4. Open `pizza_sales_analysis.sql` in MySQL Workbench and run the sections one by one.

**Data note:** The workbook contains a helper column named `Total_orders ` (with a trailing space). The SQL script calculates orders using `COUNT(DISTINCT order_id)` rather than relying on that helper column. Date/time values should be converted to MySQL date/time types during import if they are stored as Excel serial numbers.

## Portfolio description
Built an end-to-end pizza sales analysis project using Excel and MySQL. Created KPI reporting and dashboard views, then wrote SQL queries to analyze revenue, order volume, product performance, category and size contribution, daily/monthly trends, and peak ordering hours. Applied aggregation, conditional aggregation, CTEs, and window functions to turn transaction-level data into business insights.

## Suggested repository structure
```text
pizza-sales-analysis/
├── README.md
├── pizza_sales_analysis.sql
└── pizza sales project.xlsx
```

## LinkedIn project skills
SQL · MySQL · Microsoft Excel · Data Analysis · KPI Reporting · Pivot Tables · Data Visualization · Business Intelligence
