-- PROYECTO CAPSTONE: ANALISIS DE DATOS DE UNA TIENDA ONLINE
-- Herramienta: PostgreSQL
--
-- Objetivo:
-- Analizar las ventas de una tienda online para identificar
-- clientes de mayor gasto, evolucion mensual de ventas,
-- productos menos vendidos y pedidos destacados por categoria.
--
-- Antes de analizar, revisamos los datos faltantes para evitar
-- conclusiones incorrectas por problemas de calidad de datos.
-- ============================================================


-- ============================================================
-- 1. IDENTIFICACION DE PEDIDOS CON DATOS FALTANTES
-- ============================================================

-- Buscamos pedidos que no tienen precio unitario o fecha.
-- Estos campos son importantes porque el precio permite calcular
-- ingresos y la fecha permite estudiar la evolucion mensual.
-- No eliminamos los registros: primero necesitamos identificarlos
-- para decidir como tratarlos sin perder informacion.

SELECT *
FROM pedidos
WHERE precio_unitario IS NULL
   OR fecha IS NULL;


-- ============================================================
-- 2. CUANTIFICACION DE LOS DATOS FALTANTES
-- ============================================================

-- Contamos el total de pedidos y la cantidad de registros
-- que presentan problemas de precio o fecha.
-- FILTER permite contar cada tipo de problema por separado.
-- Esto ayuda a medir la calidad del dataset antes del analisis.

SELECT
    COUNT(*) AS total_pedidos,

    -- Cuenta los pedidos que no tienen precio unitario.
    COUNT(*) FILTER (
        WHERE precio_unitario IS NULL
    ) AS precios_faltantes,

    -- Cuenta los pedidos que no tienen fecha registrada.
    COUNT(*) FILTER (
        WHERE fecha IS NULL
    ) AS fechas_faltantes

FROM pedidos;


-- ============================================================
-- 3. REVISION DE PRECIOS FALTANTES CON COALESCE
-- ============================================================

-- COALESCE devuelve el primer valor que no sea NULL.
-- En este caso, muestra cero cuando el precio esta ausente.
-- El objetivo es practicar el tratamiento de valores faltantes
-- y visualizar un valor alternativo para facilitar la revision.
--
-- IMPORTANTE:
-- El cero es provisional y no significa que el producto haya
-- sido vendido gratis. Esta consulta no modifica la tabla original.

SELECT
    id_pedido,
    precio_unitario,

    -- Si el precio es NULL, muestra cero como valor provisional.
    COALESCE(precio_unitario, 0) AS precio_corregido

FROM pedidos;


-- ============================================================
-- 4. REVISION DE FECHAS FALTANTES CON COALESCE
-- ============================================================

-- Revisamos los pedidos sin fecha.
-- Se utiliza una fecha de referencia para mostrar un valor
-- alternativo cuando la fecha original es NULL.
--
-- IMPORTANTE:
-- 1900-01-01 no es la fecha real de la compra.
-- Solo sirve para visualizar el reemplazo y no debe utilizarse
-- como fecha valida en el analisis mensual de ventas.

SELECT
    id_pedido,
    fecha,

    -- Si no existe fecha, muestra una fecha de referencia.
    COALESCE(
        fecha,
        DATE '1900-01-01'
    ) AS fecha_revisada

FROM pedidos;


-- ============================================================
-- 5. CALCULO DEL IMPORTE DE CADA PEDIDO
-- ============================================================

-- Calculamos el importe multiplicando las unidades compradas
-- por el precio unitario.
-- Este indicador permite conocer el valor de cada operacion
-- antes de agrupar los resultados por cliente o por mes.
--
-- Si el precio es NULL, el importe tambien sera NULL.
-- Por eso, los importes incompletos deben revisarse antes
-- de utilizarlos como ingresos confirmados.

SELECT
    id_pedido,
    cantidad,
    precio_unitario,

    -- Calcula el importe total de la linea del pedido.
    cantidad * precio_unitario AS importe_total

FROM pedidos;


-- ============================================================
-- 6. TOP 5 CLIENTES POR GASTO TOTAL
-- ============================================================

-- Queremos identificar a los clientes que acumulan mayor gasto.
-- Para hacerlo, relacionamos clientes con pedidos mediante JOIN.
-- Filtramos precios faltantes porque no podemos confirmar
-- el importe de esos pedidos.
--
-- SUM calcula el gasto acumulado de cada cliente.
-- GROUP BY agrupa sus pedidos para obtener un total individual.
-- ORDER BY DESC ordena desde el gasto mas alto al mas bajo.
-- LIMIT 5 devuelve los cinco clientes con mayor gasto registrado.
--
-- La suma representa importes conocidos, por lo que podria
-- subestimar el gasto real de un cliente con precios faltantes.
-- Suma el importe de los pedidos con precio conocido.
-- Relaciona cada pedido con el cliente que lo realizo.
-- Excluye los pedidos cuyo precio no esta informado.
-- Agrupa por identificador y nombre para obtener un total
-- independiente para cada cliente.
-- Presenta primero a los clientes con mayor gasto.
-- Limita el resultado a los cinco primeros clientes.

SELECT
    c.id_cliente,
    c.nombre,
    SUM(p.cantidad * p.precio_unitario) AS gasto_total
FROM clientes AS c
JOIN pedidos AS p
    ON c.id_cliente = p.id_cliente
    WHERE p.precio_unitario IS NOT NULL
