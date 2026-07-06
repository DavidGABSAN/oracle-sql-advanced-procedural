
-- 2.- Sentencias de creación de tablas:

CREATE TABLE categorias (
    codigo_categoria INTEGER PRIMARY KEY,
    nombre_categoria VARCHAR2 (50) NOT NULL,
    tipo_IVA NUMBER (2,2) NOT NULL,
    descripcion VARCHAR2 (100)
);


/* He puesto el tipo de IVA como NUMBER (2,2) por el simple hecho de poner el IVA en formato decimal.*/

CREATE TABLE hoteles (
    codigo_hotel INTEGER PRIMARY KEY,
    nombre_hotel VARCHAR2 (100) NOT NULL UNIQUE,
    direccion VARCHAR2 (100) NOT NULL UNIQUE,
    telefono NUMERIC (9) NOT NULL UNIQUE,
    año_construccion NUMERIC (4) NOT NULL, 
    codigo_categoria INTEGER NOT NULL,
    FOREIGN KEY (codigo_categoria) REFERENCES categorias (codigo_categoria)
);

/* He puesto UNIQUE en dirección y teléfono, en el primer caso porque cada hotel de la cadena se encontrará
en una ciudad distinta, y en el segundo, aunque la cadena hotelera tenga una centralita común, cada hotel tendrá
su teléfono único con el prefijo de su cidudad.*/
    
CREATE TABLE tipos_habitaciones (
	codigo_tipo_habitacion INTEGER PRIMARY KEY,
	tipo_habitacion VARCHAR2 (40) NOT NULL
);

CREATE TABLE habitaciones (
	codigo_habitacion INTEGER PRIMARY KEY,
	numero_habitacion NUMERIC (3) NOT NULL,
	codigo_tipo_habitacion INTEGER NOT NULL,
	codigo_hotel INTEGER NOT NULL,
	FOREIGN KEY (codigo_hotel) REFERENCES hoteles (codigo_hotel),
	FOREIGN KEY (codigo_tipo_habitacion) REFERENCES tipos_habitaciones (codigo_tipo_habitacion),
	CONSTRAINT uk_combinacion UNIQUE (numero_habitacion, codigo_hotel)
);

/* Aquí he puesto las claves foráneas necesarias para unir las habitaciones con los tipos y los hoteles, y hemos 
creado una restricción con CONSTRAINT de combinación para obligar a que en cada hotel solo pueda existir una habitación 
con cada número de habitación, es decir, que solo haya una habitación 100, una 101, etc. Sí que permitimos que se puedan
repetir dichas habitaciones en los distintos hoteles.*/

CREATE TABLE tipos_reservas (
    codigo_tipo_reserva INTEGER PRIMARY KEY,
    tipo_reserva VARCHAR2 (30) NOT NULL
);

CREATE TABLE reservas (
    codigo_reserva INTEGER PRIMARY KEY,
    codigo_tipo_reserva INTEGER NOT NULL,
    nombre_reserva VARCHAR2 (100) NOT NULL,
    telefono NUMERIC (9) NOT NULL,
    direccion VARCHAR2(100) NOT NULL,
    fecha_entrada DATE NOT NULL,
    fecha_salida DATE NOT NULL,
    precio NUMBER (10,2) NOT NULL,
    nombre_cliente_agencia VARCHAR2 (100),
    codigo_habitacion INTEGER NOT NULL,
    FOREIGN KEY (codigo_tipo_reserva) REFERENCES tipos_reservas (codigo_tipo_reserva),
    FOREIGN KEY (codigo_habitacion) REFERENCES habitaciones (codigo_habitacion),
    CHECK(fecha_entrada < fecha_salida)
);

