create database CaseStudy1

select * from Customer;

select * from prod_cat_info;

select * from transactions;

/* 1. What is the total number of rows in each of the 3 tables in the database? */

SELECT COUNT(*) AS TotalRows
FROM Customer;

SELECT COUNT(*) AS TotalRows
FROM prod_cat_info;


SELECT COUNT(*) AS TotalRows
FROM Transactions;

/*2. What is the total number of transactions that have a return?*/

select * from transactions
where total_amt < 1;

---OR---

SELECT COUNT(*) AS TotalReturns
FROM transactions
WHERE total_amt < 1;


/* 3. As you would have noticed, the dates provided across the datasets are not in a correct format.
   As first steps, pls convert the date variables into valid date formats before proceeding ahead. */

UPDATE Transactions 
SET tran_date = CAST(tran_date as DATE);

/*4. What is the time range of the transaction data available for analysis? Show the output in number of days, 
     months and years simultaneously in different columns.*/



SELECT 
    DATEDIFF(DAY, MIN(tran_date), MAX(tran_date)) DaysRange,
    DATEDIFF(MONTH, MIN(tran_date), MAX(tran_date)) MonthsRange,
    DATEDIFF(YEAR, MIN(tran_date), MAX(tran_date)) YearsRange
FROM transactions;

/* 5. Which product category does the sub-category "DIY" belong to? */




Select *
FROM transactions as T
JOIN customer C ON C.Customer_id = T.Cust_id
JOIN prod_cat_info as pci ON t.Prod_cat_code = pci.Prod_cat_code


/*** DATA ANALYSIS ***/

SELECT store_type
FROM transactions
WHERE store_type = ('Teleshop') or store_type = ('e-shop');

SELECT store_type
FROM transactions
WHERE store_type = ('flagship store') or store_type = ('MBR');


select *from Customer
where gender like 'M'

select *from Customer
where gender like 'F'


--- OR ----

SELECT COUNT(*) AS TotalMALE
FROM Customer
WHERE Gender LIKE 'M';

SELECT COUNT(*) AS TotalFeMALE
FROM Customer
WHERE Gender LIKE 'F';


/* 1. Which channel is most frequently used for transactions? */

SELECT Store_type , count(Total_amt) AS transaction_count
FROM Transactions
GROUP BY Store_type
ORDER BY transaction_count DESC



/* 2. What is the count of Male and Female customers in the database? */

select count(*) As TotalMale
from Customer
where Gender = 'M'

select count(*) As TotalFemale
from Customer
where Gender = 'F'


--- OR ---

SELECT gender, COUNT(*) AS Total_Gender_Count
FROM Customer
GROUP BY gender
order by Total_Gender_Count desc;

/* 3. From which city do we have the maximum number of customers and how many? */

SELECT city_code, COUNT(*) AS customer_count
FROM Customer
GROUP BY city_code
ORDER BY customer_count DESC


/* 4. How many sub-categories are there under the Books category? */

SELECT COUNT(prod_cat) AS sub_category_count
FROM prod_cat_info
WHERE prod_cat = 'Books';


---OR----

select prod_subcat
from prod_cat_info
where prod_cat like 'Books'
group by prod_subcat

--- OR ---
select * From prod_cat_info
where prod_cat like  'books'


/* 5. What is the maximum quantity of products ever ordered? */

SELECT MAX(qty) AS MaxQuantity
FROM transactions;

/* 6. What is the net total revenue generated in categories Electronics and Books? */

SELECT prod_cat, SUM(total_amt) AS TotalRevenue
FROM transactions
JOIN prod_cat_info ON transactions.Prod_cat_code = prod_cat_info.Prod_cat_code
WHERE prod_cat in ('Electronics', 'Books')
GROUP BY prod_cat;

/* 7. How many customers have >10 transactions with us, excluding returns? */

SELECT COUNT(*) AS CustomerCount
FROM (
  SELECT Cust_id
  FROM transactions
  where total_amt > 0
  GROUP BY Cust_id
  having count(cust_id) > 10
) AS SubQuery;

/* 8. What is the combined revenue earned from the "Electronics" & "Clothing" categories, from "Flagship stores"? */

SELECT SUM(total_amt) AS CombinedAmnt
FROM transactions
JOIN prod_cat_info ON transactions.Prod_cat_code = prod_cat_info.Prod_cat_code
WHERE prod_cat IN ('Electronics', 'Clothing')
  AND Store_type = 'Flagship store';


/* 9. What is the total revenue generated from "Male" customers in "Electronics" category? Output should display total revenue by prod sub-cat. */

SELECT pci.prod_subcat, SUM(t.total_amt) AS TotalRevenueGenerated
FROM transactions AS t
JOIN prod_cat_info AS pci ON t.Prod_cat_code = pci.Prod_cat_code
JOIN customer AS c ON t.Cust_id = c.Customer_id
WHERE c.Gender = 'M' AND pci.prod_cat = 'Electronics'
GROUP BY pci.prod_subcat;

