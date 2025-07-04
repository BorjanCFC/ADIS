CREATE SCHEMA supermarket_discounts;
use supermarket_discounts;

ALTER DATABASE supermarket_discounts CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE Supermarket (
    supermarket_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    contact VARCHAR(30) NOT NULL,
    chain VARCHAR(50),
    no_of_employees INT NOT NULL,
    no_of_stores INT NOT NULL
);

CREATE TABLE User (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    username VARCHAR(50),
    password VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(100) NOT NULL,
    card_number VARCHAR(30)
);

CREATE TABLE Buyer (
    buyer_id INT PRIMARY KEY AUTO_INCREMENT,
    address VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    FOREIGN KEY (buyer_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Admin (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    supermarket_id INT,
    FOREIGN KEY (admin_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (supermarket_id) REFERENCES Supermarket(supermarket_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Inspector (
    inspector_id INT PRIMARY KEY AUTO_INCREMENT,
    FOREIGN KEY (inspector_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE DeliveryPerson (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    no_of_orders INT NOT NULL,
    FOREIGN KEY (delivery_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    production_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    status VARCHAR(20) check (status IN ('Истечен', 'Активен', 'На попуст'))
);

CREATE TABLE SupermarketProducts (
    sp_id INT PRIMARY KEY AUTO_INCREMENT,
    supermarket_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT,
    stock char(2),
    price INT,
    FOREIGN KEY (supermarket_id) REFERENCES Supermarket(supermarket_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ProductUpdate (
    update_id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT NOT NULL,
    product_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    old_price INT,
    new_price INT,
    FOREIGN KEY (admin_id) REFERENCES Admin(admin_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Fine (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    inspector_id INT NOT NULL,
    supermarket_id INT NOT NULL,
    serial_number VARCHAR(50) NOT NULL,
    amount INT,
    date DATE,
    FOREIGN KEY (inspector_id) REFERENCES Inspector(inspector_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (supermarket_id) REFERENCES Supermarket(supermarket_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE MyFavourite (
    myF_id INT PRIMARY KEY AUTO_INCREMENT,
    buyer_id INT NOT NULL,
    product_id INT NOT NULL,
    supermarket_id INT NOT NULL,
    date DATE,
    no_of_products INT,
    FOREIGN KEY (buyer_id) REFERENCES Buyer(buyer_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (supermarket_id) REFERENCES Supermarket(supermarket_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ProductOrder (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    buyer_id INT NOT NULL,
    product_id INT NOT NULL,
    delivery_id INT NOT NULL,
    date DATE,
    time INT,
    status VARCHAR(20) check (status IN ('Во Процес', 'Во обработка', 'Доставена')),
    price INT,
    priceDelivery INT,
    FOREIGN KEY (buyer_id) REFERENCES Buyer(buyer_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (delivery_id) REFERENCES DeliveryPerson(delivery_id) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE ProductOrder
ADD COLUMN priceDelivery INT;

ALTER TABLE ProductOrder
MODIFY COLUMN time INT;

ALTER TABLE SupermarketProducts
MODIFY COLUMN stock char(2);

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Market.csv'
INTO TABLE Supermarket
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(supermarket_id, name, address, chain, no_of_stores, contact, no_of_employees);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Proizvodi.csv'
INTO TABLE Product
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, name, description, production_date, expiration_date, status);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Kupuvac.csv'
INTO TABLE buyer
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(buyer_id, address, city);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Naracki.csv'
INTO TABLE productorder
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, product_id, buyer_id, delivery_id, status, price, priceDelivery, time);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Kazni.csv'
INTO TABLE fine
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(fine_id, supermarket_id, inspector_id, date, amount, serial_number);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MarketProizvodi.csv'
INTO TABLE supermarketproducts
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(sp_id, supermarket_id, product_id, price, quantity, stock);

-- Azuriranje na proizvodite
UPDATE SupermarketProducts
SET stock = 'Нe'
WHERE quantity IS NULL OR quantity = 0;

UPDATE SupermarketProducts
SET stock = 'Дa'
WHERE quantity > 0;

-- Azuriranje na narachkite
SELECT PO.*
FROM ProductOrder as PO
WHERE PO.product_id IN (
    SELECT DISTINCT SP.product_id
    FROM SupermarketProducts SP
    WHERE SP.stock IS NULL OR SP.stock = 'Не'
);

DELETE FROM ProductOrder
WHERE product_id NOT IN (
    SELECT DISTINCT product_id
    FROM SupermarketProducts
    WHERE stock IS NOT NULL AND stock != 'Не'
);

-- Azuriiranje na dostavuvacot
UPDATE DeliveryPerson as DP
SET no_of_orders = (
    SELECT COUNT(*)
    FROM ProductOrder as PO
    WHERE PO.delivery_id = DP.delivery_id
);

UPDATE DeliveryPerson
SET no_of_orders = 0 WHERE no_of_orders IS NULL;

-- Lazni zapisi ?

