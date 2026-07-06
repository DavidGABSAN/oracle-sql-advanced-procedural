-- RETO 2 

-- CREACIÓN DE TABLAS

-- TABLA SOCIOS

CREATE TABLE socios (
    ID_socio INTEGER PRIMARY KEY,
    nombre VARCHAR2 (100) NOT NULL,
    direccion VARCHAR2 (100) NOT NULL,
    mail VARCHAR2 (40) NOT NULL UNIQUE,
    numero_reservas INTEGER DEFAULT 0
);

/* Esta tabla contiene el ID_socio como clave primaria, tenemos en todos los campos la restricción 
adicional NOT NULL excepto en numero_reservas, ya que un socio puede no haber realizado ninguna 
reserva de actividad, sobre todo si acaba de empezar. Además le damos al campo mail la restricción
UNIQUE ya que cada socio tendrá un email único. No se la damos a nombre, porque por caprichos de la vida
podrían existir dos socios con nombres y apellidos iguales, tampoco a dirección, porque dos socios pueden
tener la misma dirección si residen en la misma vivienda (pareja, familia, compañeros de piso,...). 
Tampoco utilizaremos UNIQUE en el número de reservas ya que los socios pueden tener el mismo número de 
reservas. Sí utilizaremos DEFAULT 0 para que se establezca un número de reservas por defecto igual a 
0 en caso de no rellenar el campo, y que no se le dé por defecto el valor NULL, que imposibilitaría el 
funcionamiento del trigger posterior.
Es cierto que el atributo numero_reservas en socios no estaría en 3FN, pero en este caso lo necesitamos 
para llevar a cabo el trigger, según enunciado.*/

-- TABLA ESPECIALIDAD

CREATE TABLE especialidades (
    ID_especialidad INTEGER PRIMARY KEY,
    nombre VARCHAR2 (50) NOT NULL UNIQUE
);

/*Creamos la tabla especialidades con un ID que será clave primaria y que actuará como clave foránea en la 
tabla entrenadores para unir dichas tablas. Damos un nombre a la especialidad y aplicamos las restricciones NOT 
NULL y UNIQUE para establecer la obligatoriedad de rellenar dichos campos y que no se repitan las especialidades. 
Con esta tabla nos aseguramos una 3FN.*/

-- TABLA ENTRENADORES

CREATE TABLE entrenadores (
    ID_entrenador INTEGER PRIMARY KEY,
    nombre VARCHAR2 (100) NOT NULL,
    ID_especialidad INTEGER NOT NULL,
    FOREIGN KEY (ID_especialidad) REFERENCES especialidades (ID_especialidad)
);


/* En el caso de la tabla entrenadores, nuestra clave primaria es ID_entrenador, obviamente utilizaremos
VARCHAR2 para nombre, como hemos hecho en la tabla anterior para campos escritos, y usamos
NOT NULL para que siempre exista un nombre de entrenador. Añadimos una clave foránea ID_especialidad que 
no puede ser nula, que conecte con la tabla especialidades.*/

-- TABLA TIPO ACTIVIDAD

CREATE TABLE tipo_actividad (
    ID_tipo INTEGER PRIMARY KEY,
    nombre VARCHAR2 (50) NOT NULL UNIQUE
);    

/* Creamos la tabla tipo_actividad con la misma intención que con la tabla especialidades, es decir, dejar
todo normalizado a 3FN, y no repetir campos en actividades ni entrenadores.*/

-- TABLA ACTIVIDADES

CREATE TABLE actividades (
    ID_actividad INTEGER PRIMARY KEY,
    nombre VARCHAR2 (50) NOT NULL,
    ID_entrenador INTEGER NOT NULL,
    ID_tipo INTEGER NOT NULL,
    FOREIGN KEY (ID_entrenador) REFERENCES entrenadores (ID_entrenador),
    FOREIGN KEY (ID_tipo) REFERENCES tipo_actividad (ID_tipo)
);

