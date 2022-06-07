select * from information_schema.columns
where table_schema = 'test'
order by table_name,ordinal_position;

#What is the total amount each customer spent at the restaurant?
select sum(price), customer_id from `test`.menu,`test`.sales
group by customer_id;

#How many days has each customer visited the restaurant?
select count(distinct(order_date)),customer_id from `test`.sales
group by customer_id;

#What was the first item from the menu purchased by each customer? 
select customer_id,product_name,order_date from 
(select customer_id,order_date,product_name, dense_rank() over (partition by customer_id order by order_date ASC) as `rank` from sales
left join menu using (product_id))t
where `rank` = 1;

# What was the most purchased item on the menu and how many times was it purchased by all customers?

select product_name,count(*) as sal from sales
left join menu using (product_id)
group by product_id
order by sal DESC
limit 1;

#Which item was the most popular for each customer?
select customer_id,product_name from 
( select customer_id,product_name,count(product_id) as order_count, dense_rank() over (partition by customer_id order by count(customer_id) DESC ) as `rank`  from sales
left join menu using (product_id)
group by customer_id,product_id
)t
where `rank` = 1;

#Which item was purchased first by the customer after they became a member?
select customer_id,product_name from
( select customer_id,order_date,product_id,dense_rank() over (partition by customer_id order by order_date ASC) as `rank` from sales 
join members using(customer_id)
where members.join_date<sales.order_date
)t
join menu using (product_id)
where `rank` = 1;

#Which item was purchased just before the customer became a member?
select customer_id,order_date,product_name from
( select customer_id,order_date,product_id, dense_rank() over (partition by customer_id order by order_date DESC) as `rank` from sales
join members using (customer_id)
where members.join_date>sales.order_date)t
join menu using (product_id)
where `rank` = 1;

#What is the total items and amount spent for each member before they became a member?
select customer_id,sum(price) as amount,count(product_id) as total_items from
( select * from sales
join members using (customer_id)
join menu using (product_id)
where members.join_date>sales.order_date
)t
group by customer_id;

#If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with point_table  as (
select *, 
case when product_name = "sushi" then price*20
else price*10 end as points
from menu 
)         
select customer_id,sum(points) from sales
join point_table using (product_id)
group by customer_id ;
 
#In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

#Bonus Questions
# Join all Things
with t as(
select * from sales
left join menu using (product_id)
left join members using (customer_id)
)

select customer_id,order_date,product_name,price,
case when  join_date>order_date then "N"
when join_date <= order_date then "Y"
else "N" end as member
from t;

#Rank All The Things 
with `table` as (
select customer_id,order_date,product_name,price,
case when  join_date>order_date then "N"
when join_date <= order_date then "Y"
else "N" end as member from sales
left join menu using (product_id)
left join members using (customer_id)
)
 
 select *, 
 case when member = "N" then NULL
 when member = "Y" then dense_rank() over (partition by customer_id,member order by order_date ASC) end as ranking
 from `table`
 
 


