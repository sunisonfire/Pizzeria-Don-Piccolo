USE thepizzeria_don_piccolo;

--Procedimiento para cambiar automáticamente el estado del pedido a “entregado” cuando se registre la hora de entrega.
DELIMITER $$
CREATE PROCEDURE p_registrar_entrega(IN p_id_domicilio INT, IN p_hora_entrega DATETIME)
BEGIN
  DECLARE v_id_pedido INT;

  UPDATE domicilio
  SET hora_entrega = p_hora_entrega
  WHERE id_domicilio = p_id_domicilio;

  SELECT id_pedido INTO v_id_pedido
  FROM domicilio
  WHERE id_domicilio = p_id_domicilio;

  UPDATE pedido
  SET estado = 'entregado'
  WHERE id_pedido = v_id_pedido;
END$$
DELIMITER ;

--Probar con:
CALL p_registrar_entrega(1, '2026-08-25 14:30:00');

