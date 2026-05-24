 Q1
-- Show all product names along with their brand name. Sort by brand name, then by product name alphabetically.
 SELECT
     p.product_name,
     b.brand_name
 FROM[production].[products]p
 INNER JOIN [production].[brands]b
 ON p.brand_id=b.brand_id
 ORDER BY p.product_name asc,
 b.brand_name asc;

 
--  Q2
-- List all products with their category name and list price. Sort by category name, then by price from cheapest to most expensive.

select 
p.product_name,
p.list_price,
c.category_name
from [production].[products]p
inner join [production].[categories]c
on p.category_id=c.category_id
order by p.list_price asc,c.category_name asc;

-- Q3
-- Show all orders with the customer's full name and order date. Sort by order date from newest to oldest.

select c.first_name+ ' ' +c.last_name as [customer_name],
o.order_date,
o.order_status
from [sales].[customers]c
inner join [sales].[orders]o
on c.customer_id=o.customer_id
order by o.order_date asc;

-- Q4
-- Display each order item with the product name, quantity, unit price, and a computed column called "Line Total" (quantity × list_price). Sort by order ID
select
oi.order_id,
p.product_name,
oi.quantity,
oi.list_price,
(oi.quantity*oi.list_price)as[line_total]
from[sales].[order_items]oi
inner join [production].[products]p
on oi.product_id=p.product_id 
order by oi.order_id asc;

-- Q5
-- Show each order along with the store name where it was placed and the order date. Sort by store name.

select o.order_status,
o.order_date,
s.store_name
from [sales].[orders]o
inner join [sales].[stores]s
on o.store_id=s.store_id
order by store_name asc;

- Q6
-- Show each order with: order ID, customer full name, store name, and the staff member's full name who handled it.

select
o.order_id,
c.first_name + ' ' + c.last_name as [customer_name],
st.first_name+ ' ' +st.last_name as [staff_name],
s.store_name
from [sales].[orders]o
inner join [sales].[customers]c
on o.customer_id=c.customer_id
inner join [sales].[staffs]st
on st.staff_id=o.staff_id
inner join [sales].[stores]s
on s.store_id =st.store_id 
order by o.order_id;


-- Q7
-- List all products from the brand "Trek" along with their category name and price. Sort by price descending. (Use JOIN — do NOT filter by brand_id directly.)

select p.product_name,
c.category_name,
p.list_price,
b.brand_name
from [production].[products]p
inner join [production].[categories]c
on p.category_id=c.category_id
inner join[production].[brands]b
on b.brand_id=p.brand_id
where b.brand_name='trek'
order by p.list_price desc;


-- Q8
-- Find all customers from the state of "NY" who have placed at least one order. Show customer full name, city, and order date. (Use JOIN — do not use a subquery.)

select 
c.first_name+ ' ' + c.last_name as [customer_name],
c.city,
o.order_date,
c.state
from [sales].[customers]c
inner join[sales].[orders]o
on c.customer_id=o.customer_id
where c.state= 'NY';

-- Q9
-- Show all completed orders (order_status = 4) from the store "Rowlett Bikes". Display order ID, customer full name, and order date.
select
c.first_name+ ' ' + c.last_name as[customer name],
o.order_id,
o.order_date,
s.store_name,
o.order_status
from [sales].[customers]c
inner join [sales].[orders]o
on c.customer_id=o.customer_id 
inner join [sales].[stores]s
on o.store_id=s.store_id
where s.store_name='Rowlett Bikes'and o.order_status=4;

-- Q10
-- List ALL customers and any orders they have placed. Include customers who have never placed an order (show NULL for order columns). Sort by customer ID.
select 
c.customer_id,
c.first_name+' '+ c.last_name as [customer_name],
o.order_id,
o.order_date, 
o.order_status
from [sales].[customers]c
left join [sales].[orders]o
on c.customer_id=o.customer_id
order by c.customer_id asc;

-- Q11
-- Find all customers who have NEVER placed an order. Show their full name and email.

select
c.first_name+ ' '+c.last_name as[customer_name],
c.email,
o.order_id,
o.order_status
from [sales].[customers]c
left join [sales].[orders]o
on c.customer_id=o.customer_id
where o.order_id is null;
-- Q12
-- List all products and their stock quantity at every store. Include products that have NO stock record at all. Show product name, store ID, and quantity.
select p.product_name,
s.store_id,
s.quantity
from [production].[products]p
left join [production].[stocks]s
on p.product_id=s.product_id;

- Q13
-- Find all products that have NEVER been ordered (no record in order_items). Show product name and list price.
select p.product_name,
p.list_price,
oi.order_id
from [production].[products]p
left join [sales].[order_items]oi
on p.product_id=oi.product_id
where oi.product_id is null;



-- Q14
-- List each staff member along with the full name of their manager. Staff with no manager (top-level) should still appear — show NULL for manager name.
select
staff.staff_id,
staff.first_name + ' ' + staff.last_name as [staff_name],
manager.staff_id as manager_id,
manager.first_name +' '+ manager.last_name as [manager_name]
from [sales].[staffs]staff
left join [sales].[staffs]manager
on staff.manager_id=manager.staff_id;


-- Q15
-- Create a view called vw_bike_catalog that shows product_name, brand_name, category_name, model_year, and list_price. Then query it to show only products priced over $2,000, sorted by price descending.
 create view vw_bike_catalog  
 as 
 select 
 p.product_name, 
 b.brand_name,
 c.category_name,
 p.model_year,
 p.list_price
 from [production].[products]p
 inner join [production].[categories]c
 on p.category_id=c.category_id
 inner join [production].[brands]b
 on b.brand_id=p.brand_id;

 select 
 product_name,
 brand_name, 
 category_name,
 model_year,
 list_price
 from vw_bike_catalog ;

-- BONUS: Create a view called vw_customer_orders showing: customer full name, order_id, order_date, store_name, and order_status. Then query it to show only orders where the customer city is "New York", sorted by order_date.
create view vw_customer_order
as 
select 
c.first_name+' '+c.last_name AS [customer_name],
o.order_id,
s.store_name,
o.order_status,
c.city
from [sales].[orders]o
inner join [sales].[customers]c
on o.customer_id=c.customer_id
inner join [sales].[stores]s
on o.store_id=s.store_id;

select
customer_name,
order_id,
store_name,
order_status
from vw_customer_order