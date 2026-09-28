# Proyecto Capstone: Análisis de Datos con PostgreSQL

## 1. Dataset y elección del proyecto

Para este proyecto elegí el dataset **“Brazilian E-Commerce Public Dataset by Olist”** de Kaggle. Elegí trabajar con un dataset de e-commerce porque es un tipo de negocio relacionado con varios de los conceptos trabajados durante el curso. Además, me pareció interesante porque cuenta con varias tablas relacionadas entre sí, lo que permite trabajar con `JOIN`, claves primarias y foráneas y diferentes niveles de información sobre clientes, pedidos y productos.

El dataset contiene información sobre pedidos realizados en una plataforma de e-commerce brasileña, incluyendo datos de clientes, productos, pedidos, vendedores, pagos, reseñas y geolocalización.

Originalmente, el dataset contaba con 9 tablas. Sin embargo, decidí cargar solamente 5 de ellas, priorizando aquellas que contenían información relevante para el análisis exploratorio y que permitían trabajar con las relaciones entre clientes, pedidos, productos y pagos. Si bien no todas las tablas cargadas fueron utilizadas finalmente en las consultas de análisis, decidí mantenerlas disponibles porque contienen información que podría ser útil para profundizar el análisis posteriormente.

Las tablas seleccionadas fueron:

* `customers`
* `orders`
* `order_items`
* `order_payments`
* `products`

De esta manera, el análisis se concentra principalmente en la relación entre clientes, pedidos, productos y ventas.

## 2. Estructura y relaciones entre las tablas

Antes de comenzar a cargar los datos, realicé un esquema de las relaciones que identificaba entre las tablas para comprender mejor cómo se conectaban y qué claves foráneas debía utilizar.

```text
customers
   │
   │ customer_id
   ↓
orders
   │
   │ order_id
   ├──────────────→ order_items
   │                    │
   │                    │ product_id
   │                    ↓
   │                 products
   │
   └──────────────→ order_payments
```

Una vez identificadas las relaciones, pude definir el orden de creación y carga de las tablas. Esto es importante porque las claves foráneas generan dependencias entre ellas: una tabla que contiene una clave foránea necesita que la tabla referenciada exista previamente.

El orden utilizado fue:

1. `customers`
2. `products`
3. `orders`
4. `order_items`
5. `order_payments`

Al crear las tablas también revisé los archivos originales para determinar los tipos de datos correspondientes a cada columna y definir correctamente las claves primarias y foráneas.

### Claves de la tabla `customers`

Al revisar la tabla `customers`, encontré dos identificadores: `customer_id` y `customer_unique_id`.

Al principio pensé que `customer_unique_id` sería la clave primaria porque permite identificar de manera única al cliente. Sin embargo, al revisar las relaciones entre las tablas, entendí que `customer_id` es el identificador utilizado para relacionar los clientes con sus pedidos.

Por este motivo, decidí utilizar `customer_id` como clave primaria y mantener `customer_unique_id` como un campo adicional. Este último sigue siendo importante para identificar al mismo cliente de forma consistente y puede utilizarse en análisis posteriores, por ejemplo, para calcular el gasto total por cliente.

### Claves primarias compuestas

Al definir la estructura de las tablas, también noté que en algunas no alcanzaba con utilizar una sola columna como clave primaria, ya que ciertos identificadores podían repetirse dentro de la tabla.

Por este motivo, en `order_items` utilicé la combinación de `order_id` y `order_item_id`, mientras que en `order_payments` utilicé la combinación de `order_id` y `payment_sequential`.

De esta manera, la combinación de ambas columnas permite identificar de forma única cada registro, respetando la estructura y las relaciones presentes en el dataset.

## 3. Carga de los datos

Una vez definida la estructura, realicé la carga de los archivos CSV mediante el comando `COPY`, respetando el orden establecido previamente para evitar conflictos con las claves foráneas.

## 4. Limpieza y validación de los datos

Antes de comenzar con el análisis, realicé una verificación de valores nulos en algunas columnas críticas del dataset.

Primero revisé la columna `price` de `order_items`, ya que es necesaria para calcular los importes de las ventas. Luego revisé `order_purchase_timestamp` de `orders`, porque es la fecha que utilizaré para realizar el análisis de ventas por período.

En ambos casos, el resultado fue 0, por lo que no se encontraron valores nulos en estas columnas y no fue necesario realizar modificaciones sobre los datos.

Si bien no se encontraron valores nulos en las columnas críticas revisadas, se utilizó `COALESCE` en algunas de las consultas de análisis para mostrar cómo puede utilizarse esta función para manejar valores nulos y evitar que afecten los resultados. En estos casos, su uso tiene principalmente un objetivo metodológico y demostrativo, ya que los datos analizados no presentan nulos que requieran ser corregidos.

## 5. Análisis de negocio

### 5.1. Top 5 clientes por gasto total

