-- ================================================================================
-- HOMEWORK: CLASS 4 - MODIFYING DATA, DDL, DATA TYPES & CONSTRAINTS
-- Database: BikeStores Sample Database
-- Instructions: Write SQL statements to solve each problem below.
-- Answers will be provided in a separate file.
-- ================================================================================

-- ================================================================================
-- SECTION A: DATA TYPES & CONSTRAINTS (Conceptual Questions)
-- ================================================================================

-- Q1: What data type would you use for a product's weight (e.g., 2.5 kg)?

weight decimal(5,3)  12345.999

-- Q2: In the sales.stores table, the zip_code is varchar(5). why not use INT?

ZIP codes are categorical identifiers, not numbers used for calculations. Since you will never add, subtract, or average ZIP codes, they should be stored as text

-- Q3: Look at sales.orders.order_status. The comment says 1=Pending,2=Processing,3=Rejected,4=Completed.
--     Is TINYINT a good choice? Why not use INT?

 yes tinyint is a good choice because the status value contains only 4 values which easily fit in tinyint.

-- Q4: If you add a CHECK constraint that rating must be BETWEEN 1 AND 5, what happens if you try to INSERT rating = 0?

If you try to insert a rating = 0, the database will reject the entry and throw an error.

-- Q5: Why does sales.staffs have UNIQUE constraint on email but not on phone?

Emails must be unique because they serve as distinct user accounts and login credentials. Phone numbers are not unique because multiple staff members often share the same store landline

-- ================================================================================
-- SECTION B: DDL (CREATE, ALTER, DROP)
-- ================================================================================

-- Q6: Create a new table called sales.loyalty_programs with the following columns:
--     - program_id (INT, auto-increment starting 1, PRIMARY KEY)
--     - program_name (VARCHAR(100), NOT NULL, UNIQUE)
--     - discount_rate (DECIMAL(3,2), NOT NULL, DEFAULT 0.05, CHECK between 0.00 and 0.50)
--     - start_date (DATE, NOT NULL, DEFAULT GETDATE())
--     - end_date (DATE, NULL)

CREATE TABLE sales.loyalty_programs (
    program_id INT primary key IDENTITY(1,1) NOT NULL,
    program_name VARCHAR(100) NOT NULL UNIQUE,
    
    discount_rate DECIMAL(3,2) NOT NULL
        DEFAULT 0.05
        CHECK (discount_rate BETWEEN 0.00 AND 0.50),

    start_date DATE NOT NULL DEFAULT GETDATE(),
    end_date DATE NOT NULL DEFAULT GETDATE()
);


-- Q7: Add a new column 'loyalty_program_id' (INT, NULL) to the sales.customers table.

    alter table [sales].[customers]
    add [loyalty_program_id] INT null;

-- Q8: Add a FOREIGN KEY constraint to sales.customers.loyalty_program_id that references 
--     sales.loyalty_programs.program_id.
        
        alter table [sales].[customers]
        add constraint fk_customer_loyality_program;
        foreign key (loyalty_program_id)
        references [sales].[loyalty_programs](program_id);

-- Q9: Change the data type of sales.customers.zip_code from VARCHAR(5) to VARCHAR(10).

    ALTER TABLE sales.customers
    ALTER COLUMN zip_code VARCHAR(10);

