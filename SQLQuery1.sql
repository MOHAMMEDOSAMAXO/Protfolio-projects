USE ECommerce_Data_Analysis
SELECT * FROM customer_dim

SELECT * FROM fact_table

SELECT * FROM item_dim

SELECT * FROM store_dim

SELECT * FROM time_dim

SELECT * FROM Trans_dim


/*ECommerce Data Analysis */

/*check the number of customers who purchased more than 3 itmes*/

SELECT COUNT(DISTINCT coustomer_key) AS 'Customers with more that 3 purchases'
FROM fact_table
WHERE quantity >3

----check the number of stores 

SELECT COUNT(DISTINCT store_key) as 'number of stores'
FROM store_dim;

---- now we will get how many times each item was sold and the total revenue, Display the top 10 only

SELECT TOP 10 item_name ,i.unit_price,SUM(i.unit_price) AS total_revenue, COUNT(f.item_key) AS 'total number of items getting purchased'
FROM fact_table f 
INNER JOIN  item_dim i 
ON i.item_key = f.item_key
GROUP BY item_name,i.unit_price
ORDER BY COUNT(f.item_key) DESC

---- do the same again however this time order it by the number of purchased ascendingly

SELECT TOP 10 item_name ,i.unit_price,SUM(i.unit_price) AS total_revenue, COUNT(f.item_key) AS 'total number of items getting purchased'
FROM fact_table f 
INNER JOIN  item_dim i 
ON i.item_key = f.item_key
GROUP BY item_name,i.unit_price
ORDER BY COUNT(f.item_key) 


--- show the items with the most revenue 
SELECT item_name , f.unit_price, SUM(f.unit_price) AS total_revenue
FROM fact_table f
JOIN item_dim i 
ON f.item_key = i.item_key
GROUP BY item_name,f.unit_price
ORDER BY total_revenue DESC

---- now we show the total revenue based on the type of the products

--first we rename the desc column in items table 
---EXEC sp_rename 'dbo.item_dim.desc', 'product_type', 'COLUMN';


SELECT i.product_type , SUM(f.unit_price) AS total_revenue
FROM fact_table f
JOIN item_dim i 
ON f.item_key = i.item_key
GROUP BY i.product_type
ORDER BY total_revenue DESC


SELECT distinct year
FROM time_dim 
order by year

SELECT * FROM time_dim

/*
CREATE PROCEDURE get_time
AS
BEGIN
	SELECT time_key 
	FROM time_dim
END

EXEC get_time;

ALTER PROCEDURE get_time(@year AS SMALLINT,@quarter AS money)
	AS
	BEGIN
	SELECT time_key
	FROM time_dim
	WHERE @year = year AND @quarter  = quarter
END
*/

--GET the total revenue of each year
SELECT year, SUM(unit_price) AS total_revenue
FROM fact_table f 
JOIN time_dim t 
ON f.time_key = t.time_key
GROUP BY year
ORDER BY year DESC

SELECT year,quarter, SUM(unit_price) AS total_revenue
FROM fact_table f 
JOIN time_dim t 
ON f.time_key = t.time_key
GROUP BY year,quarter
ORDER BY total_revenue DESC

--- now check how many stores are there

SELECT COUNT(DISTINCT store_key)
FROM fact_table

SELECT COUNT(store_key), COUNT(distinct division), COUNT(distinct district), count(distinct upazila)
FROM store_dim


---GET THE stores with the top 10 revenue 

SELECT TOP 10 store_key, SUM(unit_price) AS total_revenue
FROM fact_table f
GROUP BY store_key
ORDER BY total_revenue DESC;

--- NOW SHOW THE DISTRICTS

SELECT TOP 10 f.store_key,s.district ,SUM(unit_price) AS total_revenue
FROM fact_table f
JOIN store_dim s
ON s.store_key = f.store_key
GROUP BY f.store_key,s.district
ORDER BY total_revenue DESC;



---- SHOW THE top stores and there most sold prodcuts 
-- first we will creat a temp table to make the porcess less complex

CREATE TABLE #test (
	district VARCHAR(50),
	product_type VARCHAR(100),
	total money)

INSERT INTO #test
SELECT district, product_type, SUM(total_revenue) AS total
	FROM (
		SELECT   f.store_key,s.district ,i.product_type,SUM(f.unit_price)AS total_revenue
		FROM fact_table f
		JOIN store_dim s
		ON s.store_key = f.store_key
		join item_dim i
		on i.item_key = f.item_key
		GROUP BY f.store_key,s.district,i.product_type
		--ORDER BY product_type,district
		) ms
	GROUP BY district, product_type
	ORDER BY total desc ,product_type,district

--- now we show the results.
Select ls.district, product_type, max_total
FROM
	(SELECT district,Max(total) AS max_total
	FROM #test
	GROUP BY district) ls
JOIN #test t
ON 
ls.district = t.district AND t.total = ls.max_total
ORDER BY max_total DESC, ls.district, product_type




-- now show the item with the most revenue.
WITH item_revenue AS (
	SELECT f.item_key,item_name,district,SUM(total_price) AS total_revenue
	FROM  fact_table f
	JOIN item_dim i 
	ON i.item_key = f.item_key
	JOIN  store_dim s
	ON s.store_key = f.store_key
	GROUP BY district,item_name,f.item_key
	),
	
	get_district_item AS
	(select district, MAX(total_revenue) AS max_revenue
	FROM item_revenue
	GROUP BY district)

SELECT g.district , item_name, max_revenue 
FROM get_district_item g 
JOIN item_revenue i 
ON i.district = g.district AND max_revenue = total_revenue 
ORDER BY max_revenue DESC, g.district, item_name


-- now show the number of purchase of each item in each district

WITH item_count AS (
	SELECT f.item_key,item_name,district,SUM(quantity) AS number_pruchase
	FROM  fact_table f
	JOIN item_dim i 
	ON i.item_key = f.item_key
	JOIN  store_dim s
	ON s.store_key = f.store_key
	GROUP BY district,item_name,f.item_key),
	
	get_district_item AS
	(select district, MAX(number_pruchase) AS max_pruchase
	FROM item_count
	GROUP BY district)

SELECT  g.district , item_name, max_pruchase 
FROM get_district_item g 
JOIN item_count i 
ON i.district = g.district AND max_pruchase = number_pruchase
ORDER BY max_pruchase DESC, g.district, item_name


SELECT * FROM Trans_dim
SELECT * FROM fact_table 
-- show the ammout of times crads and cash has being used
SELECT trans_type,COUNT(f.payment_key) AS number_of_times,
ROUND((CAST(COUNT(f.payment_key) AS FLOAT)/(SELECT COUNT(payment_key)FROM fact_table)*100),2) AS 'percentage'
FROM fact_table f
JOIN 
Trans_dim t 
ON 
t.payment_key = f.payment_key
GROUP BY trans_type

