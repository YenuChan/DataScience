# Northwind SQL 练习（36 题）

> 用 MySQL 完成北风贸易（Northwind）数据库的 36 道查询练习，覆盖多表连接、聚合分组、子查询和窗口函数。

---

## 📌 关于这个项目

北风贸易是一个经典的示例数据库，包含客户、订单、商品、员工等 8 张表。
本项目按难度把这 36 道题分成 5 组，从单表查询一路做到窗口函数排名。

**全部查询在 MySQL 上实测通过。**

---

## 🗂 数据库结构

### 8 张表

| 表名 | 说明 | 主要列 |
|---|---|---|
| `categories` | 商品类别 | `category_id`, `category_name` |
| `suppliers` | 供应商 | `supplier_id`, `company_name`, `country` |
| `products` | 商品 | `product_id`, `product_name`, `supplier_id`, `category_id`, `unit_price`, `units_in_stock` |
| `customers` | 客户 | `customer_id`, `company_name`, `city`, `country` |
| `employees` | 员工 | `employee_id`, `last_name`, `first_name`, `reports_to` |
| `shippers` | 承运商 | `shipper_id`, `company_name` |
| `orders` | 订单 | `order_id`, `customer_id`, `employee_id`, `order_date`, `freight` |
| `order_details` | 订单明细 | `order_id`, `product_id`, `unit_price`, `quantity`, `discount` |

### 表关系

```
categories ──┐
             ├──> products ──> order_details ──> orders ──> customers
suppliers ───┘                                      │
                                                     ├──> employees
                                                     └──> shippers
```

`order_details` 是中间表，一头连订单、一头连商品。**算销售额必须从它出发。**

### 2 个视图

| 视图 | 内容 |
|---|---|
| `v_order_total` | 每张订单的实付金额 |
| `v_product_sales` | 每个商品的销量和销售额 |

---

## 📋 题目分组

| 组 | 主题 | 题数 | 文件 |
|---|---|---|---|
| **A** | 简单查询（`SELECT` / `WHERE` / `ORDER BY` / `LIMIT`） | 8 | `北风代码A组.sql` |
| **B** | 聚合与分组（`GROUP BY` / `HAVING` / 聚合函数） | 8 | `北风代码B组.sql` |
| **C** | 多表连接（`JOIN` / `LEFT JOIN` / 自连接） | 8 | `北风代码C组.sql` |
| **D** | 子查询（标量子查询 / 派生表 / `NOT EXISTS`） | 5 | `北风代码D组.sql` |
| **E** | 进阶（窗口函数 / `CASE WHEN` / 视图 / 占比） | 7 | `北风代码E组.sql` |

---

## 🔧 用到的技能

- **基础**：`SELECT`、`WHERE`、`ORDER BY`、`LIMIT`、`DISTINCT`
- **聚合**：`COUNT` / `SUM` / `AVG` / `ROUND`，配合 `GROUP BY` 和 `HAVING`
- **连接**：`INNER JOIN`、`LEFT JOIN ... WHERE ... IS NULL`（找"没有"的记录）
- **子查询**：标量子查询（`unit_price > (SELECT AVG(...))`）、派生表、`NOT EXISTS`
- **窗口函数**：`COUNT(*) OVER (PARTITION BY ...)`、`ROW_NUMBER() OVER (...)`
- **其他**：`CASE WHEN`、`CONCAT`、`DATE_FORMAT`、子查询算占比

---

## 🚀 怎么运行

```bash
# 1. 建库并导入数据
mysql -u root -p < northwind.sql

# 2. 进入数据库
mysql -u root -p northwind

# 3. 把任意一个 .sql 文件里的语句粘进去执行
```

或者用任意 MySQL 客户端（DataGrip / Navicat / DBeaver）打开 `.sql` 文件直接运行。

---

## ⚠️ 遇到的问题（真实记录）

写的过程中踩过几个坑，记在这里防止再犯。

### 1. `count` 和 `sum` 的区别

算"平均每张订单包含几种商品"时，一开始写成了：

```sql
-- 错的
select round(count(*)/sum(order_id),0) from order_details;
```

`sum(order_id)` 是把订单号**加起来**（=9015），毫无意义。
分母要的是"有多少张订单"，应该用计数：

```sql
-- 对的
select round(count(*)/count(distinct order_id),0) from order_details;
-- 219 / 80 = 2.74 → 3
```

**`count` 是数个数，`sum` 是求和。** 这两个混了很难一眼看出来。

### 2. JOIN 条件写错，结果差了 10 倍

```sql
-- 错的
join categories on categories.category_id = order_details.product_id
```

`categories.category_id` 是类别号（1–8），`order_details.product_id` 是商品号（1–40）。
两个不同域的值做等值连接，结果全错。

```sql
-- 对的
join categories on categories.category_id = products.category_id
```

**教训：JOIN 之前先想清楚两边连的是不是同一种东西。**

### 3. 窗口函数算出了值，但没有聚合

```sql
-- 错的：返回 80 行（每张订单一行）
select customers.company_name,
       count(customer_id) over (partition by customer_id) as 订单总数
from orders ...
```

窗口函数会给每一行都附上"该客户的订单总数"，但**行并没有合并**。
问"订单最多的客户"时，应该返回 1 行。

```sql
-- 对的：用 GROUP BY 聚合
select cu.company_name, count(*) as 订单数
from orders o join customers cu on cu.customer_id = o.customer_id
group by cu.customer_id, cu.company_name
order by 订单数 desc
limit 1;
```

### 4. `CONCAT` 少了一个空格

```sql
concat(first_name, '', last_name)   -- → 'LauraCallahan'
concat(first_name, ' ', last_name)  -- → 'Laura Callahan'
```

---

## 🌍 环境

```
MySQL 8.x
字符集：utf8mb4
```

---

## 📝 说明

`northwind.sql` 是建库脚本（表结构 + 示例数据），仅用于让项目可复现。
36 道题的 SQL 为自己编写。
