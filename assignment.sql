-- ============================================
-- SQL Server — Class 3 Homework
-- BikeStores Sample Database
-- Topics: GROUP BY · HAVING · Subqueries · EXISTS
-- ============================================

-- Q1: Count how many products each brand has in the catalog.
-- Show brand name and product count.
-- Sort by count descending.

SELECT 
b.brand_name,
COUNT (p.product_id) as no_of_products
From[production].[products]p
Inner join [production].[brands]b 
On p.brand_id =b.brand_id
group by b.brand_name
Order by COUNT (product_id) desc;
 
-- Q2: For each category, show:
-- category name,
-- total number of products,
-- cheapest price,
-- most expensive price,
-- average price (rounded to 2 decimals).
-- Sort by average price descending.

Select
c.category_name,
Count (p.product_id)as no_of_products, 
Min (p.list_price)as min_price ,
Max(p.list_price)as max_price,
Avg(p.list_price)as avg_price
From [production].[categories]c
Inner join [production].[products] p
On c.category_id =p.category_id 
group by c.category_name
Order by Avg(p.list_price) desc;

-- Q3: Show the number of orders placed per order status.
-- Display the status value and order count.
-- Sort by order_status ascending.


select 
count (order_id) no_of_orders,
Order_status 
From [sales].[orders]
group by Order_status 
Order by  order_status asc;

-- Q4: For each store, calculate total revenue:
-- (quantity × list_price × (1 – discount)) from order_items.
-- Show store name and total revenue.
-- Sort by revenue descending.

Select 
Sum ((oi.quantity *oi.list_price)*(1-oi.discount))as total_revenue,
s.store_name
 From [sales].[order_items]oi
Inner join [sales].[orders]o
On oi.order_id =o.order_id
Inner join [sales].[stores]s
On s.store_id=o.store_id
group by s.store_name
Order by total_revenue desc;

-- Q5: Show total number of products per brand per model year.
-- Display brand name, model year, and product count.
-- Sort by brand name then model year.


Select 
b.brand_name, 
p.model_year,
Count (p.product_id) as no_of_products
From [production].[products]p
Inner join [production].[brands]b
On p.brand_id= b.brand_id
group by b.brand_name,p.model_year
Order by brand_name,model_year;



-- Q6: Find all brands that have more than 25 products in the catalog.
-- Show brand name and product count.

select
   b.brand_name, 
    COUNT(p.product_id) AS product_count
FROM 
   [Production].[products]p
Inner join [Production].[brands]b
on p.brand_id=b.brand_id
GROUP By b.brand_name
HAVING 
    COUNT(p.product_id) > 25;

-- Q7: Among products from year 2018 only,
-- find categories whose average price is above $1500.
-- Show category name, product count, and average price.

SELECT 
    c.category_name,
    COUNT(p.product_id) AS no_of_product,
    AVG(p.list_price) AS average_price
FROM 
   [production].[products]p
Inner join 
   [production].[categories]c
On p.category_id =c.category_id 
WHERE 
    p.model_year = 2018
GROUP BY 
    c.category_name
HAVING 
    AVG(p.list_price) > 1500;

-- Q8: Find customers who have placed 3 or more orders.
-- Show customer full name and order count.
-- Sort by order count descending.

SELECT 
    c.first_name+' '+c.last_name  AS customer_name,
    COUNT(o.order_id) AS order_count
FROM 
   [Sales].[customers]c
Inner JOIN 
    [sales].[orders] o
    ON c.customer_id = o.customer_id
GROUP BY 
   c.first_name+' '+c.last_name
HAVING 
    count (o.order_id)>=3
ORDER BY 
    order_count desc;

-- Q9: Find all products whose list price is higher than
-- the average list price of all products.
-- Show product name and price.
-- Sort by price descending.

SELECT 
    product_name, 
    list_price
FROM 
  [Production].[products]
WHERE   list_price > (SELECT
 AVG(list_price) 
FROM [Production].[products])
ORDER BY 
    list_price DESC;

-- Q10: Find all orders placed by customers from state 'TX'.
-- Use a subquery (NOT a JOIN).
-- Show order ID, customer ID, and order date.
select
order_id,
customer_id,
order_date
from [sales].[orders]
where customer_id in 
(select
     customer_id
from [sales].[customers]
where state='TX');
;
 
-- Q11: For each brand, show its average price,
-- but only for brands whose average price exceeds overall product average.
-- Use a subquery in FROM (derived table).
-- Show brand name and average price.

select 
brand_name,
(select avg (list_price)
from [production].[products]p
where p.brand_id=b.brand_id)as avg_price
from [production].[brands]b;


-- Q12: Using EXISTS:
-- Find all customers who have placed at least one order.
-- Show customer full name and email.
select 
c.first_name+ ' ' +c.last_name as customer_name,
c.email
from [sales].[customers]c
where exists
(select 1
from [sales].[orders]o 
where o.customer_id=c.customer_id);

-- Q13: Using NOT EXISTS:
-- Find all products that have never appeared in any order (order_items).
-- Show product name and list price.

select
p.product_name,
p.list_price
from [production].[products]p
where not exists 
(select 1

where from [sales].[order_items]oi
where oi.product_id=p.product_id);