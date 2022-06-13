# A. Pizza Metrics
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
group by hour(order_time)
order by hour(order_time);

# What was the volume of orders for each day of the week?
select  dayname(order_time) as day_of_the_week,count(order_id) from new_customer_orders
# Since we only need day of the week, we use dayofweek() function which indexes day of week to filter the the weekend (check documentation for indexing details)
where dayofweek(order_time) <> 1 AND dayofweek(order_time) <> 7 
group by dayname(order_time)
order by day(order_time); 
