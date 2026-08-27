USE thepizzeria_don_piccolo;


-- 1) Clientes con pedidos entre dos fechas (BETWEEN)
SELECT
  per.id_persona AS id_cliente,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_cliente,
  pe.id_pedido,
  pe.fecha_hora
FROM persona per
  --BUSCAMOS LOS CLIENTES ENTRE LAS PERSONAS
LEFT JOIN cliente c ON per.id_persona = c.id_persona
  --BUSCAMOS LOS PEDIDOS DE LOS CLIENTES
LEFT JOIN pedido pe ON c.id_persona = pe.id_cliente
WHERE pe.fecha_hora BETWEEN '2026-08-01 00:00:00'
                        AND '2026-08-10 23:59:59'
  --LOS ORDENAMOS POR FECHAS
ORDER BY pe.fecha_hora;

-- 2) Pizzas más vendidas (GROUP BY y COUNT)

SELECT
  p.id_pizza,
  p.nombre AS nombre_pizza,
  --CONTAMOS EN CUANTOS REGISTROS DE PEDIDO APARECE
  COUNT(dp.id_detalle) AS veces_vendida,
  --SUMAMOS LA CANTIDAD DE UNIDADES VENDIDAS, Y SI ES NULL, PONEMOS 0
  COALESCE(SUM(dp.cantidad), 0) AS unidades_vendidas
FROM pizza p
  --CONECTAR PIZZA CON DETALLE DE PEDIDO
LEFT JOIN detallepedido dp ON p.id_pizza = dp.id_pizza
  --AGRUPAR LOS RESULTADOS(POR USO DE COUNT Y SUM)
GROUP BY p.id_pizza, nombre_pizza
  --ORDENAR DESCENDENTE
ORDER BY unidades_vendidas DESC;

-- 3) Pedidos por repartidor (JOIN)
SELECT
  per.id_persona AS id_repartidor,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_repartidor,
  COUNT(d.id_domicilio) AS total_pedidos
FROM persona per
  --BUSCAR PERSONAS QUE SON REPARTIDORES
LEFT JOIN repartidor r ON per.id_persona = r.id_persona
LEFT JOIN domicilio d ON r.id_persona = d.id_repartidor
WHERE r.id_persona IS NOT NULL
  --AGRUPAR POR REPARTIDOR A LOS DOMICILIOS
GROUP BY per.id_persona, nombre_repartidor
ORDER BY total_pedidos DESC;

-- 4) Promedio de entrega por zona (AVG y JOIN)
SELECT
  z.id_zona,
  z.nombre AS zona,
  --PROMEDIO DE LA DIFERENCIA ENTRE HORA SALIDA Y LLEGADA, Y EN MIN
  AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)) AS promedio_minutos_entrega
FROM zona z
LEFT JOIN domicilio d
  ON z.id_zona = d.id_zona
  AND d.hora_entrega IS NOT NULL
  --SI LA HORA DE ENTREGA ES NULL, NO SE HA ENTREGADO
  --AGRUPAR DOMICILIOS POR ZONA
GROUP BY z.id_zona, zona
  --ORDENAR SEGUN EL PROMEDIO
ORDER BY promedio_minutos_entrega;

-- 5) Clientes que gastaron más de un monto (HAVING)
SELECT
  per.id_persona AS id_cliente,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_cliente,
  --SUMAR EL TOTAL DE LOS PEDIDOS
  SUM(pe.total) AS total_gastado
FROM persona per
LEFT JOIN cliente c ON per.id_persona = c.id_persona
LEFT JOIN pedido pe ON c.id_persona = pe.id_cliente
  --ASEGURAR QUE PERSONA SEA CLIENTE
WHERE c.id_persona IS NOT NULL
  --AGRUPAR PEDIDOS DE CADA CLIENTE
GROUP BY per.id_persona, nombre_cliente
  --FILTRAR AQUELLOS QUE SEA MAYOR A 30.000
HAVING SUM(pe.total) > 30000
  --ORDERNAR DE QUIEN GASTO MAS A MENOS
ORDER BY total_gastado DESC;

-- 6) Búsqueda por coincidencia parcial de nombre de pizza (LIKE)
SELECT
  id_pizza,
  nombre,
  tamano,
  precio_base,
  tipo
FROM pizza
  --BUSCADOR
WHERE nombre LIKE '%pepperoni%';

-- 7) Subconsulta: clientes frecuentes (más de 5 pedidos/mes)
SELECT
  per.id_persona AS id_cliente,
  CONCAT(per.nombre, ' ', per.apellido) AS nombre_cliente
FROM persona per
LEFT JOIN cliente c ON per.id_persona = c.id_persona
  --VERIFICAR QUE ES CLIENTE
WHERE c.id_persona IS NOT NULL
  --ID DE LA PERSONA DENTRO DE RESULTADOS?
  AND per.id_persona IN (
  --SUBCONSULTA
    SELECT pe.id_cliente
    FROM pedido pe
  --AGRUPA POR CLIENTE, AÑO Y MES
    GROUP BY pe.id_cliente, YEAR(pe.fecha_hora), MONTH(pe.fecha_hora)
  --DEJAR QUIENES TENGAN MAS DE 5
    HAVING COUNT(pe.id_pedido) > 5
  );
