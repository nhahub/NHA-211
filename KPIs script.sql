use graduationdepi;
select * from sales;


-- 1. TOTAL SALES REVENUE -------------------------------------------------------------------------------------------------------------------------------------------------
-- How much money did the company make from selling all its products?
SELECT SUM(selling_price_per_unit * quantity) AS total_sales_revenue
FROM sales;

-- 2. TOTAL PROFIT --------------------------------------------------------------------------------------------------------------------------------------------------------
-- How much money did we keep after product costs?
SELECT SUM((selling_price_per_unit - cost_price_per_unit) * quantity) AS total_profit
FROM sales;

-- # PROFIT BY CATEGORY # -- 
SELECT
    category,
    SUM((selling_price_per_unit - cost_price_per_unit) * quantity) AS total_profit
FROM sales
GROUP BY category
ORDER BY total_profit DESC;

-- 3. GROSS PROFIT MARGIN --------------------------------------------------------------------------------------------------------------------------------------------------
-- Are we pricing our products well?
SELECT
    SUM((selling_price_per_unit - cost_price_per_unit) * quantity) AS total_profit,
    SUM(selling_price_per_unit * quantity) AS total_revenue,
    ROUND(
        (SUM((selling_price_per_unit - cost_price_per_unit) * quantity)
        / SUM(selling_price_per_unit * quantity)) * 100, 2
    ) AS gross_profit_margin_percent
FROM sales;

-- # margin by category # --
SELECT
    category,
    ROUND(
      (SUM((selling_price_per_unit - cost_price_per_unit) * quantity)
      / SUM(selling_price_per_unit * quantity)) * 100, 2
    ) AS profit_margin_percent
FROM sales
GROUP BY category
ORDER BY profit_margin_percent DESC;


-- 4. AVERAGE ORDER VALUE (AOV) ---------------------------------------------------------------------------------------------------------------------------------------------
-- How much does an average customer spend per purchase?
SELECT AVG(invoice_revenue) AS average_order_value
FROM (

-- revenue from each customer invoice
    SELECT
       distinct(invoice_no),
	   SUM(selling_price_per_unit * quantity) AS invoice_revenue
    FROM sales
    GROUP BY invoice_no
) AS order_revenue;

-- # AOV by region # --
SELECT
    region,
    ROUND(AVG(invoice_revenue), 2) AS avg_order_value
FROM (
    SELECT
        region,
        invoice_no,
        SUM(selling_price_per_unit * quantity) AS invoice_revenue
    FROM sales
    GROUP BY region, invoice_no
) AS total
GROUP BY region
ORDER BY avg_order_value DESC;


-- # AOV by category # --
SELECT
    category,
    ROUND(SUM(selling_price_per_unit * quantity) / COUNT(DISTINCT invoice_no), 2) AS avg_order_value
FROM sales
GROUP BY category
ORDER BY avg_order_value DESC;


-- 5. PROFIT PER TRANSACTION ----------------------------------------------------------------------------------------------------------------------------------------------
-- How profitable is each sale?
SELECT Round(AVG(invoice_profit),2) AS avg_profit_per_transaction
FROM (
    SELECT
       distinct(invoice_no),
        SUM((selling_price_per_unit - cost_price_per_unit) * quantity) AS invoice_profit
    FROM sales
    GROUP BY invoice_no
) AS total;


-- # Profit per Transaction by Category # --
SELECT
    category,
    ROUND(AVG(invoice_profit), 2) AS avg_profit_per_transaction
FROM (
    SELECT
        category,
        invoice_no,
        SUM((selling_price_per_unit - cost_price_per_unit) * quantity) AS invoice_profit
    FROM sales
    GROUP BY category, invoice_no
) AS total
GROUP BY category
ORDER BY avg_profit_per_transaction DESC;


-- 6. TOP-SELLING CATEGORY -------------------------------------------------------------------------------------------------------------------------------------------------
-- Which product type sells the most units?
SELECT
    category,
    SUM(quantity) AS total_quantity_sold
