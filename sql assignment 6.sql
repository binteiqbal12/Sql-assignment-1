-- ============================================================
--  HOMEWORK: Indexes & Stored Procedures
--  Topic   : SQL Indexes + Stored Procedures
--  Level   : Beginner to Intermediate
-- ============================================================


-- ============================================================
--  PART A: INDEXES
-- ============================================================

-- Q1.
-- Write a query to create a non-clustered index on the
-- last_name column of sales.customers.
-- Then write a SELECT statement that would benefit from it.
-- Hint: Think about which queries filter by last name.

-- Your answer here:

create  nonclustered index idx_customer_lastname on [sales].[customers] (last_name)

select *from [sales].[customers]
where last_name='Todd';

-- Q2.
-- Create a composite index on sales.orders using
-- customer_id and order_date.
-- Write a query that filters on both columns and benefits
-- from this index.
-- Hint: Composite indexes work best when you filter on both columns.

-- Your answer here:

create index idx_customer_id_orderdate on [sales].[orders](customer_id,order_date)
 
 select * from [sales].[orders]
 where customer_id=51 and order_date='2016-05-13';

-- Q3.
-- A teammate suggests adding a unique index on
-- sales.customers(phone_number).
-- What could go wrong with this?
-- What assumption must be true for this to be safe?
-- Hint: Think about duplicate or missing (NULL) values.

-- Your answer here (write as a comment):

--1. if any customer share a phone number, the index creation will fail.
--2.If multiple customers have missing (NULL) phone numbers, SQL Server will 
--treat them as duplicates and reject the index or block future NULL entries.
-- if we create index on uniqe columns ,quere performance improves significantly.

-- Q4.
-- Look at the columns below from a sales.orders table.
-- Decide which columns SHOULD have an index and which should NOT.
-- Explain your reasoning for each as a comment.
--
--   order_id     (Primary Key)
--   status       (only 3 values: Pending, Shipped, Delivered)
--   customer_id  (Foreign Key)
--   notes        (free text, rarely searched)

-- Your answer here (write as a comment):

-- order_id: SHOULD NOT create a manual index.
-- Reasoning: Because it is the Primary Key, SQL Server automatically creates a 
--            clustered index for it. Creating another one would be redundant.

-- status: SHOULD NOT have an index.
-- Reasoning: It has very low selectivity (only 3 distinct values). The query 
--            optimizer will ignore the index and perform a full table scan instead.

-- customer_id: SHOULD have an index.
-- Reasoning: As a Foreign Key, this column will be frequently used in JOIN operations 
--            with the customers table and inside WHERE clauses to filter by customer.

-- notes: SHOULD NOT have an index.
-- Reasoning: Free-text columns take up too much index storage space, slow down write 
--            performance, and this specific column is rarely searched anyway.

-- Q5.
-- Write the command to check existing indexes on production.products.
-- Then describe (as a comment) what the output columns tell you.
-- Hint: Use sp_helpindex.

-- Your answer here:

EXEC sp_helpindex '[production].[products]'

--it tells the index name , index description and index key.
-- ============================================================
--  PART B: STORED PROCEDURES
-- ============================================================

-- Q6.
-- Create a stored procedure called sp_GetCustomerOrders
-- that accepts a @CustomerID parameter and returns all orders
-- for that customer showing: order_id, order_date, order_status.
-- Test it using EXEC after you create it.

-- Your answer here:

CREATE PROCEDURE sp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT order_id, order_date, order_status
    FROM sales.orders
    WHERE customer_id = @CustomerID;
END;

EXEC sp_GetCustomerOrders @CustomerID=4;

-- Q7.
-- Modify sp_GetCustomerOrders from Q6 so that if no orders
-- are found for the given customer, it returns the message:
-- 'No orders found for this customer'
-- Hint: Use IF EXISTS or check @@ROWCOUNT.

-- Your answer here:

alter PROCEDURE sp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN
if exists
(select 1 from [sales].[orders] where customer_id= @CustomerID)
begin 
select order_id,
order_date,
order_status
from [sales].[orders]
where customer_id=@CustomerID;
end
else 
begin
    select  'No orders found for this customer' as message;
    end
    end;

    EXEC sp_GetCustomerOrders @CustomerID=1500;

-- Q8.
-- Create a stored procedure sp_ProductsByCategory that accepts:
--   @CategoryID  INT
--   @MaxPrice    DECIMAL(10,2)  with a default value of 9999
-- It should return all matching products ordered by price (low to high).
-- Hint: Use a default parameter value like you saw with @threshold.

-- Your answer here:

create procedure  sp_ProductsByCategory
@CategoryID int,
@MaxPrice decimal(10,2)=9999
as 
begin
select*
from [production].[products]
where category_id=@CategoryID
and list_price<=@MaxPrice
ORDER BY list_price asc;
end;

EXEC  sp_ProductsByCategory @CategoryID=1,@MaxPrice=150;

-- ============================================================
--  PART C: MIXED / THINK QUESTIONS
-- ============================================================

-- Q9.
-- You have a sales.orders table with 2 million rows.
-- A stored procedure filters by store_id and order_date.
-- It runs very slowly.
-- What TWO things would you do to fix it, and why?
-- Hint: Think about both indexes and procedure logic.

-- Your answer here (write as a comment):

--create a composite index on store_id and order_DATE 
-- This prevents full table scans on 2 million rows by letting SQL Server pinpoint matches instantly.
 
 --Optimize procedure logic for parameter sniffing
 --(using WITH RECOMPILE or OPTIMIZE FOR hints) so the database generates a fresh, efficient execution plan tailored to the specific store's data volume.

-- Q10.
-- A junior developer creates indexes on EVERY column of a table
-- to "make everything faster".
-- Write a short explanation (3-5 sentences) of why this is
-- actually a bad idea.
-- Hint: Think about how INSERT, UPDATE, and DELETE are affected.

-- Your answer here (write as a comment):

-- Indexing every column is a bad idea for three main reasons:
-- 1. It severely slows down INSERT, UPDATE, and DELETE operations because SQL Server must update every single index whenever data changes.
-- 2. It wastes enormous amounts of disk space and memory (RAM) by duplicating the table data repeatedly.
-- 3. It degrades performance because the query optimizer wastes time analyzing too many index choices, sometimes picking an inefficient one.

-- ============================================================
--  END OF HOMEWORK
-- ============================================================