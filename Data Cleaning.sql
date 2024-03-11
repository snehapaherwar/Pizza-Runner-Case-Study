
USE pizza_runner;
SELECT * FROM customer_orders;

-- Cleaning null values or irrelevant values from exclusions and extras columns

CREATE TEMPORARY TABLE cust_orders
SELECT order_id, customer_id, pizza_id,
CASE
WHEN exclusions = '' THEN NULL
WHEN exclusions = 'null' THEN NULL
ELSE exclusions 
END AS exclusions,
CASE
WHEN extras = '' THEN NULL
WHEN extras = 'null' THEN NULL
ELSE extras 
END AS extras,
order_time
FROM customer_orders;

SELECT * FROM cust_orders;

SELECT * FROM runner_orders;
-- In runner_orders table, columns like pickup_time, distance, duration doesn't have
-- correct datatype. So, need to correct it.

CREATE TEMPORARY TABLE runner_orders1
SELECT order_id, runner_id, 
CASE 
WHEN pickup_time ='null' THEN NULL
WHEN pickup_time ='' THEN NULL
ELSE pickup_time
END AS pickup_time1,
CASE 
WHEN distance = 'null' THEN NULL
ELSE regexp_replace(distance, '[a-z]+','')
END AS distance_km,
CASE 
WHEN duration ='null' THEN NULL
ELSE regexp_replace(duration, '[a-z]+','')
END AS duration_mins,
CASE 
WHEN cancellation ='null' THEN NULL
WHEN cancellation ='' THEN NULL
ELSE cancellation
END AS cancellation1
FROM runner_orders;

SELECT * FROM runner_orders1;

-- Now, we have removed extra string values and null values. We can change datatype of columns : 
--  pickup_time1, duration_km, duration_mins

CREATE TEMPORARY TABLE runner_orders2
SELECT order_id, runner_id, pickup_time1, 
        CAST(distance_km AS DECIMAL(3, 1)) AS distance,
        CAST(duration_mins AS SIGNED INT) AS dutation,
		cancellation1
FROM runner_orders1;

-- In Pizza_recipes table, we have topping grouped by pizza_id in row in CSV 

SELECT *, SUBSTR(toppings, 1,1) AS t1, SUBSTR(toppings, 4,1) AS t2, 
		SUBSTR(toppings, 7,1) AS t3, SUBSTR(toppings, 10,1) AS t4,
        SUBSTR(toppings, 13,2) AS t5, SUBSTR(toppings, 17,1) AS t6, 
        SUBSTR(toppings, 19,1) AS t7 , SUBSTR(toppings, 22,2) AS t8 
FROM pizza_recipes

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, 1),
  (1, 2),
  (1, 3),
  (1, 4),
  (1, 5),
  (1, 6),
  (1, 8),
  (1, 10),
  (2, 4),
  (2, 6),
  (2, 7),
  (2, 9),
  (2, 11),
  (2, 12);

