use supermarket_discounts;

-- Proverka dali tabelite se poplneti
select * from user;
select * from inspector;
select * from deliveryperson;
select * from supermarket;
select * from admin;
select * from product;
select * from buyer;
select * from myfavourite;
select * from productorder;
select * from productupdate;
select * from fine;
select * from supermarketproducts;

-- Listanje kolku proizvodi ima sekoj market
select supermarket_id, COUNT(product_id) as kolku
from supermarketproducts
GROUP BY supermarket_id
ORDER BY supermarket_id;

-- Kolku pati se menuvala cenata za sekoj produkt vo 2024
select product_id, count(*) as kolku 
from productupdate
WHERE YEAR(start_date) = 2024
GROUP BY product_id
ORDER BY product_id;

-- Vkupno kazni za 2024
SELECT COUNT(*) AS vkupno_kazni_2024
FROM fine
WHERE YEAR(date) = 2024;

-- Vkupno kazneti marketi
select count(DISTINCT(supermarket_id)) as kolku
from fine;

-- lazni zapisi za order
SELECT po.product_id, po.date AS naracka_datum, po.price AS cena_naracka, pu.new_price AS cena_vo_toj_moment
FROM  ProductOrder AS po, ProductUpdate AS pu 
WHERE po.product_id = pu.product_id AND po.date BETWEEN pu.start_date AND pu.end_date
ORDER BY po.product_id, po.date;

-- Prvo prashanje
SELECT p.product_id, p.name, s.supermarket_id, s.name
FROM Product as p, Supermarket as s
WHERE p.product_id NOT IN (
	SELECT sp.product_id
    FROM supermarketproducts as sp
    WHERE sp.product_id = p.product_id AND s.supermarket_id = sp.supermarket_id
);

-- Vtoro prashanje
CREATE OR REPLACE VIEW LastPrices AS
SELECT pu1.product_id, QUARTER(pu1.start_date) AS kvartal, pu1.new_price as last_price
FROM ProductUpdate as pu1
WHERE pu1.start_date = (
        SELECT MAX(pu2.start_date)
        FROM ProductUpdate pu2
        WHERE pu2.product_id = pu1.product_id AND QUARTER(pu2.start_date) = QUARTER(pu1.start_date) AND YEAR(pu2.start_date) = 2024 
) AND YEAR(pu1.start_date) = 2024;

-- listanje na poslednite ceni za sekoj kvartal
SELECT * FROM LastPrices
ORDER BY product_id, kvartal;

SELECT pu.product_id, QUARTER(pu.start_date) as kvartal, COUNT(*) AS broj_promeni, lp.last_price
FROM ProductUpdate as pu, LastPrices as lp
WHERE YEAR(pu.start_date) = 2024 AND lp.product_id = pu.product_id AND QUARTER(pu.start_date) = lp.kvartal
GROUP BY pu.product_id, QUARTER(pu.start_date), lp.last_price
ORDER BY pu.product_id, QUARTER(pu.start_date);

-- Treto prashanje (izbravme random datum)
SELECT product_id, name, expiration_date, DATEDIFF(expiration_date, '2024-09-16') AS days_left
FROM Product
WHERE DATEDIFF(expiration_date, '2024-09-16') BETWEEN 0 AND 10
ORDER BY expiration_date ASC;

-- Cetvrto prashanje
SELECT MONTH(date) AS mesec, COUNT(*) AS broj_kazni
FROM Fine
WHERE YEAR(date) = 2024
GROUP BY mesec
ORDER BY mesec;

-- Petto prashanje
SELECT s.supermarket_id, s.name AS ime_na_supermarket, COUNT(f.fine_id) AS vkupno_kazni
FROM Supermarket as s, Fine as f
WHERE s.supermarket_id = f.supermarket_id
GROUP BY s.supermarket_id, s.name
ORDER BY vkupno_kazni DESC;
