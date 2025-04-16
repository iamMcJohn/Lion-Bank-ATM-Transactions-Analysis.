# 🏧 Lion Bank ATM Transaction Analysis.

## 📌 Introduction

Automated Teller Machines (ATMs) play a crucial role in providing banking services to customers, ensuring easy and quick access to cash. Analyzing ATM transaction data can reveal important insights about customer behavior, peak transaction periods, and trends that can guide operational and strategic decision-making. This exploratory data analysis (EDA) investigates ATM transaction data from Lion Bank from January, 2011 till September, 2017, uncovering key patterns and performance metrics.


## 🎯 Objectives

The primary goal of this analysis is to extract meaningful insights from the ATM transaction dataset, helping Lion Bank optimize ATM operations and customer experience. Key areas of focus include:

- Identifying transaction volume and withdrawal trends.

- Understanding customer usage patterns based on card type and time of the transaction.

- Assessing ATM performance in different locations.

- Comparing withdrawal behaviors on working vs. non-working days.


## 📊 Data Overview
The dataset contains the following columns:
- atm_name – Unique identifier for each ATM.
- transaction_date – Date of the transaction.
- No_Of_Withdrawals – Total number of withdrawals on a given day.
- no_of_lion_card_withdrawals – Withdrawals made using Lion Bank cards.
- no_of_other_card_withdrawals – Withdrawals made using other banks' cards.
- total_amount_withdrawn – Total amount withdrawn in monetary value.
- amount_withdrawn_lion_card – Amount withdrawn using Lion Bank cards.
- amount_withdrawn_other_card – Amount withdrawn using other banks' cards.
- weekday – Day of the week.
- working_day – Indicates if the transaction day was a working day (W/H).