/* La tabla actividades tiene como clave primaria ID_actividad. Contiene un nombre NOT NULL.
El nombre de la actividad no es UNIQUE ya que una misma actividad
puede llevarse a cabo por un entrenador distinto. 
Una clave foránea ID_entrenador, que no podrá ser nula y un tipo not null.
Otra clave foránea ID_tipo, no nula que conectará con la tabla tipo_actividad.*/

-- TABLA RESERVAS

CREATE TABLE reservas (
    ID_reserva INTEGER PRIMARY KEY, 
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    ID_actividad INTEGER NOT NULL,
    ID_socio INTEGER NOT NULL,
    FOREIGN KEY (ID_actividad) REFERENCES actividades (ID_actividad),
    FOREIGN KEY (ID_socio) REFERENCES socios (ID_socio),
    CHECK (fecha_fin >= fecha_inicio)
);

/* Esta última tabla tiene como clave primaria el número de reserva, tiene una fecha de inicio tipo DATE y una final DATE también, 
que no pueden ser nulas, tenemos asociados un ID_actividad y un ID_socio como claves foráneas no nulas que se conectan con las tablas
actividades y socios. Por último, he buscado si existía la manera de evitar que pudieran introducirse campos de fecha fin que ocurrieran
antes de fecha inicio y he encontrado esta solución CHECK (fecha_fin >= fecha_inicio), que aunque no la hemos dado, 
la usaré siempre que necesite precisar un rango entre dos valores, si no se me olvida su existencia XD...*/


-- INSERTAMOS LOS DATOS INICIALES

-- Especialidades 

INSERT INTO especialidades VALUES (1, 'Yoga');
INSERT INTO especialidades VALUES (2, 'Cardio');
INSERT INTO especialidades VALUES (3, 'Artes marciales');
INSERT INTO especialidades VALUES (4, 'Musculación');
INSERT INTO especialidades VALUES (5, 'Entrenamiento funcional');
INSERT INTO especialidades VALUES (6, 'Pilates');
INSERT INTO especialidades VALUES (7, 'Zumba');

-- Entrenadores

INSERT INTO entrenadores VALUES (1, 'José Luis', 2);
INSERT INTO entrenadores VALUES (2, 'Mónica', 7);
INSERT INTO entrenadores VALUES (3, 'Laura', 1);
INSERT INTO entrenadores VALUES (4, 'Marcos', 4);
INSERT INTO entrenadores VALUES (5, 'Diego', 4);
INSERT INTO entrenadores VALUES (6, 'Carolina', 4);
INSERT INTO entrenadores VALUES (7, 'Helena', 6);
INSERT INTO entrenadores VALUES (8, 'Jesús', 6);
INSERT INTO entrenadores VALUES (9, 'Juan Carlos', 2);
INSERT INTO entrenadores VALUES (10, 'Cristian', 2);
INSERT INTO entrenadores VALUES (11, 'Pablo', 3);
INSERT INTO entrenadores VALUES (12,'Lorena', 5);
INSERT INTO entrenadores VALUES (13,'Alfon', 5);

-- Socios

INSERT INTO socios VALUES (1, 'Óscar López', 'Buitrago 2', 'oscar@.com', 2);
INSERT INTO socios VALUES (2, 'Laura Ruiz', 'Segovia', 'Laura@.com', 3);
INSERT INTO socios VALUES (3, 'Jesús Bardera', 'Ovideo 4', 'jesus@.com', 3);
INSERT INTO socios VALUES (4, 'María Catena', 'Sevilla 59', 'maria@.com', 5);
INSERT INTO socios VALUES (5, 'Daniel Fernández', 'Madrid 3', 'dani@.com', 2);
INSERT INTO socios VALUES (6, 'Carla Abril', 'Barcelona 2', 'carla@.com', 1);
INSERT INTO socios VALUES (7, 'Santiago Segura', 'Luarca 34', 'santi@.com', 3);
INSERT INTO socios VALUES (8, 'Rocío López', 'Cartagena 21', 'rocio@.com', 4);
INSERT INTO socios VALUES (9, 'Raúl Gutiérrez', 'Santander 1', 'raul@.com', 1);
INSERT INTO socios VALUES (10, 'Mara Torres', 'Lugo 12', 'mara@.com', 5);
INSERT INTO socios VALUES (11, 'Guillermo Gil', 'Alicante 14', 'guille@.com', 0);

