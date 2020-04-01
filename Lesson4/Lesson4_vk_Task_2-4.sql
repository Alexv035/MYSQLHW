-- Task 2
-- Написать скрипт, возвращающий список имен (только firstname) пользователей без повторений в алфавитном порядке
SELECT DISTINCT firstname FROM users 

-- Task 3
-- Написать скрипт, отмечающий несовершеннолетних пользователей как неактивных (поле is_active = false). Предварительно добавить такое поле в таблицу profiles со значением по умолчанию = true (или 1)
ALTER TABLE vk.profiles ADD COLUMN `is_active` INT(1) unsigned DEFAULT 1 NOT NULL

UPDATE profiles 
	SET 
	is_active = 0
WHERE
	birthday <= DATE_SUB(CURRENT_DATE, INTERVAL 18 YEAR)


-- Task 4
-- Написать скрипт, удаляющий сообщения «из будущего» (дата позже сегодняшней)
DELETE FROM messages 
WHERE created_at > CURRENT_DATE
