USE pizza_runner;
SELECT * FROM cust_orders;
SELECT * FROM runner_orders2;

-- C. Ingredient Optimisation

-- 1. What are the standard ingredients for each pizza?
SELECT pr.pizza_id, pt.topping_name
FROM pizza_recipes pr
LEFT JOIN pizza_toppings pt
ON pr.toppings = pt.topping_id;

-- 2. What was the most commonly added extra?
SELECT extras, COUNT(*) AS ordered_num
FROM cust_orders
WHERE extras IS NOT NULL
GROUP BY extras
ORDER BY ordered_num DESC;

-- 3. What was the most common exclusion?
SELECT exclusions, COUNT(*) AS ordered_num
FROM cust_orders
WHERE exclusions IS NOT NULL
GROUP BY exclusions
ORDER BY ordered_num DESC;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following: Meat Lovers Meat 
-- Lovers - Exclude Beef Meat Lovers - Extra Bacon Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

-- Meat Lovers
SELECT order_id
FROM cust_orders
WHERE pizza_id = 1
GROUP BY order_id;

-- Exclude Beef Meat Lovers
SELECT order_id
FROM cust_orders
WHERE pizza_id = 1 
AND exclusions = 3 
OR exclusions LIKE '%3%'
GROUP BY order_id;

-- Extra Bacon Meat Lovers 
SELECT order_id
FROM cust_orders
WHERE pizza_id = 1
AND extras = 1 
OR extras LIKE '%1%'
GROUP BY order_id;

