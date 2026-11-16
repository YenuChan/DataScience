use northwind;#在northwind中操作
select product_name,unit_price
from products
where unit_price > (select sum(unit_price)/count(*) from products)
order by unit_price;#D1
select unit_price,product_name
from products
where unit_price = (select max(unit_price) from products);#D2
select categories.category_name as 类别,
       products.product_name    as 商品,
       products.unit_price      as 单价
from products
join categories
on categories.category_id = products.category_id
join (select category_id, max(unit_price) as mx from products
      group by category_id) m
on m.category_id = products.category_id
and m.mx= products.unit_price
order by products.unit_price desc;#D3
select customers.company_name,t.订单总数
from customers
join (select *,count(customer_id)over(partition by customer_id) 订单总数
from orders)t
where t.customer_id=customers.customer_id
order by 订单总数 desc
limit 1;#D4
select cu.customer_id, cu.company_name
from customers cu
where not exists (select 1 from orders o where o.customer_id = cu.customer_id)
order by cu.customer_id;#D5