-- Task 1. Практическое задание по теме “Транзакции, переменные, представления”
-- В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users в 
-- таблицу sample.users. Используйте транзакции.

START TRANSACTION;
INSERT INTO Sample.users SELECT * FROM shop.users WHERE id = 1;
COMMIT;

-- Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.

CREATE OR REPLACE VIEW name_view as select catalogs.name as имя,products.name as товар
from
products
join
catalogs
on catalogs.id = products.catalog_id;

SELECT * FROM name_view;

-- по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', 
-- '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, 
-- если дата присутствует в исходном таблице и 0, если она отсутствует.

DROP PROCEDURE IF EXISTS FillCalendar;
DROP TABLE IF EXISTS calendar;
CREATE TABLE IF NOT EXISTS calendar(
id INT PRIMARY KEY,
calendar_date DATE,
calendar_exist INT
);

DELIMITER //
DROP PROCEDURE IF EXISTS FillCalendar//
CREATE PROCEDURE FillCalendar(start_date DATE, end_date DATE)
BEGIN
DECLARE crt_n INT;
DECLARE crt_date DATE; 
DECLARE cex_date INT;
SET crt_date = start_date;
SET crt_n = 1;
WHILE crt_date <= end_date DO
	INSERT IGNORE INTO calendar VALUES(crt_n, crt_date,0);
	SET crt_date = ADDDATE(crt_date, INTERVAL 1 DAY);
	SET crt_n = crt_n +1;
END WHILE;
END//

CALL FillCalendar('2018-08-01', '2018-08-30');

UPDATE calendar, users 
	SET calendar_exist = 1 where calendar_date = DATE(created_at);

SELECT * from calendar

-- (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, 
-- который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

SELECT @max_id := MAX(id) FROM calendar;
DELETE FROM calendar WHERE id <= @max_id - 5;

SELECT * from calendar


-- Task 2. Практическое задание по теме “Администрирование MySQL” (эта тема изучается по вашему желанию)
-- Создайте двух пользователей которые имеют доступ к базе данных shop. Первому пользователю shop_read должны быть доступны только запросы 
-- на чтение данных, второму пользователю shop — любые операции в пределах базы данных shop.

DROP USER IF EXISTS 'shop_reader'@'localhost';
CREATE USER 'shop_reader'@'localhost' IDENTIFIED BY '12345';
GRANT SELECT ON shop.* TO 'shop_reader'@'localhost';

DROP USER IF EXISTS 'shop'@'localhost';
CREATE USER 'shop'@'localhost' IDENTIFIED BY '12345';
GRANT ALL ON shop.* TO 'shop'@'localhost';
GRANT GRANT OPTION ON shop.* TO 'shop'@'localhost';

-- (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, имя пользователя и его пароль. 
-- Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. Создайте пользователя user_read, который бы не имел доступа 
-- к таблице accounts, однако, мог бы извлекать записи из представления username.

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
	id SERIAL PRIMARY KEY,
	name VARCHAR(45),
	password VARCHAR(45)
);

INSERT INTO accounts VALUES ('1', 'Vera', '1234'),
	('2', 'Katya', '1234'),
	('3', 'Lena', '1234');

CREATE OR REPLACE VIEW username(user_id, user_name) AS SELECT id, name FROM accounts;
SELECT * FROM username;

DROP USER IF EXISTS 'shop_reader'@'localhost';
CREATE USER 'shop_reader'@'localhost' IDENTIFIED BY '1234';
GRANT SELECT ON shop.username TO 'shop_reader'@'localhost';


-- Task 3 Практическое задание по теме “Хранимые процедуры и функции, триггеры"
-- Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. С 6:00 до 12:00 
-- функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", 
-- с 00:00 до 6:00 — "Доброй ночи".

DELIMITER //
DROP function IF EXISTS hello//
CREATE function hello(tf TIME)
RETURNS TEXT DETERMINISTIC
BEGIN
  IF tf BETWEEN '06:00:00' and '12:00:00' THEN  RETURN  'доброе утро';
  ELSEIF tf BETWEEN '12:00:00' and '18:00:00' THEN RETURN 'Добрый день';
  ELSEIF tf BETWEEN '18:00:00' and '00:00:00' THEN RETURN 'Добрый вечер';
  Elseif tf BETWEEN '00:00:00' and '06:00:00' THEN  RETURN 'доброй ночи';
  END IF;
END//

SELECT hello(CURTIME())//

-- В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие обоих полей или одно из них. 
-- Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба 
-- поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.

DELIMITER //
CREATE TRIGGER not_null BEFORE INSERT ON products
FOR EACH ROW
BEGIN
    DECLARE chk VARCHAR(255) ;
    if NEW.name IS NULL AND NEW.description IS NULL
    THEN
    SET NEW.name = COALESCE(NEW.name,cat_id);
  	SET NEW.description = COALESCE (NEW.description,cat_id);
    end if;
END//

-- (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. Числами Фибоначчи называется последовательность 
-- в которой число равно сумме двух предыдущих чисел. Вызов функции FIBONACCI(10) должен возвращать число 55.

DELIMITER //
DROP function IF EXISTS fibonacci//
CREATE function fibonacci(n INT)
RETURNS INT DETERMINISTIC
BEGIN
DECLARE n0, n1, n2, n3 INT;
  IF n < 2 
  	THEN  RETURN n;
  ELSE
	SET n0 = 0;
	SET n1 = 1;
	SET n2 = 0;
	SET n3 = 2;
	WHILE n3 <= n DO
		SET n2 = n0 + n1;
		SET n0 = n1;
		SET n1 = n2;
		SET n3 = n3 + 1;
	END WHILE;
	return n2;
   END IF;
END//

SELECT fibonacci(10)//

