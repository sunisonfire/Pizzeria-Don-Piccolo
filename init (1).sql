-- USE LA BASE DE DATOS, y en su defecto, copie solo las consultas (ignore puntos 1 y 2 por que son de la creacion de database)

-- 1. Creación de tabla de pedidos
-- Crear una tabla pedidos con los siguientes campos:
-- id_pedido (PK, autoincremental)
-- id_cliente (FK que apunte a clientes)
-- fecha_pedido llamada fecha_hora (DATE) con DATETIME
-- metodo_pago (VARCHAR)
-- estado (ENUM: 'pendiente', 'preparacion', 'entregado', 'cancelado')
-- total (DECIMAL(10,2))

CREATE TABLE pedido (
  id_pedido     INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente    INT NOT NULL,
  fecha_hora    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  metodo_pago   ENUM('efectivo','tarjeta','app') NOT NULL,
  estado        ENUM('pendiente','en_preparacion','entregado','cancelado') NOT NULL DEFAULT 'pendiente',
  lugar         ENUM('local','domicilio') NOT NULL,
  subtotal      DOUBLE NOT NULL DEFAULT 0,
  total         DOUBLE NOT NULL DEFAULT 0,
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente(id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_pedido_cliente (id_cliente),
  INDEX idx_pedido_fecha (fecha_hora)
) ENGINE=InnoDB;

-- 2. Creación de tabla intermedia
-- Crear una tabla pedido_pizza(detallepedido) que relacione los pedidos con las pizzas.
-- Campos mínimos: id_pedido, id_pizza, cantidad. (se le agrega precio unitario y subtotal)

CREATE TABLE detallepedido (
  id_detalle       INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido        INT NOT NULL,
  id_pizza         INT NOT NULL,
  cantidad         INT NOT NULL DEFAULT 1,
  precio_unitario  DOUBLE NOT NULL,
  subtotal         DOUBLE AS (cantidad * precio_unitario) STORED,
  CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido)
    REFERENCES pedido(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_detalle_pizza FOREIGN KEY (id_pizza)
    REFERENCES pizza(id_pizza) ON DELETE RESTRICT ON UPDATE CASCADE,
  CHECK (cantidad > 0),
  INDEX idx_detalle_pedido (id_pedido),
  INDEX idx_detalle_pizza (id_pizza)
) ENGINE=InnoDB;



-- 3. Consulta de pedidos por cliente
-- Consulta SQL que muestre el nombre del cliente, el ID del pedido, el total y el estado del pedido.

select p.id_pedido, per.nombre as cliente, p.total, p.estado as estado_pedido from pedido p
  left join persona per
  on p.id_cliente=per.id_persona
  group by p.id_pedido, cliente;

-- o usar opcion de view con el nombre completo

CREATE VIEW v_resumen_pedidos_cliente AS
SELECT
  per.id_persona AS id_cliente,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_cliente,
  COUNT(pe.id_pedido) AS cantidad_pedidos,
  IFNULL(SUM(pe.total), 0) AS total_gastado, pe.estado as estado_pedido
FROM persona per
JOIN cliente c ON per.id_persona = c.id_persona
LEFT JOIN pedido pe ON c.id_persona = pe.id_cliente
GROUP BY per.id_persona, nombre_cliente, pe.estado;

-- 4. Consulta de pedidos entregados en un rango de fechas
-- Mostrar los pedidos con estado entregado cuya fecha esté entre dos fechas dadas (usa BETWEEN).

SELECT
  per.id_persona AS id_cliente,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_cliente,
  pe.id_pedido,
  pe.fecha_hora
FROM persona per
  -- BUSCAMOS LOS CLIENTES ENTRE LAS PERSONAS
LEFT JOIN cliente c ON per.id_persona = c.id_persona
  -- BUSCAMOS LOS PEDIDOS DE LOS CLIENTES
LEFT JOIN pedido pe ON c.id_persona = pe.id_cliente
WHERE pe.fecha_hora BETWEEN '2026-08-01 00:00:00'
                        AND '2026-08-10 23:59:59'
  -- LOS ORDENAMOS POR FECHAS
ORDER BY pe.fecha_hora;


-- 5. Consulta de resumen de pedidos por método de pago
-- Mostrar cuántos pedidos se hicieron por cada método de pago y el total acumulado (GROUP BY).

SELECT metodo_pago, COUNT(*) as cantidad, SUM(total) as total_acumulado from pedido 
group by metodo_pago;

-- 6. Consulta de clientes frecuentes
-- Mostrar los clientes que tengan más de 5 pedidos en total (usa HAVING COUNT(*) > 5).

SELECT
  per.id_persona AS id_cliente,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_cliente
FROM persona per
LEFT JOIN cliente c ON per.id_persona = c.id_persona
  -- VERIFICAR QUE ES CLIENTE
WHERE c.id_persona IS NOT NULL
  -- ID DE LA PERSONA DENTRO DE RESULTADOS?
  AND per.id_persona IN (
  -- SUBCONSULTA
    SELECT pe.id_cliente
    FROM pedido pe
  -- AGRUPA POR CLIENTE, AÑO Y MES
    GROUP BY pe.id_cliente, YEAR(pe.fecha_hora), MONTH(pe.fecha_hora)
  -- DEJAR QUIENES TENGAN MAS DE 5
    HAVING COUNT(pe.id_pedido) > 5
  );