/
CREATE OR REPLACE TRIGGER reservas_particulares 
BEFORE INSERT OR UPDATE ON reservas 
FOR EACH ROW
BEGIN
    IF :NEW.codigo_tipo_reserva = 1 AND :NEW.nombre_cliente_agencia IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20002, 'El campo nombre_cliente_agencia no debe cumplimentarse.');
    ELSIF :NEW.codigo_tipo_reserva = 2 AND :NEW.nombre_cliente_agencia IS NULL THEN
    RAISE_APPLICATION_ERROR(-20003, 'El campo nombre_cliente_agencia debe cumplimentarse.');
    END IF;
END;

/* Creo un trigger que asegure que el campo de nombre_cliente_agencia sea NULL para particulares y NOT NULL para 
reservas de agencia, antes de insertar o actualizar una reserva.*/

/
/* En este caso creamos una entidad tipos_reservas que almacenará los tipos de reserva de particular y agencia, y que mediante
una clave foránea se conecta con la tabla reservas. La tabla reservas almacenará un atributo adicional (nombre_cliente_agencia)
que solo podrá ser rellenado en caso de que la reserva sea de tipo agencia. 
Además hemos creado una restricción con CHECK para que la fecha de salida no pueda ser anterior a la de entrada.*/
    
-- 3.- Crear las siguientes vistas:

    -- a) Vista de los hoteles y sus categorías.
    
CREATE OR REPLACE VIEW hoteles_categoria AS
SELECT h.nombre_hotel AS HOTEL, c.nombre_categoria AS CATEGORIA
FROM hoteles h
JOIN categorias c ON h.codigo_categoria = c.codigo_categoria;

    -- b) Vista de las habitaciones de un hotel específico.
  
CREATE OR REPLACE VIEW hoteles_habitaciones AS
SELECT h.codigo_hotel, h.nombre_hotel AS HOTEL, ha.numero_habitacion, t.tipo_habitacion 
FROM habitaciones ha
JOIN hoteles h ON ha.codigo_hotel = h.codigo_hotel
JOIN tipos_habitaciones t ON ha.codigo_tipo_habitacion = t.codigo_tipo_habitacion;

/* En este caso creo una vista general con todos los hoteles y habitaciones para poder ser reutilizada
de manera que se puede buscar la vista específica de un hotel por medio del código de hotel, tal y como ejemplifico
más arriba. Podría haber hecho la vista con un WHERE codigo_hotel = x, pero me parecía que es más interesante 
disponer de la posibilidad de poder ver cada hotel cada vez que se necesite, sin crear una vista para cada uno.*/

    -- c) Vista de las reservas realizadas por particulares.

CREATE OR REPLACE VIEW reservas_particulares AS
SELECT r.codigo_reserva, r.nombre_reserva, r.telefono, r.direccion, r.fecha_entrada, r.fecha_salida, r.precio, r.codigo_habitacion
FROM reservas r
JOIN tipos_reservas t ON r.codigo_tipo_reserva = t.codigo_tipo_reserva
WHERE t.tipo_reserva = 'PARTICULAR';

    -- d) Vista de las reservas realizadas por agencias de viajes.

CREATE OR REPLACE VIEW reservas_agencias AS
SELECT r.codigo_reserva, r.nombre_reserva, r.telefono, r.direccion, r.fecha_entrada, r.fecha_salida, r.precio, r.codigo_habitacion, r.nombre_cliente_agencia
FROM reservas r
JOIN tipos_reservas t ON r.codigo_tipo_reserva = t.codigo_tipo_reserva
WHERE t.tipo_reserva = 'AGENCIA';

    -- e) Vista de la categoría del hotel con la fecha de construcción más reciente.

CREATE OR REPLACE VIEW categoria_hotel_mas_reciente AS    
SELECT c.nombre_categoria, h.nombre_hotel
FROM categorias c
JOIN hoteles h ON c.codigo_categoria = h.codigo_categoria
WHERE h.año_construccion = (SELECT MAX(año_construccion) FROM hoteles);

/* En este caso he tenido que poner una subconsutla dentro de la condición del WHERE que buscase el valor máximo
dentro del atributo año_construccion de la tabla hoteles, que sería el de más reciente construcción y con ello, con la 
consulta general obentemos la categoría.*/

    -- f) Vista de la habitación más cara de cada hotel.