You can download the data [here](https://www.kaggle.com/datasets/saadfareed/data-set-of-atm-transaction-of-xyz-bank)
 

## 🛠️ Tools
- Microsoft Excel - This was essentially used for cleaning the data. 

- SQL Server - This was the major analysis tool. After cleaning the data in Excel, I imported the data into SQL Server, ensure the data types were coherent with the columns and then queried the data for key insights.
- Power BI - This was used  to visualize the trend of transaction amount in the last 12 months of the dataset and the percentage distribution of Lion bank cardholders across all ATMs.

## 💡 Key Insights and Findings
- Overall Transaction Trends:

  The total amount withdrawn across all ATMs during the period was $6,053,002,800.00, reflecting strong customer reliance on cash services.
```sql
--Total amount withdrawn across all ATMs.
    SELECT SUM(total_amount_withdrawn)  AS Total_Withdrawal
    FROM atm_transactions;
```
I noticed an increase in the number of transactions in the last one year of the data collected, signifying an increasing demand for cash by customers.

```sql
--Trend of amount withdrawn across all ATMs in the last one year of the dataset.
	SELECT FORMAT(transaction_date, 'yyyy-MM') AS [month], SUM(total_amount_withdrawn) AS total_withdrawn
	FROM atm_transactions
	WHERE transaction_date >= DATEADD(month, -11, (select max(transaction_date) from atm_transactions))
	GROUP BY FORMAT(transaction_date, 'yyyy-MM')
	ORDER BY [month];
```

![Power BI Desktop 4_11_2025 10_50_11 AM](https://github.com/user-attachments/assets/c8c5e839-ea8e-45b8-bdda-dc753ed8b3d9)



- ATM Performance Highlights:

The ATM at KK Nagar had the highest total withdrawal amount at $1,854,299,300.00, while Big Street ATM had the lowest average withdrawal amount, suggesting differences in customer profiles or withdrawal limits.
```sql
--ATM with the highest total withdrawal amount.
SELECT TOP 1 atm_name, 
       SUM(total_amount_withdrawn)  AS Total_Withdrawal
FROM atm_transactions
GROUP BY atm_name
ORDER BY Total_Withdrawal DESC;

--ATM the lowest average withdrawal amount.
	SELECT  TOP 1 atm_name, 
		   AVG([total_amount_withdrawn]) AS daily_avg_withdrawal
	FROM atm_transactions
	GROUP BY atm_name
	ORDER BY daily_avg_withdrawal ASC;

--Percentage contribution to total transactions by each ATM.
	SELECT atm_name,
		   ROUND(SUM(No_Of_Withdrawals) * 100.0 / 
		   (SELECT SUM(No_Of_Withdrawals) FROM atm_transactions), 2) AS contribution_pct
	FROM atm_transactions
	GROUP BY atm_name;
```

![Power BI Desktop 4_11_2025 11_03_10 AM](https://github.com/user-attachments/assets/b379963c-fc2a-49aa-bc8a-90f666f96897)


- Customers Behavior Pattern:
  
There are more transactinons on Sunday across all ATMs, with Saturday topping the average withdrawal amount list with $590,060. 
```sql
--Busiest day of the week for ATM transactions.
	SELECT TOP 1 [weekday], 
		   SUM(No_Of_Withdrawals) AS total_transactions
	FROM atm_transactions
	GROUP BY weekday
	ORDER BY total_transactions DESC;

--Day of the week with the highest average withdrawal amount.
		SELECT TOP 1 [weekday], 
					 AVG([total_amount_withdrawn]) AS Average_Amount
		FROM atm_transactions
		GROUP BY [weekday]
		ORDER BY Average_Amount DESC;
```
- Card Usage Insights

Lion Bank cardholders contribute 55% of total withdrawals, with an average transaction amount of $4,899, compared to $3,302 for other banks. This suggests opportunities to tailor services for our cardholders.
Also, there are more Lion bank cardholders that use the Airport ATM, accounting for 74% of transactions at the ATM compared to the Big Street ATM with 33% of transaction by Lion bank cardholders

```sql
--Percentage of withdrawals made with Lion Cards.
	SELECT 
		(SUM(no_of_lion_card_withdrawals) * 100.0 /
		SUM(No_Of_Withdrawals)) AS lion_card_percentage
	FROM atm_transactions;

--Proportion of Lion card users by ATM.
	SELECT 
		atm_name,
		ROUND(SUM(no_of_lion_card_withdrawals) * 100.0 / SUM(No_Of_Withdrawals), 2) AS lion_card_percentage
	FROM atm_transactions
	GROUP BY atm_name
	ORDER BY lion_card_percentage DESC

--Average withdrawal amount between Lion Cards and other cards.
	SELECT 
		AVG(amount_withdrawn_lion_card / NULLIF(no_of_lion_card_withdrawals, 0)) AS avg_lion_card_withdrawal,
		AVG(amount_withdrawn_other_card / NULLIF(no_of_other_card_withdrawals, 0)) AS avg_other_card_withdrawal
	FROM atm_transactions;
````

- Transaction Volume Trends:
  
Working days see 5% more transactions than non-working days with KK Nagar ATM as the favourite during holiAays, probably due to its proximity to leisure aeas.
```sql
--Percentage transaction volume on working days vs non-working days.
SELECT
  working_day,
  ROUND(
    100.0 * SUM(No_Of_Withdrawals) / 
    (SELECT SUM(No_Of_Withdrawals) FROM atm_transactions), 2
  ) AS percentage_of_total
FROM atm_transactions
GROUP BY working_day;

--ATM with the most withdrawals during public holidays.
		SELECT TOP 1 atm_name, 
				     SUM(No_Of_Withdrawals) AS no_of_withdrawals
		FROM atm_transactions
		WHERE working_day = 'H'
		GROUP BY atm_name
		ORDER BY no_of_withdrawals DESC;

--Month-on-Month Growth Over The Period.
	WITH MonthlyTotals AS (
    SELECT 
        FORMAT(transaction_date, 'yyyy-MM') AS month,
        SUM(No_Of_Withdrawals) AS total_withdrawals
    FROM atm_transactions
    GROUP BY FORMAT(transaction_date, 'yyyy-MM')
),
MonthlyChange AS (
    SELECT 
        month,
        total_withdrawals,
        LAG(total_withdrawals) OVER (ORDER BY month) AS prev_total
    FROM MonthlyTotals
)
SELECT 
    month,
    total_withdrawals,
    prev_total,
    (total_withdrawals - prev_total) * 100.0 / NULLIF(prev_total, 0) AS pct_change
FROM MonthlyChange;
```
The month-on-month change in withdrawals fluctuated, with the largest consecutive drop happened in October & December of 2016, seeing and 74% and 94% drop respectively due to probably faulty machines and or inconsistent supply of cash within those peeriod.



## Conclusion

The analysis of Lion’s Bank ATM transaction data provides valuable insights into customer behavior, ATM performance, and cash demand patterns. By leveraging these insights, the bank can enhance ATM cash management, improve customer experience, and optimize network efficiency. Future analysis could focus on predictive modeling to anticipate cash shortages, fraud detection, and ATM downtime minimization.



## Recommendations

- Optimize cash replenishment schedules on Saturdays and Sundays at KK Nagar ATM as it is a high traffic location.

- Enhance customer engagement strategies by offering tailored services for lion card users.


