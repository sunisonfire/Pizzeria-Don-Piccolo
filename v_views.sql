USE `lapizzeria_don_piccolo`;

--Vista de resumen de pedidos por cliente (nombre del cliente, cantidad de pedidos, total gastado).
CREATE VIEW `v_resumen_pedidos_cliente` AS
SELECT
  per.id_persona AS id_cliente,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_cliente,
  COUNT(pe.id_pedido) AS cantidad_pedidos,
  IFNULL(SUM(pe.total), 0) AS total_gastado
FROM persona per
JOIN cliente c ON per.id_persona = c.id_persona
LEFT JOIN pedido pe ON c.id_persona = pe.id_cliente
GROUP BY per.id_persona, nombre_cliente;

--Vista de desempeño de repartidores (número de entregas, tiempo promedio, zona).
CREATE VIEW `v_desempeno_repartidores` AS
SELECT
  per.id_persona AS id_repartidor,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_repartidor,
  z.nombre AS zona,
  COUNT(d.id_domicilio) AS numero_entregas,
  AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)) AS tiempo_promedio_minutos
FROM persona per
JOIN repartidor r ON per.id_persona = r.id_persona
JOIN zona z ON r.id_zona = z.id_zona
LEFT JOIN domicilio d ON r.id_persona = d.id_repartidor AND d.hora_entrega IS NOT NULL
GROUP BY per.id_persona, nombre_repartidor, zona;

--Vista de stock de ingredientes por debajo del mínimo permitido.
CREATE VIEW `v_stock_bajo` AS
SELECT
  id_ingrediente,
  nombre,
  stock_actual,
  stock_minimo
FROM ingrediente
WHERE stock_actual < stock_minimo;

--COMO PRUEBA
SELECT * FROM v_resumen_pedidos_cliente;
SELECT * FROM v_desempeno_repartidores;
SELECT * FROM v_stock_bajo;