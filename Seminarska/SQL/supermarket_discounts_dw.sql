CREATE DATABASE IF NOT EXISTS supermarket_discounts_warehouse;
USE supermarket_discounts_warehouse;

-- Dimension Tables
CREATE TABLE Dim_Product (
    product_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    production_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Истечен', 'Активен', 'На попуст'))
);

CREATE TABLE Dim_Supermarket (
    supermarket_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    contact VARCHAR(30) NOT NULL,
    chain VARCHAR(50),
    no_of_employees INT NOT NULL,
    no_of_stores INT NOT NULL
);

CREATE TABLE Dim_Time (
    date_id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL, 
    month INT NOT NULL,
    day INT NOT NULL
);

-- Fact Tables
CREATE TABLE Fact_Stock (
    sp_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    supermarket_id INT NOT NULL,
    quantity INT,
    stock CHAR(2),
    price INT,
    FOREIGN KEY (product_id) REFERENCES Dim_Product(product_id),
    FOREIGN KEY (supermarket_id) REFERENCES Dim_Supermarket(supermarket_id)
);

CREATE TABLE Fact_PriceUpdate (
    update_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    date_id INT NOT NULL,
    old_price INT,
    new_price INT,
    price_change_count INT NOT NULL, 
    FOREIGN KEY (product_id) REFERENCES Dim_Product(product_id),
    FOREIGN KEY (date_id) REFERENCES Dim_Time(date_id)
);

CREATE TABLE Fact_Fine (
    fine_id INT PRIMARY KEY,
    supermarket_id INT NOT NULL,
    date_id INT NOT NULL,
    amount INT,
    fine_count INT NOT NULL, 
    FOREIGN KEY (supermarket_id) REFERENCES Dim_Supermarket(supermarket_id),
    FOREIGN KEY (date_id) REFERENCES Dim_Time(date_id)
);

INSERT INTO supermarket_discounts_warehouse.Dim_Product (product_id, name, description, production_date, expiration_date, status)
SELECT product_id, name, description, production_date, expiration_date, status
FROM supermarket_discounts.Product;

INSERT INTO supermarket_discounts_warehouse.Dim_Supermarket (supermarket_id, name, address, contact, chain, no_of_employees, no_of_stores)
SELECT supermarket_id, name, address, contact, chain, no_of_employees, no_of_stores
FROM supermarket_discounts.Supermarket;

INSERT INTO supermarket_discounts_warehouse.Dim_Time (date, year, quarter, month, day)
SELECT DISTINCT date, YEAR(date), QUARTER(date), MONTH(date), DAY(date)
FROM (SELECT start_date AS date FROM supermarket_discounts.ProductUpdate WHERE start_date IS NOT NULL
	  UNION
      SELECT end_date AS date FROM supermarket_discounts.ProductUpdate WHERE end_date IS NOT NULL
      UNION
      SELECT date FROM supermarket_discounts.Fine WHERE date IS NOT NULL
) as dates;

INSERT INTO supermarket_discounts_warehouse.Fact_Stock (sp_id, product_id, supermarket_id, quantity, stock, price)
SELECT sp_id, product_id, supermarket_id, quantity, stock, price
FROM supermarket_discounts.SupermarketProducts;

INSERT INTO supermarket_discounts_warehouse.Fact_PriceUpdate (update_id, product_id, date_id, old_price, new_price, price_change_count)
SELECT pu.update_id, pu.product_id, (SELECT date_id FROM supermarket_discounts_warehouse.Dim_Time WHERE date = pu.start_date) AS date_id, pu.old_price, pu.new_price, 
	(SELECT COUNT(*) 
     FROM supermarket_discounts.ProductUpdate 
     WHERE product_id = pu.product_id) AS price_change_count
FROM supermarket_discounts.ProductUpdate pu
WHERE pu.start_date IS NOT NULL;

INSERT INTO supermarket_discounts_warehouse.Fact_Fine (fine_id, supermarket_id, date_id, amount, fine_count)
SELECT f.fine_id,f.supermarket_id, (SELECT date_id FROM supermarket_discounts_warehouse.Dim_Time WHERE date = f.date) AS date_id, f.amount,
    (SELECT COUNT(*) 
     FROM supermarket_discounts.Fine 
     WHERE supermarket_id = f.supermarket_id) AS fine_count
FROM supermarket_discounts.Fine f
WHERE f.date IS NOT NULL;

-- Proverka dali se uspeshno popolneti tabelite
SELECT * FROM supermarket_discounts_warehouse.Dim_Product;
SELECT * FROM supermarket_discounts_warehouse.Dim_Supermarket;
SELECT * FROM supermarket_discounts_warehouse.Dim_Time;
SELECT * FROM supermarket_discounts_warehouse.Fact_Stock;
SELECT * FROM supermarket_discounts_warehouse.Fact_PriceUpdate;
SELECT * FROM supermarket_discounts_warehouse.Fact_Fine;



