# Pizzería Don Piccolo — Sistema de Gestión de Pedidos y Domicilios

## Descripción del proyecto

Pizzería Don Piccolo maneja actualmente sus pedidos de forma manual, lo que genera retrasos en la atención y errores en los registros de clientes y entregas. Este proyecto diseña una base de datos relacional en MySQL (`lapizzeria_don_piccolo`) que centraliza la gestión de clientes, pizzas, ingredientes, pedidos, repartidores, domicilios y pagos, e incorpora funciones, un procedimiento, triggers y vistas para automatizar y optimizar las operaciones y consultas del negocio.

## Tablas y relaciones

El modelo tiene 12 tablas:

| Tabla | Descripción |
|---|---|
| `persona` | Tabla base con los datos comunes de cualquier persona del sistema (nombre, apellido, teléfono, dirección, correo). |
| `cliente` | Especialización de `persona`. `id_persona` es a la vez PK y FK hacia `persona`. |
| `zona` | Catálogo de zonas de reparto (Centro, Norte, Sur, etc.). |
| `repartidor` | Especialización de `persona`. Tiene `id_zona` (FK a `zona`) y `estado` (`disponible` / `no_disponible`). |
| `ingrediente` | Catálogo de ingredientes con `stock_actual`, `stock_minimo` y `costo_unitario`. |
| `pizza` | Catálogo de pizzas: nombre, tamaño, precio base, tipo y disponibilidad. |
| `pizzaingrediente` | Tabla intermedia N:M entre `pizza` e `ingrediente`; define la receta de cada pizza. |
| `pedido` | Pedido de un cliente: fecha, método de pago, estado, lugar (local/domicilio), subtotal y total. |
| `detallepedido` | Detalle del pedido: qué pizzas y en qué cantidad (permite varias pizzas distintas por pedido). |
| `domicilio` | Datos de entrega a domicilio de un pedido: repartidor, zona, hora de salida/entrega, distancia y costo de envío. |
| `pago` | Pago asociado a un pedido: método, monto, fecha y estado del pago. |
| `historial_precios` | Auditoría de cambios de precio de las pizzas (alimentada por un trigger). |

**Relaciones clave:**
- `cliente` y `repartidor` heredan de `persona` mediante FK 1:1 sobre `id_persona`.
- Un `pedido` tiene muchos registros en `detallepedido` (1:N), y cada uno apunta a una `pizza` — así un pedido puede incluir varias pizzas distintas.
- `pizza` e `ingrediente` se relacionan N:M a través de `pizzaingrediente`.
- `domicilio` y `pago` tienen una relación 1:1 con `pedido` (FK única).
- `repartidor` y `domicilio` se relacionan con `zona` para calcular métricas por zona.

## Objetos de base de datos

### Funciones (prefijo `f_`)
- `f_calcular_total_pedido(id_pedido)` — subtotal de pizzas + costo de envío + IVA (19%).
- `f_ganancia_neta_diaria(fecha)` — ventas del día menos costo de ingredientes consumidos.
- `f_es_cliente_frecuente(id_cliente, anio, mes)` — `TRUE` si el cliente hizo más de 5 pedidos ese mes.

### Procedimiento (prefijo `p_`)
- `sp_registrar_entrega(id_domicilio, hora_entrega)` — registra la hora de entrega y pasa el pedido a estado `entregado`.

### Triggers (prefijo `t_`)
- `t_actualizar_stock_ingrediente` — descuenta stock de ingredientes al insertar una línea en `detallepedido`.
- `t_auditoria_precio_pizza` — guarda en `historial_precios` cada cambio de `precio_base` en `pizza`.
- `t_repartidor_disponible` — libera al repartidor (`disponible`) cuando se registra la hora de entrega de un domicilio.

### Vistas (prefijo `v_`)
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
CALL sp_registrar_entrega(1, '2026-08-25 14:30:00');

-- Usando una vista
SELECT * FROM v_stock_bajo;
```

El set completo de las 7 consultas requeridas (BETWEEN, GROUP BY/COUNT, JOIN, AVG, HAVING, LIKE y subconsulta) está en `lapizzeria_don_piccolo_consultas.sql`.

## Instrucciones para ejecutar el script

Ejecutar los archivos **en este orden** desde un cliente MySQL (Workbench, línea de comandos, DBeaver, etc.):

1. `lapizzeria_don_piccolo.sql` — crea la base de datos y las 12 tablas.
2. `lapizzeria_don_piccolo_inserts.sql` — carga datos de ejemplo en todas las tablas.
3. `lapizzeria_don_piccolo_functions.sql` — crea las funciones.
4. `lapizzeria_don_piccolo_procedures.sql` — crea el procedimiento.
5. `lapizzeria_don_piccolo_triggers.sql` — crea los triggers.
6. `lapizzeria_don_piccolo_views.sql` — crea las vistas.
7. `lapizzeria_don_piccolo_consultas.sql` — (opcional) ejecuta las consultas de ejemplo.

Por línea de comandos:
```bash
mysql -u tu_usuario -p < lapizzeria_don_piccolo.sql
mysql -u tu_usuario -p < lapizzeria_don_piccolo_inserts.sql
mysql -u tu_usuario -p < lapizzeria_don_piccolo_functions.sql
mysql -u tu_usuario -p < lapizzeria_don_piccolo_procedures.sql
mysql -u tu_usuario -p < lapizzeria_don_piccolo_triggers.sql
mysql -u tu_usuario -p < lapizzeria_don_piccolo_views.sql
```

**Nota:** si tu cliente MySQL no maneja bien el cambio de `DELIMITER` (por ejemplo, algunos conectores), ejecuta los archivos de funciones, procedimiento y triggers directamente desde MySQL Workbench o la consola `mysql`, donde `DELIMITER` sí se interpreta correctamente.
