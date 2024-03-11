# D. Pricing and Ratings

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner 
-- made so far if there are no delivery fees?
WITH cte AS (
SELECT *, 
CASE 
WHEN pizza_id = 1 THEN 12
ELSE 10
END AS cost
FROM cust_orders
)
SELECT SUM(cost) AS total 
FROM cte;

-- 2. . What if there was an additional $1 charge for any pizza extras?
-- Here, we are basing this off the same approach used in questions 6/7 (last section), where we use a locate the comma delimiter as 
-- part of a boolean based column. We also use a case statement that reflects the standard costs of a meat lover and vegetarian pizza 
-- from the previous question.

WITH cte AS (
SELECT *, 
IF(LOCATE(',', extras), TRUE, FALSE) AS ex_bool,
CASE 
WHEN pizza_id = 1 THEN 12
WHEN pizza_id = 2 THEN 10
END AS cost
FROM cust_orders
),
cte2 AS (
SELECT order_id, cost,
CASE 
WHEN ex_bool = 0 AND extras IS NOT NULL 
THEN extras
END AS bs_extras, 
CASE 
WHEN ex_bool = 1 
THEN SUBSTRING_INDEX(extras, ',', 1)
END AS ex_1,
CASE 
WHEN ex_bool = 1 
THEN SUBSTRING_INDEX(extras, ',', -1)
END AS ex_2
FROM cte
),
cte3 AS (
SELECT order_id,  
CASE 
WHEN COALESCE(bs_extras, ex_1, ex_2) IS NULL THEN cost
WHEN bs_extras IS NOT NULL AND COALESCE(ex_1, ex_2) IS NULL THEN  cost+1
WHEN bs_extras IS NULL AND ex_1 IS NOT NULL AND ex_2!=4 THEN cost+2
WHEN bs_extras IS NULL AND ex_1 IS NOT NULL AND ex_2=4 THEN cost+3  #specifically for cheese
END AS total_pizza_cost
FROM cte2
)
SELECT SUM(total_pizza_cost) AS totalcost
FROM cte3;

-- 3. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per
-- kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

WITH cte AS (
SELECT 
SUM(CASE
WHEN pizza_id = 1 THEN 12
WHEN pizza_id = 2 THEN 10
END) AS pizza_cost
FROM cust_orders
),
-- When a distance_km is labeled as null, it means that the delivery was cancelled, so we identify the orders that weren't 
-- cancelled and multiply it by 0.30 per the question.
cte2 AS (
SELECT distance, 
CASE 
WHEN distance IS NOT NULL THEN distance*0.30
END AS runner_cost 
FROM runner_orders2
), cte3 AS (
SELECT SUM(runner_cost) AS totalrunnercost 
FROM cte2
)
# We then subtract the pizza_costs (which represent the profits) with the previous total query to account for the runner expenses,
# to get the true profit.
SELECT pizza_cost-totalrunnercost AS profit
FROM cte, cte3;


# E. Bonus Question

/* If Danny wants to expand his range of pizzas - how would this impact the existing data design?
Because the pizza recipes table was modified to reflect foreign key designation for each topping linked to the base pizza, the pizza_id 
will have multiple 3s and align with the standard toppings (individually) within the toppings column.
In addition, because the data type was casted to an int to take advant
age of numerical functions, insertion of data would not affect the 
existing data design, unlike the original dangerous approach of comma separated values in a singular row (list). */


/* F. Insights Generated

Most of the successful orders are delivered by Runner ID 1.
The majority of the delivered pizzas had no changes.
The maximum number of pizzas delivered in a single order was 18.
The busiest hour of the day was from 7 pm to 9 pm, and the busiest day of the week was Sunday.
The average time it takes for each runner to arrive at the Pizza Runner HQ to pickup the order is 36 minutes.
The longest delivery time was 2 hours and 25 minutes, and the shortest delivery time was 4 minutes.
There was no correlation between the number of pizzas in an order and how long it takes to prepare them.
Most of the customers live within 5-6 km of the HQ.
/*
