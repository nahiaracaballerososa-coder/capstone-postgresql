Proyecto Capstone: Análisis de Datos de una Tienda Online con PostgreSQL
Alumna: Caballero Sosa Nahiara
1. Descripción del proyecto

Este proyecto consiste en realizar un análisis exploratorio de datos (EDA) de una tienda online ficticia utilizando PostgreSQL y SQL.

El objetivo es transformar los datos de clientes, productos y pedidos en información útil para comprender el comportamiento de las ventas, identificar a los clientes que generan mayor gasto y detectar oportunidades de mejora en el negocio.

Durante el desarrollo se aplican conceptos fundamentales de SQL, como relaciones entre tablas, consultas de limpieza de datos, funciones de agregación, funciones de fecha, expresiones condicionales y funciones de ventana.

El dataset fue creado con fines educativos y contiene información ficticia.

2. Problema de negocio

Una tienda online necesita comprender mejor el comportamiento de sus ventas para tomar decisiones comerciales fundamentadas.

Para ello, se plantea analizar las operaciones registradas y responder las siguientes preguntas:

¿Qué clientes acumulan el mayor gasto en la tienda?
¿Cómo evolucionan las ventas a lo largo de los meses?
¿Cuáles son los productos con menor cantidad de unidades vendidas?
¿Qué pedidos generan los mayores importes dentro de cada categoría?
¿Existen productos que no registran ventas?
¿Qué problemas de calidad presentan los datos y cómo pueden afectar los resultados?

Las respuestas permiten identificar clientes de mayor valor, comparar periodos de venta, estudiar el movimiento de los productos y evaluar la confiabilidad de la información utilizada.

3. Tecnologías utilizadas
PostgreSQL: sistema de gestión de bases de datos relacionales.
SQL: lenguaje utilizado para crear las tablas, cargar los datos y realizar el análisis.
pgAdmin: herramienta opcional para administrar la base de datos y ejecutar las consultas.
GitHub: plataforma utilizada para publicar y documentar el proyecto.
4. Estructura de la base de datos

La base de datos se denomina capstone_project y contiene tres tablas relacionadas.

Tabla	Descripción
clientes	Almacena el identificador, el nombre y el correo electrónico de cada cliente.
productos	Contiene el identificador, el nombre y la categoría de cada producto.
pedidos	Registra los pedidos, el cliente, el producto, la fecha, la cantidad y el precio unitario.
Relaciones entre las tablas

La tabla pedidos contiene las claves foráneas id_cliente e id_producto, que permiten relacionar cada operación con el cliente y el producto correspondientes.

Se utilizan claves primarias (PRIMARY KEY) para identificar de forma única los registros y claves foráneas (REFERENCES) para mantener la integridad de las relaciones.

Tipos de datos

Se seleccionaron tipos de datos adecuados para cada campo:

INTEGER: identificadores y cantidades.
VARCHAR: nombres, correos electrónicos y categorías.
DATE: fechas de los pedidos.
NUMERIC(10,2): precios unitarios con precisión decimal.

La elección de estos tipos facilita el almacenamiento y el procesamiento de la información.

5. Dataset utilizado

El conjunto de datos está compuesto por:

6 clientes.
6 productos.
15 pedidos.
Un periodo de operaciones comprendido entre enero y junio de 2026, con un pedido cuya fecha no está informada.

Los datos son ficticios y fueron creados para simular distintas compras de una tienda online.

Se incluyeron algunos valores faltantes intencionales para practicar la detección de problemas de calidad y analizar sus posibles consecuencias.

6. Limpieza y preparación de los datos

Antes de analizar las ventas, se revisaron los campos críticos de la tabla pedidos, especialmente el precio unitario y la fecha.

Identificación de valores faltantes

Se utilizaron IS NULL, COUNT(*) y FILTER para identificar y cuantificar los registros incompletos.

Se encontraron dos situaciones:

El pedido 12 no tiene informado el precio unitario.
El pedido 14 no tiene informada la fecha.

Además, uno de los clientes no tiene registrado su correo electrónico. Este campo no impide calcular las ventas, aunque sería relevante para futuras acciones de comunicación comercial.

Tratamiento de valores nulos con COALESCE

Se aplicó COALESCE para mostrar valores alternativos cuando un campo contiene NULL.

En el caso del precio unitario, se utilizó cero como valor provisional para visualizar cómo podría tratarse un dato faltante. Sin embargo, un precio desconocido no significa que el producto se haya vendido gratuitamente.

