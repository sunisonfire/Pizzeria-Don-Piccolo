USE thepizzeria_don_piccolo;

-- Función para calcular el total de un pedido (sumando precios de pizzas + costo de envío + IVA).
DELIMITER $$
CREATE FUNCTION calcular_total_pedido_fah(p_id_pedido INT)
RETURNS double
DETERMINISTIC
BEGIN
DECLARE v_costo_pizza DOUBLE DEFAULT 0;
DECLARE v_costo_domicilio DOUBLE DEFAULT 0;
DECLARE v_costo_total DOUBLE DEFAULT 0;
	select subtotal into v_costo_pizza FROM pedido WHERE id_pedido=p_id_pedido;
    select costo_envio into v_costo_domicilio FROM domicilio WHERE id_pedido=p_id_pedido;
    set v_costo_total=ROUND((v_costo_pizza+v_costo_domicilio)*1.19,2);
RETURN v_costo_total;
END; $$
DELIMITER ; 

-- Función para calcular la ganancia neta diaria (ventas - costos de ingredientes).
DROP FUNCTION IF EXISTS f_ganancia_neta_diaria;
DELIMITER $$
CREATE FUNCTION f_ganancia_neta_diaria(p_fecha DATE)
RETURNS DOUBLE
NOT DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE v_ventas DOUBLE DEFAULT 0;
  DECLARE v_costos DOUBLE DEFAULT 0;
 -- SE SUMA EL TOTAL DE TODOS LOS PEDIDOS Y SI ES NULL(NO VENTAS), PONE 0
  SELECT IFNULL(SUM(p.total), 0) INTO v_ventas
  FROM pedido p
    -- TRAE LA FECHA, SIN HORAS, Y SE CUENTAN LOS ENTREGADOS
  WHERE DATE(p.fecha_hora) = p_fecha AND p.estado = 'entregado';
 -- SE CALCULA EL COSTO DE LOS INGREDIENTES
  SELECT IFNULL(SUM(dp.cantidad * pi.cantidad_necesaria * i.costo_unitario), 0) INTO v_costos
  FROM detallepedido dp
    -- EL PEDIDO CONTIENE TODO LISTO, Y EL DETALLE LA CANTIDAD DE PIZZAS
  JOIN pedido pd ON dp.id_pedido = pd.id_pedido
    -- CONECTAR DETALLE CON PEDIDO
  JOIN pizzaingrediente pi ON dp.id_pizza = pi.id_pizza
    -- CONECTAR PIZZA CON INGREDIENTES
  JOIN ingrediente i ON pi.id_ingrediente = i.id_ingrediente
    -- SOLO TOMA PEDIDOS DE LA FECHA Y ENTREGADO
  WHERE DATE(pd.fecha_hora) = p_fecha AND pd.estado = 'entregado';
 -- GANANCIA COMO LAS VENTAS MENOS EL COSTO
  RETURN v_ventas - v_costos;
END$$
DELIMITER ;


-- Saber si un cliente es frecuente
DROP FUNCTION IF EXISTS f_es_cliente_frecuente;
DELIMITER $$
CREATE FUNCTION f_es_cliente_frecuente(
    p_id_cliente INT,
    p_anio INT,
    p_mes INT
)
RETURNS VARCHAR(20)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_cantidad INT DEFAULT 0;
-- CONTAR PEDIDOS
    SELECT COUNT(*) INTO v_cantidad
    FROM pedido
    WHERE id_cliente = p_id_cliente
      AND YEAR(fecha_hora) = p_anio
      AND MONTH(fecha_hora) = p_mes;
-- SI HIZO MAS DE 5 PEDIDOS
    IF v_cantidad > 5 THEN
        RETURN 'CLIENTE FRECUENTE';
-- MINIMO 1
    ELSEIF v_cantidad > 0 THEN
        RETURN 'CLIENTE';
-- SIN NINGUN PEDIDO
    ELSE
        RETURN 'SIN PEDIDOS ESTE MES';
    END IF;
END$$
DELIMITER ;

-- Prueba con:
SELECT f_calcular_total_pedido(1) AS total_pedido;
SELECT f_ganancia_neta_diaria('2026-08-26') AS ganancia_neta;
SELECT f_es_cliente_frecuente(1, 2026, 8) AS tipo_cliente;
