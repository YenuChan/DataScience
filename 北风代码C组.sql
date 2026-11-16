use northwind;#在northwind中操作
select products.product_name,categories.category_name
from products
join categories
on products.category_id=categories.category_id;#C1
select products.product_name,categories.category_name,suppliers.company_name
from products
join categories
on products.category_id=categories.category_id
join suppliers
on products.supplier_id=suppliers.supplier_id;#C2
select orders.order_id,customers.company_name,concat(employees.first_name,' ',employees.last_name)
from orders
join customers
on orders.customer_id = customers.customer_id
join employees
on orders.employee_id=employees.employee_id
order by order_id;#C3
select order_details.order_id,products.product_name,products.units_on_order,products.unit_price,order_details.discount
from order_details
join products
on order_details.product_id=products.product_id
order by order_id;#C4
select categories.category_name,sum(order_details.quantity) 商品合计
from order_details
join products
on products.product_id=order_details.product_id
join categories
on categories.category_id=products.category_id
group by categories.category_id
order by categories.category_id;#C5
select product_name,units_in_stock
from products
left join order_details
on products.product_id = order_details.product_id
where order_details.product_id is null
order by products.product_id;#C6
select customers.customer_id,customers.company_name
from customers
left join orders
on orders.customer_id=customers.customer_id
where orders.order_date is null;#C7
select concat(employees.first_name,' ',employees.last_name) 员工,count(orders.order_id) 订单数
from employees
left join orders
on employees.employee_id = orders.employee_id
group by employees.employee_id
order by 订单数 ;#C8