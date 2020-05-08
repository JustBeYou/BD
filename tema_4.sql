--- varianta 1
WITH emp_count_per_dep AS (SELECT e.department_id, COUNT(*) as total
FROM employees e
WHERE e.department_id IS NOT NULL
GROUP BY e.department_id),

named_count AS (SELECT cnt.department_id, d.department_name, cnt.total
FROM emp_count_per_dep cnt, departments d
WHERE cnt.department_id = d.department_id)

SELECT * FROM named_count WHERE total = (SELECT MAX(total) FROM named_count);

--- varianta 2 - ar trebui sa fie mai eficient asa pentru ca join-ul e mai mic
WITH emp_count_per_dep AS (SELECT e.department_id, COUNT(*) as total
FROM employees e
WHERE e.department_id IS NOT NULL
GROUP BY e.department_id),

max_cnt AS (SELECT MAX(total) FROM emp_count_per_dep)

SELECT best.department_id, d.department_name, best.total
FROM emp_count_per_dep best, departments d
WHERE best.total = (SELECT * FROM max_cnt) and best.department_id = d.department_id;

WITH cnt_condition AS (SELECT COUNT(*) as total_in_years FROM employees WHERE EXTRACT(year from hire_date) IN (1997, 1998, 1999, 2000)),
cnt_all AS (SELECT COUNT(*) as total FROM employees)

SELECT * FROM cnt_all, cnt_condition;
