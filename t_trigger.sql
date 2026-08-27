USE `lapizzeria_don_piccolo`;

--Trigger de actualización automática de stock de ingredientes cuando se realiza un pedido.
DELIMITER $$
CREATE TRIGGER `t_actualizar_stock_ingrediente`
AFTER INSERT ON `detallepedido`
FOR EACH ROW
BEGIN
  UPDATE ingrediente i
  JOIN pizzaingrediente pi ON i.id_ingrediente = pi.id_ingrediente
  SET i.stock_actual = i.stock_actual - (pi.cantidad_necesaria * NEW.cantidad)
  WHERE pi.id_pizza = NEW.id_pizza;
END$$
DELIMITER ;

--Trigger de auditoría que registre en una tabla historial_precios cada vez que se modifique el precio de una pizza.
DELIMITER $$
CREATE TRIGGER `t_auditoria_precio_pizza`
BEFORE UPDATE ON `pizza`
FOR EACH ROW
BEGIN
  IF NEW.precio_base <> OLD.precio_base THEN
    INSERT INTO historial_precios (id_pizza, precio_anterior, precio_nuevo)
    VALUES (OLD.id_pizza, OLD.precio_base, NEW.precio_base);
  END IF;
END$$
DELIMITER ;

--Trigger para marcar repartidor como “disponible” nuevamente cuando termina un domicilio.
DELIMITER $$
CREATE TRIGGER `t_repartidor_disponible`
AFTER UPDATE ON `domicilio`
FOR EACH ROW
BEGIN
  IF NEW.hora_entrega IS NOT NULL AND OLD.hora_entrega IS NULL AND NEW.id_repartidor IS NOT NULL THEN
    UPDATE repartidor
    SET estado = 'disponible'
    WHERE id_persona = NEW.id_repartidor;
  END IF;
END$$
DELIMITER ;