Para las fechas se utilizó una fecha de referencia (1900-01-01) con fines de revisión. Este valor no representa la fecha real del pedido y no debe utilizarse para calcular las ventas mensuales.

Estas consultas no modifican los registros originales de la base de datos: únicamente muestran valores alternativos en los resultados.

Criterios aplicados al análisis

Para evitar distorsionar los indicadores comerciales:

Se excluyeron los pedidos sin precio conocido del cálculo de ingresos confirmados.
Se excluyeron las fechas nulas del análisis mensual.
Se utilizó COALESCE para mostrar cero unidades cuando un producto no tiene pedidos asociados.
Se utilizó CASE para clasificar los registros que presentan problemas de calidad.

La corrección definitiva de los datos faltantes requeriría verificar la información original del negocio.

7. Análisis SQL y resultados

Se desarrollaron consultas para responder las preguntas de negocio planteadas.

7.1. Top 5 clientes por gasto total

Se combinaron las tablas clientes y pedidos mediante JOIN. Después se utilizó SUM() para calcular el gasto acumulado de cada cliente, GROUP BY para agrupar sus compras y ORDER BY para ordenar los resultados de mayor a menor.

Los pedidos sin precio conocido se excluyeron del cálculo.

Resultados obtenidos:

Posición	Cliente	Gasto registrado e interpretacion 
Ana Perez presenta el mayor gasto acumulado, con 51.000 unidades monetarias, seguida por Pedro Ruiz, con 40.000, y Maria Lopez, con 33.000. 

Estos resultados permiten identificar clientes de mayor valor para evaluar estrategias de fidelización, promociones personalizadas y acciones de retención.

Sin embargo, el gasto acumulado no demuestra por sí solo la lealtad del cliente. Para medirla de manera más completa sería necesario analizar la frecuencia de compra, la antigüedad y el tiempo transcurrido desde el último pedido.

Los importes representan el gasto registrado con precios conocidos y podrían estar subestimados si existen compras cuyo precio todavía no fue validado.

7.2. Ventas totales por mes

Se utilizó DATE_TRUNC('month', fecha) para agrupar las operaciones por mes calendario y SUM() para calcular el importe total de las ventas con fecha y precio conocidos.

Resultados obtenidos:

Mes	Ventas registradas
Enero de 2026	42.000
Febrero de 2026	34.000
Marzo de 2026	35.000
Abril de 2026	43.000
Mayo de 2026	11.000
Junio de 2026	2.000

Interpretación de negocio

Abril presenta el mayor importe de ventas registradas, con 43.000 unidades monetarias, seguido por enero, con 42.000.

En cambio, junio presenta el menor importe registrado, con 2.000. No obstante, junio cuenta con un solo pedido en el dataset, por lo que no sería correcto concluir que existe una tendencia de caída sostenida.

Los resultados permiten comparar el desempeño de los periodos incluidos y plantear nuevas preguntas sobre las causas de las diferencias mensuales.

Para realizar una evaluación comercial más sólida sería necesario contar con un periodo más extenso y un mayor volumen de operaciones.

7.3. Los tres productos menos vendidos

Se utilizó LEFT JOIN para conservar todos los productos del catálogo, incluso aquellos sin pedidos asociados. Luego se sumaron las cantidades vendidas y se aplicó COALESCE para representar con cero los productos sin ventas.

Resultados obtenidos:

Producto	Unidades vendidas
Mochila	        2
Teclado	        2
Mouse	        3

Interpretación de negocio

Mochila y Teclado registran el menor volumen de unidades vendidas, con dos unidades cada uno. Mouse registra tres unidades.

Esta información permite identificar productos que podrían requerir una revisión de su demanda, visibilidad comercial o estrategia de promoción.

Sin embargo, vender menos unidades no significa necesariamente que un producto sea poco rentable. Antes de tomar decisiones sobre el catálogo, sería conveniente analizar los márgenes de ganancia, los costos, el inventario disponible y la demanda histórica.

7.4. Ranking de pedidos por categoría

Se utilizó RANK() como función de ventana para ordenar los pedidos por importe dentro de cada categoría.

La consulta obtiene la categoría desde la tabla productos mediante un JOIN, y excluye los pedidos cuyo precio no está informado.

Interpretación de negocio

El ranking permite identificar los pedidos de mayor importe en Tecnología, Hogar, Accesorios y Librería.

