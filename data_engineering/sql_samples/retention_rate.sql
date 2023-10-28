SELECT
    ma_home_unit,
    '1 Year' AS length_retained,
    SUM(retained) AS number_retained,
    COUNT(*) AS number_of_hires
FROM
    (
        SELECT
            DISTINCT a.key2_emplid,
            a.ma_home_unit,
            CASE
                WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 1
                OR termination_dt IS NULL THEN 1
                ELSE 0
            END AS retained
        FROM
            (
                SELECT
                    CURRENT_DATE as current_date,
                    key2_emplid,
                    ma_home_unit,
                    hire_dt,
                    MAX(termination_dt) AS termination_dt
                FROM
                    dbo.wh_job a
                WHERE
                    a.department = 'ITD'
                    AND a.xref_per_org = 'EMP'
                    AND a.jobcode != 'ECC05'
                    AND a.jobcode NOT LIKE '%CWR%'
                    AND datediff(DAY, a.hire_dt, current_date) / 365.25 < 4
                    AND datediff(DAY, a.hire_dt, current_date) / 365.25 >= 1
                GROUP BY
                    current_date,
                    key2_emplid,
                    ma_home_unit,
                    hire_dt
            ) a
    ) a
WHERE
    length_retained IS NOT NULL
GROUP BY
    ma_home_unit,
    length_retained
UNION
SELECT
    ma_home_unit,
    '2 Years' AS length_retained,
    SUM(retained) AS number_retained,
    COUNT(*) AS number_of_hires
FROM
    (
        SELECT
            DISTINCT a.key2_emplid,
            a.ma_home_unit,
            CASE
                WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 2
                OR termination_dt IS NULL THEN 1
                ELSE 0
            END AS retained
        FROM
            (
                SELECT
                    CURRENT_DATE as current_date,
                    key2_emplid,
                    ma_home_unit,
                    hire_dt,
                    MAX(termination_dt) AS termination_dt
                FROM
                    dbo.wh_job a
                WHERE
                    a.department = 'ITD'
                    AND a.xref_per_org = 'EMP'
                    AND a.jobcode != 'ECC05'
                    AND a.jobcode NOT LIKE '%CWR%'
                    AND datediff(DAY, a.hire_dt, current_date) / 365.25 < 4
                    AND datediff(DAY, a.hire_dt, current_date) / 365.25 >= 2
                GROUP BY
                    current_date,
                    key2_emplid,
                    ma_home_unit,
                    hire_dt
            ) a
    ) a
WHERE
    length_retained IS NOT NULL
GROUP BY
    ma_home_unit,
    length_retained
UNION
SELECT
    ma_home_unit,
    '3 Years' AS length_retained,
    SUM(retained) AS number_retained,
    COUNT(*) AS number_of_hires
FROM
    (
        SELECT
            DISTINCT a.key2_emplid,
            a.ma_home_unit,
            CASE
                WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 3
                OR termination_dt IS NULL THEN 1
                ELSE 0
            END AS retained
        FROM
            (
                SELECT
                    CURRENT_DATE as current_date,
                    key2_emplid,
                    ma_home_unit,
                    hire_dt,
                    MAX(termination_dt) AS termination_dt
                FROM
                    dbo.wh_job a
                WHERE
                    a.department = 'ITD'
                    AND a.xref_per_org = 'EMP'
                    AND a.jobcode != 'ECC05'
                    AND a.jobcode NOT LIKE '%CWR%'
                    AND datediff(DAY, a.hire_dt, current_date) / 365.25 < 4
                    AND datediff(DAY, a.hire_dt, current_date) / 365.25 >= 3
                GROUP BY
                    current_date,
                    key2_emplid,
                    ma_home_unit,
                    hire_dt
            ) a
    ) a
WHERE
    length_retained IS NOT NULL
GROUP BY
    ma_home_unit,
    length_retained