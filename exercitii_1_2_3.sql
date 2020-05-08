SELECT manager_id, SUM(salary) as total_spent FROM employees GROUP BY manager_id;

SELECT * FROM employees WHERE ROWNUM <= 5 ORDER BY employee_id DESC;

SELECT employee_id, job_id, salary FROM employees WHERE (job_id LIKE '%CLERK%' or job_id LIKE '%REP%') and (salary NOT IN (1000, 2000, 3000));

SELECT last_name, j.job_id, job_title, department_name, salary
FROM employees e, departments d, jobs j
WHERE e.department_id = d.department_id (+) and j.job_id = e.job_id;

SELECT * FROM employees
CROSS JOIN jobs;

SELECT employee.first_name||' '||employee.last_name "Nume angajat", employee.hire_date "Data Angajare",
       boss.first_name||' '||boss.last_name "Nume sef", boss.hire_date "Data Angajare"
FROM employees employee, employees boss
WHERE employee.manager_id = boss.employee_id and boss.hire_date < employee.hire_date;

SELECT * from locations;
SELECT * FROM departments;

SELECT last_name, department_id, job_id
FROM employees
WHERE department_id IN (SELECT department_id
FROM departments d join locations l on (d.location_id = l.location_id)
WHERE lower(l.city) NOT IN ('toronto', 'london'));
