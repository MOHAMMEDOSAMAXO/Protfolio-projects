USE Healthcare



/* healthcare data analysis */



/* How many encounters did we have before the year 2020? */

SELECT COUNT(*)
FROM encounters
WHERE year(start) < 2020
--52385

--How many distinct patients did we treat before the year 2020?

SELECT  DISTINCT COUNT(PATIENT)
FROM encounters
WHERE YEAR(START) <2020

--52385

--How many distinct encounter classes are documented?

SELECT DISTINCT COUNT(ENCOUNTERCLASS)
FROM encounters

--53346


--How many inpatient/ ambulatory encounters did we have before the year 2020?
SELECT ENCOUNTERCLASS, COUNT(*)
FROM encounters
WHERE START <'2020-01-01'  AND ENCOUNTERCLASS IN ('ambulatory','inpatient')
GROUP BY ENCOUNTERCLASS



--How many emergency encounters did we have in 2019?
SELECT COUNT(*) AS #_emergency
FROM encounters
WHERE ENCOUNTERCLASS = 'emergency' AND YEAR (START) =2019


--What conditions were treated in those encounters?
SELECT  DESCRIPTION  ,COUNT(*) AS #_condtion
FROM conditions
WHERE ENCOUNTER IN (SELECT id 
					FROM encounters
					WHERE ENCOUNTERCLASS = 'emergency' AND YEAR(START)=2019 )
GROUP BY DESCRIPTION
ORDER BY #_condtion DESC


--What allergies were treated in those encounters?
SELECT  DESCRIPTION  ,COUNT(*) AS #_allergies
FROM allergies
WHERE ENCOUNTER IN (SELECT id 
					FROM encounters
					WHERE ENCOUNTERCLASS = 'emergency' AND YEAR(START)=2019 )
GROUP BY DESCRIPTION
ORDER BY #_allergies DESC


--What careplans were those encounters?
SELECT  DESCRIPTION  ,COUNT(*) AS #_plan
FROM careplans
WHERE ENCOUNTER IN (SELECT id 
					FROM encounters
					WHERE ENCOUNTERCLASS = 'emergency' AND YEAR(START)=2019 )
GROUP BY DESCRIPTION
ORDER BY #_plan DESC


--What immunizations were in those encounters?

SELECT  DESCRIPTION  ,COUNT(*) AS #_immunizations
FROM immunizations
WHERE ENCOUNTER IN (SELECT id 
					FROM encounters
					WHERE ENCOUNTERCLASS = 'emergency' AND YEAR(START)=2019 )
GROUP BY DESCRIPTION
ORDER BY #_immunizations DESC

select* from careplans
--What medications were dispensed in those encounters?
SELECT  DESCRIPTION  ,COUNT(*) AS #_dispenses
FROM medications
WHERE ENCOUNTER IN (SELECT id 
					FROM encounters
					WHERE ENCOUNTERCLASS = 'emergency' AND YEAR(START)=2019 )
GROUP BY DESCRIPTION
ORDER BY #_dispenses DESC

--How many emergency encounters did we have before 2020?
SELECT COUNT(*) AS #_emergency
FROM encounters
WHERE ENCOUNTERCLASS = 'emergency' AND YEAR (START) <2020

--Which condition was most documented for emergency encounters before 2020?
SELECT	TOP 1 DESCRIPTION  ,COUNT(*) AS #_condtion
FROM conditions
WHERE ENCOUNTER IN (SELECT id 
					FROM encounters
					WHERE ENCOUNTERCLASS = 'emergency' AND YEAR(START)<2020 )
GROUP BY DESCRIPTION
ORDER BY #_condtion DESC 

--How many conditions for emergency encounters before 2020 had average ER throughputs above 100 minutes?
SELECT COUNT(*)
FROM
	(SELECT T1.DESCRIPTION, AVG(T1.Throughputs_in_MIN) AS avg_Throughputs_in_MIN
	FROM(SELECT E.id, C.ENCOUNTER,C.DESCRIPTION , DATEDIFF(MINUTE,E.START,E.STOP) AS Throughputs_in_MIN
		FROM conditions C
		INNER JOIN encounters E
			ON E.Id=C.ENCOUNTER
		WHERE E.ENCOUNTERCLASS = 'emergency' AND YEAR(E.START)<2020)T1
	GROUP BY T1.DESCRIPTION
	HAVING AVG(T1.Throughputs_in_MIN) >100)T2
	 

-- What is total claim cost for each encounter in 2019?

SELECT SUM(TOTAL_CLAIM_COST) AS total_cost_2019
FROM encounters
WHERE YEAR(START) = 2019

-- What is total payer coverage for each encounter in 2019?

SELECT SUM(PAYER_COVERAGE) AS total_payer_coverage
FROM encounters
WHERE YEAR(START) =2019

-- Which encounter types had the highest cost in 2019?
SELECT ENCOUNTERCLASS, SUM(TOTAL_CLAIM_COST) AS total_cost_2019
FROM encounters
WHERE YEAR(START) =2019
GROUP BY ENCOUNTERCLASS
ORDER BY total_cost_2019 DESC

-- Which encounter types had the highest cost covered by payers in 2019?

SELECT ENCOUNTERCLASS, SUM(PAYER_COVERAGE) AS total_payer_coverage_2019
FROM encounters
WHERE YEAR(START) =2019
GROUP BY ENCOUNTERCLASS
ORDER BY total_payer_coverage_2019 DESC


