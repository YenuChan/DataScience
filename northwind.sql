-- ============================================================
-- Northwind（北风贸易）示例数据库
-- 用于 SQL 练习：多表连接 / 分组统计 / 子查询 / 视图
-- 表：categories, suppliers, products, customers,
--     employees, shippers, orders, order_details
-- ============================================================
--
-- 在 DataGrip 里怎么用：
--   1. 打开这个文件（双击左侧项目树里的 northwind.sql）
--   2. 顶部会提示 Choose Data Source / 目标数据源，选「小皮」
--   3. 光标放任意位置，按 Ctrl+Enter 执行当前语句
--      或者右键 -> Run 'northwind.sql' 执行整个文件
--   4. 执行完，左侧树里会出现 northwind 库和 8 张表
--
-- 注意：本文件会先 DROP 同名的 8 张表再重建，
--       如果 northwind 库里有你自己的表，请先改名保存。
-- ============================================================

CREATE DATABASE IF NOT EXISTS northwind
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;
USE northwind;

-- 临时关闭外键检查：
--   employees 表有一列 reports_to 指向自己（员工汇报给谁），
--   如果先插员工 1（汇报给员工 2），此时员工 2 还不存在，
--   开着外键检查会直接报错 1452。
--   关闭检查后再插数据，是导出示例库的标准做法（mysqldump 也这么干）。
SET FOREIGN_KEY_CHECKS = 0;

-- 先删旧表（顺序要按外键依赖倒过来）
DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS shippers;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS categories;

-- ---------- 1. categories 商品类别 ----------
CREATE TABLE categories (
    category_id   INT          PRIMARY KEY,
    category_name VARCHAR(30)  NOT NULL,
    description   VARCHAR(200)
);

INSERT INTO categories VALUES (1, 'Beverages', 'Soft drinks, coffees, teas, beers, and ales');
INSERT INTO categories VALUES (2, 'Condiments', 'Sweet and savory sauces, relishes, spreads, and seasonings');
INSERT INTO categories VALUES (3, 'Confections', 'Desserts, candies, and sweet breads');
INSERT INTO categories VALUES (4, 'Dairy Products', 'Cheeses');
INSERT INTO categories VALUES (5, 'Grains/Cereals', 'Breads, crackers, pasta, and cereal');
INSERT INTO categories VALUES (6, 'Meat/Poultry', 'Prepared meats');
INSERT INTO categories VALUES (7, 'Produce', 'Dried fruit and bean curd');
INSERT INTO categories VALUES (8, 'Seafood', 'Seaweed and fish');

-- ---------- 2. suppliers 供应商 ----------
CREATE TABLE suppliers (
    supplier_id  INT         PRIMARY KEY,
    company_name VARCHAR(50) NOT NULL,
    contact_name VARCHAR(40),
    city         VARCHAR(20),
    country      VARCHAR(20),
    phone        VARCHAR(20)
);

INSERT INTO suppliers VALUES (1, 'Exotic Liquids', 'Charlotte Cooper', 'London', 'UK', '(171) 555-2222');
INSERT INTO suppliers VALUES (2, 'New Orleans Cajun Delights', 'Shelley Burke', 'New Orleans', 'USA', '(100) 555-4822');
INSERT INTO suppliers VALUES (3, 'Grandma Kelly''s Homestead', 'Regina Murphy', 'Ann Arbor', 'USA', '(313) 555-5735');
INSERT INTO suppliers VALUES (4, 'Tokyo Traders', 'Yoshi Nagase', 'Tokyo', 'Japan', '(03) 3555-5011');
INSERT INTO suppliers VALUES (5, 'Cooperativa de Quesos Las Cabras', 'Antonio del Valle Saavedra', 'Oviedo', 'Spain', '(98) 598 76 54');
INSERT INTO suppliers VALUES (6, 'Mayumi''s', 'Mayumi Ohno', 'Osaka', 'Japan', '(06) 431-7877');
INSERT INTO suppliers VALUES (7, 'Pavlova, Ltd.', 'Ian Devling', 'Melbourne', 'Australia', '(03) 444-2343');
INSERT INTO suppliers VALUES (8, 'Specialty Biscuits, Ltd.', 'Peter Wilson', 'Manchester', 'UK', '(161) 555-4448');
INSERT INTO suppliers VALUES (9, 'PB Knackebrod AB', 'Lars Peterson', 'Goteborg', 'Sweden', '031-987 65 43');
INSERT INTO suppliers VALUES (10, 'Refrescos Americanas LTDA', 'Carlos Diaz', 'Sao Paulo', 'Brazil', '(11) 555 4640');
INSERT INTO suppliers VALUES (11, 'Heli Susswaren GmbH', 'Petra Winkler', 'Frankfurt', 'Germany', '(069) 55-82-0');
INSERT INTO suppliers VALUES (12, 'Plutzer Lebensmittelgrossmarkte AG', 'Martin Bein', 'Frankfurt', 'Germany', '(069) 55-82-0');
INSERT INTO suppliers VALUES (13, 'Nord-Ost-Fisch Handelsgesellschaft mbH', 'Sven Petersen', 'Cuxhaven', 'Germany', '(04721) 8713');
INSERT INTO suppliers VALUES (14, 'Formaggi Fortini s.r.l.', 'Elio Rossi', 'Ravenna', 'Italy', '(0544) 60323');
INSERT INTO suppliers VALUES (15, 'Norske Meierier', 'Beate Vileid', 'Sandvika', 'Norway', '(0)2-953010');
INSERT INTO suppliers VALUES (16, 'Bigfoot Breweries', 'Cheryl Saylor', 'Bend', 'USA', '(503) 555-9931');
INSERT INTO suppliers VALUES (17, 'Svensk Sjofoda AB', 'Michael Bjorn', 'Stockholm', 'Sweden', '08-123 45 67');
INSERT INTO suppliers VALUES (18, 'Aux joyeux ecclesiastiques', 'Guylaine Nollet', 'Paris', 'France', '(1) 03.83.00.62');
INSERT INTO suppliers VALUES (19, 'New England Seafood Cannery', 'Robb Merchant', 'Boston', 'USA', '(617) 555-3267');
INSERT INTO suppliers VALUES (20, 'Leka Trading', 'Chandra Leka', 'Singapore', 'Singapore', '555-8787');

