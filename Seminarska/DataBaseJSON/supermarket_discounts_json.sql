CREATE DATABASE IF NOT EXISTS supermarket_discounts_json
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE supermarket_discounts_json;

-- ZADACHA 4

CREATE TABLE Supermarket_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);
CREATE TABLE User_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);
CREATE TABLE Buyer_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);
CREATE TABLE Admin_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);
CREATE TABLE Inspector_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);
CREATE TABLE DeliveryPerson_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);
CREATE TABLE Product_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);
CREATE TABLE SupermarketProducts_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);
CREATE TABLE ProductUpdate_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);
CREATE TABLE Fine_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);
CREATE TABLE MyFavourite_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);
CREATE TABLE ProductOrder_JSON (id INT AUTO_INCREMENT PRIMARY KEY, data JSON);

 -- Supermarket -> Supermarket_JSON
INSERT INTO Supermarket_JSON (data)
SELECT JSON_OBJECT(
    'supermarket_id', supermarket_id,
    'name', name,
    'address', address,
    'contact', contact,
    'chain', chain,
    'no_of_employees', no_of_employees,
    'no_of_stores', no_of_stores
)
FROM supermarket_discounts.Supermarket;

-- User -> User_JSON
INSERT INTO User_JSON (data)
SELECT JSON_OBJECT(
    'user_id', user_id,
    'first_name', first_name,
    'last_name', last_name,
    'username', username,
    'password', password,
    'phone_number', phone_number,
    'email', email,
    'card_number', card_number
)
FROM supermarket_discounts.User;

-- Buyer -> Buyer_JSON
INSERT INTO Buyer_JSON (data)
SELECT JSON_OBJECT(
    'buyer_id', buyer_id,
    'address', address,
    'city', city
)
FROM supermarket_discounts.Buyer;

-- Admin -> Admin_JSON
INSERT INTO Admin_JSON (data)
SELECT JSON_OBJECT(
    'admin_id', admin_id,
    'supermarket_id', supermarket_id
)
FROM supermarket_discounts.Admin;

-- Inspector -> Inspector_JSON
INSERT INTO Inspector_JSON (data)
SELECT JSON_OBJECT(
    'inspector_id', inspector_id
)
FROM supermarket_discounts.Inspector;

-- DeliveryPerson -> DeliveryPerson_JSON
INSERT INTO DeliveryPerson_JSON (data)
SELECT JSON_OBJECT(
    'delivery_id', delivery_id,
    'no_of_orders', no_of_orders
)
FROM supermarket_discounts.DeliveryPerson;

-- Product -> Product_JSON
INSERT INTO Product_JSON (data)
SELECT JSON_OBJECT(
    'product_id', product_id,
    'name', name,
    'description', description,
    'production_date', production_date,
    'expiration_date', expiration_date,
    'status', status
)
FROM supermarket_discounts.Product;

-- SupermarketProducts -> SupermarketProducts_JSON
INSERT INTO SupermarketProducts_JSON (data)
SELECT JSON_OBJECT(
    'sp_id', sp_id,
    'supermarket_id', supermarket_id,
    'product_id', product_id,
    'quantity', quantity,
    'stock', stock,
    'price', price
)
FROM supermarket_discounts.SupermarketProducts;

-- ProductUpdate -> ProductUpdate_JSON
INSERT INTO ProductUpdate_JSON (data)
SELECT JSON_OBJECT(
    'update_id', update_id,
    'admin_id', admin_id,
    'product_id', product_id,
    'start_date', start_date,
    'end_date', end_date,
    'old_price', old_price,
    'new_price', new_price
)
FROM supermarket_discounts.ProductUpdate;

-- Fine -> Fine_JSON
INSERT INTO Fine_JSON (data)
SELECT JSON_OBJECT(
    'fine_id', fine_id,
    'inspector_id', inspector_id,
    'supermarket_id', supermarket_id,
    'serial_number', serial_number,
    'amount', amount,
    'date', date
)
FROM supermarket_discounts.Fine;

-- MyFavourite -> MyFavourite_JSON
INSERT INTO MyFavourite_JSON (data)
SELECT JSON_OBJECT(
    'myF_id', myF_id,
    'buyer_id', buyer_id,
    'product_id', product_id,
    'supermarket_id', supermarket_id,
    'date', date,
    'no_of_products', no_of_products
)
FROM supermarket_discounts.MyFavourite;

-- ProductOrder -> ProductOrder_JSON
INSERT INTO ProductOrder_JSON (data)
SELECT JSON_OBJECT(
    'order_id', order_id,
    'buyer_id', buyer_id,
    'product_id', product_id,
    'delivery_id', delivery_id,
    'date', date,
    'time', time,
    'status', status,
    'price', price,
    'priceDelivery', priceDelivery
)
FROM supermarket_discounts.ProductOrder;

-- Pecatenje na nekolku tabeli za proverka
SELECT (JSON_EXTRACT(data, '$.supermarket_id')) AS supermarket_id,
  (JSON_EXTRACT(data, '$.name')) AS name,
  (JSON_EXTRACT(data, '$.address')) AS address,
  (JSON_EXTRACT(data, '$.contact')) AS contact,
  (JSON_EXTRACT(data, '$.chain')) AS chain,
  JSON_EXTRACT(data, '$.no_of_employees') AS no_of_employees,
  JSON_EXTRACT(data, '$.no_of_stores') AS no_of_stores
FROM Supermarket_JSON;

SELECT JSON_EXTRACT(data, '$.user_id') AS product_id,
  JSON_EXTRACT(data, '$.first_name') AS first_name,
  JSON_EXTRACT(data, '$.last_name') AS last_name,
  JSON_EXTRACT(data, '$.username') AS username,
  JSON_EXTRACT(data, '$.phone_number') AS phone_number,
  JSON_EXTRACT(data, '$.password') AS password,
  JSON_EXTRACT(data, '$.email') AS email,
  JSON_EXTRACT(data, '$.card_number') AS card_number
FROM user_json;

SELECT JSON_EXTRACT(data, '$.fine_id') AS fine_id,
  JSON_EXTRACT(data, '$.inspector_id') AS inspector_id,
  JSON_EXTRACT(data, '$.supermarket_id') AS supermarket_id,
  JSON_EXTRACT(data, '$.serial_number') AS serial_number,
  JSON_EXTRACT(data, '$.amount') AS amount,
  JSON_EXTRACT(data, '$.date') AS date
FROM fine_json;


