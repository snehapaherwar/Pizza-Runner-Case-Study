USE pizza_runner;
SELECT * FROM cust_orders;
SELECT * FROM runner_orders2;

-- A. PIZZA METRICS

-- 1. How many pizzas were ordered?
SELECT COUNT(*) AS pizza_count
FROM cust_orders;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM cust_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(*) AS successful_orders
FROM runner_orders2
WHERE cancellation1 IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT p.pizza_name, COUNT(*) AS pizzas_delivered
FROM cust_orders c
JOIN pizza_names p
ON c.pizza_id=p.pizza_id
LEFT JOIN runner_orders2 r 
ON c.order_id=r.order_id
WHERE r.cancellation1 IS NULL
GROUP BY p.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, p.pizza_name, COUNT(*) AS ordered_num
FROM cust_orders c
JOIN pizza_names p 
ON c.pizza_id=p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id, p.pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT COUNT(*) AS pizza_count 
FROM cust_orders
GROUP BY order_id
ORDER BY COUNT(*) DESC 
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH cte AS (
SELECT c.customer_id, 
CASE 
WHEN c.exclusions LIKE '%' OR c.extras LIKE '%' THEN 1
ELSE 0 
END AS pizza_change_count,
CASE 
WHEN c.exclusions IS NULL AND c.extras IS NULL THEN 1
ELSE 0 
END AS pizza_no_change_count
FROM cust_orders c 
LEFT JOIN runner_orders2 r 
ON c.order_id = r.order_id
WHERE r.duration IS NOT NULL
)
SELECT customer_id, SUM(pizza_change_count) AS total_pizzas_with_changes,
SUM(pizza_no_change_count) AS total_pizzas_with_no_changes
FROM cte 
GROUP BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
SUM(
CASE WHEN c.exclusions LIKE '%' AND c.extras LIKE '%' 
THEN 1 
ELSE 0
END ) AS pizzas_with_exc_extras
FROM cust_orders c 
LEFT JOIN runner_orders2 r
ON c.order_id = r.order_id
WHERE r.cancellation1 IS NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS hour, COUNT(*) AS total_pizzas
FROM cust_orders
GROUP BY HOUR(order_time)
ORDER BY COUNT(*) DESC, hour;

-- 10. What was the volume of orders for each day of the week?
SELECT DAYNAME(order_time) AS day, COUNT(*) AS total_pizzas_ordered
FROM cust_orders
GROUP BY DAYNAME(order_time)
ORDER BY COUNT(*) DESC, DAYNAME(order_time);

