--ESTRUCTURA DE LA BASE DE DATOS --

-- En primer lugar, creo mi base de datos y mi esquema para comenzar.

CREATE DATABASE capstone_project;

CREATE SCHEMA capstone_project;

-- Luego creo la estructura de mis 5 tablas que luego van a ser utilizadas para el analisis. Esta estructura es unicamente la base para ingresar los datos de los archivos .csv que previamente descargue de Kaggle.

CREATE TABLE capstone_project.customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state VARCHAR(2)
);

CREATE TABLE capstone_project.products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g NUMERIC,
    product_length_cm NUMERIC,
    product_height_cm NUMERIC,
    product_width_cm NUMERIC
);

CREATE TABLE capstone_project.orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32) REFERENCES capstone_project.customers(customer_id),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE capstone_project.order_items (
    order_id VARCHAR(32) REFERENCES capstone_project.orders(order_id),
    order_item_id INTEGER,
    product_id VARCHAR(32) REFERENCES capstone_project.products(product_id),
    seller_id VARCHAR(32),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE capstone_project.order_payments (
    order_id VARCHAR(32) REFERENCES capstone_project.orders(order_id),
    payment_sequential INTEGER,
    payment_type VARCHAR(30),
    payment_installments INTEGER,
    payment_value NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- Luego inserto las tablas en formato CSV del dataset de Kaggle en la estructura existente, utilizando el comando COPY.

COPY capstone_project.customers
FROM 'C:/SQL/dataset/olist_customers_dataset.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ','
);

COPY capstone_project.products
FROM 'C:/SQL/dataset/olist_products_dataset.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ','
);

COPY capstone_project.orders
FROM 'C:/SQL/dataset/olist_orders_dataset.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ','
);

COPY capstone_project.order_items
FROM 'C:/SQL/dataset/olist_order_items_dataset.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ','
);

COPY capstone_project.order_payments
FROM 'C:/SQL/dataset/olist_order_payments_dataset.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ','
);

-- Verificamos si existen precios nulos que puedan afectar el cálculo de ventas
SELECT COUNT(*)
FROM capstone_project.order_items
WHERE price IS NULL;

-- Verificamos si existen fechas de compra nulas que puedan afectar el análisis mensual
SELECT COUNT(*)
FROM capstone_project.orders
WHERE order_purchase_timestamp IS NULL;

