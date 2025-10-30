CREATE DATABASE sales_performance_db;
use sales_performance_db;

CREATE TABLE Different_Store (
    invoice_no VARCHAR(225),
    invoice_date VARCHAR(225),
    customer_id VARCHAR(225),
    gender VARCHAR(225),
    age INT,
    category VARCHAR(225),
    quantity INT,
    selling_price_per_unit DECIMAL(10,2),
    cost_price_per_unit DECIMAL(10,2),
    total_profit DECIMAL(10,2),
    payment_method VARCHAR(225),
    region VARCHAR(225),
    state VARCHAR(225),
    shopping_mall VARCHAR(225),
    PRIMARY KEY (invoice_no, customer_id)
);

SHOW VARIABLES LIKE 'secure_file_priv';


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/Different Store.csv'
INTO TABLE Different_Store
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(invoice_no, invoice_date, customer_id, gender, age, category, quantity,
 selling_price_per_unit, cost_price_per_unit, total_profit, payment_method,
 region, state, shopping_mall);
 
 SELECT 
    SUM(invoice_no IS NULL) AS null_invoice_no,
    SUM(invoice_date IS NULL) AS null_invoice_date,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(gender IS NULL) AS null_gender,
    SUM(age IS NULL) AS null_age,
    SUM(category IS NULL) AS null_category,
    SUM(quantity IS NULL) AS null_quantity,
    SUM(selling_price_per_unit IS NULL) AS null_selling_price,
    SUM(cost_price_per_unit IS NULL) AS null_cost_price,
    SUM(total_profit IS NULL) AS null_total_profit,
    SUM(payment_method IS NULL) AS null_payment_method,
    SUM(region IS NULL) AS null_region,
    SUM(state IS NULL) AS null_state,
    SUM(shopping_mall IS NULL) AS null_shopping_mall
FROM different_store;

SELECT invoice_no, customer_id, COUNT(*) AS count
FROM different_store
GROUP BY invoice_no, customer_id
HAVING COUNT(*) > 1;

SELECT 
    invoice_no, 
    customer_id, 
    category,
    quantity,
    selling_price_per_unit,
    total_profit,
    COUNT(*) AS count
FROM different_store
GROUP BY 
    invoice_no, 
    customer_id, 
    category,
    quantity,
    selling_price_per_unit,
    total_profit
HAVING COUNT(*) > 1;

SELECT invoice_date 
FROM different_store 
WHERE STR_TO_DATE(invoice_date, '%Y-%m-%d') IS NULL;

SELECT * FROM different_store
WHERE quantity <= 0
   OR selling_price_per_unit <= 0
   OR cost_price_per_unit <= 0;