CREATE OR REPLACE VIEW precio_maximo_habitacion AS
SELECT ha.codigo_habitacion, ha.numero_habitacion, h.nombre_hotel, t.tipo_habitacion, r.precio
FROM habitaciones ha
JOIN reservas r ON ha.codigo_habitacion = r.codigo_habitacion
JOIN hoteles h ON ha.codigo_hotel = h.codigo_hotel
JOIN tipos_habitaciones t ON ha.codigo_tipo_habitacion = t.codigo_tipo_habitacion
WHERE r.precio = (SELECT MAX(r2.precio) 
FROM reservas r2
JOIN habitaciones ha2 ON r2.codigo_habitacion = ha2.codigo_habitacion
WHERE ha2.codigo_hotel = ha.codigo_hotel);

/* He tomado la habitación más cara de cada hotel obteniendo el precio máximo de la tabla reservas por cada hotel, 
ya que se trata del único lugar donde aparecen los precios.
El uso de subconsultas correlacionadas, en las que la subconsulta puede utilizar atributos de la consulta 
exterior ha sido la clave para poder afrontar la vista.*/

    -- g) Vista de la reserva más reciente realizada por particulares.

CREATE OR REPLACE VIEW reserva_mas_reciente_particular AS
SELECT r.codigo_reserva, r.nombre_reserva, r.telefono, r.direccion, r.fecha_entrada, r.fecha_salida, r.precio, 
h.nombre_hotel, ha.numero_habitacion, th.tipo_habitacion
FROM habitaciones ha
JOIN reservas r ON ha.codigo_habitacion = r.codigo_habitacion
JOIN hoteles h ON ha.codigo_hotel = h.codigo_hotel
JOIN tipos_habitaciones th ON  ha.codigo_tipo_habitacion = th.codigo_tipo_habitacion
JOIN tipos_reservas tr ON r.codigo_tipo_reserva = tr.codigo_tipo_reserva
WHERE r.fecha_entrada = (SELECT MAX(fecha_entrada) FROM reservas r2 
JOIN tipos_reservas t ON r2.codigo_tipo_reserva = t.codigo_tipo_reserva
WHERE t.tipo_reserva = 'PARTICULAR') AND tr.tipo_reserva = 'PARTICULAR';

/* Una vez conociendo la aplicación de las subconsultas y, sus dos variantes escalar y correlacionada, esta vista me llevó muy poco 
tiempo hacerla. En este caso centré el objetivo en la fecha de entrada a través de la subconsulta con MAX(fecha_entrada) y filtrándola 
por el tipo de reserva PARTICULAR. Sin embargo, al poner una misma fecha a una reserva de tipo agencia, la consulta arrojaba ambas, por
lo que comprendí que el filtro de PARTICULAR dentro de la subconsulta no era suficiente para asegurar que la consulta externa filtrase 
de la misma forma. Por lo que tuve que añadir el filtro de PARTICULAR a la consulta externa, lo que ya sí garantizaba que la vista 
arroje solo una reserva de tipo PARTICULAR. Esto es lo que más me costó ver de esta vista.
He elegido la fecha de entrada y no la de salida porque para mí tiene más sentido utilizar las entradas como reserva, es decir, normalmente
no reservamos la salida sino más bien la entrada y cuántos días nos quedamos.*/

    -- h) Vista de la agencia de viaje con la reserva más económica.