FROM sales
GROUP BY category
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- # top selling category by region # --
SELECT
    region,
    category,
    SUM(quantity) AS total_quantity_sold
FROM sales
GROUP BY region, category
ORDER BY region, total_quantity_sold DESC;


-- 7. CATEGORY PROFTABILITY -----------------------------------------------------------------------------------------------------------------------------------------------
-- Which categories are actually making us money?
SELECT
    category,
    SUM((selling_price_per_unit - cost_price_per_unit) * quantity) AS total_profit
FROM sales
GROUP BY category
ORDER BY total_profit DESC;

-- # top selling category by region # --
SELECT
    category,
    ROUND(SUM((selling_price_per_unit - cost_price_per_unit) * quantity)
        / SUM(selling_price_per_unit * quantity) * 100, 2) AS profit_margin_percent
FROM sales
GROUP BY category
ORDER BY profit_margin_percent DESC;

-- 8. AVERAGE QUANTITY SOLD PER CATEGORY ----------------------------------------------------------------------------------------------------------------------------------
-- Which products people buy in bulk vs. single items?
SELECT
    category,
    ROUND(SUM(quantity) / COUNT(DISTINCT invoice_no), 2) AS avg_quantity_per_transaction
FROM sales
GROUP BY category
ORDER BY avg_quantity_per_transaction DESC;


-- # average quantity by region # --
SELECT
    region,
    category,
    ROUND(SUM(quantity) / COUNT(DISTINCT invoice_no), 2) AS avg_quantity_per_transaction
FROM sales
GROUP BY region, category
ORDER BY region, avg_quantity_per_transaction DESC;


-- 9. CATEGORY REVENUE CONTRIBUTION --------------------------------------------------------------------------------------------------------------------------------------
-- How much does each category contribute to total sales?
SELECT
    category,
    ROUND(SUM(selling_price_per_unit * quantity), 2) AS category_revenue,
    ROUND(
        SUM(selling_price_per_unit * quantity) /
        (SELECT SUM(selling_price_per_unit * quantity) FROM sales) * 100, 2
    ) AS revenue_contribution_percent
FROM sales
GROUP BY category
ORDER BY revenue_contribution_percent DESC;

-- # category revenue contribution by region # --
SELECT
    region,
    category,
    ROUND(SUM(selling_price_per_unit * quantity), 2) AS category_revenue,
    ROUND(
        SUM(selling_price_per_unit * quantity) /
        (SELECT SUM(selling_price_per_unit * quantity) FROM sales WHERE region = s.region) * 100, 2
    ) AS revenue_contribution_percent
FROM sales AS s
GROUP BY region, category
ORDER BY region, revenue_contribution_percent DESC;

-- 10. AVERAGE MARKUP PER CATEGORY ----------------------------------------------------------------------------------------------------------------------------------------
-- Which products are priced above cost the most?
SELECT
    category,
    ROUND(AVG((selling_price_per_unit - cost_price_per_unit) / cost_price_per_unit * 100), 2) AS avg_markup_percent
FROM sales
GROUP BY category
ORDER BY avg_markup_percent DESC;


-- 11. NUMBER OF UNIQUE CUSTOMERS ------------------------------------------------------------------------------------------------------------------------------------------
-- How many distinct customers have we served?
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM sales;

-- # unique customer by region # --
SELECT
    region,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM sales
GROUP BY region
ORDER BY unique_customers DESC;


-- 12. AVERAGE AGE OF CUSTOMER ---------------------------------------------------------------------------------------------------------------------------------------------
-- What’s our main age group?
SELECT ROUND(AVG(age), 2) AS average_customer_age
FROM sales;

-- # average age by gender # --
SELECT
    gender,
    ROUND(AVG(age), 2) AS avg_age
FROM sales
GROUP BY gender;

-- # average age by region # --
SELECT
    region,
    ROUND(AVG(age), 2) AS avg_age
FROM sales
GROUP BY region
ORDER BY avg_age DESC;


