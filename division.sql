--- division
SELECT 1 FROM employees;

--- Metoda 1 - NOT EXISTS de doua ori
WITH q AS (SELECT DISTINCT employee_id FROM works_on a --- pentru fiecare employee din works_on
WHERE NOT EXISTS ( --- verificam sa nu existe
    SELECT 1 FROM project p --- niciun proiect cu buget 10.000
    WHERE p.budget = 10000
    AND NOT EXISTS ( --- care sa nu fie asociat lui employee
        SELECT 1 FROM works_on b 
        WHERE p.project_id = b.project_id
        AND b.employee_id = a.employee_id
    )
)) 
SELECT * FROM employees e, q q WHERE e.employee_id = q.employee_id;

SELECT DISTINCT employee_id FROM works_on;
SELECT * FROM project WHERE budget = 10000;
SELECT * FROM employees a WHERE EXISTS (
    SELECT 1 FROM works_on b WHERE b.project_id = 2 AND b.employee_id = a.employee_id 
);

--- Metoda 2 - COUNT
SELECT employee_id
FROM works_on
WHERE project_id IN (
    SELECT project_id
    FROM project
    WHERE budget = 10000
)
GROUP BY employee_id --- pastram proprietatea de distincte
HAVING COUNT(project_id) = (
    SELECT COUNT(*)
    FROM project
    WHERE budget = 10000
);

--- Metoda 3 - MINUS
--- complicat de scris... :(

--- Metoda 4 
SELECT DISTINCT employee_id
FROM works_on a
WHERE NOT EXISTS (
    (   --- toate proiectele de buget 10.000
        SELECT project_id
        FROM project p
        WHERE budget = 10000
    )
    MINUS
    (   --- minus toate proiectele la care participa angajatul
        SELECT p.project_id
        FROM project p, works_on b
        WHERE p.project_id = b.project_id
        AND b.employee_id = a.employee_id
    )
    --- rezultatul trebuie sa fie gol
);

--- Exercitii
WITH proiecte6luni2006 as (
    SELECT project_id 
    FROM project
    WHERE
        start_date BETWEEN TO_DATE('01/01/2006', 'DD/MM/YYYY') AND TO_DATE('30/06/2006', 'DD/MM/YYYY')
        AND
        delivery_date BETWEEN TO_DATE('01/01/2006', 'DD/MM/YYYY') AND TO_DATE('30/06/2006', 'DD/MM/YYYY')
)
SELECT DISTINCT employee_id
FROM works_on a
WHERE NOT EXISTS (
    SELECT project_id FROM proiecte6luni2006
    MINUS
    SELECT p.project_id
    FROM proiecte6luni2006 p, works_on b
    WHERE b.project_id = p.project_id
    AND b.employee_id = a.employee_id
);

SELECT * FROM job_history;

WITH totiAngajatiiCu2Posturi AS (
    SELECT employee_id FROM job_history
    GROUP BY employee_id HAVING COUNT(*) = 2
),
proiecteImportante AS (
    SELECT DISTINCT project_id FROM works_on a
    WHERE NOT EXISTS (
        SELECT employee_id FROM totiAngajatiiCu2Posturi
        MINUS
        (SELECT e.employee_id
        FROM totiAngajatiiCu2Posturi e, works_on b
        WHERE e.employee_id = b.employee_id AND
        a.project_id = b.project_id)
    )
)
SELECT * FROM proiecteImportante;