-- Tipo de actividad

INSERT INTO tipo_actividad VALUES (1, 'Yoga');
INSERT INTO tipo_actividad VALUES (2, 'Spinning');
INSERT INTO tipo_actividad VALUES (3, 'HIIT');
INSERT INTO tipo_actividad VALUES (4, 'Aeróbic');
INSERT INTO tipo_actividad VALUES (5, 'BodyCombat');
INSERT INTO tipo_actividad VALUES (6, 'Entrenamiento funcional');
INSERT INTO tipo_actividad VALUES (7, 'Tonificación');
INSERT INTO tipo_actividad VALUES (8, 'CrossFit');
INSERT INTO tipo_actividad VALUES (9, 'Fuerza y resistencia');
INSERT INTO tipo_actividad VALUES (10, 'Pilates');
INSERT INTO tipo_actividad VALUES (11, 'CardioDance');
INSERT INTO tipo_actividad VALUES (12, 'Circuito Funcional');

-- Actividades

INSERT INTO actividades VALUES (1, 'Yoga Mañanas', 3, 1);
INSERT INTO actividades VALUES (2, 'Spinning Mañanas', 9, 2);
INSERT INTO actividades VALUES (3, 'Spinning Tardes', 9, 2);
INSERT INTO actividades VALUES (4, 'HIIT Tardes', 10, 3);
INSERT INTO actividades VALUES (5, 'Fuerza y resistencia Mañanas', 5, 9);
INSERT INTO actividades VALUES (6, 'Fuerza y resistencia Tardes', 6, 9);
INSERT INTO actividades VALUES (7, 'Fuerza y resistencia Fines de semana', 4, 9);
INSERT INTO actividades VALUES (8, 'CrossFit Mañanas', 13, 8);
INSERT INTO actividades VALUES (9, 'CrossFit Tardes', 12, 8);
INSERT INTO actividades VALUES (10, 'Tonificación Tardes', 4, 7);
INSERT INTO actividades VALUES (11, 'Pilates Mañanas', 7, 10);
INSERT INTO actividades VALUES (12, 'Pilates Tardes', 8, 10);
INSERT INTO actividades VALUES (13, 'CardioDance Tardes', 2, 11);
INSERT INTO actividades VALUES (14, 'Circuito funcional Tardes', 13, 12);

-- Reservas

