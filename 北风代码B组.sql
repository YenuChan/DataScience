use northwind;#在northwind中操作
select count(product_id) as 'count of product' from products;#B1
select round(avg(unit_price),2) as 'avg_price' from products;#B2
select category_id,count(*) from products group by category_id;#B3
select categories.category_name,
products.category_id,round(avg(products.unit_price),2) as avg_price
from products
join categories
on categories.category_id=products.category_id
group by products.category_id
order by round(avg(products.unit_price),2) desc;#B4
SELECT s.supplier_id, s.company_name, COUNT(*) AS 商品数
FROM products p
JOIN suppliers s ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_id, s.company_name, s.country
HAVING COUNT(*) >= 3
ORDER BY 商品数 DESC;#B5
select sum(freight) as 订单总额,count(*) as 订单总量 from orders;#B6
select round(count(*)/count(distinct order_id),0) as 平均订单商品数量
from order_details;#B7
SELECT customer_id, COUNT(*) AS 订单数
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 3
ORDER BY 订单数 DESC;#B8