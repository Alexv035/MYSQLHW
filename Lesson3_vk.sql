DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамиль', -- COMMENT на случай, если имя неочевидное
    email VARCHAR(120) ,
    phone BIGINT unique, 
    password_hash varchar(100),
    -- INDEX users_phone_idx(phone), -- помним: как выбирать индексы
    INDEX users_firstname_lastname_idx(firstname, lastname)
);

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	user_id SERIAL PRIMARY KEY,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100)
    -- , FOREIGN KEY (photo_id) REFERENCES media(id) -- пока рано, т.к. таблицы media еще нет
);

ALTER TABLE `profiles` ADD CONSTRAINT fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE -- (значение по умолчанию)
    ON DELETE restrict; -- (значение по умолчанию)

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    is_read bit default 0,
    created_at DATETIME DEFAULT NOW(), -- можно будет даже не упоминать это поле при вставке

    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	-- id SERIAL PRIMARY KEY, -- изменили на составной ключ (initiator_user_id, target_user_id)
	initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    -- `status` TINYINT UNSIGNED,
    `status` ENUM('requested', 'approved', 'unfriended', 'declined'),
    -- `status` TINYINT UNSIGNED, -- в этом случае в коде хранили бы цифирный enum (0, 1, 2, 3...)
	requested_at DATETIME DEFAULT NOW(),
	updated_at datetime on UPDATE current_timestamp,
	confirmed_at DATETIME,
	
    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
	id SERIAL PRIMARY KEY,
	name VARCHAR(150),
	admin_users_id bigint unsigned not null ,

	INDEX communities_name_idx(name)
);

DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (user_id, community_id), -- чтобы не было 2 записей о пользователе и сообществе
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (community_id) REFERENCES communities(id)
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

    -- записей мало, поэтому индекс будет лишним (замедлит работу)!
);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
    media_type_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
  	body text,
    filename VARCHAR(255),
    size INT,
	metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),

    -- PRIMARY KEY (user_id, media_id) – можно было и так вместо id в качестве PK
  	-- слишком увлекаться индексами тоже опасно, рациональнее их добавлять по мере необходимости (напр., провисают по времени какие-то запросы)  


    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_id) REFERENCES media(id)

);