Esta información puede utilizarse para estudiar qué operaciones concentran mayor valor dentro de cada categoría y orientar futuras investigaciones comerciales.

A diferencia de una consulta que agrupa todos los pedidos por categoría, RANK() conserva el detalle de cada pedido y asigna posiciones. Si dos pedidos tienen el mismo importe dentro de una categoría, ambos reciben la misma posición.

7.5. Identificación de productos sin ventas

Se utilizó LEFT JOIN, SUM() y HAVING para detectar productos que no registran unidades vendidas.

Resultado obtenido

La consulta no devuelve filas porque los seis productos del dataset tienen al menos una venta registrada.

Interpretación de negocio

El resultado indica que no hay productos completamente sin movimiento comercial dentro de la muestra analizada.

Aunque es un resultado válido, no significa que todos los productos tengan un buen desempeño: algunos presentan un volumen de ventas menor que otros.

7.6. Clasificación de pedidos con datos incompletos

Se utilizó CASE para asignar una etiqueta a los pedidos según la presencia o ausencia de fecha y precio.

Resultados obtenidos:

Pedido 12: falta el precio unitario.
Pedido 14: falta la fecha.

Interpretación de negocio

La clasificación facilita la identificación de registros que necesitan revisión y demuestra la importancia de controlar la calidad de los datos antes de utilizar los resultados para tomar decisiones.

Los valores faltantes deben investigarse y corregirse a partir de información confiable, en lugar de asumir valores que podrían alterar los indicadores.

8. Principales conclusiones

El análisis permitió identificar diferencias en el gasto acumulado de los clientes, comparar los importes de ventas por mes y detectar productos con menor volumen de unidades vendidas.

Los principales hallazgos son:

Ana Perez es la clienta con mayor gasto registrado, con 37.000 unidades monetarias.
Abril es el mes con mayor importe de ventas registradas, con 43.000.
Mochila y Teclado presentan el menor volumen de unidades vendidas, con dos unidades cada uno.
Todos los productos del catálogo tienen al menos una venta registrada.
Se identificaron dos pedidos con información faltante: uno sin precio y otro sin fecha.

Estos resultados muestran cómo las consultas SQL pueden transformar datos operativos en indicadores útiles para analizar el negocio.

No obstante, las conclusiones deben interpretarse teniendo en cuenta que el dataset es ficticio, pequeño y contiene registros incompletos. Por ello, los resultados son demostrativos y no representan el desempeño de una tienda real.

9. Recomendaciones de negocio

A partir de los resultados, se proponen las siguientes acciones:

Fidelización: estudiar el comportamiento de los clientes con mayor gasto para diseñar acciones de retención.
Seguimiento de ventas: investigar las diferencias entre los meses con mayor y menor facturación registrada.
Análisis de productos: evaluar la demanda, los márgenes y el inventario de los artículos con menor volumen de ventas.
Calidad de datos: validar los precios y las fechas faltantes antes de generar informes definitivos.
Ampliación del análisis: incorporar más datos y métricas, como costos, márgenes, devoluciones y frecuencia de compra.

Estas recomendaciones son líneas de investigación que deberían validarse con datos adicionales antes de tomar decisiones comerciales reales.

10. Estructura del repositorio

El repositorio de GitHub contiene los siguientes archivos:

text
capstone-postgresql/
├── estructura.sql
├── analisis.sql
└── README.md

estructura.sql: crea las tablas, define las relaciones e inserta los datos ficticios.
analisis.sql: contiene las consultas de limpieza y análisis, con comentarios que explican las decisiones tomadas.
README.md: documenta el problema de negocio, la metodología, los resultados y las instrucciones de ejecución.
11. Aprendizajes del proyecto

Este proyecto permitió aplicar conceptos fundamentales de SQL y PostgreSQL en un caso práctico de análisis de ventas.

Se utilizaron relaciones entre tablas con JOIN, agregaciones con GROUP BY y SUM(), funciones de fecha con DATE_TRUNC(), funciones de ventana con RANK() y expresiones condicionales con CASE.

También se practicó la detección de valores faltantes y el uso de COALESCE para mostrar valores alternativos durante la revisión de los datos.

La principal enseñanza es que el análisis de datos no consiste únicamente en ejecutar consultas: también requiere comprender la calidad de la información, interpretar los resultados y reconocer sus limitaciones antes de formular recomendaciones.

