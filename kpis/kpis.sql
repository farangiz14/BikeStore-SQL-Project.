
--PROJECTS--
--DATABASE CREATION:
CREATE DATABASE BikeStoreDB
USE BikeStoreDB

--FOREIGN & PRIMARY KEY TABLES--
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name NVARCHAR(255) NOT NULL
);

CREATE TABLE brands (
    brand_id INT PRIMARY KEY,
    brand_name NVARCHAR(255) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name NVARCHAR(255) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    model_year INT,
    list_price DECIMAL(10,2),
    CONSTRAINT fk_products_brand FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name NVARCHAR(255) NOT NULL,
    phone NVARCHAR(50),
    email NVARCHAR(255),
    street NVARCHAR(255),
    city NVARCHAR(100),
    state NVARCHAR(100),
    zip_code NVARCHAR(20)
);

CREATE TABLE staffs (
    staff_id INT PRIMARY KEY,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(255),
    phone NVARCHAR(50),
    active BIT NOT NULL,
    store_id INT NOT NULL,
    manager_id INT NULL, -- a staff might not have a manager (for top level)
    CONSTRAINT fk_staffs_store FOREIGN KEY (store_id) REFERENCES stores(store_id),
    CONSTRAINT fk_staffs_manager FOREIGN KEY (manager_id) REFERENCES staffs(staff_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    phone NVARCHAR(50),
    email NVARCHAR(255),
    street NVARCHAR(255),
    city NVARCHAR(100),
    state NVARCHAR(100),
    zip_code NVARCHAR(20)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_status INT NOT NULL,
    order_date DATE NOT NULL,
    required_date DATE NOT NULL,
    shipped_date DATE,
    store_id INT NOT NULL,
    staff_id INT NOT NULL,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_orders_store FOREIGN KEY (store_id) REFERENCES stores(store_id),
    CONSTRAINT fk_orders_staff FOREIGN KEY (staff_id) REFERENCES staffs(staff_id)
);
CREATE TABLE order_items (
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    list_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(4,2) NOT NULL,
    PRIMARY KEY (order_id, item_id),
    CONSTRAINT fk_orderitems_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_orderitems_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE stocks (
    store_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (store_id, product_id),
    CONSTRAINT fk_stocks_store FOREIGN KEY (store_id) REFERENCES stores(store_id),
    CONSTRAINT fk_stocks_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);


--BULK INSERT:

--PRODUCTS--
BULK INSERT products
FROM 'C:\Users\Frey\Downloads\products (4).csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


--ORDERS--
BULK INSERT orders
FROM 'C:\Users\Frey\Downloads\orders (2).csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--ORDER ITEMS--
BULK INSERT order_items
FROM 'C:\Users\Frey\Downloads\order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--STORES--
BULK INSERT stores
FROM 'C:\Users\Frey\Downloads\stores.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


--STOCKS--
BULK INSERT stocks
FROM 'C:\Users\Frey\Downloads\stocks.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--STAFFS--
BULK INSERT staffs
FROM 'C:\Users\Frey\Downloads\staffs (2).csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


--CUSTOMERS--
BULK INSERT customers
FROM 'C:\Users\Frey\Downloads\customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--BRANDS--
BULK INSERT brands
FROM 'C:\Users\Frey\Downloads\brands.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--CATEGORIES--
BULK INSERT categories
FROM 'C:\Users\Frey\Downloads\categories.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


-- USER ACCESSS TO DATABASE--
CREATE LOGIN BIKESTORE WITH PASSWORD = 'team3group@';

CREATE LOGIN muslima_member WITH PASSWORD = 'muslima_member'
CREATE LOGIN abdumannof_member WITH PASSWORD = 'abdumannof_member'
CREATE LOGIN faxriddin_member WITH PASSWORD = 'faxriddin_member'

CREATE USER muslima_member FOR LOGIN muslima_member;
CREATE USER abdumannof_member FOR LOGIN abdumannof_member;
CREATE USER faxriddin_member FOR LOGIN faxriddin_member;

ALTER ROLE db_owner ADD MEMBER muslima_member
ALTER ROLE db_owner ADD MEMBER abdumannof_member
ALTER ROLE db_owner ADD MEMBER faxriddin_member


--TOTAL REVENUE--
select sum(quantity *(list_price - discount)) as Total_Revenue
from order_items

--AVERAGE REVENUE--
select sum(quantity *(list_price - discount))/sum(quantity) as Average_Revenue
from order_items;


--Average Inventory Value--
with AvgInv as(
select sum(s.quantity * p.list_price) as Average_Inventory_Value
from stocks s
join products p
on p.product_id = s.product_id
),

TS as(
select sum(quantity *(list_price - discount)) as Total_Sales
from order_items
)

select Total_Sales/Average_Inventory_Value as Inventory_Turnover
from TS sales,
	AvgInv inv;

--REVENUE BY STORE--
select sum(quantity *(list_price - discount)) as Total_Revenue, store_name
from order_items o1
join orders o2
on o2.order_id = o1.order_id
join stores s
on s.store_id = o2.store_id
group by store_name
order by  sum(quantity *(list_price - discount)) asc

----COST---
--DECLARE @Gross_Margin DECIMAL(5,2) = 0.37;

--SELECT
--    (quantity *(list_price - discount)) * (1 - @Gross_Margin) AS Estimated_Cost
--FROM
--    order_items


--GROSS PROFIT--
DECLARE @Gross_Margin DECIMAL(5, 2) = 0.37;

with sales as(
select c.category_name,
    sum(quantity *(o.list_price - discount)) as Revenue,
	sum((quantity *(o.list_price - discount)) * (1 - @Gross_Margin)) AS E_Cost
from
    order_items o
JOIN products p ON o.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
    GROUP BY c.category_name
)

select category_name, Revenue as Total_Revenue , E_Cost as Cost
from sales


--SALES BY BRAND--
select sum(quantity *(o.list_price - discount)) as Total_Revenue, brand_name
from order_items o
join products p
on p.product_id = o.product_id
join brands b
on b.brand_id = p.brand_id
group by b.brand_name
order by  sum(quantity *(o.list_price - discount)) desc

--STAFF REVENUE CONTRIBUTION--
select concat(sta.first_name, ' ', sta.last_name) as Staff_Name,
		sum(quantity *(list_price - discount)) as Total_Revenue
from order_items oi
join orders o
on o.order_id = oi.order_id
join stores sto
on sto.store_id = o.store_id
join staffs sta
on sta.store_id = sto.store_id
group by first_name, last_name
order by sum(quantity *(list_price - discount)) desc

--PRODUCT RETURN RATE--
--Return's Table
CREATE TABLE returns (
    return_id        INT IDENTITY(1,1) PRIMARY KEY,
    order_id         INT NOT NULL,
    product_id       INT NOT NULL,
    quantity_returned INT NOT NULL,
    return_date      DATE NOT NULL,
    return_reason    NVARCHAR(255) NULL,
    CONSTRAINT fk_returns_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_returns_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO returns (
    order_id,
    product_id,
    quantity_returned,     
    return_date,
    return_reason
)
VALUES
  (1,  20, 1, '2016-01-03', 'Defective part'),
  (2,  20, 1, '2016-01-03', 'Wrong size'),
    (5, 10, 2, '2016-01-04', 'Damaged on delivery'),
    (5, 17, 1, '2016-01-04', 'Wrong item'),
    (5, 26, 1, '2016-01-04', 'Not satisfied'),
    (6, 18, 1, '2016-01-05', 'Late delivery'),
    (6, 12, 2, '2016-01-05', 'Defective'),
    (6, 20, 1, '2016-01-05', 'Wrong size'),
    (4, 3, 2, '2016-01-06', 'Broken frame'),
    (3, 2, 1, '2016-01-06', 'Does not fit'),
    (7, 15, 1, '2016-01-06', 'Missing parts');
	(24, 3, 2, '2016-01-07', 'Customer changed mind'),
	(24, 18, 2, '2016-01-07', 'Customer changed mind'),
	(25, 23, 2, '2016-01-07', 'Customer changed mind'),
	(25, 10, 2, '2016-01-07', 'Customer changed mind'),
	(25, 22, 1, '2016-01-07', 'Customer changed mind'),
	(25, 14, 1, '2016-01-07', 'Customer changed mind'),
	(25, 21, 1, '2016-01-07', 'Customer changed mind'),
	(26, 7, 1, '2016-01-07', 'Customer changed mind'),
	(26, 2, 1, '2016-01-07', 'Customer changed mind'),
	(26, 12, 1, '2016-01-07', 'Customer changed mind'),
	(26, 21, 2, '2016-01-07', 'Customer changed mind'),
	(27, 5, 1, '2016-01-07', 'Customer changed mind'),
	(27, 19, 1, '2016-01-07', 'Customer changed mind'),
	(27, 26, 2, '2016-01-07', 'Customer changed mind'),
	(27, 8, 1, '2016-01-07', 'Customer changed mind');

--RETURN RATE CALCULATION--
select round(count(return_id) * 100.0 / (select count(order_id) from order_items), 6) as Return_Rate
from returns r



--select * from categories
--select * from brands
--select * from Customers
--select * from staffs

--select * from returns
--select * from order_items
--select * from Orders
--select * from stores
--select * from staffs

--select * from products
--select * from stocks
