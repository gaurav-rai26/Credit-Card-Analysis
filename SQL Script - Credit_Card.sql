-- Create Database

CREATE DATABASE CREDIT_CARD;

-- Use Database

USE CREDIT_CARD;

-- Imported tables using MySQL Table Import Wizard

-- View Tables

SELECT *
FROM CUSTOMERS;

ALTER TABLE CUSTOMERS 
RENAME COLUMN `ï»¿Customer_Number` TO Customer_Number; -- Changed Column Name

SELECT *
FROM CREDIT_CARD_TXN;

ALTER TABLE CREDIT_CARD_TXN 
RENAME COLUMN `ï»¿Customer_Number` TO Customer_Number;  -- Changed Column Name

-- Customers who activated their card within 30 days.

SELECT 	COUNT(*) AS Activated_In_30_Days
FROM 	CUSTOMERS C JOIN CREDIT_CARD_TXN TXN
ON 		C.Customer_Number = TXN.Customer_Number
WHERE 	ACTIVATION_30_DAYS = 1;

-- Average customer satisfaction score grouped by Customer_Job.

SELECT 		Customer_Job, AVG(Cust_Satisfaction_Score) as Avg_CSAT
FROM 		CUSTOMERS
GROUP BY 	Customer_Job
ORDER BY 	Avg_CSAT DESC;

-- Revenue by Card Category

SELECT 	  Card_Category, 
		  ROUND(SUM(annual_Fees+Total_Trans_Amt+Interest_Earned),1) as Revenue
FROM 	  CREDIT_CARD_TXN
GROUP BY  Card_Category
ORDER BY  Revenue DESC;

 -- Delinquent accounts existing in each card category.

WITH MyCTE1 as 
(		SELECT 		Card_Category, 
					COUNT(*) as Delinquent_Count
		FROM 		CREDIT_CARD_TXN
		WHERE 		Delinquent_Acc = 1
		GROUP BY 	Card_Category
),
MyCTE2 as 
(		SELECT 		Card_Category, 
					COUNT(*) as Card_Count
		FROM 		CREDIT_CARD_TXN
		GROUP BY 	Card_Category
)
SELECT 	MyCTE1.Card_Category, 
		MyCTE1.Delinquent_Count, 
        CONCAT(ROUND(((MyCTE1.Delinquent_Count/MyCTE2.Card_Count)*100),1),"%") as Percentage
FROM 	MyCTE1 JOIN MyCTE2
ON 		MyCTE1.Card_Category = MyCTE2.Card_Category;

--  interest earned by quarter and gender.

SELECT 		TXN.Qtr, 
			C.Gender, 
			ROUND(SUM(Interest_Earned),1) as Interest_Earned
FROM 		CUSTOMERS C JOIN CREDIT_CARD_TXN TXN
ON 			C.Customer_Number = TXN.Customer_Number
GROUP BY 	TXN.Qtr, C.Gender;


-- Average Credit Limit by Card Category

SELECT 		Card_Category, 
			AVG(credit_limit) as Avg_Credit_Limit
FROM 		CREDIT_CARD_TXN 
GROUP BY 	Card_Category;

-- Average Credit Limit by Customer Job

SELECT 		Customer_Job, 
			AVG(credit_limit) as Avg_Credit_Limit
FROM 		CUSTOMERS C JOIN CREDIT_CARD_TXN TXN
ON 			C.Customer_Number = TXN.Customer_Number
GROUP BY 	customer_job
ORDER BY 	Avg_Credit_Limit DESC;

-- Top 5 Spending Customers

WITH MyCTE AS
(		SELECT 		C.Customer_Number, 
					SUM(TXN.Total_Trans_Amt) as Total_Transaction, 
					DENSE_RANK() OVER(ORDER BY SUM(TXN.Total_Trans_Amt) DESC) as Ranking
		FROM 		CUSTOMERS C JOIN CREDIT_CARD_TXN TXN
		ON 			C.Customer_Number = TXN.Customer_Number
		GROUP BY 	C.Customer_Number
)
SELECT 	*
FROM 	MyCTE
WHERE 	Ranking <= 5;

