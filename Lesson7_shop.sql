select @@sql_mode;
set @@sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'

-- Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
SELECT  
users.id, users.name,
COUNT(*) as amount 
FROM 
users
join 
orders
WHERE (SELECT orders.user_id = users.id)
group by user_id 
order by amount DESC 


-- Выведите список товаров products и разделов catalogs, который соответствует товару.
select ct.name, pr.name
FROM products pr
join 
catalogs ct
WHERE pr.catalog_id = ct.id and pr.name = 'Intel Core i5-7400' 

-- (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.


DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
  id SERIAL ,
  labels VARCHAR(255) PRIMARY KEY,
  name_c VARCHAR(255) 
);

INSERT INTO `cities` VALUES ('1','Moscow','Москва'),
('2','Novgorod','Новгород'),
('3','Irkutsk','Иркутск'),
('4','Omsk','Омск'),
('5','Kazan','Казань');


DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
  id SERIAL PRIMARY KEY,
  from_c VARCHAR(255),
  to_c VARCHAR(255),
  FOREIGN KEY (from_c) REFERENCES cities (labels),
  FOREIGN KEY (to_c) REFERENCES cities (labels)
) ;

INSERT INTO `flights` VALUES ('1','Moscow','Omsk'),
('2','Novgorod','kazan'),
('3','Irkutsk','Moscow'),
('4','Omsk','Irkutsk'),
('5','Moscow','Kazan');

SELECT 
(SELECT name_c from cities where from_c = labels) as from_city,
(SELECT name_c from cities where to_c = labels) as to_city
from flights  



