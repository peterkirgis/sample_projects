SELECT
    DISTINCT a.ma_home_unit,
    a.hire_year,
    a.hire_year_order,
    CASE
        WHEN a.retained = 1 THEN 'True'
        WHEN a.retained = 0 THEN 'False'
    END AS retained,
    a.separation_year,
    coalesce(b.count, 0) AS count,
    CASE
        WHEN a.retained = 1 THEN coalesce(
            round(
                SUM(b.count) over (PARTITION BY a.ma_home_unit, a.hire_year) :: FLOAT,
                3
            ),
            0
        )
        ELSE NULL
    END AS total_hires
FROM
    (
        SELECT
            DISTINCT b.ma_home_unit,
            CASE
                WHEN a.termination_dt IS NOT NULL THEN 0
                ELSE 1
            END AS retained,
            CASE
                WHEN datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 >= 3
                AND datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 < 4 THEN 'Hired 3 - <4 Years Ago'
                WHEN datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 >= 2
                AND datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 < 3 THEN 'Hired 2 - <3 Years Ago'
                WHEN datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 >= 1
                AND datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 < 2 THEN 'Hired 1 - <2 Years Ago'
                WHEN datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 < 1 THEN 'Hired <1 Year Ago'
                ELSE NULL
            END AS hire_year,
            CASE
                WHEN datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 >= 3
                AND datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 < 4 THEN 4
                WHEN datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 >= 2
                AND datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 < 3 THEN 3
                WHEN datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 >= 1
                AND datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 < 2 THEN 2
                WHEN datediff(DAY, a.hire_dt, a.key4_pay_end_dt) / 365.25 < 1 THEN 1
                ELSE NULL
            END AS hire_year_order,
            CASE
                WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 < 1 THEN '<1 Year'
                WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 1
                AND datediff(DAY, hire_dt, termination_dt) / 365.25 < 2 THEN '1 - <2 Years'
                WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 2
                AND datediff(DAY, hire_dt, termination_dt) / 365.25 < 3 THEN '2 - <3 Years'
                WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 3
                AND datediff(DAY, hire_dt, termination_dt) / 365.25 < 4 THEN '3 - <4 Years'
                ELSE 'Retained'
            END AS separation_year,
            a.department
        FROM
            dbo.wh_empjob_pay_end_dt_snapshot a
            INNER JOIN(
                SELECT
                    DISTINCT ma_home_unit,
                    department
                FROM
                    (
                        SELECT
                            DISTINCT a.key2_emplid,
                            a.hire_dt,
                            department,
                            a.ma_home_unit,
                            CASE
                                WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 3
                                AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 4 THEN 'Hired 3 - <4 Years Ago'
                                WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 2
                                AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 3 THEN 'Hired 2 - <3 Years Ago'
                                WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 1
                                AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 2 THEN 'Hired 1 - <2 Years Ago'
                                WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 1 THEN 'Hired <1 YEAR Ago'
                                ELSE NULL
                            END AS hire_year,
                            CASE
                                WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 3
                                AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 4 THEN 4
                                WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 2
                                AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 3 THEN 3
                                WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 1
                                AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 2 THEN 2
                                WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 1 THEN 1
                                ELSE NULL
                            END AS hire_year_order,
                            CASE
                                WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 < 1 THEN '<1 Year'
                                WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 1
                                AND datediff(DAY, hire_dt, termination_dt) / 365.25 < 2 THEN '1 - <2 Years'
                                WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 2
                                AND datediff(DAY, hire_dt, termination_dt) / 365.25 < 3 THEN '2 - <3 Years'
                                WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 3
                                AND datediff(DAY, hire_dt, termination_dt) / 365.25 < 4 THEN '3 - <4 Years'
                                ELSE 'Retained'
                            END AS separation_year
                        FROM
                            (
                                SELECT
                                    CURRENT_DATE AS current_date,
                                    key2_emplid,
                                    ma_home_unit,
                                    hire_dt,
                                    department,
                                    MAX(termination_dt) AS termination_dt
                                FROM
                                    dbo.wh_job a
                                WHERE
                                    a.department = 'ITD'
                                    AND a.xref_per_org = 'EMP'
                                    AND a.jobcode != 'ECC05'
                                    AND a.jobcode NOT LIKE '%CWR%'
                                    AND datediff(DAY, a.hire_dt, current_date) / 365.25 < 4
                                GROUP BY
                                    current_date,
                                    key2_emplid,
                                    ma_home_unit,
                                    hire_dt,
                                    department
                            ) a
                    ) a
                WHERE
                    hire_year IS NOT NULL
            ) b ON a.department = b.department
        WHERE
            hire_year IS NOT NULL
    ) a
    LEFT JOIN(
        SELECT
            ma_home_unit,
            hire_year,
            hire_year_order,
            retained,
            separation_year,
            COUNT(*) as count
        FROM
            (
                SELECT
                    DISTINCT a.key2_emplid,
                    a.hire_dt,
                    a.ma_home_unit,
                    CASE
                        WHEN a.termination_dt IS NOT NULL THEN 0
                        ELSE 1
                    END AS retained,
                    CASE
                        WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 3
                        AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 4 THEN 'Hired 3 - <4 Years Ago'
                        WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 2
                        AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 3 THEN 'Hired 2 - <3 Years Ago'
                        WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 1
                        AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 2 THEN 'Hired 1 - <2 Years Ago'
                        WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 1 THEN 'Hired <1 Year Ago'
                        ELSE NULL
                    END AS hire_year,
                    CASE
                        WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 3
                        AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 4 THEN 4
                        WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 2
                        AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 3 THEN 3
                        WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 >= 1
                        AND datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 2 THEN 2
                        WHEN datediff(DAY, a.hire_dt, a.current_date) / 365.25 < 1 THEN 1
                        ELSE NULL
                    END AS hire_year_order,
                    CASE
                        WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 < 1 THEN '<1 Year'
                        WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 1
                        AND datediff(DAY, hire_dt, termination_dt) / 365.25 < 2 THEN '1 - <2 Years'
                        WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 2
                        AND datediff(DAY, hire_dt, termination_dt) / 365.25 < 3 THEN '2 - <3 Years'
                        WHEN datediff(DAY, hire_dt, termination_dt) / 365.25 >= 3
                        AND datediff(DAY, hire_dt, termination_dt) / 365.25 < 4 THEN '3 - <4 Years'
                        ELSE 'Retained'
                    END AS separation_year
                FROM
                    (
                        SELECT
                            CURRENT_DATE AS current_date,
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
                        GROUP BY
                            current_date,
                            key2_emplid,
                            ma_home_unit,
                            hire_dt
                    ) a
            ) a
        GROUP BY
            ma_home_unit,
            hire_year,
            hire_year_order,
            retained,
            separation_year
    ) b ON a.ma_home_unit = b.ma_home_unit
    AND a.retained = b.retained
    AND a.hire_year = b.hire_year
    AND a.hire_year_order = b.hire_year_order
    AND a.separation_year = b.separation_year