-- 2) Generar los comandos DDL de creación de las tablas.

/* Creamos las tablas con las respectivas claves primarias y foráneas que nos permiten comunicarlas más tarde en las vistas. Añado 
la columna total_puntos a la tabla partidos para poder realizar posteriormente el trigger. Aplicamos también las restricciones necesarias.*/

CREATE TABLE equipos (
    codigo_equipo INTEGER PRIMARY KEY,
    nombre_equipo VARCHAR2 (100) UNIQUE NOT NULL,
    pabellon VARCHAR2 (100) NOT NULL,
    aforo_pabellon NUMBER NOT NULL,
    año_fundacion NUMBER (4) NOT NULL,
    ciudad VARCHAR2 (100) NOT NULL
);
INSERT INTO equipos VALUES (1, 'Estudiantes', 'Movistar Arena', 14000, 1985, 'Madrid'); -- Insertamos algunos datos de prueba.
INSERT INTO equipos VALUES (2, 'Real Madrid', 'Movistar Arena', 14000, 1900, 'Madrid');

CREATE TABLE presidentes (
    dni CHAR (9) PRIMARY KEY,
    nombre VARCHAR2 (100) NOT NULL,
    apellidos VARCHAR2 (100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    codigo_equipo INTEGER NOT NULL UNIQUE,
    año_eleccion NUMBER (4) NOT NULL,
    FOREIGN KEY (codigo_equipo) REFERENCES equipos (codigo_equipo)
);

-- Insertamos algunos datos de prueba.

INSERT INTO presidentes VALUES ('45631236p', 'Carlos', 'Martín Morata', TO_DATE ('1987-12-31', 'YYYY-MM-DD'), 1, 2024);

CREATE TABLE jugadores (
    codigo_jugador INTEGER PRIMARY KEY,
    nombre VARCHAR2 (100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    posicion VARCHAR2 (10) CHECK (posicion IN ('base', 'escolta', 'alero', 'pivot')) NOT NULL,
    codigo_equipo INTEGER NOT NULL,
    FOREIGN KEY (codigo_equipo) REFERENCES equipos (codigo_equipo)
);

INSERT INTO jugadores VALUES (19, 'Miguel', TO_DATE ('2003-08-22', 'YYYY-MM-DD'), 'pivot', 1); -- Insertamos algunos datos de prueba.

CREATE TABLE partidos (
    codigo_partido INTEGER PRIMARY KEY,
    fecha_partido DATE NOT NULL,
    puntos_local NUMBER NOT NULL,
    puntos_visitante NUMBER NOT NULL,
    total_puntos NUMBER DEFAULT 0 NOT NULL,
    codigo_equipo_local INTEGER NOT NULL,
    codigo_equipo_visitante INTEGER NOT NULL,
    CHECK(codigo_equipo_local!=codigo_equipo_visitante),
    FOREIGN KEY (codigo_equipo_local) REFERENCES equipos (codigo_equipo),
    FOREIGN KEY (codigo_equipo_visitante) REFERENCES equipos (codigo_equipo)
);
INSERT INTO partidos VALUES (1001, TO_DATE ('2025-12-19', 'YYYY-MM-DD'), 0, 0, 0, 1, 2); -- Prueba inserción.



CREATE TABLE canastas (
    codigo_canasta INTEGER PRIMARY KEY, 
    minuto_anotacion NUMBER NOT NULL,
    tipo_canasta VARCHAR2 (10) CHECK(tipo_canasta IN ('doble', 'triple', 'tiro libre')) NOT NULL,
    descripcion VARCHAR2 (200),
    codigo_partido INTEGER NOT NULL,
    codigo_jugador INTEGER NOT NULL,
    FOREIGN KEY (codigo_jugador) REFERENCES jugadores (codigo_jugador),
    FOREIGN KEY (codigo_partido) REFERENCES partidos (codigo_partido)
);


-- 3) Crear las siguiente vistas:

-- a) Vista con nombres y fechas nacimiento jugadores.


CREATE OR REPLACE VIEW jugadores_vw AS
SELECT nombre, fecha_nacimiento
FROM jugadores;


-- b) Vista con los nombres de los equipos y el nombres de sus pabellones.

CREATE OR REPLACE VIEW equipo_pabellon AS
SELECT nombre_equipo, pabellon
FROM equipos;

-- c) Vista de los partidos con los nombres de los equipos y la cantidad total de puntos.

CREATE OR REPLACE VIEW partidos_equipos AS
SELECT p.codigo_partido, e.nombre_equipo AS equipo_local, eq.nombre_equipo AS equipo_visitante, p.total_puntos
FROM partidos p
JOIN equipos e ON p.codigo_equipo_local = e.codigo_equipo
JOIN equipos eq ON p.codigo_equipo_visitante = eq.codigo_equipo;

-- d) Vista de los jugadores y sus equipos.

CREATE OR REPLACE VIEW jugadores_equipos AS
SELECT j.nombre AS nombre_jugador, e.nombre_equipo
FROM jugadores j
JOIN equipos e ON j.codigo_equipo = e.codigo_equipo;

-- e) Vista de las canastas de cada partido con la descripción y el nombre del jugador.

