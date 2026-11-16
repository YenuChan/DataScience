USE northwind;#在northwind中操作
SELECT order_id, company_name, order_total
FROM v_order_total
ORDER BY order_total desc
LIMIT 5;#E1
SELECT c.category_name,
       ROUND(SUM(d.quantity * d.unit_price * (1 - d.discount)), 2) AS sales_amount
FROM order_details d
JOIN products p   ON p.product_id = d.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY sales_amount DESC;#E2
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS ym,   -- 等价于 LEFT(o.order_date, 7)
       ROUND(SUM(d.quantity * d.unit_price * (1 - d.discount)), 2) AS sales_amount
FROM orders o
JOIN order_details d ON d.order_id = o.order_id
GROUP BY ym
ORDER BY ym;#E3
SELECT c.category_name,
       p.product_name,
       p.unit_price,
       ROW_NUMBER() OVER (PARTITION BY p.category_id
                          ORDER BY p.unit_price DESC) AS price_rank
FROM products p
JOIN categories c ON c.category_id = p.category_id;#E4
SELECT CASE
           WHEN unit_price >= 50 THEN '高'
           WHEN unit_price >= 20 THEN '中'
           ELSE '低'
       END AS price_level,
       COUNT(*) AS product_count
FROM products
GROUP BY price_level
ORDER BY price_level DESC;#E5
SELECT p.product_name,
       ROUND(SUM(d.quantity * d.unit_price * (1 - d.discount)), 2) AS sales_amount
FROM order_details d
JOIN products p ON p.product_id = d.product_id
GROUP BY p.product_id, p.product_name
ORDER BY sales_amount DESC
LIMIT 5;#E6
SELECT p.product_name,
       ROUND(SUM(d.quantity * d.unit_price * (1 - d.discount)), 2) AS sales_amount,
       ROUND(SUM(d.quantity * d.unit_price * (1 - d.discount)) * 100.0 /
             (SELECT SUM(quantity * unit_price * (1 - discount)) FROM order_details), 2) AS pct
FROM order_details d
JOIN products p ON p.product_id = d.product_id
GROUP BY p.product_id, p.product_name
HAVING sales_amount >= (SELECT SUM(quantity * unit_price * (1 - discount)) FROM order_details) * 0.05
ORDER BY sales_amount DESC;#E7