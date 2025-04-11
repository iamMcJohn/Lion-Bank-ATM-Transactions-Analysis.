
--Number of Lion bank ATMs
	SELECT COUNT(DISTINCT atm_name) AS total_atms
	FROM atm_transactions;

--Total amount withdrawn across all ATMs
	SELECT SUM(total_amount_withdrawn) AS total_withdrawn
	FROM atm_transactions;

--Average daily transaction across all ATM
	SELECT AVG(No_Of_Withdrawals) AS avg_withdrawals_per_atm
	FROM atm_transactions;

--ATM with the highest number of withdrawal
	SELECT TOP 1 atm_name, 
		   SUM(No_Of_Withdrawals) AS total_withdrawals
	FROM atm_transactions
	GROUP BY atm_name
	ORDER BY total_withdrawals DESC;

--ATM with the highest amount of withdrawal
	SELECT TOP 1 atm_name, 
		   SUM(total_amount_withdrawn) AS total_amount_withdrawn
	FROM atm_transactions
	GROUP BY atm_name
	ORDER BY total_amount_withdrawn DESC;

--Daily average transactions per ATM
	SELECT atm_name, 
		   AVG(No_Of_Withdrawals) AS avg_daily_transactions
	FROM atm_transactions
	GROUP BY atm_name;

--Busiest day of the week for ATM transaction
	SELECT TOP 1 [weekday], 
		   SUM(No_Of_Withdrawals) AS total_transactions
	FROM atm_transactions
	GROUP BY weekday
	ORDER BY total_transactions DESC;

--Highest performing month by transaction
	SELECT 
		DATENAME(MONTH, transaction_date) AS [month],
		SUM(No_Of_Withdrawals) AS total_withdrawals
	FROM atm_transactions
	GROUP BY DATENAME(MONTH, transaction_date) 
	ORDER BY total_withdrawals DESC;

--Percentage of transactions made using Lion Bank cards versus other bank cards
	SELECT 
		ROUND(SUM(no_of_lion_card_withdrawals) * 100.0 / SUM(No_Of_Withdrawals), 2) AS lion_card_percentage,
		ROUND(SUM(no_of_other_card_withdrawals) * 100.0 / SUM(No_Of_Withdrawals), 2) AS other_card_percentage
	FROM atm_transactions;

--Total amount withdrawn on weekends vs weekdays
	SELECT 
		CASE 
			WHEN weekday IN ('Saturday', 'Sunday') THEN 'Weekend'
			ELSE 'Weekday'
		END AS day_type,
		SUM(total_amount_withdrawn) AS total_amount
	FROM atm_transactions
	GROUP BY CASE 
				WHEN weekday IN ('Saturday', 'Sunday') THEN 'Weekend'
				ELSE 'Weekday'
			END;

--Transaction volume difference on working days vs non-working days
	SELECT working_day, SUM(No_Of_Withdrawals) AS total_transactions
	FROM atm_transactions
	GROUP BY working_day;
	
--Number of Lion Card withdrawals on working days
	SELECT SUM(no_of_lion_card_withdrawals) AS lion_card_workday_withdrawals
	FROM atm_transactions
	WHERE working_day = 'W';

--Total amount withdrawn per ATM over the last six months
	SELECT atm_name, 
		   SUM(total_amount_withdrawn) AS Total_Withdrawal
	FROM atm_transactions
	WHERE transaction_date >= DATEADD(MONTH, -5, (SELECT MAX(transaction_date) FROM atm_transactions))
	GROUP BY atm_name;

--Percentage of withdrawals made with Lion Cards
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

--The ratio of Lion Card withdrawals to other cards on weekends
	SELECT 
		SUM(no_of_lion_card_withdrawals) AS lion_withdrawals,
		SUM(no_of_other_card_withdrawals) AS other_withdrawals,
		(SUM(no_of_lion_card_withdrawals) * 1.0 / NULLIF(SUM(no_of_other_card_withdrawals), 0)) AS ratio
	FROM atm_transactions
	WHERE weekday IN ('Saturday', 'Sunday');

