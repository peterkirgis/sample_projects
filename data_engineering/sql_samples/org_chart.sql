SELECT
    b.first_name,
    b.last_name,
    c.descr AS position_name,
    CASE
        WHEN a.xref_per_org = 'EMP' THEN 'FTE'
        WHEN a.xref_per_org = 'CWR' THEN 'Staff Aug'
        ELSE NULL
    END AS employee_type,
    CASE
        WHEN a.jobcode LIKE ('%M%') THEN 'Manager'
        ELSE 'Non-Manager'
    END AS manager,
    a.ma_home_unit,
    NULL AS seniority,
    CASE
        WHEN a.position_nbr = c.reports_to THEN d.direct_reports - 1
        ELSE d.direct_reports
    END AS direct_reports,
    a.jobcode,
    a.position_nbr,
    c.reports_to,
    CASE
        WHEN a.xref_per_org = 'EMP' THEN TO_CHAR(
            ROUND(a.hourly_rt * a.std_hours * 52.143, 2),
            'fm999G999'
        ) || '/yr'
        WHEN a.xref_per_org = 'CWR' THEN ROUND(a.hourly_rt, 0) :: TEXT || '/hr'
    END AS salary,
    NULL AS span_of_control
FROM
    dbo.wh_job a
    INNER JOIN dbo.wh_employees b ON a.key2_emplid = b.key2_emplid
    INNER JOIN dbo.ps_posn_data c ON a.position_nbr = c.key2_position_nbr
    LEFT JOIN (
        SELECT
            a.reports_to AS position_nbr,
            COUNT(*) AS direct_reports
        FROM
            dbo.ps_job a
        WHERE
            a.department = 'ITD'
            AND a.xref_empl_status IN ('A', 'P', 'L', 'S')
            AND a.jobcode NOT IN ('ECC05')
        GROUP BY
            a.reports_to
    ) d ON a.position_nbr = d.position_nbr
WHERE
    a.department = 'ITD'
    AND a.xref_empl_status IN ('A', 'P', 'L', 'S')
    AND a.jobcode NOT IN ('ECC05')
UNION
SELECT
    DISTINCT NULL AS first_name,
    'VACANT' AS last_name,
    a.descr AS position_name,
    NULL AS employee_type,
    CASE
        WHEN a.jobcode LIKE ('%M%') THEN 'Manager'
        ELSE 'Non-Manager'
    END AS manager,
    c.ma_home_unit :: TEXT,
    NULL AS seniority,
    NULL :: BIGINT AS direct_reports,
    a.jobcode AS jobcode,
    a.key2_position_nbr AS position_nbr,
    a.reports_to,
    NULL AS salary,
    NULL AS span_of_control
FROM
    dbo.ps_posn_data a
    INNER JOIN (
        SELECT
            a.reports_to
        FROM
            dbo.ps_job a
        WHERE
            a.xref_empl_status IN ('A', 'P', 'L', 'S')
            AND a.jobcode != 'ECC05'
            AND a.department = 'ITD'
            AND a.reports_to NOT IN (
                SELECT
                    a.position_nbr
                FROM
                    dbo.ps_job a
                WHERE
                    a.xref_empl_status IN ('A', 'P', 'L', 'S')
                    AND a.jobcode != 'ECC05'
                    AND a.department = 'ITD'
            )
    ) b ON a.key2_position_nbr = b.reports_to
    LEFT JOIN (
        SELECT
            position_nbr,
            ma_home_unit
        FROM
            (
                SELECT
                    position_nbr,
                    ma_home_unit,
                    ROW_NUMBER() over (
                        PARTITION BY position_nbr
                        ORDER BY
                            date_to_warehouse DESC
                    ) AS rn
                FROM
                    dbo.wh_job_h a
            ) a
        WHERE
            rn = 1
    ) c ON a.key2_position_nbr = c.position_nbr
WHERE
    a.xref_eff_status = 'A'
    AND a.position_status = 'A'