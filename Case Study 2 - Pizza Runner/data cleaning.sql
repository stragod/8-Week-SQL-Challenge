# Data Cleaning 
# Customer order table - removing blank and Nan values and replacing with null values 
# remember to check the resultant table to see if the null values filled in the table are key-words ( highlighted in grey) and not strings.
# key word null are very useful since they can easily be identified using inbuilt mysql functions
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
 
# Creating a new cleaned table with null values and no other blank or NaN like values
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

# Change the column datatypes to the correct format
ALTER TABLE new_runner_orders
change column pickup_time pickup_time datetime,
CHANGE COLUMN distance distance decimal(10,2),
change column duration duration int;