GROUP BY
    c.id_cliente,
    c.nombre
ORDER BY gasto_total DESC
LIMIT 5;

-- ============================================================
-- 7. VENTAS TOTALES POR MES
-- ============================================================

-- Analizamos como se distribuyen las ventas a lo largo del tiempo.
-- DATE_TRUNC agrupa las fechas por mes, sin distinguir cada dia.
-- SUM calcula los ingresos de los pedidos con precio conocido.
--
-- Se excluyen las fechas NULL porque no es posible asignar
-- esos pedidos a un mes real.
-- Tambien se excluyen precios NULL para no informar importes
-- incompletos como si fueran ventas confirmadas.
SELECT
    DATE_TRUNC('month', fecha)::DATE AS mes,
    SUM(cantidad * precio_unitario) AS ventas_totales
FROM pedidos
WHERE fecha IS NOT NULL
GROUP BY DATE_TRUNC('month', fecha)::DATE
ORDER BY mes;

-- ============================================================
-- 8. IDENTIFICACION DE LOS TRES PRODUCTOS MENOS VENDIDOS
-- ============================================================

-- Buscamos los productos con menor cantidad de unidades vendidas.
-- LEFT JOIN permite conservar todos los productos del catalogo,
-- incluso aquellos que no tengan ningun pedido.
-- SUM calcula las unidades vendidas de cada producto.
-- COALESCE convierte el resultado NULL en cero cuando no hay
-- ventas asociadas.
--
-- Ordenamos de menor a mayor para identificar los productos
-- con menor movimiento comercial.
SELECT
    pr.id_producto,
    pr.nombre_producto,
    COALESCE(SUM(p.cantidad), 0) AS unidades_vendidas
FROM productos AS pr
LEFT JOIN pedidos AS p
    ON pr.id_producto = p.id_producto
GROUP BY
    pr.id_producto,
    pr.nombre_producto
ORDER BY unidades_vendidas ASC, pr.nombre_producto ASC
LIMIT 3;

-- ============================================================
-- 9. RANKING DE PEDIDOS POR CATEGORIA
-- ============================================================

-- Comparamos los importes de los pedidos dentro de cada categoria.
-- JOIN permite obtener la categoria definida en el catalogo
-- de productos, evitando depender de la categoria duplicada
-- que tambien existe en la tabla pedidos.
--
-- RANK es una funcion de ventana que asigna posiciones segun
-- el importe de cada pedido dentro de su categoria.
-- PARTITION BY reinicia el ranking para cada categoria.
-- Los empates reciben la misma posicion.
--
-- Excluimos precios NULL porque su importe es desconocido.

SELECT
    id_pedido,
    categoria,
    cantidad * precio_unitario AS importe_total,
    RANK() OVER (
        PARTITION BY categoria
        ORDER BY cantidad * precio_unitario DESC
    ) AS ranking_categoria
FROM pedidos
WHERE precio_unitario IS NOT NULL
ORDER BY categoria, ranking_categoria;

-- ============================================================
-- 10. PRODUCTOS QUE NO REGISTRAN VENTAS
-- ============================================================

-- Identificamos productos sin unidades vendidas.
-- LEFT JOIN conserva todos los productos, incluso los que
-- no tienen pedidos asociados.
-- SUM calcula las unidades vendidas y COALESCE devuelve cero
-- cuando no existen cantidades para un producto.
--
-- HAVING filtra despues de la agrupacion y permite seleccionar
-- productos cuyo total de unidades vendidas es igual a cero.
-- El resultado ayuda a detectar productos sin movimiento.
SELECT
    pr.nombre_producto,
    COALESCE(SUM(p.cantidad), 0) AS unidades_vendidas
FROM productos AS pr
LEFT JOIN pedidos AS p
    ON pr.id_producto = p.id_producto
GROUP BY
    pr.id_producto,
    pr.nombre_producto
HAVING COALESCE(SUM(p.cantidad), 0) = 0;

-- ============================================================
-- 11. CLASIFICACION DE PEDIDOS CON DATOS INCOMPLETOS
-- ============================================================

-- Clasificamos los registros segun la presencia de fecha y precio.
-- CASE evalua las condiciones en orden y devuelve una etiqueta.
-- Primero comprobamos si faltan ambos campos; luego revisamos
-- cada campo individualmente.
--
-- El filtro final muestra unicamente los pedidos que necesitan
-- revision, facilitando la identificacion de errores de calidad.

SELECT
    id_pedido,
    fecha,
    cantidad,
    precio_unitario,
    CASE
        WHEN fecha IS NULL AND precio_unitario IS NULL
            THEN 'Faltan fecha y precio'
        WHEN fecha IS NULL
            THEN 'Falta fecha'
        WHEN precio_unitario IS NULL
            THEN 'Falta precio'
        ELSE 'Datos completos'
    END AS estado_datos
FROM pedidos
WHERE fecha IS NULL
   OR precio_unitario IS NULL;

-- ============================================================
-- FIN DEL ANALISIS
-- ============================================================
-- Las consultas permiten revisar la calidad de los datos,
-- calcular indicadores de ventas, comparar clientes y productos
-- y aplicar funciones de agregacion y funciones avanzadas.
--
-- Los resultados deben interpretarse teniendo en cuenta que
-- el dataset es ficticio y que los precios y fechas faltantes
-- pueden limitar las conclusiones del negocio.
-- ============================================================