-- PIZZA ORDER DELIVERY ANALYSIS

-- BASIC QUESTIONS 

-- 1. Retrieve the total number of orders placed

SELECT COUNT(order_ID) AS Total_Orders
FROM orders;

-- ANS : 21350

-- 2. Calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(OD.quantity * P.price), 2) AS TOTAL_Revenue
FROM
    order_details AS OD
        INNER JOIN
    pizzas AS P ON OD.pizza_ID = P.pizza_id;
    
-- ANS : 817860.05

-- 3. Identify the highest-priced pizza

SELECT *
FROM pizzas
ORDER BY price DESC
LIMIT 1;

-- ANS : the_greek_xxl, Price = 35.95

-- 4. Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(quantity)
FROM
    order_details AS OD
        INNER JOIN
    pizzas AS P ON OD.pizza_id = P.pizza_ID
GROUP BY P.size
ORDER BY COUNT(quantity) DESC;

-- Ans : Large size has highest Order = 18526

-- 5. List the top 5 most ordered pizza types along with their quantities

SELECT 
    P.pizza_type_id, name, SUM(quantity)
FROM
    order_details AS OD
        INNER JOIN
    pizzas AS P ON OD.pizza_id = P.pizza_id
        INNER JOIN
    pizza_types AS PT ON PT.pizza_type_id = P.pizza_type_id
GROUP BY P.pizza_type_id , `name`
ORDER BY SUM(quantity) DESC
LIMIT 5;

-- ANS : Classic Deluxe Pizza (2453) / The Barbecue Chicken Pizza (2432) / The Hawaiian Pizza (2422) / The Pepperoni Pizza (2418) / The Thai Chicken Pizza (2371)

-- INTERMEDIATE QUESTIONS

-- 1. Join the necessary tables to find the total quantity of each pizza category ordered

SELECT 
    Category, SUM(quantity)
FROM
    order_details AS OD
        INNER JOIN
    pizzas AS P ON OD.pizza_id = P.pizza_id
        INNER JOIN
    pizza_types AS PT ON PT.pizza_type_id = P.pizza_type_id
GROUP BY Category;

-- ANS : Classic (14888) / Veggie (11649) / Supreme (11987) / Chicken (11050)

-- 2. Determine the distribution of orders by hour of the day

SELECT COUNT(Order_id) AS Order_count,
	HOUR(order_time) AS hours -- Using 'HOUR' FUNCTIONS
FROM orders
GROUP BY HOUR(order_time);

-- 3. Join relevant tables to find the category-wise distribution of pizzas

SELECT category, SUM(OD.quantity)
FROM order_details AS OD
INNER JOIN pizzas AS P
	ON OD.pizza_id = P.pizza_id
INNER JOIN pizza_types AS PT
	ON P.pizza_type_id = PT.pizza_type_id
GROUP BY category;

-- 4. Group the orders by date and calculate the average number of pizzas ordered per day

WITH Sum_perday_CTE AS
(
SELECT SUM(quantity) AS Total_pizza_perday, order_date
FROM order_details AS OD
INNER JOIN orders AS O
	ON OD.Order_id = O.order_id
GROUP BY order_date
)
SELECT ROUND(AVG(Total_pizza_perday),2) AS Average_pizzperday
FROM Sum_perday_CTE;

-- ANS : 138.46 ROUNDED off to 2 decimal Places

-- 5. Determine the top 3 most ordered pizza types based on revenue

SELECT pizza_type_id, SUM(OD.quantity*P.price) AS Total_revenue
FROM order_details AS OD
INNER JOIN pizzas AS P
	ON OD.pizza_id = P.pizza_id
GROUP BY pizza_type_id
ORDER BY SUM(OD.quantity*P.price) DESC
LIMIT 3;

-- ANS : Thai_ckn (43434.25) / bbq_ckn (42786) / cali_ckn (41409.5)

-- Advanced Questions

-- 1. Calculate the percentage contribution of each pizza type to total revenue

WITH percentage_CTE AS
(
SELECT pizza_type_id, SUM(OD.quantity*P.price) AS Total_revenue_each_pizza_type
FROM order_details AS OD
INNER JOIN pizzas AS P
	ON OD.pizza_id = P.pizza_id
GROUP BY pizza_type_id
)
SELECT pizza_type_id, ROUND(Total_revenue_each_pizza_type/SUM(Total_revenue_each_pizza_type) OVER() * 100, 2) AS percentage_contribution
from percentage_CTE;

-- 2 : Analyze the cumulative revenue generated over time

SELECT O.order_date, ROUND(SUM(OD.quantity*P.price), 2) AS revenue_over_time,
ROUND(SUM(SUM(OD.quantity*P.price)) OVER (ORDER BY O.order_date), 2) AS cumulative_revenue_over_time
FROM order_details AS OD
INNER JOIN orders AS O
	ON OD.order_id = O.order_id
INNER JOIN pizzas AS P
	ON OD.pizza_id = P.pizza_id
GROUP BY O.order_date
ORDER BY O.order_date;

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category

WITH revenue_per_type AS (
    SELECT 
        PT.category,
        PT.name AS pizza_type,
        SUM(OD.quantity * P.price) AS revenue
    FROM order_details OD
    JOIN pizzas P 
        ON OD.pizza_id = P.pizza_id
    JOIN pizza_types PT 
        ON P.pizza_type_id = PT.pizza_type_id
    GROUP BY PT.category, PT.name
)
SELECT 
    category,
    pizza_type,
    revenue
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
    FROM revenue_per_type
) t
WHERE rnk <= 3;