INSERT INTO reservas VALUES (1, TO_DATE('10/09/2025', 'DD/MM/YYYY'), TO_DATE('31/05/2026', 'DD/MM/YYYY'),6, 1);
INSERT INTO reservas VALUES (2, TO_DATE('10/08/2025', 'DD/MM/YYYY'), TO_DATE('31/10/2025', 'DD/MM/YYYY'),9, 1);
INSERT INTO reservas VALUES (3, TO_DATE('24/10/2024', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),1, 2);
INSERT INTO reservas VALUES (4, TO_DATE('29/03/2025', 'DD/MM/YYYY'), TO_DATE('31/12/2025', 'DD/MM/YYYY'),11, 2);
INSERT INTO reservas VALUES (5, TO_DATE('09/05/2024', 'DD/MM/YYYY'), TO_DATE('30/06/2025', 'DD/MM/YYYY'),13, 2);
INSERT INTO reservas VALUES (6, TO_DATE('01/09/2025', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),9, 3);
INSERT INTO reservas VALUES (7, TO_DATE('01/01/2020', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),6, 3);
INSERT INTO reservas VALUES (8, TO_DATE('01/09/2021', 'DD/MM/YYYY'), TO_DATE('31/01/2022', 'DD/MM/YYYY'),14, 3);
INSERT INTO reservas VALUES (9, TO_DATE('01/09/2023', 'DD/MM/YYYY'), TO_DATE('31/05/2026', 'DD/MM/YYYY'),13, 4);
INSERT INTO reservas VALUES (10, TO_DATE('01/01/2022', 'DD/MM/YYYY'), TO_DATE('31/05/2026', 'DD/MM/YYYY'),5, 4);
INSERT INTO reservas VALUES (11, TO_DATE('01/03/2019', 'DD/MM/YYYY'), TO_DATE('31/08/2019', 'DD/MM/YYYY'),11, 4);
INSERT INTO reservas VALUES (12, TO_DATE('13/09/2025', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),1, 4);
INSERT INTO reservas VALUES (13, TO_DATE('24/11/2024', 'DD/MM/YYYY'), TO_DATE('31/01/2025', 'DD/MM/YYYY'),8, 4);
INSERT INTO reservas VALUES (14, TO_DATE('01/01/2024', 'DD/MM/YYYY'), TO_DATE('31/05/2026', 'DD/MM/YYYY'),9, 5);
INSERT INTO reservas VALUES (15, TO_DATE('01/01/2022', 'DD/MM/YYYY'), TO_DATE('31/12/2024', 'DD/MM/YYYY'),6, 5);
INSERT INTO reservas VALUES (16, TO_DATE('01/01/2023', 'DD/MM/YYYY'), TO_DATE('31/05/2026', 'DD/MM/YYYY'),7, 6);
INSERT INTO reservas VALUES (17, TO_DATE('01/01/2021', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),3, 7);
INSERT INTO reservas VALUES (18, TO_DATE('01/01/2020', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),5, 7);
INSERT INTO reservas VALUES (19, TO_DATE('01/08/2024', 'DD/MM/YYYY'), TO_DATE('30/09/2024', 'DD/MM/YYYY'),1, 7);
INSERT INTO reservas VALUES (20, TO_DATE('01/01/2024', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),6, 8);
INSERT INTO reservas VALUES (21, TO_DATE('01/03/2024', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),3, 8);
INSERT INTO reservas VALUES (22, TO_DATE('10/06/2025', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),7, 8);
INSERT INTO reservas VALUES (23, TO_DATE('01/02/2020', 'DD/MM/YYYY'), TO_DATE('30/04/2021', 'DD/MM/YYYY'),10, 8);
INSERT INTO reservas VALUES (24, TO_DATE('01/01/2023', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),9, 9);
INSERT INTO reservas VALUES (25, TO_DATE('01/01/2022', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),6, 10);
INSERT INTO reservas VALUES (26, TO_DATE('01/03/2023', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),11, 10);
INSERT INTO reservas VALUES (27, TO_DATE('12/08/2022', 'DD/MM/YYYY'), TO_DATE('31/12/2023', 'DD/MM/YYYY'),14, 10);
INSERT INTO reservas VALUES (28, TO_DATE('10/10/2022', 'DD/MM/YYYY'), TO_DATE('31/12/2026', 'DD/MM/YYYY'),10, 10);
INSERT INTO reservas VALUES (29, TO_DATE('09/08/2023', 'DD/MM/YYYY'), TO_DATE('30/04/2024', 'DD/MM/YYYY'),1, 10);

COMMIT;


-- VISTAS

-- A)

CREATE OR REPLACE VIEW actividades_entrenador AS
SELECT a.ID_actividad, a.nombre AS nombre_actividad, a.ID_entrenador, e.nombre AS nombre_entrenador, t.nombre AS tipo_actividad
FROM actividades a
JOIN entrenadores e ON a.ID_entrenador = e.ID_entrenador
JOIN tipo_actividad t ON a.ID_tipo = t.ID_tipo;

/* Con esta vista conseguimos relacionar las actividades junto con cada entrenador que las imparte. Unimos 3 tablas, actividades, 
entrenadores y tipo de actividad para poder visualizar correctamente los datos, a través de las claves foráneas.*/

-- B) 

CREATE OR REPLACE VIEW reservas_activas AS
SELECT r.ID_reserva, r.fecha_inicio, r.fecha_fin, s.nombre AS nombre_socio, a.nombre AS nombre_actividad
FROM reservas r
JOIN socios s ON r.ID_socio = s.ID_socio
JOIN actividades a ON r.ID_actividad = a.ID_actividad
WHERE r.fecha_inicio <= SYSDATE AND r.fecha_fin >= SYSDATE;

