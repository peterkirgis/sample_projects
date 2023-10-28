SELECT
    fiscal_year,
    fiscal_quarter,
    CASE
        WHEN fiscal_year = MAX(fiscal_year) over () THEN 1
        ELSE 0
    END AS current_fy,
    ma_home_unit,
    separations,
    headcount
FROM
(
        SELECT
            a.fiscal_year,
            a.fiscal_quarter,
            a.ma_home_unit,
            dense_rank() over (
                ORDER BY
                    a.fiscal_year DESC,
                    a.fiscal_quarter DESC
            ) AS quarter_rank,
            coalesce(separations :: FLOAT, 0) AS separations,
            headcount :: FLOAT AS headcount
        FROM
(
                SELECT
                    CASE
                        WHEN date_part('month', a.key4_pay_end_dt) >= 7
                        AND date_part('month', a.key4_pay_end_dt) < 10 THEN 'Q1'
                        WHEN date_part('month', a.key4_pay_end_dt) >= 10
                        AND date_part('month', a.key4_pay_end_dt) <= 12 THEN 'Q2'
                        WHEN date_part('month', a.key4_pay_end_dt) >= 1
                        AND date_part('month', a.key4_pay_end_dt) < 4 THEN 'Q3'
                        WHEN date_part('month', a.key4_pay_end_dt) >= 4
                        AND date_part('month', a.key4_pay_end_dt) < 7 THEN 'Q4'
                        ELSE NULL
                    END AS fiscal_quarter,
                    CASE
                        WHEN (
                            date_part('month', a.key4_pay_end_dt) >= 7
                            AND date_part('year', a.key4_pay_end_dt) = 2019
                        )
                        OR (
                            date_part('month', a.key4_pay_end_dt) < 7
                            AND date_part('year', a.key4_pay_end_dt) = 2020
                        ) THEN 'FY20'
                        WHEN (
                            date_part('month', a.key4_pay_end_dt) >= 7
                            AND date_part('year', a.key4_pay_end_dt) = 2020
                        )
                        OR (
                            date_part('month', a.key4_pay_end_dt) < 7
                            AND date_part('year', a.key4_pay_end_dt) = 2021
                        ) THEN 'FY21'
                        WHEN (
                            date_part('month', a.key4_pay_end_dt) >= 7
                            AND date_part('year', a.key4_pay_end_dt) = 2021
                        )
                        OR (
                            date_part('month', a.key4_pay_end_dt) < 7
                            AND date_part('year', a.key4_pay_end_dt) = 2022
                        ) THEN 'FY22'
                        WHEN (
                            date_part('month', a.key4_pay_end_dt) >= 7
                            AND date_part('year', a.key4_pay_end_dt) = 2022
                        )
                        OR (
                            date_part('month', a.key4_pay_end_dt) < 7
                            AND date_part('year', a.key4_pay_end_dt) = 2023
                        ) THEN 'FY23'
                        WHEN (
                            date_part('month', a.key4_pay_end_dt) >= 7
                            AND date_part('year', a.key4_pay_end_dt) = 2023
                        )
                        OR (
                            date_part('month', a.key4_pay_end_dt) < 7
                            AND date_part('year', a.key4_pay_end_dt) = 2024
                        ) THEN 'FY24'
                        ELSE NULL
                    END AS fiscal_year,
                    ma_home_unit,
                    AVG(headcount) AS headcount
                FROM
(
                        SELECT
                            key4_pay_end_dt,
                            ma_home_unit,
                            COUNT(*) AS headcount
                        FROM
                            dbo.wh_empjob_pay_end_dt_snapshot a
                        WHERE
                            a.department = 'ITD'
                            AND a.xref_empl_status IN ('A', 'P', 'L', 'S')
                            AND a.xref_per_org = 'EMP'
                            AND a.jobcode != 'ECC05'
                            AND a.jobcode NOT LIKE '%CWR%'
                        GROUP BY
                            key4_pay_end_dt,
                            ma_home_unit
                    ) a
                WHERE
                    fiscal_year IS NOT NULL
                GROUP BY
                    fiscal_year,
                    fiscal_quarter,
                    ma_home_unit
            ) a
            LEFT JOIN(
                SELECT
                    CASE
                        WHEN date_part('month', a.termination_dt) >= 7
                        AND date_part('month', a.termination_dt) < 10 THEN 'Q1'
                        WHEN date_part('month', a.termination_dt) >= 10
                        AND date_part('month', a.termination_dt) <= 12 THEN 'Q2'
                        WHEN date_part('month', a.termination_dt) >= 1
                        AND date_part('month', a.termination_dt) < 4 THEN 'Q3'
                        WHEN date_part('month', a.termination_dt) >= 4
                        AND date_part('month', a.termination_dt) < 7 THEN 'Q4'
                        ELSE NULL
                    END AS fiscal_quarter,
                    CASE
                        WHEN (
                            date_part('month', a.termination_dt) >= 7
                            AND date_part('year', a.termination_dt) = 2019
                        )
                        OR (
                            date_part('month', a.termination_dt) < 7
                            AND date_part('year', a.termination_dt) = 2020
                        ) THEN 'FY20'
                        WHEN (
                            date_part('month', a.termination_dt) >= 7
                            AND date_part('year', a.termination_dt) = 2020
                        )
                        OR (
                            date_part('month', a.termination_dt) < 7
                            AND date_part('year', a.termination_dt) = 2021
                        ) THEN 'FY21'
                        WHEN (
                            date_part('month', a.termination_dt) >= 7
                            AND date_part('year', a.termination_dt) = 2021
                        )
                        OR (
                            date_part('month', a.termination_dt) < 7
                            AND date_part('year', a.termination_dt) = 2022
                        ) THEN 'FY22'
                        WHEN (
                            date_part('month', a.termination_dt) >= 7
                            AND date_part('year', a.termination_dt) = 2022
                        )
                        OR (
                            date_part('month', a.termination_dt) < 7
                            AND date_part('year', a.termination_dt) = 2023
                        ) THEN 'FY23'
                        WHEN (
                            date_part('month', a.termination_dt) >= 7
                            AND date_part('year', a.termination_dt) = 2023
                        )
                        OR (
                            date_part('month', a.termination_dt) < 7
                            AND date_part('year', a.termination_dt) = 2024
                        ) THEN 'FY24'
                        ELSE NULL
                    END AS fiscal_year,
                    ma_home_unit,
                    COUNT(*) AS separations
                FROM
                    (
                        SELECT
                            a.key2_emplid,
                            a.ma_home_unit,
                            MIN(a.termination_dt) AS termination_dt
                        FROM
                            dbo.wh_empjob_pay_end_dt_snapshot a
                        WHERE
                            a.department = 'ITD'
                            AND a.termination_dt IS NOT NULL
                            AND a.xref_action IN (
                                'RWP',
                                'TER',
                                'TWB',
                                'LOF',
                                'RET',
                                'SF7',
                                'TWP',
                                'XFR'
                            )
                            AND a.action_reason != 'TRP'
                            AND a.xref_per_org = 'EMP'
                            AND a.jobcode != 'ECC05'
                            AND a.jobcode NOT LIKE '%CWR%'
                        GROUP BY
                            a.key2_emplid,
                            a.ma_home_unit
                    ) a
                WHERE
                    fiscal_quarter IS NOT NULL
                    AND fiscal_year IS NOT NULL
                GROUP BY
                    fiscal_year,
                    fiscal_quarter,
                    ma_home_unit
            ) b ON a.fiscal_quarter = b.fiscal_quarter
            AND a.fiscal_year = b.fiscal_year
            AND a.ma_home_unit = b.ma_home_unit
        WHERE
            a.fiscal_year IS NOT NULL
        ORDER BY
            fiscal_year DESC,
            fiscal_quarter DESC
    ) a
WHERE
    quarter_rank <= 12