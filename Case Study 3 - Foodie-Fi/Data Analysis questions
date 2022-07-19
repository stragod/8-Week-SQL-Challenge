-- B. Data Analysis Questions

-- How many customers has Foodie-Fi ever had?
 select count(distinct(customer_id)) from subscriptions; 
     
-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
	select plan_id,count(plan_id) as `no`,month(start_date)  from subscriptions
    group by plan_id,month(start_date)
	order by month(start_date);
    
-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select plan_name,count(plan_id),year(start_date) from (select plan_name,plan_id,start_date from subscriptions 
join plans using (plan_id)
where year(start_date) <> 2020
)t
group by plan_id;

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select sum(case when plan_name= 'churn' then 1 else 0 end) as count,concat(round(100*sum(case when plan_name = 'churn' then 1 else 0 end)/count(distinct(customer_id)),1),'%') as percentage 
from subscriptions 
join plans using (plan_id);

-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
with t as (( select * ,dense_rank() over ( partition by customer_id order by plan_id) as ran from  subscriptions 
join plans using (plan_id)))
select sum(case when plan_name= 'churn' and ran = 2 then 1 else 0 end) as count,concat(round((100*sum(case when plan_name = 'churn' and ran= 2 then 1 else 0 end)/count(distinct(customer_id)))),'%') as percentage 
from t;
-- What is the number and percentage of customer plans after their initial free trial?
with t as ( select * ,dense_rank() over ( partition by customer_id order by plan_id) as ran 
from  subscriptions 
join plans using (plan_id))

select sum(case when ran > 1 then 1 else 0 end) as count,concat(round((100*sum(case when ran > 1 then 1 else 0 end)/count(plan_id))),'%') as percentage 
from t;
-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

-- How many customers have upgraded to an annual plan in 2020?
select sum(case when plan_name= 'pro annual' then 1 else 0 end) as number_of_customers from
(select * from subscriptions 
join plans using (plan_id) 
where year(start_date) = 2020)t;
-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with trial as 
( select customer_id,start_date as tri_date from subscriptions
where plan_id = 0),
annual as
( select customer_id, start_date as ann_date from subscriptions
where plan_id = 3)
select avg(datediff(ann_date,tri_date)) from trial 
join annual on trial.customer_id = annual.customer_id;
