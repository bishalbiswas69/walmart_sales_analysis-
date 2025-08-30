create database walmart_db; 
use walmart_db;

select * from walmart;
select count(*) from walmart;
select distinct payment_method from walmart;
select payment_method,
        count(*)  
from walmart
group by  payment_method;

select count(distinct branch ) from walmart;

-- Business Problems
-- Q.1 Find different payment method and no of transactions,number quantity sold
select payment_method,
count(*) as no_of_transactions,
sum(quantity) as no_qty_sold 
from walmart 
group by payment_method;

-- Q.2 Identify the highest rated category in each branch displaying the branch,category and avg rating
select * from (
   select branch,
	   category,
       avg(rating) as avg_rating,
       rank() over(partition by branch order by avg(rating) desc) as rnk
   from walmart
group by branch,category
)as sub 
where rnk = 1;

-- Q.3 Identify the busiest day of each branch based on the number od transactions
select * from( 
select
    branch,
    dayname(str_to_date(`date`, '%d/%m/%y')) as day_name,
    count(*) as no_transactions,
    rank() over(partition by branch order by count(*)  desc ) as transc_rank
FROM walmart
group by branch,day_name
)as sub
where transc_rank=1;

-- Q.4 calculate the total quantity of items sold per payment method.List payment method and total quantities
select payment_method,
count(*) as no_of_transactions,
sum(quantity) as no_qty_sold 
from walmart 
group by payment_method;

-- Q.5 Determine the average minimum and maximum rating of category  for each city 
-- list the city ,average rating,maximum rating,minimum rating
select 
	city,
    category,
    min(rating),
    max(rating),
    avg(rating)
from walmart
group by city,category ;    


-- Q.6 calculate the total profit  of each category by considering total profit as 
-- (unit_price * quantity * profit margin)
-- list category and total profit  ordered from highest to lowest profit

select
	category,
    sum(total * quantity) as total_revenue,
    sum(total * quantity * profit_margin) as profit
from walmart
group by category;

    
-- Q.7 determine the most common payment method for each branch.Display branch and display branch and preffered payment method
	
    with  cte as 
    (select 
		branch,
        payment_method,
        count(*) as total_trans,
        rank() over(partition by branch order by count(*) desc) as rnk
	from walmart
    group by branch,payment_method
     ) 
     select * from cte 
     where rnk = 1;
     
	-- categorize sales in to three group morning,afternoon and evening
    -- find out each of the shift and number of invoices
    
SELECT 
branch,
    case
		when hour(str_to_date(`time`,'%H:%i:%s')) between 6  and  11 then "morning shift"
        when hour(str_to_date(`time`,'%H:%i:%s')) between 12 and  17 then "afternoon shift"
        when hour(str_to_date(`time`,'%H:%i:%s')) between 18 and  23 then "evening shift"
        else "night shift"
    end as shift,
    count(*) as no_invoices
   
FROM walmart
group by branch,shift
order by no_invoices desc;

-- Q.8 indentify the 5 branch with highest decrease in revenue compare to last year(current year 2022 and last year is 2022)
-- revenue decrease ratio= last year revenue - current year revenue /last year revenue *100
select 
 *,
year(str_to_date(`date`, '%d/%m/%y')) as formatted_date
from walmart;

-- 2022 sales
with revenue_2022 
as
(
select
branch,
sum(total) as revenue
from walmart
where year(str_to_date(`date`, '%d/%m/%y')) =  2022
group by branch
),
-- 2023 sales

revenue_2023
as
(
select
branch,
sum(total) as revenue
from walmart
where year(str_to_date(`date`, '%d/%m/%y')) =  2023
group by branch
)
select 
ls.branch,
ls.revenue as revenue_2022,
cs.revenue as revenue_2023,
round(((ls.revenue - cs.revenue)/ls.revenue )* 100,2) as revenue_drop_percent
from revenue_2022 as ls
join 
revenue_2023 as cs
on ls.branch=cs.branch
where ls.revenue > cs.revenue
order by revenue_drop_percent desc;