CREATE OR REPLACE VIEW agencia_reserva_economica AS
SELECT r.nombre_reserva, r.codigo_reserva, r.telefono, r.direccion, r.fecha_entrada, r.fecha_salida, r.precio, h.nombre_hotel, 
ha.numero_habitacion, th.tipo_habitacion, r.nombre_cliente_agencia 
FROM habitaciones ha
JOIN reservas r ON ha.codigo_habitacion = r.codigo_habitacion
JOIN hoteles h ON ha.codigo_hotel = h.codigo_hotel
JOIN tipos_habitaciones th ON ha.codigo_tipo_habitacion = th.codigo_tipo_habitacion
JOIN tipos_reservas tr ON r.codigo_tipo_reserva = tr.codigo_tipo_reserva
WHERE r.precio = (SELECT MIN(r2.precio) FROM reservas r2 
JOIN tipos_reservas tr2 ON r2.codigo_tipo_reserva = tr2.codigo_tipo_reserva
WHERE tr2.tipo_reserva = 'AGENCIA') AND tr.tipo_reserva = 'AGENCIA';

/* En este caso, he seguido el patrón de la vista anterior, centrándome en una subconsulta escalar para obtener le precio mínimo, y filtrarlo 
por agencia. Como en el caso anterior, me curo en salud y también filtro por agencia en la consulta externa.*/


-- 4.- Crear una función para calcular el promedio de precios de reserva para un tipo de habitación específico en un hotel determinado.

CREATE FUNCTION media_precio_habitacion_hotel (codigo_tipo_habitacion INTEGER, codigo_hotel INTEGER)
RETURN NUMBER AS
v_media_precios NUMBER (10,2);
BEGIN
    SELECT AVG(r.precio) INTO v_media_precios
    FROM reservas r
    JOIN habitaciones ha ON r.codigo_habitacion = ha.codigo_habitacion
    JOIN hoteles h ON ha.codigo_hotel = h.codigo_hotel
    WHERE ha.codigo_tipo_habitacion = codigo_tipo_habitacion AND h.codigo_hotel = codigo_hotel;
    RETURN v_media_precios;  
END;

/* En este caso, hay un poco menos que explicar, creamos la función utilizando los parámetros codigo_tipo_habitacion y codigo_hotel,
para ceñirnos al enunciado.
Declaramos una variable para almacenar en ella la media. Por último buscamos, por medio de un SELECT, el promedio de los precios que 
cumplan la condición WHERE y lo almacenamos en la variable v_media_precios, la cual pedimos que se devuleva al final del bloque.*/

-- 5.- Crear una función que obtenga la lista de hoteles que tienen una cantidad mínima de habitaciones disponibles para reservar.
/
CREATE OR REPLACE FUNCTION lista_hoteles_habitaciones_disponibles (fecha_inicio_solicitada DATE, fecha_fin_solicitada DATE, 
cantidad_minima INTEGER)
RETURN SYS_REFCURSOR
AS
    v_cursor SYS_REFCURSOR;
    v_fecha_inicio DATE;
    v_fecha_fin DATE;
    v_minimo INTEGER;
BEGIN
    v_fecha_inicio := fecha_inicio_solicitada;
    v_fecha_fin := fecha_fin_solicitada;
    v_minimo := cantidad_minima;
OPEN v_cursor FOR 
SELECT COUNT(ha.codigo_habitacion), h.nombre_hotel
FROM habitaciones ha
JOIN hoteles h ON ha.codigo_hotel = h.codigo_hotel
WHERE NOT EXISTS(SELECT codigo_reserva
FROM reservas r2
WHERE ha.codigo_habitacion = r2.codigo_habitacion AND
(r2.fecha_entrada < v_fecha_fin AND r2.fecha_salida > v_fecha_inicio))
GROUP BY h.nombre_hotel
HAVING COUNT(ha.codigo_habitacion) >= v_minimo;
RETURN v_cursor;
END;
/
/*  
Esta función devuelve un cursor como forma de devolver una lista de resultados desde la propia función.  
La función recibe un rango de fechas y una cantidad mínima, y mediante una subconsulta con NOT EXISTS se comprueba qué 
habitaciones no tienen reservas que se solapen con ese rango. Posteriormente se agrupan las habitaciones por hotel y se 
filtran aquellos que tienen al menos el número mínimo solicitado de habitaciones disponibles.  

De esta forma, la función permite obtener la lista de hoteles que cumplen la condición indicada en el 
enunciado.  
*/

