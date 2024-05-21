CREATE DATABASE IF NOT EXISTS employee_database;
USE employee_database;

CREATE TABLE employee_data (
    name VARCHAR(255),
    address VARCHAR(255)
);

INSERT INTO employee_data (name, address) VALUES ('Ivan Mladenov', '531 Foo Lane');
INSERT INTO employee_data (name, address) VALUES ('Abhinav Inavolu', '530 Foo Drive');