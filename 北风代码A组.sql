use northwind;#在northwind中操作
select product_name,unit_price from products order by unit_price DESC;#A1
select product_name,unit_price from products where unit_price > 50;#A2
select category_id,category_name from categories;#A3
select product_name, units_in_stock from products where units_in_stock != 0;#A4
select country,company_name from suppliers where country = 'Germany';#A5
select product_name,unit_price from products order by unit_price DESC limit 0,5;#A6
select product_name,discontinued from products where discontinued = 0;#A7
select order_id,customer_id,order_date from orders where required_date > '2025-1-1';#A8