El primer análisis busca identificar a los clientes que concentran el mayor gasto dentro de la plataforma. Para esto, se calculó el gasto total de cada cliente a partir del valor de los productos incluidos en sus pedidos y se seleccionaron los cinco clientes con mayor gasto.

Conocer este grupo permite reconocer a los clientes de mayor valor económico para el negocio y puede servir como punto de partida para analizar sus patrones de compra, frecuencia de pedidos y posibles estrategias de fidelización y retención.

Este análisis podría profundizarse incorporando otras variables para entender mejor el comportamiento de los clientes de mayor gasto. Por ejemplo, sería posible analizar su ubicación geográfica, la cantidad y frecuencia de sus pedidos y si concentran su gasto en pocas compras de mayor valor o realizan compras más frecuentes de menor importe.

También podría calcularse el ticket promedio por cliente para diferenciar entre clientes que gastan mucho debido a compras puntuales y aquellos que mantienen un nivel de consumo elevado a lo largo del tiempo. Estas variables permitirían obtener una visión más completa del perfil y comportamiento de los clientes de mayor valor.

### 5.2. Ventas totales por mes y estacionalidad

El segundo análisis busca identificar qué meses del año concentran mayores o menores niveles de ventas y detectar posibles patrones de estacionalidad.

Para esto, las ventas se agruparon según el mes del año, independientemente del año en que se realizó el pedido. De esta manera, es posible comparar el comportamiento de enero, febrero, marzo, etc., y observar si existen determinados períodos del año que concentran un mayor nivel de ventas.

En los resultados obtenidos, mayo y agosto presentan los mayores niveles de ventas, mientras que diciembre, septiembre y octubre se encuentran entre los meses con menores ingresos.

Estos resultados muestran que la demanda no se distribuye de manera uniforme a lo largo del año. Algunas de estas variaciones podrían estar relacionadas con fechas comerciales y hábitos de consumo, aunque el análisis por sí solo no permite establecer una relación causal.

Por ejemplo, el mayor nivel de ventas observado en mayo podría estar relacionado con el período del Día de las Madres, mientras que los menores niveles observados en septiembre y octubre resultan interesantes al encontrarse antes del período de Black Friday. Estas posibles relaciones deberían analizarse incorporando información adicional, como categorías de productos, cantidad de pedidos y períodos promocionales, para determinar si existe efectivamente una relación.

Es importante considerar que el dataset de Olist representa un período histórico específico, con aproximadamente 100.000 pedidos realizados entre 2016 y 2018. Por lo tanto, los patrones identificados representan el comportamiento observado en ese dataset y no necesariamente el comportamiento actual del e-commerce brasileño.

### 5.3. Tres productos menos vendidos por categoría

El tercer análisis busca identificar los tres productos con menor cantidad de unidades vendidas dentro de cada categoría. Para esto, se utilizó la cantidad de unidades vendidas como indicador de rotación y se compararon los productos dentro de cada categoría, en lugar de analizar únicamente los productos con menor venta de todo el catálogo.

Este análisis permite detectar productos de baja rotación y puede servir como información complementaria para la planificación del stock y las reposiciones. Identificar estos productos puede ayudar a detectar posibles acumulaciones de inventario y a evaluar si determinados productos requieren cambios en su estrategia comercial, como promociones o ajustes en su presencia dentro del catálogo.

Como siguiente paso, el análisis podría complementarse incorporando el precio, los ingresos generados y la evolución de las ventas a lo largo del tiempo. Esto permitiría diferenciar entre productos que tienen pocas unidades vendidas pero generan un ingreso significativo y aquellos que presentan una baja rotación y también un bajo impacto económico para el negocio.

## 6. Conclusiones

A partir de los análisis realizados, fue posible identificar diferentes aspectos del comportamiento comercial del dataset. Por un lado, se identificaron los clientes que concentran el mayor gasto; por otro, se observaron diferencias en los niveles de ventas según el mes del año y, finalmente, se detectaron productos con baja rotación dentro de sus respectivas categorías.

En conjunto, estos análisis permiten observar el negocio desde diferentes perspectivas: clientes, comportamiento temporal de las ventas y desempeño de los productos. A su vez, cada análisis puede profundizarse incorporando nuevas variables para obtener una visión más completa y generar conclusiones de mayor alcance.

## 7. Cómo ejecutar el proyecto

Para ejecutar el proyecto en PostgreSQL, primero se debe crear una base de datos llamada `capstone_project`. Luego, se debe ejecutar el archivo `estructura.sql`, que contiene la creación del esquema, las tablas y la carga de los archivos CSV. En caso de utilizar una ubicación diferente para los archivos, será necesario actualizar las rutas indicadas en los comandos `COPY`. Una vez cargados los datos, se puede ejecutar el archivo `analisis.sql`, que contiene las consultas utilizadas para realizar los análisis y obtener los resultados presentados en este README.