--ATM with the highest single day withdrawal amount.
	SELECT atm_name, 
		   MAX(total_amount_withdrawn) AS max_withdrawal
	FROM atm_transactions
	GROUP BY atm_name
	ORDER BY max_withdrawal DESC

--Percentage contribution to total transactions by each ATM
	SELECT atm_name,
		   ROUND(SUM(No_Of_Withdrawals) * 100.0 / 
		   (SELECT SUM(No_Of_Withdrawals) FROM atm_transactions), 2) AS contribution_pct
	FROM atm_transactions
	GROUP BY atm_name;

--Average withdrawal amount for a Lion card
	SELECT AVG(amount_withdrawn_lion_card / NULLIF(no_of_lion_card_withdrawals, 0)) AS avg_lion_withdrawal
	FROM atm_transactions;

--Change in transaction over the months
	SELECT FORMAT(transaction_date, 'yyyy-MM') AS [month], 
		   SUM(No_Of_Withdrawals) AS total_withdrawals
	FROM atm_transactions
	GROUP BY FORMAT(transaction_date, 'yyyy-MM')
	ORDER BY [month];

	--or

	WITH Monthlytransaction
		AS
			(
			 SELECT DATENAME(YEAR, transaction_date) AS [Year], 
					DATENAME(MONTH, transaction_date) AS [Month], 
					DATEPART(MONTH, transaction_date) AS Monthnum, 
					SUM(No_Of_Withdrawals) AS No_of_transactions
			 FROM atm_transactions
			 GROUP BY DATENAME(YEAR, transaction_date), 
					  DATENAME(MONTH, transaction_date), 
					  DATEPART(MONTH, transaction_date)
			)
	SELECT [Year], 
		   [Month], 
		   No_of_transactions
	FROM Monthlytransaction
	ORDER BY [Year], 
			 Monthnum;

--Percentage increase or decrease in withdrawals compared to the previous week
	WITH weekly_transactions
	AS 
	(
    SELECT 
		datename(year, transaction_date) AS [year],
        DATEPART(WEEK, transaction_date) AS week_start,
        SUM(no_of_lion_card_withdrawals + no_of_other_card_withdrawals) AS total_transactions
    FROM atm_transactions
    GROUP BY datename(year, transaction_date),
		     DATEPART(WEEK, transaction_date)
	)
	SELECT [year],
		week_start,
		total_transactions,
		LAG(total_transactions) OVER (ORDER BY [year], week_start) AS prev_week_transactions,
		ROUND(((total_transactions - LAG(total_transactions) OVER (ORDER BY [year], week_start)) * 100.0 /
			   NULLIF(LAG(total_transactions) OVER (ORDER BY [year], week_start), 0)), 2) AS percentage_change
	FROM weekly_transactions;

--Percentage transaction volume on working days vs non-working days
SELECT
  working_day,
  ROUND(
    100.0 * SUM(No_Of_Withdrawals) / 
    (SELECT SUM(No_Of_Withdrawals) FROM atm_transactions), 2
  ) AS percentage_of_total
FROM atm_transactions
GROUP BY working_day;

--Month-on-Month Growth
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

--Total amount withdrawn in the last 12 months trend
	SELECT FORMAT(transaction_date, 'yyyy-MM') AS [month], SUM(total_amount_withdrawn) AS total_withdrawn
	FROM atm_transactions
	WHERE transaction_date >= DATEADD(month, -11, (select max(transaction_date) from atm_transactions))
	GROUP BY FORMAT(transaction_date, 'yyyy-MM')
	ORDER BY [month];

--Which ATM had the most withdrawals during public holidays?
		SELECT TOP 1 atm_name, 
				     SUM(No_Of_Withdrawals) AS no_of_withdrawals
		FROM atm_transactions
		WHERE working_day = 'H'
		GROUP BY atm_name
		ORDER BY no_of_withdrawals DESC;