-- Q10: Drop the column 'birth_date' from sales.customers (first add it if it doesn't exist, then drop it).

   alter table sales.customers
   add birth_date date null;


   alter table sales.customers
   drop column  birth_date

-- Q11: Create a new table production.product_reviews with appropriate columns and constraints:
--      - review_id (PK, auto-increment)
--      - product_id (FK to production.products)
--      - customer_id (FK to sales.customers)
--      - rating (TINYINT, 1-5)
--      - review_text (VARCHAR(1000))
--      - review_date (DATE, default today)
create table production.product_reviews (
review_id int primary key identity(1,1),
product_id int not null references [production].[products] (product_id),
customer_id int not null references [sales].[customers] (customer_id),
 rating TINYINT check (rating between 1 and 5),
 review_text VARCHAR(1000),
 review_date DATE default getdate()
 );

-- ================================================================================
-- SECTION C: INSERT STATEMENTS
-- ================================================================================

-- Q12: Insert a new brand called 'Santa Cruz' into production.brands.

SET IDENTITY_INSERT production.brands on;
        
        INSERT INTO production.brands
        (BRAND_ID, BRAND_NAME)
        VALUES (10,  'Santa Cruz')

        select* from [production].[brands];

-- Q13: Insert three new categories at once: 'Mountain', 'Road', 'Hybrid'.
 
 SELECT * FROM production.categories;
 INSERT INTO production.categories
 (category_name)
 VALUES ('Mountain'), ('Road'), ('Hybrid')
        

-- Q14: Insert  a new product with the following details:
--      product_name = 'Santa Cruz Bronson'
--      brand_id = (the brand_id of 'Santa Cruz' from Q12)
--      category_id = (category_id of 'Mountain' from Q13)
--      model_year = 2025
--      list_price = 4299.99

insert into [production].[products](
product_name,
brand_id,
category_id,
model_year,
list_price
)
select
 'Santa Cruz Bronson',
 (select brand_id from [production].[brands] where brand_name ='Santa Cruz'),
 (select category_id from [production].[categories] where category_name ='Mountain' ),
 2025,
 4299.99
 ;

 select* from [production].[products] where brand_id=10;

-- Q15: Copy all customers from California (state = 'CA') into a new table called sales.ca_customers_backup.
--      (Create the table first with the same structure as sales.customers)

CREATE TABLE sales.ca_customers_backup (
	[customer_id] [int] IDENTITY(1,1) NOT NULL,
	[first_name] [varchar](255) NOT NULL,
	[last_name] [varchar](255) NOT NULL,
	[phone] [varchar](25) NULL,
	[email] [varchar](255) NOT NULL,
	[street] [varchar](255) NULL,
	[city] [varchar](50) NULL,
	[state] [varchar](25) NULL,
	[zip_code] [varchar](10) NULL,
	[loyalty_program_id] [int] NULL
    );

    set identity_insert [sales].[ca_customers_backup] on;
    
    insert into [sales].[ca_customers_backup](customer_id ,first_name,last_name,phone,email,street,city,state,zip_code,loyalty_program_id)
    select 
    customer_id,first_name,last_name,phone,email,street,city,state,zip_code,loyalty_program_id
    from [sales].[customers]
    where state='CA';

       set identity_insert [sales].[ca_customers_backup] off;

    select * from [sales].[ca_customers_backup];
-- ================================================================================
-- SECTION D: UPDATE STATEMENTS
-- ================================================================================

-- Q16: Update the phone number of customer with customer_id = 10 to '(555) 123-4567'.

update [sales].[customers] 
set [phone]=  '(555) 123-4567'
where customer_id = 10;

-- Q17: Increase the list price of all products in the 'Road' category by 8%.

update p
set p.list_price=p.list_price*1.08
from [production].[products]p
inner join [production].[categories]c
on p.category_id=c.category_id
where c.category_name ='Road';

-- Q18: Mark all orders that have status = 4 (Completed) and shipped_date IS NULL 
--      to set shipped_date = order_date + 3 days.
 
 update [sales].[orders]
 set order_date= dateadd(day,3,order_date)
where order_status=4 and shipped_date=null;

-- Q19: Set the manager_id of all staffs working at store_id = 1 to staff_id = 5 
--      (assume staff_id 5 is the manager of that store).

update [sales].[staffs]
set manager_id= 5
where store_id =1;

select* from [sales].[staffs]
where store_id=1;

-- Q20: Update the discount for order_items where order_id = 100 and item_id = 2 to 0.15 (15%).

update [sales].[order_items]
set discount = 0.15
where order_id=100 and item_id=2;

select * from [sales].[order_items]
where order_id=100;

-- ================================================================================
-- SECTION E: DELETE STATEMENTS
-- ================================================================================

-- Q21: Delete the brand 'Santa Cruz' you inserted in Q12
 
 delete from [production].[brands]
 where brand_name= 'Santa Cruz';

-- Q22: Delete all order_items that have quantity = 0.

delete from [sales].[order_items]
where quantity=0;

-- Q23: Delete all customers who have never placed an order (use subquery with NOT EXISTS).
 
 select * from [sales].[customers]
 where not exists (
 select 1
 from[sales].[orders]
 where [sales].[orders].customer_id=[sales].[customers].customer_id);

-- Q24: Delete all products that have list_price > 10000 and model_year < 2020.

delete from [production].[products]
where list_price>10000 and model_year<2020;

-- Q25: Delete the loyalty_programs table you created in Q6 (clean up).

  
        alter table [sales].[customers]
        drop constraint fk_customer_loyality_program;

      drop table [sales].[loyalty_programs];

-- ================================================================================
-- SECTION F: COMBINED & CHALLENGE QUESTIONS
-- ================================================================================

-- Q26: Write a single transaction that:
--      1. Creates a new store called 'Downtown LA'
--      2. Adds 3 new staff members to that store
--      3. Inserts 100 units of product_id = 1 into stocks for that store
--      (ROLLBACK if any step fails)

INSERT INTO [sales].[stores] (store_name)
values ('Downtown LA');

  DECLARE @NewStoreId INT;
    SET @NewStoreId = SCOPE_IDENTITY();

    INSERT INTO [sales].[staffs] (first_name, last_name, email, phone, active, store_id, manager_id)
    VALUES 
    ('John', 'Doe', 'john.doe@bikes.shop', '(555) 010-1234', 1, @NewStoreId, NULL),
    ('Jane', 'Smith', 'jane.smith@bikes.shop', '(555) 010-5678', 1, @NewStoreId, NULL),
    ('Alice', 'Johnson', 'alice.j@bikes.shop', '(555) 010-9012', 1, @NewStoreId, NULL);

 

     INSERT INTO production.stocks (store_id, product_id, quantity)
    VALUES (4, 1, 100);

   select * from [production].[stocks];

-- Q27: Change the schema of sales.order_items: add a new column 'tax_amount' DECIMAL(8,2) DEFAULT 0.00,
--      then update it to be (list_price * quantity * discount * 0.08) for all existing rows.

ALTER TABLE sales.order_items 
ADD tax_amount DECIMAL(8,2) DEFAULT 0.00;

UPDATE sales.order_items 
SET tax_amount = list_price * quantity * discount * 0.08;

select * from [sales].[order_items];

-- Q28: Identify and delete duplicate email addresses in sales.customers (keeping the smallest customer_id).

   with cte as (
   select customer_id,
   email,
   ROW_NUMBER ( ) over(partition by email order by customer_id asc) as Rn
   from [sales].[customers])
   DELETE FROM CTE 
   WHERE customer_id IN(
   select customer_id from cte 
   where Rn >1
   );
-- Q29: Archive all orders from year 2020 or older: 
--      Insert them into a new table sales.orders_archive, then delete from sales.orders.

CREATE TABLE sales.orders_archive (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_status TINYINT,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    store_id INT,
    staff_id INT
);

insert into [sales].[orders_archive]
select * from [sales].[orders]
where year(order_date)<=2020;

delete from [sales].[orders]
where year(order_date)<=2020;

-- Q30: Add a CHECK constraint to production.products ensuring list_price >= 0 AND model_year BETWEEN 1900 AND YEAR(GETDATE())+1.

ALTER TABLE production.products
ADD CONSTRAINT CHK_product
CHECK (list_price >= 0 AND model_year >= 1900 AND model_year <= YEAR(GETDATE()) + 1);

-- ================================================================================
-- END OF HOMEWORK QUESTIONS
-- ================================================================================