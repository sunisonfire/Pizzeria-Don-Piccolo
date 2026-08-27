USE thepizzeria_don_piccolo;

DELIMITER $$
CREATE TRIGGER t_actualizar_stock_ingrediente
AFTER INSERT ON detallepedido
FOR EACH ROW
BEGIN
  UPDATE ingrediente i
  JOIN pizzaingrediente pi ON i.id_ingrediente = pi.id_ingrediente
  SET i.stock_actual = i.stock_actual - (pi.cantidad_necesaria * NEW.cantidad)
  WHERE pi.id_pizza = NEW.id_pizza;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER t_auditoria_precio_pizza
BEFORE UPDATE ON pizza
FOR EACH ROW
BEGIN
  IF NEW.precio_base <> OLD.precio_base THEN
    INSERT INTO historial_precios (id_pizza, precio_anterior, precio_nuevo)
    VALUES (OLD.id_pizza, OLD.precio_base, NEW.precio_base);
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER t_repartidor_disponible
AFTER UPDATE ON domicilio
FOR EACH ROW
BEGIN
  IF NEW.hora_entrega IS NOT NULL AND OLD.hora_entrega IS NULL AND NEW.id_repartidor IS NOT NULL THEN
    UPDATE repartidor
    SET estado = 'disponible'
    WHERE id_persona = NEW.id_repartidor;
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER t_disponibilidad_ingrediente_insert
BEFORE INSERT ON ingrediente
FOR EACH ROW
BEGIN
  IF NEW.stock_actual <= 0 THEN
    SET NEW.disponible = 0;
  ELSE
    SET NEW.disponible = 1;
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER t_disponibilidad_ingrediente_update
BEFORE UPDATE ON ingrediente
FOR EACH ROW
BEGIN
  IF NEW.stock_actual <= 0 THEN
    SET NEW.disponible = 0;
  ELSE
    SET NEW.disponible = 1;
  END IF;
END$$
DELIMITER ;
