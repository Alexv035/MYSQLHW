
/* Задача 1
Установите СУБД MySQL. Создайте в домашней директории файл .my.cnf, задав в нем логин и пароль, который указывался при установке.
*/
[mysql]
user=alex
password=

-- вхожу пол логином alex

/* Задача 2
Создайте базу данных example, разместите в ней таблицу users, состоящую из двух столбцов, числового id и строкового name.
*/
CREATE DATABASE IF NOT EXISTS example;
USE example;
DROP TABLE if EXISTS users;
CREATE TABLE users (
	id INT UNSIGNED,
	name VARCHAR(255)
) COMMENT = 'Создание таблицы users';

/* Задача 3
Создайте дамп базы данных example из предыдущего задания, разверните содержимое дампа в новую базу данных sample.
*/
mysqldump -u alex -p example > sample.sql
mysql -p
CREATE DATABASE IF NOT EXISTS sample;
USE sample;
SOURCE example.sql

-- screenshots in the comments

/* Задача 4
(по желанию) Ознакомьтесь более подробно с документацией утилиты mysqldump. Создайте дамп единственной таблицы help_keyword базы данных mysql. Причем добейтесь того, чтобы
дамп содержал только первые 100 строк таблицы.
*/
mysqldump -u alex -p --opt --where="1 limit 100" mysql help_keyword > first_100_rows_help_keyword.sql
