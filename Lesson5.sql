-- Задача 1: Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.

UPDATE users SET created_at=CURRENT_TIMESTAMP(), updated_at = CURRENT_TIMESTAMP();

-- Задача 2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время 
-- помещались значения в формате "20.10.2017 8:10". Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.

-- ALTER TABLE users DROP COLUMN temp, temp2;

ALTER TABLE users ADD COLUMN (temp DATETIME, temp2 DATETIME);
update users set temp = created_at, temp2 = updated_at; 
ALTER TABLE users DROP COLUMN created_at, updated_at;
ALTER TABLE users CHANGE COLUMN (temp created_at datetime, temp2 updated_at datetime);

-- Задача 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, если товар 
-- закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи таким образом, чтобы они выводились в порядке 
-- увеличения значения value. Однако, нулевые запасы должны выводиться в конце, после всех записей.

SELECT value FROM storehouses_products ORDER BY value = 0, value;

-- Задача 4. Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. Месяцы заданы в виде списка английских названий ('may', 'august')

SELECT name, birthday_at FROM users WHERE MONTHNAME(birthday_at) ='May' OR MONTHNAME(birthday_at) = 'August';

-- если заданая отдельный столбец BMONTH тогда:

UPDATE users SET BMONTH=MONTHNAME(birthday_at);
SELECT name, birthday_at FROM users WHERE BMONTH ='May' OR BMONTH = 'August';

-- Практическое задание теме “Агрегация данных”
-- Задача 1. Подсчитайте средний возраст пользователей в таблице users

SELECT SUM(TIMESTAMPDIFF(YEAR, birthday_at , CURDATE()))/(SELECT COUNT('birthday_at') FROM users) FROM users;

-- OR

SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at , CURDATE())) FROM users;


-- Задача 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы дни недели 
-- текущего года, а не года рождения.
SELECT DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at))) from users;

SELECT COUNT(DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at)))) as 'Mondaybirth' FROM users where DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at))) = "Monday"; 
SELECT COUNT(DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at)))) as 'Tuesdaybirth' FROM users where DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at))) = "Tuesday"; 
SELECT COUNT(DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at)))) as 'Wednesdaybirth' FROM users where DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at))) = "Wednesday"; 
SELECT COUNT(DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at)))) as 'Thursdaybirth' FROM users where DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at))) = "Thursday"; 
--- Не нашел как создать сразу одну агрегированную таблицу по расчету количеств



-- Задача 3. Подсчитайте произведение чисел в столбце таблицы
SELECT EXP(SUM(LN(value))) from vtable 



