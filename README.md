# Pizzería Don Piccolo — Sistema de Gestión de Pedidos y Domicilios
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/82cbd588-c45a-4eff-95d8-50dc538412d5" />

## Descripción del proyecto

Pizzería Don Piccolo maneja actualmente sus pedidos de forma manual, lo que genera retrasos en la atención y errores en los registros de clientes y entregas. Este proyecto diseña una base de datos relacional en MySQL (`thepizzeria_don_piccolo`) que centraliza la gestión de clientes, pizzas, ingredientes, pedidos, repartidores, domicilios y pagos, e incorpora funciones, un procedimiento, triggers y vistas para automatizar y optimizar las operaciones y consultas del negocio.

## Tablas y relaciones

El modelo tiene 12 tablas:

| Tabla | Descripción |
|---|---|
| `persona` | Datos comunes de cualquier persona del sistema (nombre, apellido, teléfono, dirección, correo). |
| `cliente` | Especialización de `persona`. `id_persona` es a la vez PK y FK hacia `persona`. |
| `zona` | Catálogo de zonas de reparto (Norte, Centro, Sur, etc.). |
| `repartidor` | Especialización de `persona`. Tiene `id_zona` (FK a `zona`) y `estado` (`disponible` / `no_disponible`). |
| `pizza` | Catálogo de pizzas: nombre, tamaño, precio base, tipo y disponibilidad. |
| `ingrediente` | Catálogo de ingredientes, con `stock_actual`, `stock_minimo`, `costo_unitario` y `disponible`. |
| `pizzaingrediente` | Tabla intermedia N:M entre `pizza` e `ingrediente`; define la receta de cada pizza. |
| `pedido` | Pedido de un cliente: fecha, método de pago, estado, lugar (local/domicilio), subtotal y total. |
| `detallepedido` | Detalle del pedido: qué pizzas y en qué cantidad (permite varias pizzas por pedido). |
| `domicilio` | Datos de entrega de un pedido: repartidor, zona, hora de salida/entrega, distancia y costo de envío. |
| `pago` | Pago asociado a un pedido: método, monto, fecha y estado del pago. |
| `historial_precios` | Auditoría de cambios de precio de las pizzas (alimentada por un trigger). |

**Relaciones clave:**
- `cliente` y `repartidor` heredan de `persona` mediante FK 1:1 sobre `id_persona`.
- Un `pedido` tiene muchos registros en `detallepedido` (1:N), y cada uno apunta a una `pizza`, así un pedido puede incluir varias pizzas distintas.
- `pizza` e `ingrediente` se relacionan N:M a través de `pizzaingrediente`.
- `domicilio` y `pago` tienen una relación 1:1 con `pedido` (FK única).
- `repartidor` y `domicilio` se relacionan con `zona` para calcular métricas por zona.

## Objetos de base de datos

### Funciones (`funciones.sql`)
- `f_calcular_total_pedido(id_pedido)` → `DOUBLE`. Suma el subtotal de las pizzas del pedido más el costo de envío (si tiene domicilio) y le aplica el 19% de IVA.
- `f_ganancia_neta_diaria(fecha)` → `DOUBLE`. Ventas del día (pedidos `entregado`) menos el costo de los ingredientes consumidos ese día.
- `f_es_cliente_frecuente(id_cliente, anio, mes)` → `VARCHAR(20)`. Devuelve `'CLIENTE FRECUENTE'` si el cliente hizo más de 5 pedidos ese mes, `'CLIENTE'` si hizo entre 1 y 5, o `'SIN PEDIDOS ESTE MES'` si no hizo ninguno.

### Procedimiento (incluido en `funciones.sql`)
- `p_registrar_entrega(id_domicilio, hora_entrega)` — registra la hora de entrega del domicilio y cambia automáticamente el estado del pedido asociado a `entregado`.

Adicionalmente, `mejoras_registro_pedido.sql` agrega `p_registrar_pedido_completo`, un procedimiento opcional que crea un pedido junto con su detalle, valida stock de ingredientes disponible antes de insertar y genera el pago pendiente, todo dentro de una transacción.

### Triggers (`triggers.sql`)
- `t_actualizar_stock_ingrediente` — descuenta stock de ingredientes al insertar una línea en `detallepedido`.
- `t_auditoria_precio_pizza` — guarda en `historial_precios` cada cambio de `precio_base` en `pizza`.
- `t_repartidor_disponible` — libera al repartidor (`disponible`) cuando se registra la hora de entrega de un domicilio.
- `t_disponibilidad_ingrediente_insert` / `t_disponibilidad_ingrediente_update` — mantienen el campo `disponible` de `ingrediente` sincronizado con el stock: si `stock_actual <= 0` el ingrediente pasa a no disponible automáticamente, tanto al insertarlo como al actualizarlo (incluye las bajas de stock del trigger anterior).

### Vistas (`vistas.sql`)
- `v_resumen_pedidos_cliente` — cliente, cantidad de pedidos y total gastado.
- `v_desempeno_repartidores` — repartidor, zona, número de entregas y tiempo promedio de entrega.
- `v_stock_bajo` — ingredientes con stock por debajo del mínimo permitido.

## Ejemplos de consultas

```sql
-- Clientes con pedidos entre dos fechas
SELECT * FROM pedido WHERE fecha_hora BETWEEN '2026-08-01' AND '2026-08-10';

-- Pizzas más vendidas
SELECT p.nombre, SUM(dp.cantidad) AS unidades
FROM pizza p JOIN detallepedido dp ON p.id_pizza = dp.id_pizza
GROUP BY p.nombre ORDER BY unidades DESC;

-- Clientes que gastaron más de $30.000
SELECT id_cliente, SUM(total) AS total_gastado
FROM pedido GROUP BY id_cliente HAVING SUM(total) > 30000;

-- Usando una función
SELECT f_calcular_total_pedido(1);

-- Usando el procedimiento
CALL p_registrar_entrega(1, '2026-08-25 14:30:00');

-- Usando una vista
SELECT * FROM v_stock_bajo;
```

El set completo de las 7 consultas requeridas (BETWEEN, GROUP BY/COUNT, JOIN, AVG, HAVING, LIKE y subconsulta) está en `consultas.sql`.

## Instrucciones para ejecutar el script

Ejecutar los archivos **en este orden** desde un cliente MySQL:

1. `database.sql` — crea la base de datos y las 12 tablas.
2. `funciones.sql` — crea las funciones y el procedimiento `p_registrar_entrega`.
3. `triggers.sql` — crea los triggers (deben existir antes de insertar datos, porque descuentan stock).
4. `vistas.sql` — crea las vistas.
5. `datos_prueba.sql` — carga datos de ejemplo consistentes entre sí (clientes, pizzas, ingredientes, pedidos, domicilios y pagos con subtotales y totales ya calculados).
6. `consultas.sql` — ejecuta las consultas de ejemplo.
7. `mejoras_registro_pedido.sql` — (opcional) agrega el procedimiento `p_registrar_pedido_completo`.


## Estructura del proyecto

```
/pizzeria-don-piccolo/
 ├── database.sql
 ├── f_funciones.sql
 ├── t_triggers.sql
 ├── v_views.sql
 ├── consultas.sql
 ├── mejoras_registro_pedido.sql
 └── README.md
```
