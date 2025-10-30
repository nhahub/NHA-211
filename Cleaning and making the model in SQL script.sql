-- Create the table of the final project.
Create database if not exists FinalProject;
Use FinalProject;

-- Create the stagging table where original data is stored as first stage
-- first step is best practice not necessary to drop the table
Drop table if exists ecommerce;
CREATE TABLE ecommerce (
    invoice_no VARCHAR(20) PRIMARY KEY,
    invoice_date DATETIME NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    gender VARCHAR(10),
    age INT CHECK (age >= 0),
    category VARCHAR(50),
    quantity INT CHECK (quantity >= 0),
    selling_price_per_unit DECIMAL(10,2) CHECK (selling_price_per_unit >= 0),
    cost_price_per_unit DECIMAL(10,2) CHECK (cost_price_per_unit >= 0),
    payment_method VARCHAR(30),
    region VARCHAR(50),
    state VARCHAR(50),
    shopping_mall VARCHAR(100)
);
-- load data directly as import wizard takes too much time
-- the following step needs adjustment in the SQL settings
LOAD DATA LOCAL INFILE 'D:/Data Analysis/Final Project/Different_stores_datasetupdated time.csv'
INTO TABLE ecommerce
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(invoice_no, invoice_date, customer_id, gender, age, category, quantity, selling_price_per_unit, cost_price_per_unit, payment_method, region, state, shopping_mall);

-- Make the database is the default one
Use finalproject;

-- Check the table structure
Select *
from ecommerce;

-- Check for duplicates 
select distinct 
invoice_no,
invoice_date,
customer_id,
gender,
age,
category,
quantity,
selling_price_per_unit,
cost_price_per_unit,
payment_method,
region, state,
shopping_mall
from ecommerce;

/* 
The number of columns are the same 99457 rows
if it was not i should have made a temporary staging table with the unduplicated value,
then truncate the columns values from the table then insert the unduplicated values from the staging table into the original one
*/

-- Creating Dimension Tables
-- Creating the dimension table for cusotmer
Drop table if exists DimCustomer;
CREATE TABLE DimCustomer (
    customer_id VARCHAR(255) NOT NULL, -- Unique, contains letters and numbers
    gender VARCHAR(10) NULL,           -- Check for NULLs after loading in Power BI
    age INT NULL,                      -- Check for NULLs after loading in Power BI

    -- Constraints & indexes
    CONSTRAINT uq_DimCustomer_customerid UNIQUE (customer_id),
    INDEX ix_DimCustomer_BK (customer_id),
    INDEX ix_DimCustomer_Lookup (gender, age)
)
ENGINE = InnoDB;

-- Check if the dimension table dimcustomer has no data so i can i insert the data 
select * from dimcustomer;

-- Load the data into dim customer
INSERT INTO DimCustomer (customer_id, gender, age)
SELECT DISTINCT
    customer_id,
    gender,
    age
FROM ecommerce
WHERE customer_id IS NOT NULL;

-- ========================================
-- CREATE DIMENSION AND FACT TABLES
-- (excluding DimCustomer which you already have)
-- ========================================

-- 1️⃣ DimDate
CREATE TABLE DimDate (
    date_key INT PRIMARY KEY,         -- Format: YYYYMMDD
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day INT,
    day_name VARCHAR(20)
) ENGINE = InnoDB;

-- 2️⃣ DimProduct
CREATE TABLE DimProduct (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(100)
) ENGINE = InnoDB;

-- 3️⃣ DimPayment
CREATE TABLE DimPayment (
    payment_key INT AUTO_INCREMENT PRIMARY KEY,
    payment_method VARCHAR(50)
) ENGINE = InnoDB;

-- 4️⃣ DimLocation
CREATE TABLE DimLocation (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    region VARCHAR(100),
    state VARCHAR(100),
    shopping_mall VARCHAR(100)
) ENGINE = InnoDB;

-- 5️⃣ FactSales (central fact table)
CREATE TABLE FactSales (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_no VARCHAR(50),
    invoice_date_key INT,
    customer_id VARCHAR(255),  -- foreign key to DimCustomer
    product_key INT,
    payment_key INT,
    location_key INT,
    quantity INT,
    selling_price_per_unit DECIMAL(10,2),
    cost_price_per_unit DECIMAL(10,2),

    -- Foreign key relationships
    FOREIGN KEY (invoice_date_key) REFERENCES DimDate(date_key),
    FOREIGN KEY (customer_id) REFERENCES DimCustomer(customer_id),
    FOREIGN KEY (product_key) REFERENCES DimProduct(product_key),
    FOREIGN KEY (payment_key) REFERENCES DimPayment(payment_key),
    FOREIGN KEY (location_key) REFERENCES DimLocation(location_key)
) ENGINE = InnoDB;
-- ========================================
-- POPULATE DIMENSION TABLES FROM ECOMMERCE
-- ========================================

-- 🛍️ 2️⃣ DimProduct
INSERT INTO DimProduct (category)
SELECT DISTINCT
    category
FROM ecommerce
WHERE category IS NOT NULL;

-- 💳 3️⃣ DimPayment
INSERT INTO DimPayment (payment_method)
SELECT DISTINCT
    payment_method
FROM ecommerce
WHERE payment_method IS NOT NULL;

-- 📍 4️⃣ DimLocation
INSERT INTO DimLocation (region, state, shopping_mall)
SELECT DISTINCT
    region,
    state,
    shopping_mall
FROM ecommerce
WHERE region IS NOT NULL
   OR state IS NOT NULL
   OR shopping_mall IS NOT NULL;

-- 📅 5️⃣ DimDate
-- Generate unique invoice dates
INSERT INTO DimDate (date_key, full_date, year, quarter, month, month_name, day, day_name)
SELECT DISTINCT
    DATE_FORMAT(invoice_date, '%Y%m%d') AS date_key,
    DATE(invoice_date) AS full_date,
    YEAR(invoice_date) AS year,
    QUARTER(invoice_date) AS quarter,
    MONTH(invoice_date) AS month,
    MONTHNAME(invoice_date) AS month_name,
    DAY(invoice_date) AS day,
    DAYNAME(invoice_date) AS day_name
FROM ecommerce
WHERE invoice_date IS NOT NULL;

-- ========================================
-- POPULATE FACT TABLE
-- ========================================

INSERT INTO FactSales (
    invoice_no,
    invoice_date_key,
    customer_id,
    product_key,
    payment_key,
    location_key,
    quantity,
    selling_price_per_unit,
    cost_price_per_unit
)
SELECT
    e.invoice_no,
    DATE_FORMAT(e.invoice_date, '%Y%m%d') AS invoice_date_key,
    e.customer_id,
    p.product_key,
    pay.payment_key,
    l.location_key,
    e.quantity,
    e.selling_price_per_unit,
    e.cost_price_per_unit
FROM ecommerce e
LEFT JOIN DimProduct p
    ON e.category = p.category
LEFT JOIN DimPayment pay
    ON e.payment_method = pay.payment_method
LEFT JOIN DimLocation l
    ON e.region = l.region
   AND e.state = l.state
   AND e.shopping_mall = l.shopping_mall;

