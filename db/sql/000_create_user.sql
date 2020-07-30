-- MySQL5.6ではパスワードの強度設定がないらしい
-- SET GLOBAL validate_password_policy=LOW;
CREATE USER 'testuser1'@'localhost' IDENTIFIED BY 'pass2';
CREATE USER 'testuser2'@'localhost' IDENTIFIED BY 'pass2';

GRANT SELECT ON *.* TO testuser1@localhost WITH GRANT OPTION;
GRANT SELECT,INSERT,UPDATE ON *.* TO testuser2@localhost WITH GRANT OPTION;
