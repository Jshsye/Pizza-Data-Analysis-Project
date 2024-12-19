select * from orders

select * from orders_details

select * from pizza_types

select * from pizzas

--1] total orders
select count(order_id) from orders

-- 2] total revenue

SELECT
	ROUND(
		SUM(
			CAST(ORDERS_DETAILS.QUANTITY AS NUMERIC) * CAST(PIZZAS.PRICE AS NUMERIC)
		),
		2
	) AS TOTAL_PRICE
FROM
	ORDERS_DETAILS
	JOIN PIZZAS ON ORDERS_DETAILS.PIZZA_ID =PIZZAS.PIZZA_ID;


-- 3] IDENTIFY THE HIGHEST PRICED PIZZA

SELECT pizza_types.name ,PIZZAS.PRICE
FROM pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1


-- 4]identify most common size pizza order

select pizzas.size, count(orders_details.order_details_id)
from pizzas join orders_details
on pizzas.pizza_id = orders_details.pizza_id
group by pizzas.size

-- 5] List the top 5 most ordered pizza types 
--along with their quantities.

SELECT 
    PIZZA_TYPES.NAME,
    SUM(CAST(ORDERS_DETAILS.QUANTITY AS INTEGER)) AS total_qty
FROM 
    PIZZA_TYPES
JOIN 
    PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
JOIN 
    ORDERS_DETAILS ON ORDERS_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY 
    PIZZA_TYPES.NAME
ORDER BY 
    total_qty DESC
LIMIT 
    5;


--6] Join the necessary tables to find the total quantity 
--     of each pizza category ordered.
SELECT
	PIZZA_TYPES.CATEGORY,
	SUM(CAST(ORDERS_DETAILS.QUANTITY AS INTEGER)) AS QUANTITY
FROM
	PIZZA_TYPES
	JOIN PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
	JOIN ORDERS_DETAILS ON ORDERS_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY
	PIZZA_TYPES.CATEGORY
ORDER BY
	QUANTITY DESC


---7] Determine the distribution of orders by hour of the day.

SELECT EXTRACT(HOUR FROM time) AS hour, count(cast(order_id as int)) as ids
FROM orders
group by EXTRACT(HOUR FROM time)
order by hour


--8] Join relevant tables to find the category-wise distribution of pizzas.

SELECT
	CATEGORY,
	COUNT(NAME)
FROM
	PIZZA_TYPES
GROUP BY
	CATEGORY

--9] Group the orders by date and calculate 
--   the average number of pizzas ordered per day.

select round(avg(new_qty),1) from
(select orders.date, sum(cast(orders_details.quantity as int)) as new_qty
from orders join orders_details
on orders.order_id=orders_details.order_id
group by orders.date)


--10] Determine the top 3 most ordered pizza types based on revenue.

SELECT
	PIZZA_TYPES.NAME,
	SUM(
		CAST(ORDERS_DETAILS.QUANTITY AS INT) * (PIZZAS.PRICE)
	) AS TOTAL_REVENUE
FROM
	PIZZA_TYPES
	JOIN PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
	JOIN ORDERS_DETAILS ON ORDERS_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY
	PIZZA_TYPES.NAME
ORDER BY
	TOTAL_REVENUE DESC LIMIT
	3


--11] Calculate the percentage contribution of each pizza type to total revenue.

SELECT PIZZA_TYPES.CATEGORY,
SUM(
	CAST(ORDERS_DETAILS.QUANTITY AS INT) * (PIZZAS.PRICE)
) / (
SELECT
	ROUND(
		SUM(
			CAST(ORDERS_DETAILS.QUANTITY AS NUMERIC) * CAST(PIZZAS.PRICE AS NUMERIC)
		),
		2
	) AS TOTAL_PRICE
FROM
	ORDERS_DETAILS
	JOIN PIZZAS ON ORDERS_DETAILS.PIZZA_ID =PIZZAS.PIZZA_ID) * 100 AS TOTAL_REVENUE
FROM
	PIZZA_TYPES
	JOIN PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
	JOIN ORDERS_DETAILS ON ORDERS_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY
	PIZZA_TYPES.CATEGORY
ORDER BY
	TOTAL_REVENUE DESC


--12] Analyze the cumulative revenue generated over time.
SELECT
	SALES.DATE,
	SUM(REVENUE) OVER (
		ORDER BY
			SALES.DATE
	) AS ACCUMNT
FROM
	(
		SELECT
			ORDERS.DATE,
			SUM(
				CAST(ORDERS_DETAILS.QUANTITY AS INT) * (PIZZAS.PRICE)
			) AS REVENUE
		FROM
			PIZZAS
			JOIN ORDERS_DETAILS ON PIZZAS.PIZZA_ID = ORDERS_DETAILS.PIZZA_ID
			JOIN ORDERS ON ORDERS.ORDER_ID = ORDERS_DETAILS.ORDER_ID
		GROUP BY
			ORDERS.DATE
	) AS SALES
	
	
	
--13] Determine the top 3 most ordered pizza types based on 
--      revenue for each pizza category.
SELECT
	CATEGORY,
	NAME, TOTAL_REVENUE
FROM
	(
		SELECT
			CATEGORY,
			NAME,
			TOTAL_REVENUE,
			RANK() OVER (
				PARTITION BY
					CATEGORY
				ORDER BY
					TOTAL_REVENUE DESC
			) AS NEW1
		FROM
			(
				SELECT
					PIZZA_TYPES.CATEGORY,
					PIZZA_TYPES.NAME,
					SUM(
						CAST(ORDERS_DETAILS.QUANTITY AS INT) * (PIZZAS.PRICE)
					) AS TOTAL_REVENUE
				FROM
					PIZZA_TYPES
					JOIN PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
					JOIN ORDERS_DETAILS ON ORDERS_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
				GROUP BY
					PIZZA_TYPES.CATEGORY,
					PIZZA_TYPES.NAME
			) AS TABLE1
	)
WHERE
	NEW1 > 3


	
--14] Determine the top 3 most ordered pizza types based on 
--     revenue for each pizza category.

SELECT
	PIZZA_TYPES.NAME,
	SUM(
		CAST(ORDERS_DETAILS.QUANTITY AS INT) * (PIZZAS.PRICE)
	) AS TOT_REV
FROM
	PIZZA_TYPES
	JOIN PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
	JOIN ORDERS_DETAILS ON ORDERS_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID

GROUP BY
	PIZZA_TYPES.NAME
ORDER BY TOT_REV DESC LIMIT 3;

