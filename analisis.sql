
-- ANALISIS DE NEGOCIO --

-- CONSULTA 1: TOP 5 CLIENTES
-- Se calcula el gasto total de cada cliente a partir de sus pedidos y productos comprados, para identificar a los 5 clientes que realizaron el mayor gasto. Este análisis permite reconocer a los clientes de mayor valor para el negocio y puede servir como punto de partida para analizar estrategias de fidelización y retención.

SELECT
	c.customer_unique_id AS id_customer,
	SUM(COALESCE(oi.price, 0)) AS gasto_total
FROM capstone_project.customers AS c
JOIN capstone_project.orders AS o 
	USING(customer_id)
JOIN capstone_project.order_items AS oi
	USING(order_id)
GROUP BY c.customer_unique_id
ORDER BY gasto_total DESC
LIMIT 5;

-- CONSULTA 2: ESTACIONALIDAD DE VENTAS
-- La idea es usar order_purchase_timestamp para agrupar las ventas por mes y ver cómo evolucionó el volumen de ventas a lo largo del año. En términos de negocio, nos permite identificar meses con mayor o menor nivel de ventas, detectar posibles patrones de estacionalidad y entender mejor el comportamiento de la demanda

SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS mes,
    SUM(COALESCE(oi.price, 0)) AS ingresos_totales
FROM capstone_project.orders AS o
JOIN capstone_project.order_items AS oi
    USING (order_id)
GROUP BY EXTRACT (MONTH FROM o.order_purchase_timestamp)
ORDER BY mes ASC;

-- CONSULTA 3: PRODUCTOS MENOS VENDIDOS POR CATEGORIA
-- Se identifican los 3 productos con menor cantidad de unidades vendidas dentro de cada categoría. Este análisis permite detectar productos de baja rotación y utilizar esta información como apoyo para planificar el stock y las reposiciones. El mismo enfoque puede aplicarse para identificar los productos con mayor nivel de ventas.

WITH productos_rankeados AS (
    SELECT
        p.product_id AS id_producto,
        COALESCE(p.product_category_name, 'Sin Categoria') AS categoria,
        COUNT(oi.product_id) AS unidades_vendidas,
        ROW_NUMBER() OVER (
            PARTITION BY COALESCE(p.product_category_name, 'Sin Categoria')
            ORDER BY COUNT(oi.product_id) ASC
        ) AS ranking
    FROM capstone_project.products AS p
    JOIN capstone_project.order_items AS oi
        USING (product_id)
    GROUP BY p.product_id, p.product_category_name
)

SELECT
    id_producto,
    categoria,
    unidades_vendidas
FROM productos_rankeados
WHERE ranking <= 3
ORDER BY categoria, unidades_vendidas ASC;