DROP TABLE IF EXISTS `photo_albums`;
CREATE TABLE `photo_albums` (
	`id` SERIAL,
	`name` varchar(255) DEFAULT NULL,
    `user_id` BIGINT UNSIGNED DEFAULT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
  	PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos` (
	id SERIAL PRIMARY KEY,
	`album_id` BIGINT unsigned NOT NULL,
	`media_id` BIGINT unsigned NOT NULL,

	FOREIGN KEY (album_id) REFERENCES photo_albums(id),
    FOREIGN KEY (media_id) REFERENCES media(id)
);

-- Homework

-- Таблица видео альбомы
DROP TABLE IF EXISTS `video_albums`;
CREATE TABLE `video_albums` (
	 id SERIAL,
	 name varchar(255) DEFAULT NULL,
     user_video_id BIGINT UNSIGNED DEFAULT NULL,

    FOREIGN KEY (user_video_id) REFERENCES users(id),
  	PRIMARY KEY (`id`)
);

-- Таблица видео
DROP TABLE IF EXISTS `videos`;
CREATE TABLE `videos` (
	id SERIAL PRIMARY KEY,
	`album_video_id` BIGINT unsigned NOT NULL,
	`media_video_id` BIGINT unsigned NOT NULL,

	FOREIGN KEY (album_video_id) REFERENCES video_albums(id),
    FOREIGN KEY (media_video_id) REFERENCES media(id)
);

-- таблица новостная лента
DROP TABLE IF EXISTS news;
CREATE TABLE news(
    id SERIAL PRIMARY KEY,
	user_news_id BIGINT UNSIGNED NOT NULL,
    media_news_id BIGINT UNSIGNED,
    photos_news_id BIGINT UNSIGNED,
    video_news_id BIGINT UNSIGNED,
    communities_news_id BIGINT UNSIGNED,
    text_news text NOT NULL,
    links_news VARCHAR(256) ,
    
    created_news_at DATETIME DEFAULT NOW(),
    updated_news_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
   FOREIGN KEY (user_news_id) REFERENCES users(id),
   FOREIGN KEY (media_news_id) REFERENCES media(id),
   FOREIGN KEY (photos_news_id) REFERENCES photos(id),    
   FOREIGN KEY (video_news_id) REFERENCES videos(id),
   FOREIGN KEY (communities_news_id) REFERENCES communities(id)
);
	
-- таблица комментарии к медиа, новостной ленте
DROP TABLE IF EXISTS comments;
CREATE TABLE comments(
    id SERIAL PRIMARY KEY,
	user_commentator_id BIGINT UNSIGNED NOT NULL,
    user_owner_id BIGINT UNSIGNED NOT NULL,
	media_comments_id BIGINT UNSIGNED,
    news_comments_id BIGINT UNSIGNED,
    text_comments text NOT NULL,
        
    created_comments_at DATETIME DEFAULT NOW(),
        
   FOREIGN KEY (user_commentator_id) REFERENCES users(id),
   FOREIGN KEY (media_comments_id) REFERENCES media(id),
   FOREIGN KEY (news_comments_id) REFERENCES news(id),    
   FOREIGN KEY (user_owner_id) REFERENCES users(id)
   
);

-- Таблица комментарии к комментариям
DROP TABLE IF EXISTS `comment_comments`;
CREATE TABLE comment_comments(
    ctocs_id SERIAL PRIMARY KEY,
    user_ctocs_commentator_id BIGINT UNSIGNED NOT NULL,
    user_ctocs_owner_id BIGINT UNSIGNED NOT NULL,
    text_comments text NOT NULL,

   created_ctocs_at DATETIME DEFAULT NOW(),
        
   FOREIGN KEY (user_ctocs_commentator_id) REFERENCES users(id),   
   FOREIGN KEY (user_ctocs_owner_id) REFERENCES users(id)
);   
   ALTER TABLE `comment_comments` ADD CONSTRAINT fk_comments_id
   FOREIGN KEY (ctocs_id) REFERENCES comments(id)
   ON UPDATE CASCADE -- (значение по умолчанию)
   ON DELETE CASCADE; -- (значение по умолчанию)
   
-- таблица События-Календарь   
DROP TABLE IF EXISTS `events`;
CREATE TABLE events(
    id SERIAL PRIMARY KEY,
    user_event_id BIGINT UNSIGNED NOT NULL,
    text_event text NOT NULL,
    filename_event VARCHAR(255),
    size_event INT,
	metadata_event JSON,
	data_event DATETIME NOT NULL,

   created_event_at DATETIME DEFAULT NOW(),
        
   FOREIGN KEY (user_event_id) REFERENCES users(id)  
   
);  

-- Таблица запрос на совместное участие в Событии
DROP TABLE IF EXISTS event_request;
CREATE TABLE event_requests (
	event_requests_id SERIAL,
	initiator_user_event_id BIGINT UNSIGNED NOT NULL,
    target_user_event_id BIGINT UNSIGNED NOT NULL,
    status_event_request ENUM('requested', 'confirmed', 'declined'),
    requested_event_at DATETIME DEFAULT NOW(),
	updated_event_at datetime on UPDATE current_timestamp,
	confirmed_event_at DATETIME,
	
    PRIMARY KEY (initiator_user_event_id, target_user_event_id),
    FOREIGN KEY (initiator_user_event_id) REFERENCES users(id),
    FOREIGN KEY (target_user_event_id) REFERENCES users(id)
);

   ALTER TABLE event_requests ADD CONSTRAINT fk_event_id
   FOREIGN KEY (event_requests_id) REFERENCES events(id)
   ON UPDATE CASCADE 
   ON DELETE CASCADE; 

  -- Таблица Коммерческих предложений
  DROP TABLE IF EXISTS `proposals`;
  CREATE TABLE proposals(
    id SERIAL PRIMARY KEY,
    user_proposal_id BIGINT UNSIGNED NOT NULL,
    communities_proposal_id BIGINT UNSIGNED,
    text_proposal text NOT NULL,
    filename_proposal VARCHAR(255),
    size_proposal INT,
	metadata_proposal JSON,
	data_close_proposal DATETIME NOT NULL,

   created_proposal_at DATETIME DEFAULT NOW(),
   updated_proposal_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        
   FOREIGN KEY (user_proposal_id) REFERENCES users(id),  
   FOREIGN KEY (communities_proposal_id) REFERENCES communities(id)  

);













