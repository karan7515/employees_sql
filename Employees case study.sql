USE employees_mod;

/*
Comparing the number of male employees to the number of female employees from different departments for each year,
 starting from 1990.
 */
SELECT 
    YEAR(tde.from_date) AS calender_year,
    te.gender,
    COUNT(te.emp_no) AS no_of_employees
FROM
    t_dept_emp tde
        JOIN
    t_employees te ON tde.emp_no = te.emp_no
GROUP BY calender_year , te.gender
HAVING calender_year >= 1990;

SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN
            YEAR(dm.to_date) >= e.calendar_year
                AND YEAR(dm.from_date) <= e.calendar_year
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no , calendar_year;

/*
Comparing the average salary of female versus male employees in the entire company until year 2002, 
and add a filter allowing you to see that per each department.
*/
SELECT 
    e.gender,
    d.dept_name,
    ROUND(AVG(s.salary), 2) AS salary,
    YEAR(s.from_date) AS calendar_year
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no , e.gender , calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;

/*
Creating an SQL stored procedure that will allow to obtain the average male and female salary per department 
within a certain salary range. Let this range be defined by two values the user can insert when calling the procedure.
*/
DROP PROCEDURE IF EXISTS filter_salary;
Delimiter $$
Create procedure filter_salary(in p_min_salary  float , in p_max_salary float)
BEGIN
SELECT 
e.gender,d.dept_name, AVG(s.salary) as avg_salary
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
WHERE s.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY d.dept_no, e.gender;
END$$
DELIMITER ;

CALL filter_salary(50000, 90000);
