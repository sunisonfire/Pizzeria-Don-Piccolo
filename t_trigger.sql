USE thepizzeria_don_piccolo;

--Trigger de actualización automática de stock de ingredientes cuando se realiza un pedido.
DELIMITER $$
  --AL AGREGAR UN PRODUCTO A DETALLEPEDIDO, DESCUENTA DEL STOCK LOS INGREDIENTES
CREATE TRIGGER t_actualizar_stock_ingrediente
AFTER INSERT ON detallepedido
FOR EACH ROW
BEGIN
  --ACTUALIZAR TABLA DE INGREDIENTES
  UPDATE ingrediente i
  JOIN pizzaingrediente pi ON i.id_ingrediente = pi.id_ingrediente
  --NEW CANTIDAD SON LA CANTIDAD PIZZAS COMPRADAS
  --CANTIDAD_NECESARIA INGREDIENTES
  --SE RESTAN
  SET i.stock_actual = i.stock_actual - (pi.cantidad_necesaria * NEW.cantidad)
  WHERE pi.id_pizza = NEW.id_pizza;
END$$
DELIMITER ;

--Trigger de auditoría que registre en una tabla historial_precios cada vez que se modifique el precio de una pizza.
DELIMITER $$
CREATE TRIGGER t_auditoria_precio_pizza
BEFORE UPDATE ON pizza
FOR EACH ROW
BEGIN
  --COMPARAR EL PRECIO ANTERIOR CON EL NUEVO
  IF NEW.precio_base <> OLD.precio_base THEN
  --SI EL PRECIO CAMBIA, GUARDAR CAMBIO EN HISTORIAL DE PRECIOS
    INSERT INTO historial_precios (id_pizza, precio_anterior, precio_nuevo)
    VALUES (OLD.id_pizza, OLD.precio_base, NEW.precio_base);
  END IF;
END$$
DELIMITER ;

--Trigger para marcar repartidor como “disponible” nuevamente cuando termina un domicilio.
DELIMITER $$
CREATE TRIGGER t_repartidor_disponible
AFTER UPDATE ON domicilio
FOR EACH ROW
BEGIN
  --ANTES NO TENIA HORA DE ENTREGA, ASI QUE SE LE ASIGNA
  IF NEW.hora_entrega IS NOT NULL AND OLD.hora_entrega IS NULL AND NEW.id_repartidor IS NOT NULL THEN
    UPDATE repartidor
  --CAMBIAR ESTADO DEL REPARTIDOR
    SET estado = 'disponible'
  --BUSCANDO AL QUE HIZO ESE DOMICILIO
    WHERE id_persona = NEW.id_repartidor;
  END IF;
END$$
DELIMITER ;

--extras para mejorar:
DELIMITER $$
CREATE TRIGGER t_disponibilidad_ingrediente_insert
BEFORE INSERT ON ingrediente
FOR EACH ROW
BEGIN
  --REVISAR EL STOCK QUE TENDRÁ EL INGREDIENTE
  IF NEW.stock_actual <= 0 THEN
  --0 SERÁ EL NO DISPONIBLE
    SET NEW.disponible = 0;
  ELSE
    --DISPONIBLE 1
    SET NEW.disponible = 1;
  END IF;
END$$
DELIMITER ;

--EL MISMO DEL ANTERIOR PERO PARA ACTUALIZAR
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

DELIMITER $$

CREATE TRIGGER t_verificar_stock_pizza
BEFORE INSERT ON detallepedido
FOR EACH ROW
BEGIN
  --¿EXISTE AL MENOS UN REGISTRO ASI?
    IF EXISTS (
        SELECT 1
        FROM pizzaingrediente pi
  --CONECTAR LA RECETA DE LA PIZZA CON INGREDIENTES
        JOIN ingrediente i
            ON pi.id_ingrediente = i.id_ingrediente
        WHERE pi.id_pizza = NEW.id_pizza
          AND i.stock_actual < (pi.cantidad_necesaria * NEW.cantidad)
    ) THEN
  --SI NO ALCANZAN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay suficiente stock para preparar esta pizza';
    END IF;
END$$

DELIMITER ;

--COMPLEMENTO DE LAS PROCEDURES:
DROP TRIGGER IF EXISTS trg_domicilio_marcar_entregado;
DELIMITER $$
CREATE TRIGGER trg_domicilio_marcar_entregado
AFTER UPDATE ON domicilio
FOR EACH ROW
BEGIN
  --SI EXISTE HORA DE ENTREGA
  IF NEW.hora_entrega IS NOT NULL
  --O SI ANTES NO LA HABIA PERO LA CAMBIO EN UPDATE
     AND (OLD.hora_entrega IS NULL OR OLD.hora_entrega <> NEW.hora_entrega) THEN
    UPDATE pedido
  --SE MARCA COMO ENTREGADO
    SET estado = 'entregado'
    WHERE id_pedido = NEW.id_pedido;
  END IF;
END$$
DELIMITER ;
