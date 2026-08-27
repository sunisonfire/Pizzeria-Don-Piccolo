USE `lapizzeria_don_piccolo`;

--Función para calcular el total de un pedido (sumando precios de pizzas + costo de envío + IVA).
DELIMITER $$
CREATE FUNCTION `f_calcular_total_pedido`(p_id_pedido INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
  DECLARE v_envio DECIMAL(10,2) DEFAULT 0;
  DECLARE v_total DECIMAL(10,2) DEFAULT 0;

  SELECT IFNULL(SUM(cantidad * precio_unitario),0) INTO v_subtotal
  FROM detallepedido
  WHERE id_pedido = p_id_pedido;

  SELECT IFNULL(costo_envio,0) INTO v_envio
  FROM domicilio
  WHERE id_pedido = p_id_pedido;

  SET v_total = ROUND((v_subtotal + v_envio) * 1.19, 2);

  RETURN v_total;
END$$
DELIMITER ;

--Función para calcular la ganancia neta diaria (ventas - costos de ingredientes).
DELIMITER $$
CREATE FUNCTION `f_ganancia_neta_diaria`(p_fecha DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE v_ventas DECIMAL(10,2) DEFAULT 0;
  DECLARE v_costos DECIMAL(10,2) DEFAULT 0;

  SELECT IFNULL(SUM(p.total),0) INTO v_ventas
  FROM pedido p
  WHERE DATE(p.fecha_hora) = p_fecha AND p.estado = 'entregado';

  SELECT IFNULL(SUM(dp.cantidad * pi.cantidad_necesaria * i.costo_unitario),0) INTO v_costos
  FROM detallepedido dp
  JOIN pedido pd ON dp.id_pedido = pd.id_pedido
  JOIN pizzaingrediente pi ON dp.id_pizza = pi.id_pizza
  JOIN ingrediente i ON pi.id_ingrediente = i.id_ingrediente
  WHERE DATE(pd.fecha_hora) = p_fecha AND pd.estado = 'entregado';

  RETURN v_ventas - v_costos;
END$$
DELIMITER ;

--Permitir identificar clientes frecuentes (más de 5 pedidos en el mes).
DELIMITER $$
CREATE FUNCTION f_es_cliente_frecuente(
    p_id_cliente INT,
    p_anio INT,
    p_mes INT
)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_cantidad INT DEFAULT 0;

    SELECT COUNT(*) INTO v_cantidad
    FROM pedido
    WHERE id_cliente = p_id_cliente
      AND YEAR(fecha_hora) = p_anio
      AND MONTH(fecha_hora) = p_mes;

    IF v_cantidad > 5 THEN
        RETURN 'CLIENTE FRECUENTE';
    ELSEIF v_cantidad > 0 THEN
        RETURN 'CLIENTE';
    ELSE
        RETURN 'SIN PEDIDOS ESTE MES';
    END IF;
END$$
DELIMITER ;

SELECT f_calcular_total_pedido(1);
SELECT f_ganancia_neta_diaria('2026-08-01');
SELECT f_es_cliente_frecuente(1, 2026, 1);
