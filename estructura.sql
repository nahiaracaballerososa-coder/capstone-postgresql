-- ============================================================
-- PROYECTO CAPSTONE: ANALISIS DE DATOS DE UNA TIENDA ONLINE
-- Herramienta: PostgreSQL
--
-- Objetivo:
-- Crear una base de datos que permita analizar las ventas
-- de una tienda online ficticia.
--
-- Se busca identificar clientes con mayor gasto, analizar
-- las ventas por mes y comparar el rendimiento de los productos.
--
-- Se incluyen algunos valores NULL para practicar la limpieza
-- de datos y comprender como afectan los resultados del analisis.
-- ============================================================
-- ============================================================
-- 1. CREACION DE LA BASE DE DATOS
-- ============================================================

-- Creamos una base de datos independiente para el proyecto.
-- Esto permite mantener organizadas las tablas y los datos
-- utilizados durante el analisis.

CREATE DATABASE capstone_project;

-- ============================================================
-- 2. CREACION DE LA TABLA CLIENTES
-- ============================================================

-- Almacenamos la informacion de los clientes.
-- Esta tabla permite relacionar cada compra con la persona
-- que la realizo y calcular su gasto acumulado.
--
-- id_cliente: identificador unico de cada cliente.
-- nombre: es obligatorio para poder identificar al cliente.
-- email: puede ser NULL porque el correo no siempre esta
-- disponible al momento de registrar un cliente.

CREATE TABLE clientes (
    id_cliente INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150)
);

-- ============================================================
-- 3. CREACION DE LA TABLA PRODUCTOS
-- ============================================================

-- Registramos los productos disponibles en la tienda.
-- La categoria permite agrupar los articulos para comparar
-- su rendimiento comercial.
--
-- id_producto: identifica de forma unica cada producto.
-- nombre_producto: evita que existan productos sin nombre.
-- categoria: permite analizar las ventas por tipo de producto.
--
-- Utilizamos NOT NULL en nombre y categoria porque ambos
-- campos son necesarios para interpretar el catalogo.

CREATE TABLE productos (
    id_producto INTEGER PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL
);

-- ============================================================
-- 4. CREACION DE LA TABLA PEDIDOS
-- ============================================================

-- Registramos las operaciones de compra de la tienda.
-- Esta tabla conecta clientes y productos para poder analizar
-- cuanto compra cada cliente y que productos se venden mas.
--
-- id_pedido: identifica de forma unica cada pedido.
-- id_cliente: relaciona el pedido con un cliente existente.
-- id_producto: relaciona el pedido con un producto existente.
-- fecha: permite analizar la evolucion mensual de las ventas.
-- cantidad: indica cuantas unidades se compraron.
-- precio_unitario: permite calcular el importe de cada pedido.
-- categoria: se incluye para practicar el analisis por categoria.
--
-- Las claves foraneas REFERENCES evitan registrar pedidos
-- asociados a clientes o productos que no existen.
--
-- DATE permite trabajar con fechas y NUMERIC(10,2) almacena
-- precios con dos decimales para realizar calculos monetarios.
--
-- Fecha y precio_unitario admiten NULL intencionalmente para
-- simular datos incompletos que luego revisaremos en analisis.sql.

CREATE TABLE pedidos (
    id_pedido INTEGER PRIMARY KEY,
    id_cliente INTEGER NOT NULL REFERENCES clientes(id_cliente),
    id_producto INTEGER NOT NULL REFERENCES productos(id_producto),
    fecha DATE,
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(10, 2),
    categoria VARCHAR(50)
);

-- ============================================================
-- 5. CARGA DE DATOS DE CLIENTES
-- ============================================================

-- Insertamos seis clientes ficticios.
-- Estos datos permiten practicar la relacion entre clientes
-- y pedidos y calcular el gasto acumulado por persona.
--
-- El correo de Sofia Diaz se deja como NULL para representar
-- un dato de contacto faltante y practicar su identificacion.
-- No se inventa un correo porque no conocemos el valor real.
INSERT INTO clientes (id_cliente, nombre, email) VALUES
(1, 'Ana Perez', 'ana@email.com'),
(2, 'Luis Gomez', 'luis@email.com'),
(3, 'Maria Lopez', 'maria@email.com'),
(4, 'Juan Torres', 'juan@email.com'),
(5, 'Sofia Diaz', NULL),
(6, 'Pedro Ruiz', 'pedro@email.com');

-- ============================================================
-- 6. CARGA DE DATOS DE PRODUCTOS
-- ============================================================

-- Insertamos seis productos de distintas categorias.
-- La variedad permite comparar las unidades vendidas y los
-- importes de los pedidos entre Tecnologia, Hogar, Accesorios
-- y Libreria.
--
-- Los identificadores permiten vincular cada producto con
-- los pedidos correspondientes mediante id_producto.
INSERT INTO productos (id_producto, nombre_producto, categoria) VALUES
(1, 'Auriculares', 'Tecnologia'),
(2, 'Teclado', 'Tecnologia'),
(3, 'Taza', 'Hogar'),
(4, 'Mochila', 'Accesorios'),
(5, 'Cuaderno', 'Libreria'),
(6, 'Mouse', 'Tecnologia');

-- ============================================================
-- 7. CARGA DE DATOS DE PEDIDOS
-- ============================================================

-- Insertamos quince pedidos ficticios realizados entre enero
-- y junio de 2026.
--
-- Cada registro relaciona un cliente con un producto e informa
-- la fecha, la cantidad y el precio unitario cuando se conocen.
--
-- Estos datos permiten calcular importes, comparar clientes,
-- agrupar ventas por mes y construir rankings por categoria.
--
-- Se incluyen dos casos incompletos de manera intencional:
-- - Pedido 12: precio_unitario es NULL.
-- - Pedido 14: fecha es NULL.
--
-- Estos casos permiten practicar la deteccion de valores
-- faltantes y evaluar su impacto en los indicadores.
--
-- Los valores NULL no deben interpretarse como cero ni como
-- una fecha real: requieren revision antes de tomar decisiones.
INSERT INTO pedidos
(id_pedido, id_cliente, id_producto, fecha, cantidad, precio_unitario, categoria)
VALUES
(1, 1, 1, '2026-01-10', 2, 15000, 'Tecnologia'),
(2, 2, 2, '2026-01-15', 1, 12000, 'Tecnologia'),
(3, 1, 3, '2026-02-05', 3, 3000, 'Hogar'),
(4, 3, 4, '2026-02-12', 1, 25000, 'Accesorios'),
(5, 4, 5, '2026-03-02', 2, 2000, 'Libreria'),
(6, 2, 1, '2026-03-10', 1, 15000, 'Tecnologia'),
(7, 5, 6, '2026-03-18', 2, 8000, 'Tecnologia'),
(8, 1, 2, '2026-04-01', 1, 12000, 'Tecnologia'),
(9, 3, 3, '2026-04-07', 2, 3000, 'Hogar'),
(10, 6, 4, '2026-04-20', 1, 25000, 'Accesorios'),
(11, 4, 6, '2026-05-03', 1, 8000, 'Tecnologia'),
(12, 5, 5, '2026-05-15', 3, NULL, 'Libreria'),
(13, 2, 3, '2026-05-20', 1, 3000, 'Hogar'),
(14, 6, 1, NULL, 1, 15000, 'Tecnologia'),
(15, 3, 5, '2026-06-02', 1, 2000, 'Libreria');
