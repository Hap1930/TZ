CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    post_date DATETIME NOT NULL,
    post_date_last DATETIME NOT NULL,
    likes_count INT NOT NULL,
    day_of_week ENUM('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'),
    time_of_day ENUM('morning', 'afternoon', 'evening', 'night'),
    time_since_last_post TIME,
    time_type ENUM('from 1 to 5 minutes', 'from 5 minutes to an hour', 'from one to 5 hours', 'from 5 to 12 hours', 'from 12 to 24 hours', 'More than a day')
);

DELIMITER //

CREATE TRIGGER calculate_time_since_last_post
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    -- Вычисляем разницу между post_date и post_date_last
    SET NEW.time_since_last_post = TIMEDIFF(NEW.post_date, NEW.post_date_last);
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER set_day_of_week
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    -- Определяем день недели по post_date
    SET NEW.day_of_week = DAYNAME(NEW.post_date);
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER set_time_of_day
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    -- Определяем время суток по post_date
    DECLARE hour_of_day INT;
    SET hour_of_day = HOUR(NEW.post_date);

    -- Записываем время суток в поле time_of_day
    IF hour_of_day >= 6 AND hour_of_day < 12 THEN
        SET NEW.time_of_day = 'morning';
    ELSEIF hour_of_day >= 12 AND hour_of_day < 18 THEN
        SET NEW.time_of_day = 'afternoon';
    ELSEIF hour_of_day >= 18 AND hour_of_day < 24 THEN
        SET NEW.time_of_day = 'evening';
    ELSE
        SET NEW.time_of_day = 'night';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER set_time_type
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    DECLARE time_diff TIME;
    DECLARE time_type_value ENUM('from 1 to 5 minutes', 'from 5 minutes to an hour', 'from one to 5 hours', 'from 5 to 12 hours', 'from 12 to 24 hours', 'More than a day');

    SET time_diff = NEW.time_since_last_post;

    IF time_diff <= '00:05:00' THEN
        SET time_type_value = 'from 1 to 5 minutes';
    ELSEIF time_diff > '00:05:00' AND time_diff <= '01:00:00' THEN
        SET time_type_value = 'from 5 minutes to an hour';
    ELSEIF time_diff > '01:00:00' AND time_diff <= '05:00:00' THEN
        SET time_type_value = 'from one to 5 hours';
    ELSEIF time_diff > '05:00:00' AND time_diff <= '12:00:00' THEN
        SET time_type_value = 'from 5 to 12 hours';
    ELSEIF time_diff > '12:00:00' AND time_diff <= '24:00:00' THEN
        SET time_type_value = 'from 12 to 24 hours';
    ELSE
        SET time_type_value = 'More than a day';
    END IF;

    SET NEW.time_type = time_type_value;
END //

DELIMITER ;

