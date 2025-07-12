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
ADD COLUMN date DATE;

ALTER TABLE ProductOrder
MODIFY COLUMN time INT;

ALTER TABLE SupermarketProducts
MODIFY COLUMN stock char(2);

-- ZADACHA 2

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

-- Lazni zapisi 

-- Provereni se site tabeli edinstveniot lazen zapis pronajden e vo tabelata fine kade inspector id e nepostoecki vo inspector
SELECT * FROM Fine
WHERE inspector_id NOT IN (SELECT inspector_id FROM Inspector) OR supermarket_id NOT IN (SELECT supermarket_id FROM Supermarket);
   
DELETE FROM Fine
WHERE inspector_id NOT IN (SELECT inspector_id FROM Inspector) OR supermarket_id NOT IN (SELECT supermarket_id FROM Supermarket);

-- Nemame referenciranje na id-to na fine vo nikoja druga tabela i mozeme da go updejetneme AUTO INCREMENTOT da nema dupka
UPDATE Fine
SET fine_id = fine_id - 1
WHERE fine_id > 99;

-- Proverka dali cenata kaj productOrder e istata so novata cena kaj productUpdate za konkreten datum
SELECT po.product_id, po.date AS naracka_datum, po.price AS cena_naracka, pu.new_price AS cena_vo_toj_moment, pu.start_date, pu.end_date
FROM  ProductOrder AS po, ProductUpdate AS pu 
WHERE po.product_id = pu.product_id AND po.date BETWEEN pu.start_date AND pu.end_date
ORDER BY po.product_id;

-- Cenata na narachaniot produkt na konkretniot datum ne e ista so cenata definirana vo tabelata productUpdate 
-- i zatoa gi updejtirame site ceni da bidat tochni za datumot na koj bil narachan produktot
UPDATE ProductOrder po
JOIN ProductUpdate pu ON po.product_id = pu.product_id AND po.date BETWEEN pu.start_date AND pu.end_date
SET po.price = pu.new_price;

-- Koga kje go izvrsime povtorno ova query gi dobivame site ceni updejtnati so cenata sto bila vo toj moment
SELECT po.product_id, po.date AS naracka_datum, po.price AS cena_naracka, pu.new_price AS cena_vo_toj_moment, pu.start_date, pu.end_date
FROM  ProductOrder AS po, ProductUpdate AS pu 
WHERE po.product_id = pu.product_id AND po.date BETWEEN pu.start_date AND pu.end_date
ORDER BY po.product_id;