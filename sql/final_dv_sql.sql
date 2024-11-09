select * from transactions_info;

select * from customer_info;

WITH MonthlyTransactions AS (
    SELECT 
        ID_client,
        DATE_FORMAT(date_new, '%Y-%m') AS transaction_month
    FROM 
        transactions_info
    WHERE 
        date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY 
        ID_client, DATE_FORMAT(date_new, '%Y-%m')
)
SELECT 
    ID_client
FROM 
    MonthlyTransactions
GROUP BY 
    ID_client
HAVING 
    COUNT(DISTINCT transaction_month) = 12;  
    
    
SELECT 
    ID_client,
    AVG(Sum_payment) AS average_check
FROM 
    transactions_info
WHERE 
    date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY 
    ID_client;
    

SELECT 
    ID_client,
    COUNT(Id_check) AS total_transactions
FROM 
    transactions_info
WHERE 
    date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY 
    ID_client;

-- a)	средняя сумма чека в месяц;

SELECT 
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    AVG(Sum_payment) AS average_check_per_month
FROM 
    transactions_info
GROUP BY 
    DATE_FORMAT(date_new, '%Y-%m');

-- b)	среднее количество операций в месяц;

SELECT 
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(Id_check) AS average_transactions_per_month
FROM 
    transactions_info
GROUP BY 
    DATE_FORMAT(date_new, '%Y-%m');

-- c)	среднее количество клиентов, которые совершали операции;
SELECT 
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(DISTINCT ID_client) AS average_clients_per_month
FROM 
    transactions_info
GROUP BY 
    DATE_FORMAT(date_new, '%Y-%m');

-- d)	долю от общего количества операций за год и долю в месяц от общей суммы операций;
WITH YearlyTotals AS (
    SELECT 
        COUNT(Id_check) AS total_transactions_year,
        SUM(Sum_payment) AS total_sum_year
    FROM 
        transactions_info
    WHERE 
        date_new BETWEEN '2015-06-01' AND '2016-06-01'
)
SELECT 
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(Id_check) AS transactions_per_month,
    COUNT(Id_check) / (SELECT total_transactions_year FROM YearlyTotals) AS transaction_share,
    SUM(Sum_payment) AS sum_per_month,
    SUM(Sum_payment) / (SELECT total_sum_year FROM YearlyTotals) AS sum_share
FROM 
    transactions_info
WHERE 
    date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY 
    DATE_FORMAT(date_new, '%Y-%m');
    
    
-- e)	вывести % соотношение M/F/NA в каждом месяце с их долей затрат;
WITH MonthlyStats AS (
    SELECT 
        DATE_FORMAT(t.date_new, '%Y-%m') AS month,
        ci.Gender,
        COUNT(t.ID_client) AS transactions_count,
        SUM(t.Sum_payment) AS total_spent
    FROM 
        transactions_info t
    JOIN 
        customer_info ci ON t.ID_client = ci.Id_client
    GROUP BY 
        month, ci.Gender
)

SELECT 
    month,
    Gender,
    transactions_count,
    total_spent,
    -- Процент от общего количества операций по полу
    (transactions_count / SUM(transactions_count) OVER (PARTITION BY month)) * 100 AS gender_percentage,
    -- Процент от общей суммы затрат по полу
    (total_spent / SUM(total_spent) OVER (PARTITION BY month)) * 100 AS spending_share
FROM 
    MonthlyStats
ORDER BY 
    month, Gender;

    
    
 
 -- 3
    WITH AgeGroups AS (
    SELECT 
        CASE 
            WHEN Age IS NULL THEN 'Unknown'
            WHEN Age BETWEEN 0 AND 9 THEN '0-9'
            WHEN Age BETWEEN 10 AND 19 THEN '10-19'
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            ELSE '70+'
        END AS age_group,
        ci.Id_client,
        t.Sum_payment,
        t.date_new
    FROM 
        customer_info ci
    LEFT JOIN 
        transactions_info t ON ci.Id_client = t.ID_client
)

-- Сумма и количество операций за весь период по возрастным группам
SELECT 
    age_group,
    SUM(Sum_payment) AS total_sum,
    COUNT(*) AS total_transactions
FROM 
    AgeGroups
GROUP BY 
    age_group;

-- Поквартальный расчет средней суммы и количества операций, а также процентного распределения
-- Определение возрастных групп и подключение транзакций
WITH AgeGroups AS (
    SELECT 
        CASE 
            WHEN Age IS NULL THEN 'Unknown'
            WHEN Age BETWEEN 0 AND 9 THEN '0-9'
            WHEN Age BETWEEN 10 AND 19 THEN '10-19'
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            ELSE '70+'
        END AS age_group,
        ci.Id_client,
        t.Sum_payment,
        t.date_new
    FROM 
        customer_info ci
    LEFT JOIN 
        transactions_info t ON ci.Id_client = t.ID_client
),

-- Подсчет средней суммы и количества операций поквартально
QuarterlyStats AS (
    SELECT 
        age_group,
        CONCAT(YEAR(date_new), '-Q', QUARTER(date_new)) AS quarter,
        AVG(Sum_payment) AS average_sum_per_quarter,
        COUNT(*) AS transactions_per_quarter
    FROM 
        AgeGroups
    GROUP BY 
        age_group, quarter
)

-- Основной запрос для вывода результатов с процентными показателями
SELECT 
    age_group,
    quarter,
    average_sum_per_quarter,
    transactions_per_quarter,
    (transactions_per_quarter / SUM(transactions_per_quarter) OVER (PARTITION BY quarter)) * 100 AS percentage_share
FROM 
    QuarterlyStats
ORDER BY 
    age_group, quarter;



    
 