-- Exclude Cheese, Bacon   Extra Mushroom, Peppers
WITH cte AS (
SELECT order_id, 
CASE 
WHEN exclusions IN (1, 4) OR exclusions LIKE '%1%' OR exclusions LIKE '%4%' THEN 1 
WHEN extras IN (6,9) OR exclusions LIKE '%6%' OR exclusions LIKE '%9%' THEN 1 
ELSE 0 
END AS 'countexcext'
FROM cust_orders
WHERE pizza_id = 1
)
SELECT order_id FROM cte 
WHERE countexcext = 1 
GROUP BY order_id;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table 
-- and add a 2x in front of any relevant ingredients. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH cte AS (
	SELECT
	order_id,
	pizza_id,
	exclusions,
	extras,
	IF(LOCATE(',', exclusions), TRUE, FALSE) AS exclusions_bool,
	IF(LOCATE(',', extras), TRUE, FALSE) AS extras_bool 
	FROM cust_orders
), cte2 AS (
	SELECT
		c.order_id,
		c.pizza_id,
		pn.pizza_name,
		IF(LOCATE(0, extras_bool), extras, NULL) AS base_extras,
		IF(LOCATE(0, exclusions_bool), exclusions, NULL) AS base_exclusions,
		IF(LOCATE(1, exclusions_bool), SUBSTRING_INDEX(exclusions, ',', 1), NULL) AS exclusions_1,
		IF(LOCATE(1, exclusions_bool), SUBSTRING_INDEX(exclusions, ',', -1), NULL) AS exclusions_2,
		IF(LOCATE(1, extras_bool), SUBSTRING_INDEX(extras, ',', 1), NULL) AS extras_1,
		IF(LOCATE(1, extras_bool), SUBSTRING_INDEX(extras, ',', -1), NULL) AS extras_2
	FROM cte c 
	INNER JOIN pizza_names pn 
		ON c.pizza_id = pn.pizza_id
), cte3 AS (
	SELECT
    order_id, 
    pizza_id, 
    pizza_name, 
    base_exclusions, 
    base_extras, 
    exclusions_1, 
    exclusions_2, 
    extras_1, 
    extras_2, 
    topping_name AS exclusions_1_txt
	FROM cte2
	LEFT JOIN pizza_toppings pt 
    ON pt.topping_id = exclusions_1
), cte4 AS (
	SELECT 
    order_id, 
    pizza_id, 
    pizza_name, 
    base_exclusions, 
    base_extras, 
    exclusions_1, 
    exclusions_2, 
    extras_1, 
    extras_2, 
    exclusions_1_txt, 
    topping_name AS exclusions_2_txt
	FROM cte3
	LEFT JOIN pizza_toppings pt 
    ON pt.topping_id = exclusions_2
), cte5 AS (
SELECT 
    order_id, 
    pizza_id, 
    pizza_name, 
    base_exclusions, 
    base_extras, 
    exclusions_1, 
    exclusions_2, 
    extras_1, 
    extras_2, 
    exclusions_1_txt, 
    exclusions_2_txt, 
    topping_name AS extras_1_txt
FROM cte4
LEFT JOIN pizza_toppings pt 
    ON pt.topping_id = extras_1
), cte6 AS (
SELECT 
    order_id, 
    pizza_id, 
    pizza_name, 
    base_exclusions,
    base_extras,
    exclusions_1,
    exclusions_2,
    extras_1,
    extras_2,
    exclusions_1_txt,
    exclusions_2_txt, 
    extras_1_txt, 
    topping_name AS extras_2_txt
FROM cte5
LEFT JOIN pizza_toppings pt 
    ON pt.topping_id = extras_2
), cte7 AS (
SELECT 
    order_id, 
    pizza_id, 
    pizza_name, 
    base_exclusions, 
    base_extras, 
    exclusions_1, 
    exclusions_2, 
    extras_1, 
    extras_2, 
    exclusions_1_txt, 
    exclusions_2_txt, 
    extras_1_txt, 
    extras_2_txt, 
    topping_name AS base_exclusions_1
FROM cte6
LEFT JOIN pizza_toppings pt 
    ON pt.topping_id = base_exclusions
), cte8 AS 
(
SELECT 
    order_id, 
    pizza_id, 
    pizza_name, 
    base_exclusions, 
    base_extras, 
    exclusions_1, 
    exclusions_2, 
    extras_1, 
    extras_2, 
    exclusions_1_txt, 
    exclusions_2_txt, 
    extras_1_txt, 
    extras_2_txt, 
    base_exclusions_1, 
    topping_name AS base_extras_1
FROM cte7
LEFT JOIN pizza_toppings pt 
    ON pt.topping_id = base_extras
), cte9 AS (
SELECT 
	order_id, 
    pizza_id,
	pizza_name,
    base_exclusions,
    base_extras,
    base_extras_1,
    exclusions_1,
    exclusions_2,
    extras_1,
    extras_2,
CASE
    WHEN base_exclusions_1 IS NULL AND COALESCE(exclusions_1_txt, exclusions_2_txt) IS NOT NULL THEN CONCAT(exclusions_1_txt, ', ', exclusions_2_txt)
    WHEN base_exclusions_1 IS NOT NULL THEN CONCAT(base_exclusions_1)
    WHEN COALESCE(base_exclusions_1, exclusions_1_txt, exclusions_2_txt) IS NOT NULL THEN CONCAT(base_exclusions_1, ', ', exclusions_1_txt, ', ', exclusions_2_txt)
END AS exclusions_list,
CASE
    WHEN base_extras_1 IS NULL AND COALESCE(extras_1_txt, extras_2_txt) IS NOT NULL and pizza_id = 1 AND extras_1 in (1,2,3,4,5,6,8,10) AND extras_2 IN (1,2,3,4,5,6,8,10) THEN CONCAT('2x ', extras_1_txt, ', ', '2x ',extras_2_txt)
    WHEN base_extras_1 IS NOT NULL AND pizza_id = 1 AND base_extras IN (1,2,3,4,5,6,7,10) THEN CONCAT('2x ', base_extras_1)
    WHEN base_extras_1 IS NOT NULL THEN base_extras_1
END AS extras_list
FROM cte8
)
SELECT
	order_id,
	CASE
	WHEN exclusions_list IS NOT NULL AND extras_list IS NULL THEN CONCAT(pizza_name, ' - ', ' |Exclude| ', exclusions_list)
	WHEN extras_list IS NOT NULL AND exclusions_list IS NULL THEN CONCAT(pizza_name, ' - ', ' |Extras| ' , extras_list)
		WHEN COALESCE(exclusions_list, extras_list) IS NULL THEN pizza_name
	WHEN COALESCE(exclusions_list, extras_list) IS NOT NULL THEN CONCAT(pizza_name, ' - ', ' |Exclude| ', exclusions_list, ' |Extras| ', extras_list)
	END AS pizza_type
FROM cte9;