-- 13. SALES BY GENDER -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Who buys more — men or women?
SELECT
    gender,
    ROUND(SUM(selling_price_per_unit * quantity), 2) AS total_sales,
    ROUND(
        SUM(selling_price_per_unit * quantity) /
        (SELECT SUM(selling_price_per_unit * quantity) FROM sales) * 100, 2
    ) AS sales_percentage
FROM sales
GROUP BY gender
ORDER BY total_sales DESC;

-- # sales by gender & category # --
SELECT
    gender,
    category,
    ROUND(SUM(selling_price_per_unit * quantity), 2) AS total_sales
FROM sales
GROUP BY gender, category
ORDER BY gender, total_sales DESC;


-- 14. REPEAT CUSTOMER RATE ------------------------------------------------------------------------------------------------------------------------------------------------
-- How loyal are our customers?
SELECT
    ROUND(
        (COUNT(DISTINCT CASE WHEN purchase_count > 1 THEN customer_id END)
        / COUNT(DISTINCT customer_id)) * 100, 2) AS repeat_customer_rate
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS purchase_count
    FROM sales
    GROUP BY customer_id
) AS total;


-- 15. AVERAGE REVENUE PER CUSTOMER ----------------------------------------------------------------------------------------------------------------------------------------
-- How much revenue does each customer bring?
SELECT
    ROUND(SUM(quantity * selling_price_per_unit) / COUNT(DISTINCT customer_id), 2) AS average_revenue_per_customer
FROM sales;


-- 16. SALES BY REGION ----------------------------------------------------------------------------------------------------------------------------------------------------
-- Which region sells the most?
SELECT
    region,
    ROUND(SUM(quantity * selling_price_per_unit), 2) AS total_sales_revenue
FROM sales
GROUP BY region
ORDER BY total_sales_revenue DESC;

-- # sales & profit per region # --
SELECT
    region,
    ROUND(SUM(quantity * selling_price_per_unit), 2) AS total_revenue,
    ROUND(SUM((selling_price_per_unit - cost_price_per_unit) * quantity), 2) AS total_profit
FROM sales
GROUP BY region
ORDER BY total_revenue DESC;


-- 17. PROFIT BY SHOPPING MALL ---------------------------------------------------------------------------------------------------------------------------------------------
-- Which mall performs best?
SELECT
    shopping_mall,
    ROUND(SUM((selling_price_per_unit - cost_price_per_unit) * quantity), 2) AS total_profit
FROM sales
GROUP BY shopping_mall
ORDER BY total_profit DESC;

-- # profit by mall & region # --
SELECT
    region,
    shopping_mall,
    ROUND(SUM((selling_price_per_unit - cost_price_per_unit) * quantity), 2) AS total_profit
FROM sales
GROUP BY region, shopping_mall
ORDER BY region, total_profit DESC;

-- 18. TOP PERFORMNG STATE -------------------------------------------------------------------------------------------------------------------------------------------------
-- Which state brings the highest revenue?
SELECT
    state,
    ROUND(SUM((selling_price_per_unit - cost_price_per_unit) * quantity), 2) AS total_profit
FROM sales
GROUP BY state
ORDER BY total_profit DESC
LIMIT 1;

-- 19. AVERAGE TRANSACTION VALUE PER REGION --------------------------------------------------------------------------------------------------------------------------------
-- How big is an average purchase in each region?
SELECT
    region,
    ROUND(SUM(quantity * selling_price_per_unit) / COUNT(DISTINCT invoice_no), 2) AS avg_transaction_value
FROM sales
GROUP BY region
ORDER BY avg_transaction_value DESC;

-- 20. REGIONAL PROFIT MARGIN -----------------------------------------------------------------------------------------------------------------------------------------------
-- Which region is the most profitable (not just big sales)?
SELECT
    region,
    ROUND((SUM((selling_price_per_unit - cost_price_per_unit) * quantity) / SUM(quantity * selling_price_per_unit)) * 100, 2) AS regional_profit_margin
FROM sales
GROUP BY region
ORDER BY regional_profit_margin DESC;
