/*
PROJECT: Pizza Sales Analysis
PURPOSE: Analyze revenue, orders, pizza demand, category/size performance,
         daily and monthly trends, and best/worst-selling pizzas.

DIALECT: MySQL 8.0+
SOURCE WORKBOOK: pizza sales project.xlsx
SOURCE DATA SHEET: pizza_sales
EXPECTED ROWS: approximately 48,620

BEFORE RUNNING
1. Import the `pizza_sales` sheet into MySQL as a table named `pizza_sales`.
2. Ensure `order_date` is a DATE column and `order_time` is a TIME column.
   If imported from Excel, convert Excel serial dates/times during import.
3. The workbook has a helper column named `Total_orders ` (with a trailing
   space in the original header). This script does not rely on that helper;
   it counts distinct order_id values instead.
4. If your imported column names differ, adjust them in the queries below.
*/

-- =========================================================
-- 1. CHECK THE IMPORTED DATA
-- =========================================================
SELECT *
FROM pizza_sales
LIMIT 10;

SELECT
    COUNT(*) AS total_order_lines,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT pizza_id) AS distinct_pizza_records,
    COUNT(DISTINCT pizza_name) AS distinct_pizza_names
FROM pizza_sales;

-- Check missing values in important columns.
SELECT
    SUM(pizza_id IS NULL) AS missing_pizza_id,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(quantity IS NULL) AS missing_quantity,
    SUM(total_price IS NULL) AS missing_total_price,
    SUM(pizza_name IS NULL) AS missing_pizza_name
FROM pizza_sales;

-- =========================================================
-- 2. KEY BUSINESS KPIs
-- =========================================================
SELECT
    ROUND(SUM(total_price), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS pizzas_sold,
    ROUND(SUM(total_price) / NULLIF(COUNT(DISTINCT order_id), 0), 2)
        AS average_order_value,
    ROUND(SUM(quantity) / NULLIF(COUNT(DISTINCT order_id), 0), 2)
        AS average_pizzas_per_order
FROM pizza_sales;

-- =========================================================
-- 3. REVENUE AND ORDERS BY DAY OF WEEK
-- =========================================================
SELECT
    DAYNAME(order_date) AS day_of_week,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM pizza_sales
GROUP BY DAYOFWEEK(order_date), DAYNAME(order_date)
ORDER BY DAYOFWEEK(order_date);

-- =========================================================
-- 4. MONTHLY SALES TREND
-- =========================================================
SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    DATE_FORMAT(order_date, '%Y-%m') AS year_month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS pizzas_sold,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM pizza_sales
GROUP BY YEAR(order_date), MONTH(order_date), DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_year, sales_month;

-- =========================================================
-- 5. SALES BY PIZZA CATEGORY
-- =========================================================
SELECT
    pizza_category,
    SUM(quantity) AS pizzas_sold,
    COUNT(DISTINCT order_id) AS orders_including_category,
    ROUND(SUM(total_price), 2) AS total_revenue,
    ROUND(
        100 * SUM(total_price) / NULLIF((SELECT SUM(total_price) FROM pizza_sales), 0),
        2
    ) AS revenue_percentage
FROM pizza_sales
GROUP BY pizza_category
ORDER BY total_revenue DESC;

-- =========================================================
-- 6. SALES BY PIZZA SIZE
-- =========================================================
SELECT
    pizza_Size AS pizza_size,
    SUM(quantity) AS pizzas_sold,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM pizza_sales
GROUP BY pizza_Size
ORDER BY total_revenue DESC;

-- =========================================================
-- 7. TOP 10 PIZZAS BY REVENUE
-- =========================================================
SELECT
    pizza_name,
    pizza_category,
    pizza_Size AS pizza_size,
    SUM(quantity) AS pizzas_sold,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM pizza_sales
GROUP BY pizza_name, pizza_category, pizza_Size
ORDER BY total_revenue DESC
LIMIT 10;

-- =========================================================
-- 8. TOP 10 PIZZAS BY QUANTITY SOLD
-- =========================================================
SELECT
    pizza_name,
    SUM(quantity) AS pizzas_sold,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY pizzas_sold DESC
LIMIT 10;

-- =========================================================
-- 9. BOTTOM 10 PIZZAS BY QUANTITY SOLD
-- =========================================================
SELECT
    pizza_name,
    SUM(quantity) AS pizzas_sold,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY pizzas_sold ASC, total_revenue ASC
LIMIT 10;

-- =========================================================
-- 10. REVENUE BY HOUR OF DAY
-- =========================================================
SELECT
    HOUR(order_time) AS order_hour,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM pizza_sales
GROUP BY HOUR(order_time)
ORDER BY order_hour;

-- =========================================================
-- 11. WEEKDAY / WEEKEND COMPARISON
-- =========================================================
SELECT
    CASE
        WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_group,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS pizzas_sold,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM pizza_sales
GROUP BY
    CASE
        WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END
ORDER BY total_revenue DESC;

-- =========================================================
-- 12. CATEGORY x SIZE PERFORMANCE
-- =========================================================
SELECT
    pizza_category,
    pizza_Size AS pizza_size,
    SUM(quantity) AS pizzas_sold,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM pizza_sales
GROUP BY pizza_category, pizza_Size
ORDER BY pizza_category, total_revenue DESC;

-- =========================================================
-- 13. CONDITIONAL AGGREGATION: REVENUE BY CATEGORY
-- =========================================================
SELECT
    ROUND(SUM(CASE WHEN pizza_category = 'Classic' THEN total_price ELSE 0 END), 2)
        AS classic_revenue,
    ROUND(SUM(CASE WHEN pizza_category = 'Chicken' THEN total_price ELSE 0 END), 2)
        AS chicken_revenue,
    ROUND(SUM(CASE WHEN pizza_category = 'Supreme' THEN total_price ELSE 0 END), 2)
        AS supreme_revenue,
    ROUND(SUM(CASE WHEN pizza_category = 'Veggie' THEN total_price ELSE 0 END), 2)
        AS veggie_revenue
FROM pizza_sales;

-- =========================================================
-- 14. RANK PIZZAS BY REVENUE (WINDOW FUNCTION)
-- =========================================================
WITH pizza_revenue AS (
    SELECT
        pizza_name,
        SUM(quantity) AS pizzas_sold,
        SUM(total_price) AS total_revenue
    FROM pizza_sales
    GROUP BY pizza_name
)
SELECT
    pizza_name,
    pizzas_sold,
    ROUND(total_revenue, 2) AS total_revenue,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM pizza_revenue
ORDER BY revenue_rank, pizza_name;

-- =========================================================
-- 15. DAILY KPI SUMMARY (USEFUL FOR DASHBOARD VALIDATION)
-- =========================================================
SELECT
    order_date,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS pizzas_sold,
    ROUND(SUM(total_price), 2) AS total_revenue,
    ROUND(SUM(total_price) / NULLIF(COUNT(DISTINCT order_id), 0), 2)
        AS average_order_value
FROM pizza_sales
GROUP BY order_date
ORDER BY order_date;

-- =========================================================
-- END OF PROJECT QUERIES
-- =========================================================