CREATE OR REPLACE VIEW canastas_partido_jugador AS
SELECT c.codigo_canasta, c.codigo_partido, p.fecha_partido, e.nombre_equipo AS equipo_local, eq.nombre_equipo AS equipo_visitante, 
c.descripcion, j.nombre AS nombre_jugador
FROM canastas c
JOIN jugadores j ON c.codigo_jugador = j.codigo_jugador
JOIN partidos p ON c.codigo_partido = p.codigo_partido
JOIN equipos e ON p.codigo_equipo_local = e.codigo_equipo
JOIN equipos eq ON p.codigo_equipo_visitante = eq.codigo_equipo;

/* En este caso mi intención no es saturar la vista sino, hacer comprensible la consulta a una persona, en el caso de que 
fuera consultada por esta, ya que considero que el código de partido no sería suficientemente representativo, por lo que añado
información adicional como la fecha y los equipos intervinientes, lo que posibilita encontrar una relación mental rápida con dicho
partido.*/

-- f) Vista de los equipos y sus presidentes.

CREATE OR REPLACE VIEW equipos_presidentes AS
SELECT e.nombre_equipo, p.nombre AS nombre_presidente, p.apellidos
FROM equipos e
JOIN presidentes p ON e.codigo_equipo = p.codigo_equipo;

/*  IMPORTANTE:
Tanto el enunciado de la vista g) como la h) he tenido que hace mi propia interpretación, no sé si porque existe algún tipo
de puntuación que exista en baloncesto y que yo desconozco, pero en ambos enunciados se hace referencia a "en un partido" y "por partidos",
y no "de todos los partidos". Es por ello que yo he realizado el ejercicio teniendo en cuenta los valores del total_puntos de todos los partidos,
ya que no encontré el sentido a realizar el máximo y mínimo de un partido, ya que el total_puntos es uno, y de igual forma con la media.*/

-- g) Vista de la cantidad máxima y mínima de puntos en un partido.

/* Por el enuncidado interpreto: que buscamos ver qué partido tiene el número máximo de puntos totales y qué partido tiene el mínimo.*/

CREATE OR REPLACE VIEW puntos_max_min AS
SELECT 'maximo' AS cantidad, MAX(total_puntos) AS puntos
FROM partidos
UNION
SELECT 'minimo' AS cantidad, MIN(total_puntos) AS puntos
FROM partidos;

/*En este caso tuve que unir dos consultas para poder mostrar una vista que unificase todo en uno.*/

-- h) Vista de la cantidad promedio de puntos por partido.

/* En este caso también comprendo que debemos sacar el promedio de todos los partidos.*/

CREATE OR REPLACE VIEW promedio_partidos AS
SELECT 'promedio' AS promedio_partido, AVG(total_puntos) AS cantidad 
FROM partidos;

/* Aquí creo una tabla que muestre en dos columnas el promedio de puntos de todos los partidos.*/

-- i) Vista del número total de puntos anotados por cada jugador.

CREATE OR REPLACE VIEW puntos_jugador AS
SELECT c.codigo_jugador, j.nombre AS nombre_jugador, SUM(
    CASE
    WHEN tipo_canasta = 'doble' THEN 2
    WHEN tipo_canasta = 'triple' THEN 3
    ELSE 1
    END) AS puntos_jugador
FROM canastas c
JOIN jugadores j ON c.codigo_jugador = j.codigo_jugador
GROUP BY c.codigo_jugador, j.nombre;



/* Esta vista me pareció especialmente difícil. Tuve que buscar información para poder hacerla, finalmente usando 
CASE para poder establecer las canastas con la devolución de su puntuación.*/

-- 4) Crear un trigger en la tabla Partido para actualizar el campo TotalPuntos cada vez que se inserte o elimine una canasta.

CREATE OR REPLACE TRIGGER trg_canasta 
AFTER INSERT OR DELETE ON canastas
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.tipo_canasta = 'triple' THEN
        UPDATE partidos
        SET total_puntos = total_puntos + 3
        WHERE codigo_partido = :NEW.codigo_partido;
        ELSIF :NEW.tipo_canasta = 'doble' THEN
        UPDATE partidos
        SET total_puntos = total_puntos + 2
        WHERE codigo_partido = :NEW.codigo_partido;
        ELSE 
        UPDATE partidos
        SET total_puntos = total_puntos + 1
        WHERE codigo_partido = :NEW.codigo_partido;
        END IF;
    END IF;
    IF DELETING THEN
        IF :OLD.tipo_canasta = 'triple' THEN
        UPDATE partidos
        SET total_puntos = total_puntos - 3
        WHERE codigo_partido = :OLD.codigo_partido;
        ELSIF :OLD.tipo_canasta = 'doble' THEN
        UPDATE partidos
        SET total_puntos = total_puntos - 2
        WHERE codigo_partido = :OLD.codigo_partido;
        ELSE 
        UPDATE partidos
        SET total_puntos = total_puntos - 1
        WHERE codigo_partido = :OLD.codigo_partido;
        END IF;
    END IF;
END;
/
-- Probamos el trigger:

INSERT INTO canastas VALUES (102, 12, 'doble', 'canasta marcada tras contraataque', 1001, 19); -- Insertamos la canasta.
SELECT * FROM partidos; -- Comprobamos que el trigger funciona suma 2 puntos al partido en total_puntos.
DELETE FROM canastas WHERE codigo_canasta = 102; -- Eliminamos la canasta y se resta la puntuación.
