--- Tema 7

--- Exercitiul 1
--- Numarul de subalterni pentru fiecare angajat (daca e cazul)
WITH numarSubalterni AS (
    SELECT manager_id as id_sef, COUNT(*) as subalterni 
    FROM employees 
    WHERE manager_id IS NOT NULL 
    GROUP BY manager_id
)
SELECT id_sef, e.last_name as nume, e.first_name as prenume, subalterni 
FROM numarSubalterni, employees e 
WHERE e.employee_id = id_sef;

--- Exercitiul 2
--- Departamentele care au cel putin 2 job-uri unice
WITH numarJoburiUnice AS (
    SELECT e.department_id, COUNT(DISTINCT e.job_id) as count 
    FROM employees e 
    WHERE department_id IS NOT NULL 
    GROUP BY e.department_id
    HAVING COUNT(DISTINCT e.job_id) >= 2

)
SELECT d.department_id, d.department_name, count 
FROM departments d, numarJoburiUnice j
WHERE d.department_id = j.department_id;  

--- Exercitiul 3
--- Pentru fiecare angajat, afiseaza orasul in care a lucrat cel mai mult timp (job curent + joburi anterioare)
WITH
jobDaysHistory AS ( --- time lucrat in joburile anterioare
    SELECT employee_id, job_id, department_id, end_date - start_date as time 
    FROM job_history
),
jobDaysCurrent AS ( --- timp lucrat la jobul curent
    SELECT employee_id, job_id, department_id, CURRENT_DATE - hire_date as time 
    FROM employees
),
jobDaysAll AS ( --- timp lucrat la toate joburile
    SELECT * FROM jobDaysHistory
    UNION ALL
    SELECT * FROM jobDaysCurrent
),
cityOfDepartments AS ( --- orasul corespunzator fiecarui departament
    SELECT DISTINCT e.department_id, l.city
    FROM employees e, departments d, locations l
    WHERE d.department_id = e.department_id AND d.location_id = l.location_id
),
totalTimeInEachCity AS ( --- timpul total lucrat in fiecare oras
    SELECT j.employee_id, SUM(j.time) total_time, cd.city
    FROM jobDaysAll j, cityOfDepartments cd
    WHERE cd.department_id = j.department_id
    GROUP BY j.employee_id, cd.city
),
maxTime AS ( --- orasul in care s-a lucrat timpul maxim
    SELECT employee_id, MAX(total_time) as max_time
    FROM totalTimeInEachCity
    GROUP BY employee_id
)
--- query final, join intre informatii angajat + orasul cu timp maxim
SELECT t.employee_id, e.first_name, e.last_name, t.city 
FROM totalTimeInEachCity t, maxTime m, employees e
WHERE t.employee_id = m.employee_id 
    AND m.max_time = t.total_time
    AND e.employee_id = t.employee_id;
