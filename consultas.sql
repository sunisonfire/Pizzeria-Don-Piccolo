USE thepizzeria_don_piccolo;


-- 1) Clientes con pedidos entre dos fechas (BETWEEN)
SELECT
  per.id_persona AS id_cliente,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_cliente,
  pe.id_pedido,
  pe.fecha_hora
FROM persona per
LEFT JOIN cliente c ON per.id_persona = c.id_persona
LEFT JOIN pedido pe ON c.id_persona = pe.id_cliente
WHERE pe.fecha_hora BETWEEN '2026-08-01 00:00:00'
                        AND '2026-08-10 23:59:59'
ORDER BY pe.fecha_hora;

-- 2) Pizzas más vendidas (GROUP BY y COUNT)

SELECT
  p.id_pizza,
  p.nombre AS nombre_pizza,
  COUNT(dp.id_detalle) AS veces_vendida,
  COALESCE(SUM(dp.cantidad), 0) AS unidades_vendidas
FROM pizza p
LEFT JOIN detallepedido dp ON p.id_pizza = dp.id_pizza
GROUP BY p.id_pizza, nombre_pizza
ORDER BY unidades_vendidas DESC;

-- 3) Pedidos por repartidor (JOIN)
SELECT
  per.id_persona AS id_repartidor,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_repartidor,
  COUNT(d.id_domicilio) AS total_pedidos
FROM persona per
LEFT JOIN repartidor r ON per.id_persona = r.id_persona
LEFT JOIN domicilio d ON r.id_persona = d.id_repartidor
WHERE r.id_persona IS NOT NULL
GROUP BY per.id_persona, nombre_repartidor
ORDER BY total_pedidos DESC;

-- 4) Promedio de entrega por zona (AVG y JOIN)
SELECT
  z.id_zona,
  z.nombre AS zona,
  AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)) AS promedio_minutos_entrega
FROM zona z
LEFT JOIN domicilio d
  ON z.id_zona = d.id_zona
  AND d.hora_entrega IS NOT NULL
GROUP BY z.id_zona, zona
ORDER BY promedio_minutos_entrega;

-- 5) Clientes que gastaron más de un monto (HAVING)
SELECT
  per.id_persona AS id_cliente,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_cliente,
  SUM(pe.total) AS total_gastado
FROM persona per
LEFT JOIN cliente c ON per.id_persona = c.id_persona
LEFT JOIN pedido pe ON c.id_persona = pe.id_cliente
WHERE c.id_persona IS NOT NULL
GROUP BY per.id_persona, nombre_cliente
HAVING SUM(pe.total) > 30000
ORDER BY total_gastado DESC;

-- 6) Búsqueda por coincidencia parcial de nombre de pizza (LIKE)
SELECT
  id_pizza,
  nombre,
  tamano,
  precio_base,
  tipo
FROM pizza
WHERE nombre LIKE '%pepperoni%';

-- 7) Subconsulta: clientes frecuentes (más de 5 pedidos/mes)
SELECT
  per.id_persona AS id_cliente,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_cliente
FROM persona per
LEFT JOIN cliente c ON per.id_persona = c.id_persona
WHERE c.id_persona IS NOT NULL
  AND per.id_persona IN (
    SELECT pe.id_cliente
    FROM pedido pe
    GROUP BY pe.id_cliente, YEAR(pe.fecha_hora), MONTH(pe.fecha_hora)
    HAVING COUNT(pe.id_pedido) > 5
  );