-- ---------- 3. products 商品 ----------
CREATE TABLE products (
    product_id       INT           PRIMARY KEY,
    product_name     VARCHAR(50)   NOT NULL,
    supplier_id      INT,
    category_id      INT,
    quantity_per_unit VARCHAR(30),
    unit_price       DECIMAL(10,2) NOT NULL DEFAULT 0,
    units_in_stock   INT           NOT NULL DEFAULT 0,
    units_on_order   INT           NOT NULL DEFAULT 0,
    reorder_level    INT           NOT NULL DEFAULT 0,
    discontinued     TINYINT       NOT NULL DEFAULT 0,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

INSERT INTO products VALUES (1, 'Chai', 1, 1, '10 boxes x 20 bags', 18.00, 39, 0, 10, 0);
INSERT INTO products VALUES (2, 'Chang', 1, 1, '24 - 12 oz bottles', 19.00, 17, 40, 25, 0);
INSERT INTO products VALUES (3, 'Aniseed Syrup', 1, 2, '12 - 550 ml bottles', 10.00, 13, 70, 25, 0);
INSERT INTO products VALUES (4, 'Chef Anton''s Cajun Seasoning', 2, 2, '48 - 6 oz jars', 22.00, 53, 0, 0, 0);
INSERT INTO products VALUES (5, 'Chef Anton''s Gumbo Mix', 2, 2, '36 boxes', 21.35, 0, 0, 0, 1);
INSERT INTO products VALUES (6, 'Grandma''s Boysenberry Spread', 3, 2, '12 - 8 oz jars', 25.00, 120, 0, 25, 0);
INSERT INTO products VALUES (7, 'Uncle Bob''s Organic Dried Pears', 3, 7, '12 - 1 lb pkgs.', 30.00, 15, 0, 10, 0);
INSERT INTO products VALUES (8, 'Northwoods Cranberry Sauce', 3, 2, '12 - 12 oz jars', 40.00, 6, 0, 0, 0);
INSERT INTO products VALUES (9, 'Mishi Kobe Niku', 4, 6, '18 - 500 g pkgs.', 97.00, 29, 0, 0, 1);
INSERT INTO products VALUES (10, 'Ikura', 4, 8, '12 - 200 ml jars', 31.00, 31, 0, 0, 0);
INSERT INTO products VALUES (11, 'Queso Cabrales', 5, 4, '1 kg pkg.', 21.00, 22, 30, 30, 0);
INSERT INTO products VALUES (12, 'Queso Manchego La Pastora', 5, 4, '10 - 500 g pkgs.', 38.00, 86, 0, 0, 0);
INSERT INTO products VALUES (13, 'Konbu', 6, 8, '2 kg box', 6.00, 24, 0, 5, 0);
INSERT INTO products VALUES (14, 'Tofu', 6, 7, '40 - 100 g pkgs.', 23.25, 35, 0, 0, 0);
INSERT INTO products VALUES (15, 'Genen Shouyu', 6, 2, '24 - 250 ml bottles', 15.50, 39, 0, 5, 0);
INSERT INTO products VALUES (16, 'Pavlova', 7, 3, '32 - 500 g boxes', 17.45, 29, 0, 10, 0);
INSERT INTO products VALUES (17, 'Alice Mutton', 7, 6, '20 - 1 kg tins', 39.00, 0, 0, 0, 1);
INSERT INTO products VALUES (18, 'Carnarvon Tigers', 7, 8, '16 kg pkg.', 62.50, 42, 0, 0, 0);
INSERT INTO products VALUES (19, 'Teatime Chocolate Biscuits', 8, 3, '10 boxes x 12 pieces', 9.20, 25, 0, 5, 0);
INSERT INTO products VALUES (20, 'Sir Rodney''s Marmalade', 8, 3, '30 gift boxes', 81.00, 40, 0, 0, 0);
INSERT INTO products VALUES (21, 'Sir Rodney''s Scones', 8, 3, '24 pkgs. x 4 pieces', 10.00, 3, 40, 5, 0);
INSERT INTO products VALUES (22, 'Gustaf''s Knackebrod', 9, 5, '24 - 500 g pkgs.', 21.00, 104, 0, 25, 0);
INSERT INTO products VALUES (23, 'Tunnbrod', 9, 5, '12 - 250 g pkgs.', 9.00, 61, 0, 25, 0);
INSERT INTO products VALUES (24, 'Guarana Fantastica', 10, 1, '12 - 355 ml cans', 4.50, 20, 0, 0, 1);
INSERT INTO products VALUES (25, 'NuNuCa Nuss-Nougat-Creme', 11, 3, '20 - 450 g glasses', 14.00, 76, 0, 30, 0);
INSERT INTO products VALUES (26, 'Gumbar Gummibarchen', 11, 3, '100 - 250 g bags', 31.23, 15, 0, 0, 0);
INSERT INTO products VALUES (27, 'Schoggi Schokolade', 11, 3, '100 - 100 g pieces', 43.90, 49, 0, 30, 0);
INSERT INTO products VALUES (28, 'Rossle Sauerkraut', 12, 7, '25 - 825 g cans', 45.60, 26, 0, 0, 1);
INSERT INTO products VALUES (29, 'Thuringer Rostbratwurst', 12, 6, '50 bags x 30 sausgs.', 123.79, 0, 0, 0, 1);
INSERT INTO products VALUES (30, 'Nord-Ost Matjeshering', 13, 8, '10 - 200 g glasses', 25.89, 10, 0, 15, 0);
INSERT INTO products VALUES (31, 'Gorgonzola Telino', 14, 4, '12 - 100 g pkgs', 12.50, 0, 70, 20, 0);
INSERT INTO products VALUES (32, 'Mascarpone Fabioli', 14, 4, '24 - 200 g pkgs.', 32.00, 9, 40, 25, 0);
INSERT INTO products VALUES (33, 'Geitost', 15, 4, '500 g', 2.50, 112, 0, 20, 0);
INSERT INTO products VALUES (34, 'Sasquatch Ale', 16, 1, '24 - 12 oz bottles', 14.00, 111, 0, 15, 0);
INSERT INTO products VALUES (35, 'Steeleye Stout', 16, 1, '24 - 12 oz bottles', 18.00, 20, 0, 15, 0);
INSERT INTO products VALUES (36, 'Inlagd Sill', 17, 8, '24 - 250 g jars', 19.00, 112, 0, 20, 0);
INSERT INTO products VALUES (37, 'Gravad lax', 17, 8, '12 - 500 g pkgs.', 26.00, 11, 50, 25, 0);
INSERT INTO products VALUES (38, 'Cote de Blaye', 18, 1, '12 - 75 cl bottles', 263.50, 17, 0, 15, 0);
INSERT INTO products VALUES (39, 'Chartreuse verte', 18, 1, '750 cc per bottle', 18.00, 69, 0, 5, 0);
INSERT INTO products VALUES (40, 'Boston Crab Meat', 19, 8, '24 - 4 oz tins', 18.40, 123, 0, 30, 0);

-- ---------- 4. customers 客户 ----------
CREATE TABLE customers (
    customer_id   CHAR(5)     PRIMARY KEY,
    company_name  VARCHAR(50) NOT NULL,
    contact_name  VARCHAR(40),
    contact_title VARCHAR(30),
    city          VARCHAR(20),
    country       VARCHAR(20),
    phone         VARCHAR(20)
);

INSERT INTO customers VALUES ('ALFKI', 'Alfreds Futterkiste', 'Maria Anders', 'Sales Representative', 'Berlin', 'Germany', '030-0074321');
INSERT INTO customers VALUES ('ANATR', 'Ana Trujillo Emparedados y helados', 'Ana Trujillo', 'Owner', 'Mexico D.F.', 'Mexico', '(5) 555-4729');
INSERT INTO customers VALUES ('ANTON', 'Antonio Moreno Taqueria', 'Antonio Moreno', 'Owner', 'Mexico D.F.', 'Mexico', '(5) 555-3932');
INSERT INTO customers VALUES ('AROUT', 'Around the Horn', 'Thomas Hardy', 'Sales Representative', 'London', 'UK', '(171) 555-7788');
INSERT INTO customers VALUES ('BERGS', 'Berglunds snabbkop', 'Christina Berglund', 'Order Administrator', 'Lulea', 'Sweden', '0921-12 34 65');
INSERT INTO customers VALUES ('BLAUS', 'Blauer See Delikatessen', 'Hanna Moos', 'Sales Representative', 'Mannheim', 'Germany', '0621-08460');
INSERT INTO customers VALUES ('BLONP', 'Blondesddsl pere et fils', 'Frederique Citeaux', 'Marketing Manager', 'Strasbourg', 'France', '88.60.15.31');
INSERT INTO customers VALUES ('BOLID', 'Bolido Comidas preparadas', 'Martin Sommer', 'Owner', 'Madrid', 'Spain', '(91) 555 22 82');
INSERT INTO customers VALUES ('BONAP', 'Bon app', 'Laurence Lebihan', 'Owner', 'Marseille', 'France', '91.24.45.40');
INSERT INTO customers VALUES ('BOTTM', 'Bottom-Dollar Markets', 'Elizabeth Lincoln', 'Accounting Manager', 'Tsawassen', 'Canada', '(604) 555-4729');
INSERT INTO customers VALUES ('BSBEV', 'B''s Beverages', 'Victoria Ashworth', 'Sales Representative', 'London', 'UK', '(171) 555-1212');
INSERT INTO customers VALUES ('CACTU', 'Cactus Comidas para llevar', 'Patricio Simpson', 'Sales Agent', 'Buenos Aires', 'Argentina', '(1) 135-5555');
INSERT INTO customers VALUES ('CENTC', 'Centro comercial Moctezuma', 'Francisco Chang', 'Marketing Manager', 'Mexico D.F.', 'Mexico', '(5) 555-3392');
INSERT INTO customers VALUES ('CHOPS', 'Chop-suey Chinese', 'Yang Wang', 'Owner', 'Bern', 'Switzerland', '0452-076545');
INSERT INTO customers VALUES ('COMMI', 'Comercio Mineiro', 'Pedro Afonso', 'Sales Associate', 'Sao Paulo', 'Brazil', '(11) 555-7647');
INSERT INTO customers VALUES ('CONSH', 'Consolidated Holdings', 'Elizabeth Brown', 'Sales Representative', 'London', 'UK', '(171) 555-2282');
INSERT INTO customers VALUES ('DRACD', 'Drachenblut Delikatessen', 'Sven Ottlieb', 'Order Administrator', 'Aachen', 'Germany', '0241-039123');
INSERT INTO customers VALUES ('DUMON', 'Du monde entier', 'Janine Labrune', 'Owner', 'Nantes', 'France', '40.67.88.88');
INSERT INTO customers VALUES ('EASTC', 'Eastern Connection', 'Ann Devon', 'Sales Agent', 'London', 'UK', '(171) 555-0297');
INSERT INTO customers VALUES ('ERNSH', 'Ernst Handel', 'Roland Mendel', 'Sales Manager', 'Graz', 'Austria', '7675-3425');

-- ---------- 5. employees 员工 ----------
CREATE TABLE employees (
    employee_id      INT         PRIMARY KEY,
    last_name        VARCHAR(20) NOT NULL,
    first_name       VARCHAR(20) NOT NULL,
    title            VARCHAR(30),
    title_of_courtesy VARCHAR(10),
    birth_date       DATE,
    hire_date        DATE,
    city             VARCHAR(20),
    country          VARCHAR(20),
    reports_to       INT,
    FOREIGN KEY (reports_to) REFERENCES employees(employee_id)
);

INSERT INTO employees VALUES (1, 'Davolio', 'Nancy', 'Sales Representative', 'Ms.', '1948-12-08', '1992-05-01', 'Seattle', 'USA', 2);
INSERT INTO employees VALUES (2, 'Fuller', 'Andrew', 'Vice President, Sales', 'Dr.', '1952-02-19', '1992-08-14', 'Tacoma', 'USA', NULL);
INSERT INTO employees VALUES (3, 'Leverling', 'Janet', 'Sales Representative', 'Ms.', '1963-08-30', '1992-04-01', 'Kirkland', 'USA', 2);
INSERT INTO employees VALUES (4, 'Peacock', 'Margaret', 'Sales Representative', 'Mrs.', '1958-09-19', '1993-05-03', 'Redmond', 'USA', 2);
INSERT INTO employees VALUES (5, 'Buchanan', 'Steven', 'Sales Manager', 'Mr.', '1955-03-04', '1993-10-17', 'London', 'UK', 2);
INSERT INTO employees VALUES (6, 'Suyama', 'Michael', 'Sales Representative', 'Mr.', '1963-07-02', '1993-10-17', 'London', 'UK', 5);
INSERT INTO employees VALUES (7, 'King', 'Robert', 'Sales Representative', 'Mr.', '1960-05-29', '1994-01-02', 'London', 'UK', 5);
INSERT INTO employees VALUES (8, 'Callahan', 'Laura', 'Inside Sales Coordinator', 'Ms.', '1958-01-09', '1994-03-05', 'Seattle', 'USA', 2);
INSERT INTO employees VALUES (9, 'Dodsworth', 'Anne', 'Sales Representative', 'Ms.', '1966-01-27', '1994-11-15', 'London', 'UK', 5);

-- ---------- 6. shippers 承运商 ----------
CREATE TABLE shippers (
    shipper_id   INT         PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    phone        VARCHAR(20)
);

INSERT INTO shippers VALUES (1, 'Speedy Express', '(503) 555-9831');
INSERT INTO shippers VALUES (2, 'United Package', '(503) 555-3199');
INSERT INTO shippers VALUES (3, 'Federal Shipping', '(503) 555-9931');

-- ---------- 7. orders 订单 ----------
CREATE TABLE orders (
    order_id      INT           PRIMARY KEY,
    customer_id   CHAR(5),
    employee_id   INT,
    order_date    DATE          NOT NULL,
    required_date DATE,
    shipped_date  DATE,
    shipper_id    INT,
    freight       DECIMAL(10,2) NOT NULL DEFAULT 0,
    ship_city     VARCHAR(20),
    ship_country  VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (shipper_id)  REFERENCES shippers(shipper_id)
);

INSERT INTO orders VALUES (1, 'BSBEV', 8, '2024-04-10', '2024-04-19', '2024-04-15', 3, 295.41, 'London', 'UK');
INSERT INTO orders VALUES (2, 'CACTU', 5, '2024-11-13', '2024-11-23', '2024-11-16', 2, 245.82, 'Buenos Aires', 'Argentina');
INSERT INTO orders VALUES (3, 'COMMI', 8, '2024-12-16', '2024-12-20', '2024-12-20', 3, 156.94, 'Sao Paulo', 'Brazil');
INSERT INTO orders VALUES (4, 'CONSH', 3, '2024-01-09', '2024-01-20', '2024-01-10', 2, 237.06, 'London', 'UK');
INSERT INTO orders VALUES (5, 'BOTTM', 8, '2024-06-05', '2024-06-16', '2024-06-06', 2, 117.63, 'Tsawassen', 'Canada');
INSERT INTO orders VALUES (6, 'BOLID', 8, '2024-06-15', '2024-06-23', '2024-06-17', 1, 84.49, 'Madrid', 'Spain');
INSERT INTO orders VALUES (7, 'ALFKI', 7, '2024-02-13', '2024-02-16', '2024-02-14', 1, 109.17, 'Berlin', 'Germany');
INSERT INTO orders VALUES (8, 'ANATR', 2, '2024-10-24', '2024-10-28', '2024-10-28', 3, 295.58, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (9, 'CACTU', 8, '2024-01-18', '2024-01-25', '2024-01-19', 3, 81.08, 'Buenos Aires', 'Argentina');
INSERT INTO orders VALUES (10, 'ANATR', 8, '2024-03-02', '2024-03-10', '2024-03-07', 2, 212.50, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (11, 'ALFKI', 6, '2024-11-12', '2024-11-18', '2024-11-17', 2, 197.98, 'Berlin', 'Germany');
INSERT INTO orders VALUES (12, 'ANTON', 4, '2024-12-28', '2024-12-28', '2024-12-28', 2, 5.65, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (13, 'CHOPS', 4, '2024-12-23', '2024-12-28', '2024-12-26', 2, 30.36, 'Bern', 'Switzerland');
INSERT INTO orders VALUES (14, 'ANTON', 1, '2024-11-04', '2024-11-13', '2024-11-07', 2, 39.43, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (15, 'ALFKI', 7, '2024-03-08', '2024-03-21', '2024-03-09', 2, 41.37, 'Berlin', 'Germany');
INSERT INTO orders VALUES (16, 'ANTON', 5, '2024-06-17', '2024-06-26', '2024-06-18', 3, 283.36, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (17, 'BOTTM', 3, '2024-09-23', '2024-09-28', '2024-09-28', 1, 119.07, 'Tsawassen', 'Canada');
INSERT INTO orders VALUES (18, 'CONSH', 6, '2024-11-17', '2024-11-28', '2024-11-22', 3, 144.21, 'London', 'UK');
INSERT INTO orders VALUES (19, 'AROUT', 1, '2024-07-24', '2024-07-28', '2024-07-26', 3, 168.53, 'London', 'UK');
INSERT INTO orders VALUES (20, 'BSBEV', 2, '2024-12-02', '2024-12-06', '2024-12-04', 1, 226.21, 'London', 'UK');
INSERT INTO orders VALUES (21, 'BOLID', 7, '2024-11-17', '2024-11-28', '2024-11-18', 3, 241.99, 'Madrid', 'Spain');
INSERT INTO orders VALUES (22, 'DRACD', 2, '2024-11-03', '2024-11-07', '2024-11-08', 3, 154.92, 'Aachen', 'Germany');
INSERT INTO orders VALUES (23, 'COMMI', 5, '2024-09-10', '2024-09-17', '2024-09-12', 1, 136.97, 'Sao Paulo', 'Brazil');
INSERT INTO orders VALUES (24, 'CONSH', 3, '2024-02-09', '2024-02-17', '2024-02-13', 3, 16.76, 'London', 'UK');
INSERT INTO orders VALUES (25, 'AROUT', 8, '2024-04-11', '2024-04-20', NULL, 1, 36.51, 'London', 'UK');
INSERT INTO orders VALUES (26, 'BLONP', 1, '2024-06-16', '2024-06-28', '2024-06-17', 2, 128.27, 'Strasbourg', 'France');
INSERT INTO orders VALUES (27, 'BONAP', 4, '2024-07-12', '2024-07-16', '2024-07-17', 2, 172.97, 'Marseille', 'France');
INSERT INTO orders VALUES (28, 'ALFKI', 4, '2024-09-06', '2024-09-18', NULL, 2, 124.86, 'Berlin', 'Germany');
INSERT INTO orders VALUES (29, 'BOTTM', 6, '2024-10-25', '2024-10-28', '2024-10-27', 1, 80.12, 'Tsawassen', 'Canada');
INSERT INTO orders VALUES (30, 'BLONP', 1, '2024-02-26', '2024-02-28', '2024-02-27', 3, 178.76, 'Strasbourg', 'France');
INSERT INTO orders VALUES (31, 'BLONP', 2, '2024-11-28', '2024-11-28', '2024-11-28', 3, 252.03, 'Strasbourg', 'France');
INSERT INTO orders VALUES (32, 'BLAUS', 1, '2024-07-13', '2024-07-22', '2024-07-14', 2, 223.40, 'Mannheim', 'Germany');
INSERT INTO orders VALUES (33, 'CACTU', 5, '2024-12-06', '2024-12-20', '2024-12-09', 2, 164.19, 'Buenos Aires', 'Argentina');
INSERT INTO orders VALUES (34, 'BOTTM', 5, '2024-11-14', '2024-11-22', '2024-11-15', 3, 59.45, 'Tsawassen', 'Canada');
INSERT INTO orders VALUES (35, 'DRACD', 3, '2024-05-28', '2024-05-28', '2024-05-28', 3, 277.06, 'Aachen', 'Germany');
INSERT INTO orders VALUES (36, 'ALFKI', 1, '2024-10-11', '2024-10-19', '2024-10-12', 2, 132.47, 'Berlin', 'Germany');
INSERT INTO orders VALUES (37, 'CHOPS', 3, '2024-09-09', '2024-09-23', '2024-09-12', 3, 60.95, 'Bern', 'Switzerland');
INSERT INTO orders VALUES (38, 'ANATR', 2, '2024-01-24', '2024-01-28', '2024-01-28', 2, 296.61, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (39, 'BSBEV', 8, '2024-04-28', '2024-04-28', '2024-04-28', 2, 104.68, 'London', 'UK');
INSERT INTO orders VALUES (40, 'CENTC', 6, '2024-01-23', '2024-01-27', '2024-01-24', 1, 175.26, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (41, 'BONAP', 1, '2025-07-09', '2025-07-22', '2025-07-12', 1, 155.76, 'Marseille', 'France');
INSERT INTO orders VALUES (42, 'COMMI', 3, '2025-02-03', '2025-02-13', '2025-02-05', 1, 42.98, 'Sao Paulo', 'Brazil');
INSERT INTO orders VALUES (43, 'CONSH', 5, '2025-05-21', '2025-05-28', '2025-05-25', 3, 129.21, 'London', 'UK');
INSERT INTO orders VALUES (44, 'CACTU', 3, '2025-08-25', '2025-08-28', '2025-08-28', 1, 186.99, 'Buenos Aires', 'Argentina');
INSERT INTO orders VALUES (45, 'ANTON', 4, '2025-02-24', '2025-02-28', '2025-02-27', 2, 192.38, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (46, 'BLAUS', 2, '2025-12-11', '2025-12-25', '2025-12-12', 2, 36.32, 'Mannheim', 'Germany');
INSERT INTO orders VALUES (47, 'CACTU', 1, '2025-12-04', '2025-12-15', '2025-12-09', 2, 72.47, 'Buenos Aires', 'Argentina');
INSERT INTO orders VALUES (48, 'BOLID', 3, '2025-07-05', '2025-07-10', '2025-07-06', 3, 175.45, 'Madrid', 'Spain');
INSERT INTO orders VALUES (49, 'BOLID', 7, '2025-03-28', '2025-03-28', '2025-03-28', 1, 284.57, 'Madrid', 'Spain');
INSERT INTO orders VALUES (50, 'COMMI', 3, '2025-05-17', '2025-05-28', '2025-05-19', 1, 23.91, 'Sao Paulo', 'Brazil');
INSERT INTO orders VALUES (51, 'AROUT', 2, '2025-09-24', '2025-09-28', '2025-09-28', 3, 277.64, 'London', 'UK');
INSERT INTO orders VALUES (52, 'BONAP', 4, '2025-08-09', '2025-08-14', '2025-08-14', 3, 49.90, 'Marseille', 'France');
INSERT INTO orders VALUES (53, 'CHOPS', 3, '2025-06-03', '2025-06-13', '2025-06-07', 2, 106.11, 'Bern', 'Switzerland');
INSERT INTO orders VALUES (54, 'ANATR', 4, '2025-03-10', '2025-03-16', '2025-03-12', 3, 56.30, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (55, 'ALFKI', 1, '2025-11-24', '2025-11-27', '2025-11-27', 3, 291.22, 'Berlin', 'Germany');
INSERT INTO orders VALUES (56, 'COMMI', 8, '2025-06-09', '2025-06-14', '2025-06-13', 1, 218.62, 'Sao Paulo', 'Brazil');
INSERT INTO orders VALUES (57, 'BOTTM', 3, '2025-06-25', '2025-06-28', '2025-06-28', 3, 174.93, 'Tsawassen', 'Canada');
INSERT INTO orders VALUES (58, 'BONAP', 1, '2025-09-28', '2025-09-28', '2025-09-28', 3, 189.53, 'Marseille', 'France');
INSERT INTO orders VALUES (59, 'BOLID', 7, '2025-02-08', '2025-02-12', '2025-02-12', 1, 98.74, 'Madrid', 'Spain');
INSERT INTO orders VALUES (60, 'BOTTM', 6, '2025-01-09', '2025-01-20', '2025-01-12', 3, 27.48, 'Tsawassen', 'Canada');
INSERT INTO orders VALUES (61, 'BSBEV', 2, '2025-04-01', '2025-04-13', '2025-04-02', 1, 6.46, 'London', 'UK');
INSERT INTO orders VALUES (62, 'CHOPS', 1, '2025-10-12', '2025-10-16', '2025-10-15', 2, 128.95, 'Bern', 'Switzerland');
INSERT INTO orders VALUES (63, 'CACTU', 8, '2025-12-03', '2025-12-16', '2025-12-05', 2, 101.69, 'Buenos Aires', 'Argentina');
INSERT INTO orders VALUES (64, 'BSBEV', 4, '2025-04-23', '2025-04-27', '2025-04-24', 3, 177.62, 'London', 'UK');
INSERT INTO orders VALUES (65, 'BOLID', 7, '2025-08-15', '2025-08-23', '2025-08-20', 1, 112.68, 'Madrid', 'Spain');
INSERT INTO orders VALUES (66, 'CENTC', 1, '2025-11-07', '2025-11-21', '2025-11-09', 1, 108.37, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (67, 'BONAP', 4, '2025-01-24', '2025-01-28', '2025-01-28', 1, 264.03, 'Marseille', 'France');
INSERT INTO orders VALUES (68, 'BLONP', 4, '2025-05-01', '2025-05-15', '2025-05-04', 3, 200.53, 'Strasbourg', 'France');
INSERT INTO orders VALUES (69, 'ALFKI', 4, '2025-03-23', '2025-03-28', '2025-03-28', 3, 237.21, 'Berlin', 'Germany');
INSERT INTO orders VALUES (70, 'CONSH', 8, '2025-01-13', '2025-01-20', NULL, 1, 203.08, 'London', 'UK');
INSERT INTO orders VALUES (71, 'ANTON', 4, '2025-05-21', '2025-05-24', '2025-05-23', 3, 182.42, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (72, 'DRACD', 7, '2025-07-21', '2025-07-28', '2025-07-23', 1, 127.06, 'Aachen', 'Germany');
INSERT INTO orders VALUES (73, 'DRACD', 7, '2025-10-25', '2025-10-28', '2025-10-27', 2, 152.68, 'Aachen', 'Germany');
INSERT INTO orders VALUES (74, 'ALFKI', 3, '2025-07-03', '2025-07-11', '2025-07-04', 2, 263.33, 'Berlin', 'Germany');
INSERT INTO orders VALUES (75, 'CACTU', 8, '2025-07-09', '2025-07-14', '2025-07-12', 2, 225.72, 'Buenos Aires', 'Argentina');
INSERT INTO orders VALUES (76, 'BERGS', 5, '2025-03-05', '2025-03-11', NULL, 2, 87.25, 'Lulea', 'Sweden');
INSERT INTO orders VALUES (77, 'ALFKI', 2, '2025-10-20', '2025-10-28', NULL, 1, 103.41, 'Berlin', 'Germany');
INSERT INTO orders VALUES (78, 'BLONP', 7, '2025-01-02', '2025-01-07', '2025-01-07', 2, 16.33, 'Strasbourg', 'France');
INSERT INTO orders VALUES (79, 'ANTON', 5, '2025-12-20', '2025-12-28', '2025-12-25', 1, 41.35, 'Mexico D.F.', 'Mexico');
INSERT INTO orders VALUES (80, 'AROUT', 6, '2025-05-23', '2025-05-28', '2025-05-25', 3, 141.59, 'London', 'UK');

-- ---------- 8. order_details 订单明细 ----------
CREATE TABLE order_details (
    order_id   INT           NOT NULL,
    product_id INT           NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity   SMALLINT      NOT NULL,
    discount   DECIMAL(4,2)  NOT NULL DEFAULT 0,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_details VALUES (1, 34, 14.00, 7, 0.00);
INSERT INTO order_details VALUES (2, 1, 18.00, 28, 0.20);
INSERT INTO order_details VALUES (2, 34, 14.00, 32, 0.00);
INSERT INTO order_details VALUES (2, 26, 31.23, 1, 0.20);
INSERT INTO order_details VALUES (2, 15, 15.50, 32, 0.00);
INSERT INTO order_details VALUES (3, 27, 43.90, 4, 0.10);
INSERT INTO order_details VALUES (4, 3, 10.00, 33, 0.15);
INSERT INTO order_details VALUES (4, 1, 18.00, 7, 0.00);
INSERT INTO order_details VALUES (5, 19, 9.20, 35, 0.05);
INSERT INTO order_details VALUES (6, 36, 19.00, 14, 0.05);
INSERT INTO order_details VALUES (6, 22, 21.00, 6, 0.05);
INSERT INTO order_details VALUES (6, 2, 19.00, 15, 0.20);
INSERT INTO order_details VALUES (7, 25, 14.00, 14, 0.05);
INSERT INTO order_details VALUES (7, 36, 19.00, 27, 0.05);
INSERT INTO order_details VALUES (8, 27, 43.90, 8, 0.00);
INSERT INTO order_details VALUES (8, 25, 14.00, 34, 0.20);
INSERT INTO order_details VALUES (9, 12, 38.00, 2, 0.15);
INSERT INTO order_details VALUES (9, 8, 40.00, 26, 0.25);
INSERT INTO order_details VALUES (9, 4, 22.00, 34, 0.00);
INSERT INTO order_details VALUES (9, 40, 18.40, 34, 0.10);
INSERT INTO order_details VALUES (10, 14, 23.25, 38, 0.15);
INSERT INTO order_details VALUES (10, 4, 22.00, 29, 0.15);
INSERT INTO order_details VALUES (10, 19, 9.20, 7, 0.20);
INSERT INTO order_details VALUES (11, 30, 25.89, 38, 0.00);
INSERT INTO order_details VALUES (11, 13, 6.00, 7, 0.00);
INSERT INTO order_details VALUES (11, 11, 21.00, 7, 0.05);
INSERT INTO order_details VALUES (11, 33, 2.50, 6, 0.00);
INSERT INTO order_details VALUES (11, 4, 22.00, 31, 0.00);
INSERT INTO order_details VALUES (12, 33, 2.50, 37, 0.10);
INSERT INTO order_details VALUES (12, 10, 31.00, 25, 0.00);
INSERT INTO order_details VALUES (13, 13, 6.00, 38, 0.00);
INSERT INTO order_details VALUES (13, 12, 38.00, 23, 0.00);
INSERT INTO order_details VALUES (14, 31, 12.50, 20, 0.00);
INSERT INTO order_details VALUES (14, 2, 19.00, 19, 0.05);
INSERT INTO order_details VALUES (14, 23, 9.00, 2, 0.00);
INSERT INTO order_details VALUES (15, 39, 18.00, 28, 0.25);
INSERT INTO order_details VALUES (15, 34, 14.00, 20, 0.00);
INSERT INTO order_details VALUES (15, 26, 31.23, 1, 0.10);
INSERT INTO order_details VALUES (15, 20, 81.00, 38, 0.00);
INSERT INTO order_details VALUES (15, 38, 263.50, 31, 0.00);
INSERT INTO order_details VALUES (16, 4, 22.00, 36, 0.05);
INSERT INTO order_details VALUES (16, 30, 25.89, 38, 0.15);
INSERT INTO order_details VALUES (16, 37, 26.00, 18, 0.25);
INSERT INTO order_details VALUES (17, 2, 19.00, 13, 0.10);
INSERT INTO order_details VALUES (18, 39, 18.00, 7, 0.00);
INSERT INTO order_details VALUES (18, 27, 43.90, 2, 0.05);
INSERT INTO order_details VALUES (18, 38, 263.50, 19, 0.00);
INSERT INTO order_details VALUES (18, 26, 31.23, 18, 0.00);
INSERT INTO order_details VALUES (18, 11, 21.00, 11, 0.05);
INSERT INTO order_details VALUES (19, 13, 6.00, 10, 0.20);
INSERT INTO order_details VALUES (20, 39, 18.00, 33, 0.00);
INSERT INTO order_details VALUES (20, 7, 30.00, 1, 0.00);
INSERT INTO order_details VALUES (20, 20, 81.00, 27, 0.00);
INSERT INTO order_details VALUES (20, 33, 2.50, 23, 0.10);
INSERT INTO order_details VALUES (21, 6, 25.00, 23, 0.00);
INSERT INTO order_details VALUES (21, 40, 18.40, 28, 0.15);
INSERT INTO order_details VALUES (22, 21, 10.00, 8, 0.15);
INSERT INTO order_details VALUES (23, 40, 18.40, 17, 0.25);
INSERT INTO order_details VALUES (24, 15, 15.50, 13, 0.10);
INSERT INTO order_details VALUES (24, 20, 81.00, 38, 0.05);
INSERT INTO order_details VALUES (24, 30, 25.89, 1, 0.00);
INSERT INTO order_details VALUES (24, 26, 31.23, 11, 0.00);
INSERT INTO order_details VALUES (24, 12, 38.00, 34, 0.20);
INSERT INTO order_details VALUES (25, 7, 30.00, 3, 0.15);
INSERT INTO order_details VALUES (25, 36, 19.00, 24, 0.00);
INSERT INTO order_details VALUES (25, 40, 18.40, 28, 0.20);
INSERT INTO order_details VALUES (25, 27, 43.90, 8, 0.00);
INSERT INTO order_details VALUES (26, 2, 19.00, 21, 0.00);
INSERT INTO order_details VALUES (26, 12, 38.00, 12, 0.00);
INSERT INTO order_details VALUES (26, 3, 10.00, 39, 0.00);
INSERT INTO order_details VALUES (26, 8, 40.00, 36, 0.15);
INSERT INTO order_details VALUES (27, 10, 31.00, 27, 0.00);
INSERT INTO order_details VALUES (28, 22, 21.00, 4, 0.15);
INSERT INTO order_details VALUES (28, 3, 10.00, 18, 0.20);
INSERT INTO order_details VALUES (28, 37, 26.00, 19, 0.10);
INSERT INTO order_details VALUES (29, 30, 25.89, 33, 0.20);
INSERT INTO order_details VALUES (29, 22, 21.00, 32, 0.10);
INSERT INTO order_details VALUES (29, 23, 9.00, 17, 0.00);
INSERT INTO order_details VALUES (30, 10, 31.00, 7, 0.20);
INSERT INTO order_details VALUES (30, 8, 40.00, 16, 0.15);
INSERT INTO order_details VALUES (30, 26, 31.23, 31, 0.10);
INSERT INTO order_details VALUES (30, 16, 17.45, 31, 0.00);
INSERT INTO order_details VALUES (31, 19, 9.20, 27, 0.00);
INSERT INTO order_details VALUES (31, 8, 40.00, 29, 0.15);
INSERT INTO order_details VALUES (31, 1, 18.00, 10, 0.25);
INSERT INTO order_details VALUES (31, 20, 81.00, 4, 0.25);
INSERT INTO order_details VALUES (32, 10, 31.00, 39, 0.25);
INSERT INTO order_details VALUES (33, 27, 43.90, 23, 0.00);
INSERT INTO order_details VALUES (33, 12, 38.00, 7, 0.05);
INSERT INTO order_details VALUES (34, 10, 31.00, 8, 0.25);
INSERT INTO order_details VALUES (34, 27, 43.90, 9, 0.10);
INSERT INTO order_details VALUES (34, 12, 38.00, 24, 0.10);
INSERT INTO order_details VALUES (35, 20, 81.00, 17, 0.00);
INSERT INTO order_details VALUES (35, 16, 17.45, 5, 0.05);
INSERT INTO order_details VALUES (35, 33, 2.50, 27, 0.15);
INSERT INTO order_details VALUES (36, 25, 14.00, 30, 0.00);
INSERT INTO order_details VALUES (36, 37, 26.00, 12, 0.05);
INSERT INTO order_details VALUES (36, 32, 32.00, 12, 0.25);
INSERT INTO order_details VALUES (37, 22, 21.00, 2, 0.00);
INSERT INTO order_details VALUES (37, 16, 17.45, 31, 0.00);
INSERT INTO order_details VALUES (37, 27, 43.90, 34, 0.25);
INSERT INTO order_details VALUES (38, 27, 43.90, 35, 0.10);
INSERT INTO order_details VALUES (38, 20, 81.00, 1, 0.10);
INSERT INTO order_details VALUES (38, 11, 21.00, 25, 0.15);
INSERT INTO order_details VALUES (38, 10, 31.00, 30, 0.00);
INSERT INTO order_details VALUES (38, 40, 18.40, 9, 0.25);
INSERT INTO order_details VALUES (39, 35, 18.00, 31, 0.00);
INSERT INTO order_details VALUES (39, 19, 9.20, 21, 0.15);
INSERT INTO order_details VALUES (39, 10, 31.00, 24, 0.20);
INSERT INTO order_details VALUES (39, 2, 19.00, 30, 0.15);
INSERT INTO order_details VALUES (39, 27, 43.90, 15, 0.00);
INSERT INTO order_details VALUES (40, 33, 2.50, 2, 0.20);
INSERT INTO order_details VALUES (40, 40, 18.40, 7, 0.10);
INSERT INTO order_details VALUES (40, 35, 18.00, 39, 0.00);
INSERT INTO order_details VALUES (40, 39, 18.00, 39, 0.05);
INSERT INTO order_details VALUES (41, 4, 22.00, 26, 0.05);
INSERT INTO order_details VALUES (42, 15, 15.50, 37, 0.05);
INSERT INTO order_details VALUES (42, 20, 81.00, 39, 0.10);
INSERT INTO order_details VALUES (42, 26, 31.23, 25, 0.25);
INSERT INTO order_details VALUES (43, 2, 19.00, 37, 0.05);
INSERT INTO order_details VALUES (43, 34, 14.00, 7, 0.00);
INSERT INTO order_details VALUES (44, 32, 32.00, 1, 0.20);
INSERT INTO order_details VALUES (45, 40, 18.40, 12, 0.05);
INSERT INTO order_details VALUES (45, 16, 17.45, 18, 0.10);
INSERT INTO order_details VALUES (46, 30, 25.89, 2, 0.25);
INSERT INTO order_details VALUES (46, 22, 21.00, 32, 0.25);
INSERT INTO order_details VALUES (46, 39, 18.00, 6, 0.05);
INSERT INTO order_details VALUES (46, 15, 15.50, 39, 0.25);
INSERT INTO order_details VALUES (46, 27, 43.90, 34, 0.20);
INSERT INTO order_details VALUES (47, 10, 31.00, 22, 0.10);
INSERT INTO order_details VALUES (48, 25, 14.00, 36, 0.05);
INSERT INTO order_details VALUES (48, 36, 19.00, 37, 0.00);
INSERT INTO order_details VALUES (48, 35, 18.00, 16, 0.25);
INSERT INTO order_details VALUES (49, 1, 18.00, 17, 0.10);
INSERT INTO order_details VALUES (50, 22, 21.00, 21, 0.05);
INSERT INTO order_details VALUES (50, 37, 26.00, 39, 0.00);
INSERT INTO order_details VALUES (51, 18, 62.50, 15, 0.00);
INSERT INTO order_details VALUES (51, 4, 22.00, 39, 0.15);
INSERT INTO order_details VALUES (51, 26, 31.23, 33, 0.25);
INSERT INTO order_details VALUES (52, 7, 30.00, 5, 0.10);
INSERT INTO order_details VALUES (52, 26, 31.23, 26, 0.20);
INSERT INTO order_details VALUES (52, 12, 38.00, 39, 0.00);
INSERT INTO order_details VALUES (52, 10, 31.00, 24, 0.05);
INSERT INTO order_details VALUES (52, 31, 12.50, 6, 0.05);
INSERT INTO order_details VALUES (53, 26, 31.23, 20, 0.00);
INSERT INTO order_details VALUES (54, 32, 32.00, 15, 0.05);
INSERT INTO order_details VALUES (54, 12, 38.00, 35, 0.15);
INSERT INTO order_details VALUES (55, 23, 9.00, 23, 0.15);
INSERT INTO order_details VALUES (55, 3, 10.00, 28, 0.10);
INSERT INTO order_details VALUES (56, 16, 17.45, 40, 0.00);
INSERT INTO order_details VALUES (57, 2, 19.00, 4, 0.00);
INSERT INTO order_details VALUES (57, 39, 18.00, 2, 0.20);
INSERT INTO order_details VALUES (57, 26, 31.23, 32, 0.25);
INSERT INTO order_details VALUES (57, 35, 18.00, 8, 0.05);
INSERT INTO order_details VALUES (58, 26, 31.23, 6, 0.15);
INSERT INTO order_details VALUES (59, 21, 10.00, 35, 0.15);
INSERT INTO order_details VALUES (60, 38, 263.50, 7, 0.20);
INSERT INTO order_details VALUES (60, 31, 12.50, 26, 0.00);
INSERT INTO order_details VALUES (61, 10, 31.00, 16, 0.05);
INSERT INTO order_details VALUES (61, 30, 25.89, 10, 0.00);
INSERT INTO order_details VALUES (61, 14, 23.25, 33, 0.00);
INSERT INTO order_details VALUES (62, 20, 81.00, 8, 0.00);
INSERT INTO order_details VALUES (62, 35, 18.00, 2, 0.15);
INSERT INTO order_details VALUES (62, 2, 19.00, 18, 0.10);
INSERT INTO order_details VALUES (62, 6, 25.00, 31, 0.15);
INSERT INTO order_details VALUES (63, 27, 43.90, 14, 0.25);
INSERT INTO order_details VALUES (63, 22, 21.00, 29, 0.25);
INSERT INTO order_details VALUES (63, 18, 62.50, 31, 0.25);
INSERT INTO order_details VALUES (63, 35, 18.00, 20, 0.10);
INSERT INTO order_details VALUES (64, 15, 15.50, 35, 0.05);
INSERT INTO order_details VALUES (64, 30, 25.89, 25, 0.00);
INSERT INTO order_details VALUES (64, 33, 2.50, 9, 0.25);
INSERT INTO order_details VALUES (64, 26, 31.23, 19, 0.20);
INSERT INTO order_details VALUES (65, 39, 18.00, 2, 0.20);
INSERT INTO order_details VALUES (65, 23, 9.00, 19, 0.00);
INSERT INTO order_details VALUES (66, 3, 10.00, 23, 0.00);
INSERT INTO order_details VALUES (67, 4, 22.00, 39, 0.00);
INSERT INTO order_details VALUES (67, 3, 10.00, 6, 0.05);
INSERT INTO order_details VALUES (67, 40, 18.40, 12, 0.05);
INSERT INTO order_details VALUES (68, 22, 21.00, 11, 0.00);
INSERT INTO order_details VALUES (68, 40, 18.40, 32, 0.00);
INSERT INTO order_details VALUES (68, 39, 18.00, 14, 0.00);
INSERT INTO order_details VALUES (68, 6, 25.00, 2, 0.25);
INSERT INTO order_details VALUES (69, 15, 15.50, 25, 0.00);
INSERT INTO order_details VALUES (69, 13, 6.00, 24, 0.00);
INSERT INTO order_details VALUES (69, 2, 19.00, 28, 0.10);
INSERT INTO order_details VALUES (69, 14, 23.25, 26, 0.05);
INSERT INTO order_details VALUES (70, 26, 31.23, 27, 0.10);
INSERT INTO order_details VALUES (71, 36, 19.00, 30, 0.20);
INSERT INTO order_details VALUES (71, 31, 12.50, 27, 0.25);
INSERT INTO order_details VALUES (72, 26, 31.23, 39, 0.00);
INSERT INTO order_details VALUES (72, 38, 263.50, 2, 0.05);
INSERT INTO order_details VALUES (72, 31, 12.50, 14, 0.25);
INSERT INTO order_details VALUES (73, 23, 9.00, 7, 0.25);
INSERT INTO order_details VALUES (73, 22, 21.00, 28, 0.25);
INSERT INTO order_details VALUES (73, 1, 18.00, 15, 0.25);
INSERT INTO order_details VALUES (73, 15, 15.50, 34, 0.05);
INSERT INTO order_details VALUES (73, 37, 26.00, 16, 0.00);
INSERT INTO order_details VALUES (74, 38, 263.50, 27, 0.00);
INSERT INTO order_details VALUES (75, 7, 30.00, 40, 0.00);
INSERT INTO order_details VALUES (76, 4, 22.00, 16, 0.25);
INSERT INTO order_details VALUES (77, 18, 62.50, 14, 0.20);
INSERT INTO order_details VALUES (77, 11, 21.00, 15, 0.00);
INSERT INTO order_details VALUES (77, 10, 31.00, 33, 0.00);
INSERT INTO order_details VALUES (77, 38, 263.50, 13, 0.05);
INSERT INTO order_details VALUES (78, 4, 22.00, 11, 0.00);
INSERT INTO order_details VALUES (78, 6, 25.00, 26, 0.25);
INSERT INTO order_details VALUES (78, 15, 15.50, 40, 0.10);
INSERT INTO order_details VALUES (78, 38, 263.50, 29, 0.10);
INSERT INTO order_details VALUES (78, 11, 21.00, 34, 0.15);
INSERT INTO order_details VALUES (79, 15, 15.50, 16, 0.20);
INSERT INTO order_details VALUES (79, 39, 18.00, 24, 0.10);
INSERT INTO order_details VALUES (79, 7, 30.00, 17, 0.00);
INSERT INTO order_details VALUES (79, 6, 25.00, 38, 0.10);
INSERT INTO order_details VALUES (80, 31, 12.50, 30, 0.15);
INSERT INTO order_details VALUES (80, 15, 15.50, 19, 0.00);
INSERT INTO order_details VALUES (80, 40, 18.40, 5, 0.10);
INSERT INTO order_details VALUES (80, 26, 31.23, 21, 0.05);
INSERT INTO order_details VALUES (80, 4, 22.00, 30, 0.00);

-- ---------- 9. 两个常用视图 ----------
-- 订单金额视图：每张订单的实付金额
CREATE OR REPLACE VIEW v_order_total AS
SELECT o.order_id,
       o.customer_id,
       c.company_name,
       o.employee_id,
       o.order_date,
       ROUND(SUM(d.quantity * d.unit_price * (1 - d.discount)), 2) AS order_total
FROM orders o
JOIN order_details d ON d.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY o.order_id, o.customer_id, c.company_name, o.employee_id, o.order_date;

-- 商品销售视图：每个商品卖了多少
CREATE OR REPLACE VIEW v_product_sales AS
SELECT p.product_id,
       p.product_name,
       cat.category_name,
       SUM(d.quantity) AS total_qty,
       ROUND(SUM(d.quantity * d.unit_price * (1 - d.discount)), 2) AS total_amount
FROM products p
JOIN categories cat ON cat.category_id = p.category_id
JOIN order_details d ON d.product_id = p.product_id
GROUP BY p.product_id, p.product_name, cat.category_name;

-- 恢复外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 自查：执行到这里会出一张结果表（8 行）
-- 如果看到 8 行、行数和注释一致，说明建库成功
-- ============================================================
SELECT 'categories'    AS 表名, COUNT(*) AS 行数 FROM categories
UNION ALL SELECT 'suppliers',    COUNT(*) FROM suppliers
UNION ALL SELECT 'products',     COUNT(*) FROM products
UNION ALL SELECT 'customers',    COUNT(*) FROM customers
UNION ALL SELECT 'employees',    COUNT(*) FROM employees
UNION ALL SELECT 'shippers',     COUNT(*) FROM shippers
UNION ALL SELECT 'orders',       COUNT(*) FROM orders
UNION ALL SELECT 'order_details', COUNT(*) FROM order_details;

-- ============================================================
-- 建完了。快速自检：
--   SELECT COUNT(*) FROM categories;      -- 8
--   SELECT COUNT(*) FROM products;        -- 40
--   SELECT COUNT(*) FROM customers;       -- 20
--   SELECT COUNT(*) FROM employees;       -- 9
--   SELECT COUNT(*) FROM orders;          -- 80
--   SELECT COUNT(*) FROM order_details;   -- 219
-- ============================================================