/* 10. What is the percentage of sales and returns by product sub-category? Display only the top 5 sub-categories in terms of sales. */

SELECT pci.prod_subcat,
       SUM(CASE WHEN t.rate = 0 THEN t.total_amt ELSE 0 END) AS sales_revenue,
       SUM(CASE WHEN t.rate = 1 THEN t.total_amt ELSE 0 END) AS return_revenue,
       (SUM(CASE WHEN t.rate = 0 THEN t.total_amt ELSE 0 END) / SUM(t.total_amt)) * 100 AS sales_percentage
FROM Transactions t
JOIN prod_cat_info pci ON t.prod_subcat_code = pci.prod_cat_code
GROUP BY pci.prod_subcat
ORDER BY sales_revenue DESC

SELECT TOP 5 
PROD_SUBCAT, (SUM(TOTAL_AMT)/(SELECT SUM(TOTAL_AMT) FROM Transactions))*100 AS PERCANTAGE_OF_SALES, 
(COUNT(CASE WHEN QTY< 0 THEN QTY ELSE NULL END)/SUM(QTY))*100 AS PERCENTAGE_OF_RETURN
FROM Transactions t
INNER JOIN prod_cat_info ON t.PROD_CAT_CODE = prod_cat_info.PROD_CAT_CODE AND PROD_SUBCAT_CODE= prod_sub_cat_code
GROUP BY PROD_SUBCAT
ORDER BY SUM(TOTAL_AMT) DESC;

/*11. For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of 
      transactions from max transaction date available in the data? */

	  SELECT CUST_ID,SUM(TOTAL_AMT) AS REVENUE FROM Transactions
WHERE CUST_ID IN 
	(SELECT CUSTOMER_ID
	 FROM CUSTOMER
     WHERE DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35)
     AND CONVERT(DATE,tran_date,103) BETWEEN DATEADD(DAY,-30,(SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)) 
	 AND (SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)
GROUP BY CUST_ID

/* 12. Which product category has seen the max value of returns in the last 3 
	months of transactions? */

	SELECT TOP 1 prod_cat, SUM(TOTAL_AMT) FROM Transactions T1
INNER JOIN prod_cat_info T2 ON T1.PROD_CAT_CODE = T2.prod_cat_code AND T1.PROD_SUBCAT_CODE = T2.prod_sub_cat_code

WHERE TOTAL_AMT < 0 AND 
CONVERT(date, tran_date, 103) BETWEEN DATEADD(MONTH,-3,(SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)) 
	 AND (SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)
GROUP BY PROD_CAT
ORDER BY 2 DESC;


/* 13. which store-type sells the maximum products; by value of sales amount and
	by quantity sold? */

	SELECT  STORE_TYPE, SUM(TOTAL_AMT) TOTAL_SALES, SUM(QTY) TOTAL_QUANTITY
FROM Transactions
GROUP BY STORE_TYPE
HAVING SUM(TOTAL_AMT) >=ALL (SELECT SUM(TOTAL_AMT) FROM Transactions GROUP BY STORE_TYPE)
AND SUM(QTY) >=ALL (SELECT SUM(QTY) FROM Transactions GROUP BY STORE_TYPE);

/* 14. What are the categories for which average revenue is above the overall average. */

SELECT PROD_CAT, AVG(TOTAL_AMT) AS AVERAGE
FROM TRANSACTIONS t
INNER JOIN prod_cat_info  ON t.prod_cat_code = prod_cat_info.prod_cat_code AND prod_sub_cat_code=PROD_SUBCAT_CODE
GROUP BY PROD_CAT
HAVING AVG(TOTAL_AMT)> (SELECT AVG(TOTAL_AMT) FROM Transactions);

/* 15. Find the average and total revenue by each subcategory for the categories 
	which are among top 5 categories in terms of quantity sold. */

	SELECT PROD_CAT, PROD_SUBCAT, AVG(TOTAL_AMT) AS AVERAGE_REV, SUM(TOTAL_AMT) AS REVENUE
FROM Transactions t
INNER JOIN prod_cat_info ON t.prod_cat_code=prod_cat_info.PROD_CAT_CODE AND prod_sub_cat_code=PROD_SUBCAT_CODE
WHERE PROD_CAT IN
(
SELECT TOP 5 
PROD_CAT
FROM Transactions 
INNER JOIN prod_cat_info ON t.prod_cat_code=prod_cat_info.PROD_CAT_CODE AND prod_sub_cat_code=PROD_SUBCAT_CODE
GROUP BY PROD_CAT
ORDER BY SUM(QTY) DESC
)
GROUP BY PROD_CAT, PROD_SUBCAT 

----------------------------------**************---------------------