/* En esta vista mostramos las reservas activas con los nombres de los socios que han reservado, y a qué actividad
corresponde cada reserva. Para poder definir lo que es "reservas activas" pensamos en aquellas que están dentro de la fecha
actual, es decir, aquellas cuya fecha fin no ha pasado ya y cuya fecha inicio ya ha sucedido en el momento de consulta, 
es decir, tomando como referencia SYSDATE. */

-- C)

CREATE OR REPLACE VIEW numero_actividades_entrenador AS
SELECT e.ID_entrenador, e.nombre, COUNT(DISTINCT a.ID_actividad) AS numero_actividades
FROM actividades a
JOIN entrenadores e ON a.ID_entrenador = e.ID_entrenador
GROUP BY e.nombre, e.ID_entrenador; 

/* Esta vista cuenta el número de actividades que realiza cada entrenador por medio de COUNT.
Utilizamos DISTINCT para evitar posibles duplicados de actividades asociadas al mismo entrenador.
Incluimos e.nombre y e.ID_entrenador en el GROUP BY para poder mostrarlos en la consulta.*/

-- D)


CREATE OR REPLACE VIEW numero_actividades_socios AS
SELECT s.ID_socio, s.nombre, COUNT(DISTINCT r.ID_actividad) AS numero_actividades_reservadas
FROM reservas r
RIGHT JOIN socios s ON r.ID_socio = s.ID_socio
GROUP BY s.ID_socio, s.nombre;

/* Aquí realizamos una vista parecida a la anterior, con el mismo sistema de agregación COUNT, pero esta 
vez con el número de actividades que tiene cada socio. Hemos utilizado RIGHT JOIN para forzar que aparezcan
también los socios que no tienen reservas.*/

-- CONSULTA VISTAS

-- A)

SELECT * FROM actividades_entrenador
ORDER BY ID_actividad ASC;

-- B)

SELECT * FROM reservas_activas
ORDER BY ID_reserva ASC;

-- C)

SELECT * FROM numero_actividades_entrenador
ORDER BY numero_actividades DESC;

-- D)

SELECT * FROM numero_actividades_socios
ORDER BY numero_actividades_reservadas DESC;

-- TRIGGER

CREATE OR REPLACE TRIGGER trg_numero_reservas 
AFTER INSERT OR DELETE ON reservas
FOR EACH ROW
    BEGIN
        IF INSERTING THEN
            UPDATE socios
            SET numero_reservas = numero_reservas + 1
            WHERE ID_socio = :NEW.ID_socio;
        ELSIF DELETING THEN
            UPDATE socios
            SET numero_reservas = numero_reservas - 1
            WHERE ID_socio = :OLD.ID_socio;
        END IF;
    END;
/

/* Gracias al trigger podemos mantener sincronizado el campo numero_reservas de la tabla socios
cada vez que se inserta o se elimina una reserva. Tuve que buscar en internet cómo crear las
condiciones porque no sabía que podía utilizar las palabras INSERTING, DELETING, UPDATING, etc.
Muy útiles y directas para estos casos.*/

-- FUNCIÓN

CREATE FUNCTION cantidad_dias 
(fecha_inicio DATE, fecha_fin DATE)
RETURN NUMBER
AS
    v_dias NUMBER;
    
BEGIN
    v_dias := fecha_fin - fecha_inicio;
    RETURN v_dias;
END cantidad_dias;

/

/* Tenemos una función que contiene un bloque PL/SQL y que es sencilla. Básicamente, creo 
una variable que almacena el resultado del cálculo, con el mismo tipo de dato NUMBER que 
devuelve la función. En el bloque defino el valor de la función como la resta entre la fecha 
final y la fecha de inicio. Por último le pido que devuelva el valor de v_dias. Con esta 
función podríamos crear consultas o vistas que, gracias al ID_reserva especificado nos 
diga el número de días entre ambas fechas.*/


/* FIN */
