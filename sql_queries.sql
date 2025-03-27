use pizza_sales;
# EXPLORE TABLES -------------------------------
select * from  pizza_types;
select * from  pizzas;
select * from  orders;
select * from  order_details;

# TOTAL ORDER COUNT ---------------------------------------------------------------
select count(orderid) from orders;

# TOTAL SALES -------------------------------------------------------------------------------------------
select sum(od.quantiy * p.price) as total_sales
from order_details od
join pizzas p ON od.pizza_id = p.pizza_id;

# MOST SELLING PIZZA-----------------------------------------------------------------------------------------------------
select p.pizza_id,pt.name,sum(od.quantiy) as total_quantity_sold
from order_details od 
join pizzas p ON p.pizza_id = od.pizza_id
join pizza_types pt ON pt.pizza_type = p.pizza_type_id
group by p.pizza_id,pt.name
order by total_quantity_sold DESC
limit 15;

# LEAST SELLING PIZZA --------------------------------------------------------------------------
select p.pizza_id,pt.name,sum(od.quantiy) as total_quantity_sold
from order_details od 
join pizzas p ON p.pizza_id = od.pizza_id
join pizza_types pt ON pt.pizza_type = p.pizza_type_id
group by p.pizza_id,pt.name
order by total_quantity_sold
limit 15;

# MOST POPULAR PIZZA SIZE -------------------------------------------------------------------------------------------
select p.size,sum(od.quantiy) as total_sold
from order_details od
join pizzas p ON p.pizza_id = od.pizza_id
group by p.size
order by total_sold DESC;

# Average sales per day------------------------------------------------------------------------------------------------------
select avg(daily_sales) as avg_daily_sales
from(
select date(o.date) as order_date,
sum(od.quantiy*p.price) as daily_sales
from orders o
join order_details od ON od.order_id = o.orderid
join pizzas p ON p.pizza_id = od.pizza_id
group by order_date
) AS subquery;

# MONTHLY SALES ---------------------------------------------------------------------------------------
select date_format(o.date, "%Y-%m") as order_month,count(o.orderid) as total_orders,
sum(od.quantiy * p.price) as monthly_sales
from orders o 
join order_details od ON o.orderid = od.order_id
join pizzas p  ON p.pizza_id = od.pizza_id
group by order_month
order by order_month desc
limit 15; 

# HIGHEST SEELING PIZZA CATEGORY ------------------------------------------------------------------
select pt.category,sum(od.quantiy) as total_quantity_sold
from order_details od
join pizzas p ON p.pizza_id = od.pizza_id
join pizza_types pt ON pt.pizza_type = p.pizza_type_id
group by pt.category
order by total_quantity_sold DESC;

# peak hours with revenue----------------------------------------------------------------------------------------------
select hour(o.time) as order_hour,
count(o.orderid) as total_orders,
sum(od.quantiy * p.price) as total_revenue
from orders o
join order_details od on o.orderid = od.order_id
join pizzas p on p.pizza_id = od.pizza_id
group by order_hour
order by total_orders desc;

# low selling pizza type ------------------------------------------------------------------
select pt.name,sum(od.quantiy) as total_sold
from order_details od 
join pizzas p ON p.pizza_id = od.pizza_id
join pizza_types pt ON pt.pizza_type = p.pizza_type_id
group by pt.name
order by total_sold
limit 5; 

# most popular ingridents  --------------------------------------------------------------------------
select pt.ingredients,count(od.order_id) as total_orders
from order_details od
join pizzas p ON od.pizza_id = p.pizza_id
join pizza_types pt ON pt.pizza_type = p.pizza_type_id
group by pt.ingredients
order by total_orders DESC
limit 3;

# order per day -------------------------------------------------------------------
select o.date,count(o.orderid) as total_orders
from orders o
group by o.date
order by o.date;

# Biggest order-------------------------------------------------------------------------------------------
SELECT o.orderid, COUNT(od.pizza_id) AS total_pizzas, 
       SUM(od.quantiy * p.price) AS order_value
FROM orders o
JOIN order_details od ON o.orderid = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.orderid
ORDER BY order_value DESC
LIMIT 10;

# best time for discount --------------------------------------------------------------------
SELECT 
    CASE 
        WHEN HOUR(o.time) BETWEEN 11 AND 14 THEN 'Lunch Time'
        WHEN HOUR(o.time) BETWEEN 18 AND 21 THEN 'Dinner Time'
        ELSE 'Non-Peak Time'
    END AS time_category,
    COUNT(o.orderid) AS total_orders
FROM orders o
GROUP BY time_category
ORDER BY total_orders DESC;

#WEEKEND AND WEEKDAY SALES ------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN DAYOFWEEK(o.date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(o.orderid) AS total_orders
FROM orders o
GROUP BY day_type;

# BEST SEELINNG PIZZA ON WEEKEND -------------------------------------------------------------------------
SELECT p.pizza_id, COUNT(od.pizza_id) AS total_orders
FROM orders o
JOIN order_details od ON o.orderid = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
WHERE DAYOFWEEK(o.date) IN (1, 7)
GROUP BY p.pizza_id
ORDER BY total_orders DESC
LIMIT 10;

#MONTH GROWTH RATE
SELECT month_number, total_orders,
       LAG(total_orders) OVER (ORDER BY month_number) AS previous_month_orders,
       ((total_orders - LAG(total_orders) OVER (ORDER BY month_number)) / 
       LAG(total_orders) OVER (ORDER BY month_number)) * 100 AS growth_rate
FROM (
    SELECT MONTH(o.date) AS month_number, COUNT(o.orderid) AS total_orders
    FROM orders o
    GROUP BY month_number
) AS monthly_data;
