USE pizza_runner;
SELECT * FROM cust_orders;
SELECT * FROM runner_orders2;

-- B. Runner and Customer Experience

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT WEEK(registration_date), COUNT(*) AS total_runners 
FROM runners
GROUP BY WEEK(registration_date);

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH cte AS (
SELECT c.order_id, c.customer_id, c.order_time, r.runner_id, r.pickup_time1, TIMEDIFF(c.order_time, r.pickup_time1) AS tt
FROM cust_orders c
LEFT JOIN runner_orders2 r
ON c.order_id= r.order_id
WHERE r.cancellation1 IS NULL
)
SELECT runner_id, ROUND(AVG(MINUTE(tt)),2) AS avg_time_in_mins
FROM cte
GROUP BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH cte AS (
SELECT c.order_id, c.customer_id, c.order_time, r.runner_id, r.pickup_time1, TIMEDIFF(c.order_time, r.pickup_time1) AS tt
FROM cust_orders c
LEFT JOIN runner_orders2 r
ON c.order_id= r.order_id
WHERE r.cancellation1 IS NULL
)
SELECT order_id, COUNT(*) AS total_pizzas_ordered, ROUND(AVG(MINUTE(tt)),0) AS total_min
FROM cte
GROUP BY order_id;

-- Based on the above query, there is relationship. As the number of pizzas increases per order, the time to prepare 
-- an order increases. This is shown with order 4 with total 3 pizzas ordered ranking at the highest in time prep of 29 mins. There seems 
-- to be a slight variance with orders consisting of 2 pizzas taking anywhere from 15 - 21 mins, while an order of 1 pizza takes as 
-- only 10 minutes.

-- 4. What was the average distance travelled for each customer?
SELECT c.customer_id, ROUND(AVG(distance),2) AS avg_distance
FROM cust_orders c
LEFT JOIN runner_orders2 r
ON c.order_id = r.order_id
WHERE r.cancellation1 IS NULL
GROUP BY c.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) - MIN(duration) AS diff FROM runner_orders2;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, AVG(distance) AS avg_dist, AVG(duration) AS avg_time
FROM runner_orders2 
WHERE cancellation1 IS NULL
GROUP BY runner_id;
	
-- Yes, as the distance increases, the time it takes to deliver an order, increases as well.

-- 7. What is the successful delivery percentage for each runner?
SELECT r.runner_id, 
ROUND(SUM(CASE WHEN cancellation1 IS NULL THEN 1 ELSE 0 END)/COUNT(*) * 100,2) AS delivery_percentage
FROM cust_orders c
LEFT JOIN runner_orders2 r
ON c.order_id = r.order_id
GROUP BY r.runner_id
ORDER BY delivery_percentage DESC;