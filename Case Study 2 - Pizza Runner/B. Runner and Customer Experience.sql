# B. Runner and Customer Experience

# How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select count(runner_id) as no_of_registrations,(week(registration_date,5)+1) as 1_week_period from runners
group by week(registration_date,5);

# What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
with t as 
(
select order_id,runner_id,pickup_time,order_time,timediff(pickup_time,order_time) as time_taken from new_runner_orders
join new_customer_orders using (order_id)
where distance <> 0 
group by order_id
)

select runner_id,sec_to_time(avg(time_to_sec(time_taken))) as avg_time from t 
group by runner_id
order by runner_id;

# Is there any relationship between the number of pizzas and how long the order takes to prepare?
with t as 
(
select order_id,pizza_id,timediff(pickup_time,order_time) as time_taken,exclusions,extras from new_runner_orders
join new_customer_orders using (order_id)
where distance <> 0
)

select order_id,count(extras),count(exclusions),count(pizza_id) as no_of_pizza,sec_to_time(avg(time_to_sec(time_taken))) as avg_time from t
group by order_id
order by sec_to_time(avg(time_to_sec(time_taken))) DESC; 

# What was the average distance travelled for each customer?
with t as 
(
select order_id,customer_id,pizza_id,distance from new_runner_orders
join new_customer_orders using (order_id)
where distance <> 0
)
select customer_id,avg(distance) from t
group by customer_id;

# What was the difference between the longest and shortest delivery times for all orders?
select (max(duration)-min(duration)) as difference from new_runner_orders;

# What was the average speed for each runner for each delivery and do you notice any trend for these values?
with t as (
select round(avg(((distance)/(duration/60))),2) as speed,runner_id,order_id,distance,(duration/60) as duration_hr from new_runner_orders
where distance <> 0
group by order_id
order by runner_id 
)
 select avg(speed),runner_id from t
 group by runner_id
 order by runner_id;
 
# What is the successful delivery percentage for each runner?
select round(100*sum(case when distance is null then 0 else 1 end )/count(*)) as percentage,runner_id from new_runner_orders
group by runner_id;