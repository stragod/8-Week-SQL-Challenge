# A. Pizza Metrics
# data cleaning
drop table if exists new_customer_orders;
create table new_customer_orders as
(select order_id,customer_id,pizza_id,
case 
when exclusions is null or exclusions like "null" then null
when exclusions = '' then null
else exclusions 
end as exclusions,
case 
when extras is null or extras like "null" then null
when extras = '' then null
else extras
end as extras,order_time
from customer_orders);
 select * from new_customer_orders;
 drop table if exists new_runner_orders;
 create table new_runner_orders as
 (select order_id,runner_id,
 case
 when pickup_time is null or pickup_time like "null" then null
 else pickup_time 
 end as pickup_time,
 case
 when distance is null or distance like "null" then null 
 when distance like "%km" then trim(trailing "km" from distance)
 else distance 
 end as distance,
 case
 when duration is null or duration like "null" then null
 when duration like "%mins" then trim(trailing "mins" from duration)
 when duration like "%minute" then trim(trailing "minute" from duration)
 when duration like "%minutes" then trim(trailing "minutes" from duration)
 else duration
 end as duration,
 case 
 when cancellation is null or cancellation like "null" then null
 when cancellation = '' then null
 else null
 end as cancellation 
 from runner_orders);
 select * from new_runner_orders;
# alter table new_runner_orders
# change the column datatypes to the correct format
ALTER TABLE new_runner_orders
change column pickup_time pickup_time datetime,
CHANGE COLUMN distance distance decimal(10,2),
change column duration duration int;
#CHANGE COLUMN duration duration int;

# 1. How many pizzas were ordered?
 select count(order_id) from customer_orders;
 
# How many unique customer orders were made?
select count(distinct(order_id)) from customer_orders;

# How many successful orders were delivered by each runner?
select runner_id,count(order_id) as succesful_orders from new_runner_orders
where distance is not null
group by runner_id;

# How many of each type of pizza was delivered?
select pizza_name,count(order_id) as number_of_orders from 
(select order_id,runner_id,distance,pizza_name from 
new_customer_orders join pizza_names using (pizza_id)
right join new_runner_orders using (order_id) 
where distance is not null)t
group by pizza_name;

# How many Vegetarian and Meatlovers were ordered by each customer?
with t as (
select order_id,customer_id,pizza_id,pizza_name from new_customer_orders
 left join pizza_names using (pizza_id))

select customer_id,pizza_name,count(order_id) from t
 group by customer_id,pizza_name
 order by customer_id;
 
# What was the maximum number of pizzas delivered in a single order?
with t as 
( select order_id,count(pizza_id) as number_of_pizzas from new_runner_orders
left join new_customer_orders using (order_id)
where distance is not null
group by order_id )

select order_id,max(number_of_pizzas) from t;

# For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
with t as
(
 select order_id,customer_id,pizza_id,exclusions,extras,
 sum(
 case
 when exclusions is null and extras is null then 1
 else 0
  end ) as no_change,
  sum(
  case
  when exclusions is not null or extras is not null then 1
  else 0
  end) as min_1_change
 from new_customer_orders
 join new_runner_orders using (order_id)
 where distance is not null
 group by customer_id
)
select  customer_id,no_change,min_1_change from t;
 
# How many pizzas were delivered that had both exclusions and extras?
with t as
(
 select order_id,customer_id,pizza_id,exclusions,extras,
 sum(
 case
 when exclusions is not null and extras is not null then 1
 else 0
  end ) as exclusions_and_extras
 from new_customer_orders
 join new_runner_orders using (order_id)
 where distance is not null
 group by customer_id
)
select  customer_id,exclusions_and_extras from t
where exclusions_and_extras = 1;
# What was the total volume of pizzas ordered for each hour of the day?
select  hour(order_time) as hours,count(order_id) from new_customer_orders
group by hour(order_time);

# What was the volume of orders for each day of the week?