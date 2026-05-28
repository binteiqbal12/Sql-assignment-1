-- ================================================================================
-- HOMEWORK: CLASS 5 - CTEs, PIVOT, EXPRESSIONS & WINDOW FUNCTIONS (EASY VERSION)
-- Database: BikeStores Sample Database
-- Instructions: Write SQL statements to solve each problem below.
-- ================================================================================

-- ================================================================================
-- SECTION A: CASE Expressions 
-- ================================================================================

-- Q1: Write a simple CASE that shows order_status as a word instead of number.
--     Show order_id, order_status (number), and status_description (word).

SELECT 
order_id,
order_status,
    CASE    
	    WHEN order_status = 1 THEN 'PLACED'
		WHEN order_status = 2 THEN 'CONFIRMED'
		WHEN order_status = 3 THEN 'DISPATCHED'
		WHEN order_status = 4 THEN 'COMPLETED'
        ELSE 'UNKNOWN'
	END AS order_status_desc
	from[sales].[orders];

-- Q2: Categorize products by price:
--     Under $500 = 'Budget'
--     $500 to $2000 = 'Standard' 
--     Over $2000 = 'Premium'
--     Show product_name, list_price, and price_category.

select
    product_name,
	list_price,
	case
	when list_price > 500 then 'Budget'
	when list_price between 500 and 2000 then 'Standard'
	when list_price <2000 then 'premium'
	else 'unknown'
end as price_category
from [production].[products];

-- Q3: Using CASE with COUNT, count how many orders have status = 4 (Completed) 
--     vs non-completed for each store. Show store_id, completed_count, not_completed_count.

SELECT 
    store_id,
    COUNT(CASE WHEN order_status = 4 THEN 1 END) AS completed_count,
    COUNT(CASE WHEN order_status <> 4 THEN 1 END) AS not_completed_count
FROM [sales].[orders]
GROUP BY store_id;


-- Q4: Create a column called "year_label" that shows:
--     If model_year = 2024: 'New'
--     If model_year = 2023: 'Recent'
--     Else: 'Older'
--     Show product_name, model_year, year_label.

select 
product_name,
model_year,
case 
   when model_year=2024 then 'new'
   when model_year =2023 then 'recent'
   else 'older'
   end as year_label
from [production].[products];

-- Q5: For customers, show email and a column called "has_email" that says 'Yes' if email is not NULL, 'No' if NULL.
 
 select first_name+' '+last_name as customer_name,
 email,
 case 
 when email is not null then 'yes'
 when email is null then 'No'
 else 'No'
 end as 'has_email'
 from [sales].[customers];

-- ================================================================================
-- SECTION B: CTEs (Common Table Expressions)
-- ================================================================================

-- Q6: Create a CTE called "high_value_products" that selects products with list_price > 3000.
--     Then SELECT from that CTE to show all those products.
 
 WITH high_value_products as(
     select *
       from [production].[products]
	   where list_price >3000)

	   select * from high_value_products;

-- Q7: Write a CTE that calculates the average list_price of all products.
--     Then use it to find products that cost more than average.

WITH AVG_LIST_PRICE AS(
 select avg(list_price) as avg_price
 from [production].[products])

 select * from [production].[products]
 where list_price>(select avg_price from AVG_LIST_PRICE);

-- Q8: Create a CTE called "customer_order_counts" that counts how many orders each customer has.
--     Then use it to find customers with more than 5 orders.

WITH customer_order_counts as (
select
c.customer_id,
count (order_id) as order_count
from [sales].[orders]o
inner join [sales].[customers]c 
on o.customer_id=c.customer_id
group by c.customer_id)

select * from customer_order_counts where order_count>5; 

-- ================================================================================
-- SECTION C: ROW_NUMBER() and RANK() - EASY BEGINNER
-- ================================================================================

-- Q9: Use ROW_NUMBER() to number all products ordered by list_price from highest to lowest.
--      Show product_name, list_price, and row_number.

select 
product_name,
list_price,
ROW_NUMBER()OVER(ORDER BY list_price desc) as Rn
from [production].[products];

-- Q10: Use ROW_NUMBER() to rank products by price WITHIN each brand (partition by brand_id).
--      Show brand_id, product_name, list_price, and rank_in_brand.

select 
product_name,
brand_id,
list_price,
ROW_NUMBER()over (partition by brand_id order by list_price desc) as rank_in_brand
from [production].[products];

-- Q11: Use RANK() instead of ROW_NUMBER() on products ordered by list_price.
--      See what happens when multiple products have the same price.

select product_name,
list_price,
RANK() OVER (ORDER BY list_price)AS rank
from [production].[products];

-- ================================================================================
-- SECTION D: Window Functions - Running Totals and Averages
-- ================================================================================

-- Q12: Calculate a running total of daily orders (cumulative sum over time).
--      Show order_date, daily_order_count, and running_total.

select 
order_date,
count(*) as daily_order_count,
sum (count(*))over(order by order_date) as runnig_total
from [sales].[orders]
group by order_date;

