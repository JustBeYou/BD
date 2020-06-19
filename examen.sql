/* Exercitiul 1 */
with
cazariAzi as (
    select id, id_camera, data_cazare from CAZARE
    where data_cazare >= trunc(sysdate) - 1
    -- am folosit data de ieri pentru ca nu exista intrari astazi
),
turistiAzi as (
    select a.nume, a.prenume, b.id_camera from TURIST a, cazariAzi b
    where exists (
        select id_cazare from TURIST_CAZARE c
        where c.id_cazare = b.id and c.id_turist = a.id
    )
)
select a.nume, a.prenume, b.nr_camera, c.denumire from
turistiAzi a
inner join CAMERA b on a.id_camera = b.id
inner join HOTEL c on b.id_hotel = c.id;

/* Exercitiul 2 */
with
cazariTinta as (
    select * from CAZARE
    where extract (year from data_cazare) = 2017 or
    extract (year from data_cazare) = 2018 or
    extract (year from data_cazare) = 2019
),
numaratoare as (
    select id_camera, extract(year from data_cazare) as an, COUNT(*) as cazari
    from cazariTinta
    group by id_camera, extract(year from data_cazare)
),
informatiiFinale as (
    select c.denumire as denumire_hotel, b.nr_camera, a.an, a.cazari from numaratoare a
    inner join CAMERA b on b.id = a.id_camera
    inner join HOTEL c on c.id = b.id_hotel
)

select denumire_hotel, nr_camera,
    MAX(CASE WHEN an = 2017
            THEN cazari END) as cazari2017,
    MAX(CASE WHEN an = 2018
            THEN cazari END) as cazari2018,
    MAX(CASE WHEN an = 2019
            THEN cazari END) as cazari2019
from informatiiFInale
group by denumire_hotel, nr_camera;

/* Exercitiul 3 */

with
tarifeActive as (
    select * from TARIF_CAMERA
    where data_start <= sysdate and (data_end >= sysdate or data_end is null)
)

select h.id, h.denumire from HOTEL h
where exists (
        select * from CAMERA a
        inner join tarifeActive b on b.id_camera = a.id
        where a.id_hotel = h.id
        having count(distinct tarif) = 1
);

/* Exercitiul 4 */
--- cautam camerele fara tarife active
with tarifeActive as (
    select * from TARIF_CAMERA
    where data_start <= sysdate and (data_end >= sysdate or data_end is null)
)
select a.id from CAMERA a
where not exists (
    select * from tarifeActive b
    where a.id = b.id_camera
);
--- un exemplu este camera 7

--- obtinem tariful minim si adaugam
select MIN(tarif) as tarif_minim from TARIF_CAMERA where id_camera = 7; --- tarif minim = 200
insert into TARIF_CAMERA VALUES
(7, sysdate, sysdate + 10, 200);

/* Exercitiul 5 */

alter table CAMERA
drop constraint FK_HOTEL_CAMERA;

alter table CAMERA
add constraint FK_HOTEL_CAMERA
FOREIGN KEY (id_hotel) REFERENCES HOTEL(id)
on delete cascade;