-- Q13: For each product, show its list_price and the average list_price of its brand.
--      Use AVG() OVER (PARTITION BY brand_id).

select
product_name,
list_price,
brand_id,
avg(list_price) over(partition by brand_id order by list_price) as avg_price
from [production].[products];

-- Q14: Calculate a running total of quantity sold for each product over time.
--      Show product_id, order_date, quantity, and cumulative_quantity for that product.

select 
oi.product_id,
o.order_date,
oi.quantity,
sum(oi.quantity) over(partition by oi.product_id order by o.order_date)as cumulative_quantity
from [sales].[orders] o
inner join [sales].[order_items]oi
on o.order_id=oi.order_id;

-- ================================================================================
-- SECTION E: LAG, LEAD (Previous and Next)
-- ================================================================================

-- Q15: For each customer, show their order date and the date of their previous order.
--      Use LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date).

select 
customer_id,
order_date,
LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) as previous_date
from [sales].[orders];

-- Q16: Calculate the number of days between a customer's consecutive orders.
--      (Use LAG and DATEDIFF)

select customer_id,
order_date,
DATEDIFF(day,LAG(order_date)over (partition by customer_id order by order_date),order_date)as days_between_order
from [sales].[orders];

-- ================================================================================
-- SECTION F: PIVOT (Rows to Columns)
-- ================================================================================

-- Q17: Create a simple pivot showing the count of orders for each order_status (1,2,3,4) 
--      as separate columns. Only need store_id and the 4 status columns.

SELECT *
FROM (
    SELECT store_id, order_status,order_id
    FROM sales.orders
) AS SourceTable
PIVOT (
    COUNT(order_id)
    FOR order_status IN ([1], [2], [3], [4])
) AS PivotTable;

-- ================================================================================
-- SECTION G: Mixed Practice (Putting It All Together)
-- ================================================================================

-- Q18: Use CASE to categorize customers by total spending:
--      Over $5000 = 'VIP'
--      $1000-$5000 = 'Regular'
--      Under $1000 = 'New'
--      Show customer_name and tier.

with  customer_total_spending as(
select c.first_name+' '+c.last_name as customer_name,
sum(oi.quantity*oi.list_price*(1-oi.discount)) as total_spending
from [sales].[customers]c
inner join [sales].[orders]o
on c.customer_id=o.customer_id
inner join [sales].[order_items]oi
on oi.order_id=o.order_id
group by c.first_name+' '+c.last_name)

select customer_name,
total_spending,
case
when total_spending >5000 then 'VIP'
when total_spending between 1000 and 5000 then 'Regular'
when total_spending <1000 then 'New'
else 'Unknown'
end as Tier 
from  customer_total_spending ;

-- Q19: Use ROW_NUMBER() and CASE together: Find top 3 products per category, 
--      and label them as 'Gold', 'Silver', 'Bronze'.

with rank_products as
(select 
product_name,
product_id,
category_id,
row_number()over(partition by category_id order by product_id)as Rn
from [production].[products])

select 
product_name,
product_id,
category_id,
case
when Rn=1 then 'Gold'
when Rn=2 then 'Silver'
when Rn=3 then 'Bronze'
end as product_label
from rank_products
where Rn<=3;

-- Q20: Create a CTE that calculates monthly revenue, then use LAG to show month-over-month growth.

with monthly_revenue as(
select EOMONTH (o.order_date)as order_month,
sum (oi.quantity*oi.list_price*(1-oi.discount))as current_month_revenue
from [sales].[order_items]oi
inner join [sales].[orders]o
on oi.order_id=o.order_id
group by EOMONTH (o.order_date)
)

select 
order_month,
current_month_revenue,
lag(current_month_revenue,1)over (order by order_month) as previous_month_revenue
from  monthly_revenue;

-- Q21: Write a query that shows each product, its price, its rank in its brand, 
--      and a CASE that says 'Top Product' if rank = 1, else 'Other'.

with product_rank as(
select product_name,
list_price,
brand_id,
rank()over(partition by brand_id order by list_price desc)as Rank
from [production].[products])

select
brand_id,
product_name,
list_price,
case 
when Rank=1 then 'Top Product'
else 'other'
end as product_ranking
from product_rank;

-- Q22: Create a pivot showing the count of customers by state and by customer tier 
--      (you'll need to create the tier using CASE first, then pivot).

with Customer_Tier as(
select 
state,
customer_id,
case 
when customer_id<=500 then 'Tier 1'
when customer_id<=1000 then 'Tier 2'
else 'Tier 3'
end as customer_tier
from [sales].[customers]
)
select
state,
[Tier 1],[Tier 2],[Tier 3]
from  Customer_Tier
pivot (
count(customer_id)
FOR  customer_tier in([Tier 1],[Tier 2],[Tier 3])
)as PivotTable;

-- ================================================================================
-- END OF HOMEWORK - ALL QUESTIONS ARE BEGINNER-FRIENDLY
-- ================================================================================