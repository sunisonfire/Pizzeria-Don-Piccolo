DROP DATABASE IF EXISTS `lapizzeria_don_piccolo`;
CREATE DATABASE `lapizzeria_don_piccolo` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `lapizzeria_don_piccolo`;

CREATE TABLE `persona` (
  `id_persona` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `apellido` VARCHAR(100) NOT NULL,
  `telefono` VARCHAR(20) NOT NULL,
  `direccion` VARCHAR(150) NOT NULL,
  `correo` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_persona`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cliente` (
  `id_persona` INT NOT NULL,
  PRIMARY KEY (`id_persona`),
  CONSTRAINT `fk_cliente_persona`
    FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `zona` (
  `id_zona` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(50) NOT NULL UNIQUE,
  PRIMARY KEY (`id_zona`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `repartidor` (
  `id_persona` INT NOT NULL,
  `id_zona` INT NOT NULL,
  `estado` ENUM('disponible','no_disponible') NOT NULL DEFAULT 'disponible',
  PRIMARY KEY (`id_persona`),
  INDEX `idx_repartidor_zona` (`id_zona`),
  CONSTRAINT `fk_repartidor_persona`
    FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_repartidor_zona`
    FOREIGN KEY (`id_zona`) REFERENCES `zona` (`id_zona`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `ingrediente` (
  `id_ingrediente` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL UNIQUE,
  `disponible` BOOLEAN NOT NULL DEFAULT TRUE,
  `stock_actual` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `stock_minimo` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `costo_unitario` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id_ingrediente`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pizza` (
  `id_pizza` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `tamano` ENUM('pequena','mediana','grande','familiar') NOT NULL,
  `precio_base` DECIMAL(10,2) NOT NULL,
  `tipo` ENUM('vegetariana','especial','clasica') NOT NULL,
  `disponible` BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (`id_pizza`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pizzaingrediente` (
  `id_pizza` INT NOT NULL,
  `id_ingrediente` INT NOT NULL,
  `cantidad_necesaria` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_pizza`,`id_ingrediente`),
  INDEX `idx_pi_ingrediente` (`id_ingrediente`),
  CONSTRAINT `fk_pi_pizza`
    FOREIGN KEY (`id_pizza`) REFERENCES `pizza` (`id_pizza`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_pi_ingrediente`
    FOREIGN KEY (`id_ingrediente`) REFERENCES `ingrediente` (`id_ingrediente`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pedido` (
  `id_pedido` INT NOT NULL AUTO_INCREMENT,
  `id_cliente` INT NOT NULL,
  `fecha_hora` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `metodo_pago` ENUM('efectivo','tarjeta','app') NOT NULL,
  `estado` ENUM('pendiente','en_preparacion','entregado','cancelado') NOT NULL DEFAULT 'pendiente',
  `lugar` ENUM('local','domicilio') NOT NULL,
  `subtotal` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `total` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id_pedido`),
  INDEX `idx_pedido_cliente` (`id_cliente`),
  CONSTRAINT `fk_pedido_cliente`
    FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_persona`)
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `detallepedido` (
  `id_detalle` INT NOT NULL AUTO_INCREMENT,
  `id_pedido` INT NOT NULL,
  `id_pizza` INT NOT NULL,
  `cantidad` INT NOT NULL DEFAULT 1,
  `precio_unitario` DECIMAL(10,2) NOT NULL,
  `subtotal` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_detalle`),
  INDEX `idx_detalle_pedido` (`id_pedido`),
  INDEX `idx_detalle_pizza` (`id_pizza`),
  CONSTRAINT `fk_detalle_pedido`
    FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_detalle_pizza`
    FOREIGN KEY (`id_pizza`) REFERENCES `pizza` (`id_pizza`)
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `domicilio` (
  `id_domicilio` INT NOT NULL AUTO_INCREMENT,
  `id_pedido` INT NOT NULL,
  `id_repartidor` INT NULL,
  `id_zona` INT NOT NULL,
  `hora_salida` DATETIME NULL DEFAULT NULL,
  `hora_entrega` DATETIME NULL DEFAULT NULL,
  `distancia_km` DECIMAL(6,2) NULL,
  `costo_envio` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_domicilio`),
  UNIQUE INDEX `uq_domicilio_pedido` (`id_pedido`),
  INDEX `idx_domicilio_repartidor` (`id_repartidor`),
  INDEX `idx_domicilio_zona` (`id_zona`),
  CONSTRAINT `fk_domicilio_pedido`
    FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_domicilio_repartidor`
    FOREIGN KEY (`id_repartidor`) REFERENCES `repartidor` (`id_persona`)
    ON DELETE SET NULL,
  CONSTRAINT `fk_domicilio_zona`
    FOREIGN KEY (`id_zona`) REFERENCES `zona` (`id_zona`)
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pago` (
  `id_pago` INT NOT NULL AUTO_INCREMENT,
  `id_pedido` INT NOT NULL,
  `metodo` ENUM('efectivo','tarjeta','app') NOT NULL,
  `monto` DECIMAL(10,2) NOT NULL,
  `fecha_pago` DATETIME NULL DEFAULT NULL,
  `estado_pago` ENUM('pendiente','completado','rechazado') NOT NULL DEFAULT 'pendiente',
  PRIMARY KEY (`id_pago`),
  UNIQUE INDEX `uq_pago_pedido` (`id_pedido`),
  CONSTRAINT `fk_pago_pedido`
    FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `historial_precios` (
  `id_historial` INT NOT NULL AUTO_INCREMENT,
  `id_pizza` INT NOT NULL,
  `precio_anterior` DECIMAL(10,2) NOT NULL,
  `precio_nuevo` DECIMAL(10,2) NOT NULL,
  `fecha_cambio` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_historial`),
  INDEX `idx_historial_pizza` (`id_pizza`),
  CONSTRAINT `fk_historial_pizza`
    FOREIGN KEY (`id_pizza`) REFERENCES `pizza` (`id_pizza`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

USE `lapizzeria_don_piccolo`;

INSERT INTO `persona` (`id_persona`, `nombre`, `apellido`, `telefono`, `direccion`, `correo`) VALUES
(1, 'Carlos', 'Ramirez', '3001112233', 'Calle 10 #5-20', 'carlos.ramirez@mail.com'),
(2, 'Ana', 'Gomez', '3002223344', 'Carrera 15 #22-30', 'ana.gomez@mail.com'),
(3, 'Luis', 'Fernandez', '3003334455', 'Calle 45 #12-08', 'luis.fernandez@mail.com'),
(4, 'Maria', 'Lopez', '3004445566', 'Carrera 7 #33-15', 'maria.lopez@mail.com'),
(5, 'Jorge', 'Martinez', '3005556677', 'Calle 80 #9-10', 'jorge.martinez@mail.com'),
(6, 'Paula', 'Diaz', '3006667788', 'Carrera 20 #18-25', 'paula.diaz@mail.com'),
(7, 'Andres', 'Torres', '3007778899', 'Calle 100 #14-40', 'andres.torres@mail.com'),
(8, 'Sofia', 'Castro', '3008889900', 'Carrera 3 #50-12', 'sofia.castro@mail.com'),
(9, 'Miguel', 'Rojas', '3009990011', 'Calle 25 #6-18', 'miguel.rojas@mail.com'),
(10, 'Laura', 'Perez', '3010001122', 'Carrera 30 #40-05', 'laura.perez@mail.com'),
(11, 'David', 'Suarez', '3011112233', 'Calle 60 #21-33', 'david.suarez@mail.com'),
(12, 'Camila', 'Vargas', '3012223344', 'Carrera 12 #10-50', 'camila.vargas@mail.com'),
(13, 'Santiago', 'Medina', '3013334455', 'Calle 90 #8-15', 'santiago.medina@mail.com'),
(14, 'Isabella', 'Rojas', '3014445566', 'Carrera 55 #30-10', 'isabella.rojas@mail.com');

INSERT INTO `cliente` (`id_persona`) VALUES
(1), (2), (3), (4), (5), (6), (7), (8);

INSERT INTO `zona` (`id_zona`, `nombre`) VALUES
(1, 'Centro'),
(2, 'Norte'),
(3, 'Sur'),
(4, 'Chapinero'),
(5, 'Usaquen'),
(6, 'Suba');

INSERT INTO `repartidor` (`id_persona`, `id_zona`, `estado`) VALUES
(9, 1, 'disponible'),
(10, 2, 'disponible'),
(11, 3, 'no_disponible'),
(12, 4, 'disponible'),
(13, 5, 'disponible'),
(14, 6, 'no_disponible');

INSERT INTO `ingrediente` (`id_ingrediente`, `nombre`, `disponible`, `stock_actual`, `stock_minimo`, `costo_unitario`) VALUES
(1, 'Queso mozzarella', TRUE, 50.00, 10.00, 1200.00),
(2, 'Salsa de tomate', TRUE, 40.00, 8.00, 800.00),
(3, 'Pepperoni', TRUE, 25.00, 5.00, 2500.00),
(4, 'Pina', TRUE, 15.00, 3.00, 1500.00),
(5, 'Jamon', TRUE, 20.00, 4.00, 2200.00),
(6, 'Champinones', TRUE, 18.00, 4.00, 1800.00),
(7, 'Aceitunas', TRUE, 12.00, 3.00, 1600.00),
(8, 'Pimenton', TRUE, 22.00, 5.00, 1000.00);

INSERT INTO `pizza` (`id_pizza`, `nombre`, `tamano`, `precio_base`, `tipo`, `disponible`) VALUES
(1, 'Margarita', 'mediana', 25000.00, 'clasica', TRUE),
(2, 'Pepperoni', 'grande', 32000.00, 'clasica', TRUE),
(3, 'Hawaiana', 'mediana', 28000.00, 'especial', TRUE),
(4, 'Vegetariana', 'pequena', 22000.00, 'vegetariana', TRUE),
(5, 'Cuatro Quesos', 'familiar', 45000.00, 'especial', TRUE),
(6, 'Napolitana', 'grande', 30000.00, 'clasica', TRUE);

INSERT INTO `pizzaingrediente` (`id_pizza`, `id_ingrediente`, `cantidad_necesaria`) VALUES
(1, 1, 0.20), (1, 2, 0.15),
(2, 1, 0.20), (2, 2, 0.15), (2, 3, 0.10),
(3, 1, 0.20), (3, 2, 0.15), (3, 5, 0.10), (3, 4, 0.10),
(4, 1, 0.20), (4, 2, 0.15), (4, 6, 0.10), (4, 8, 0.10),
(5, 1, 0.30), (5, 2, 0.10),
(6, 1, 0.20), (6, 2, 0.15), (6, 7, 0.08), (6, 8, 0.08);

INSERT INTO `pedido` (`id_pedido`, `id_cliente`, `fecha_hora`, `metodo_pago`, `estado`, `lugar`, `subtotal`, `total`) VALUES
(1, 1, '2026-08-01 12:30:00', 'efectivo', 'entregado', 'domicilio', 25000.00, 29750.00),
(2, 2, '2026-08-02 13:15:00', 'tarjeta', 'entregado', 'local', 32000.00, 38080.00),
(3, 3, '2026-08-03 19:00:00', 'app', 'entregado', 'domicilio', 50000.00, 59500.00),
(4, 4, '2026-08-04 20:10:00', 'efectivo', 'entregado', 'local', 22000.00, 26180.00),
(5, 5, '2026-08-05 18:45:00', 'tarjeta', 'en_preparacion', 'domicilio', 45000.00, 53550.00),
(6, 6, '2026-08-06 12:00:00', 'app', 'pendiente', 'local', 30000.00, 35700.00),
(7, 7, '2026-08-07 21:00:00', 'efectivo', 'cancelado', 'domicilio', 25000.00, 29750.00),
(8, 8, '2026-08-08 14:20:00', 'tarjeta', 'entregado', 'domicilio', 32000.00, 38080.00),
(9, 1, '2026-08-09 13:00:00', 'app', 'entregado', 'local', 28000.00, 33320.00),
(10, 2, '2026-08-10 19:30:00', 'efectivo', 'en_preparacion', 'domicilio', 22000.00, 26180.00),
(11, 3, '2026-08-11 20:00:00', 'tarjeta', 'pendiente', 'local', 45000.00, 53550.00),
(12, 4, '2026-08-12 12:40:00', 'app', 'entregado', 'domicilio', 55000.00, 65450.00);

INSERT INTO `detallepedido` (`id_detalle`, `id_pedido`, `id_pizza`, `cantidad`, `precio_unitario`, `subtotal`) VALUES
(1, 1, 1, 1, 25000.00, 25000.00),
(2, 2, 2, 1, 32000.00, 32000.00),
(3, 3, 3, 1, 28000.00, 28000.00),
(4, 3, 4, 1, 22000.00, 22000.00),
(5, 3, 1, 0, 0.00, 0.00),
(6, 4, 4, 1, 22000.00, 22000.00),
(7, 5, 5, 1, 45000.00, 45000.00),
(8, 6, 6, 1, 30000.00, 30000.00),
(9, 7, 1, 1, 25000.00, 25000.00),
(10, 8, 2, 1, 32000.00, 32000.00),
(11, 9, 3, 1, 28000.00, 28000.00),
(12, 10, 4, 1, 22000.00, 22000.00),
(13, 11, 5, 1, 45000.00, 45000.00),
(14, 12, 6, 1, 30000.00, 30000.00),
(15, 12, 1, 1, 25000.00, 25000.00),
(16, 12, 4, 0, 0.00, 5000.00);

INSERT INTO `domicilio` (`id_domicilio`, `id_pedido`, `id_repartidor`, `id_zona`, `hora_salida`, `hora_entrega`, `distancia_km`, `costo_envio`) VALUES
(1, 1, 9, 1, '2026-08-01 12:40:00', '2026-08-01 13:00:00', 3.20, 4000.00),
(2, 3, 10, 2, '2026-08-03 19:10:00', '2026-08-03 19:35:00', 2.80, 3500.00),
(3, 5, 12, 4, '2026-08-05 18:55:00', NULL, 5.10, 5500.00),
(4, 7, 13, 5, '2026-08-07 21:10:00', NULL, 4.00, 4500.00),
(5, 8, 9, 1, '2026-08-08 14:30:00', '2026-08-08 14:55:00', 6.30, 6000.00),
(6, 10, 14, 6, '2026-08-10 19:40:00', NULL, 3.50, 4200.00),
(7, 12, 10, 2, '2026-08-12 12:50:00', '2026-08-12 13:15:00', 2.10, 3200.00);

INSERT INTO `pago` (`id_pago`, `id_pedido`, `metodo`, `monto`, `fecha_pago`, `estado_pago`) VALUES
(1, 1, 'efectivo', 29750.00, '2026-08-01 13:05:00', 'completado'),
(2, 2, 'tarjeta', 38080.00, '2026-08-02 13:20:00', 'completado'),
(3, 3, 'app', 63070.00, '2026-08-03 19:40:00', 'completado'),
(4, 4, 'efectivo', 26180.00, '2026-08-04 20:15:00', 'completado'),
(5, 5, 'tarjeta', 53550.00, NULL, 'pendiente'),
(6, 6, 'app', 35700.00, NULL, 'pendiente'),
(7, 7, 'efectivo', 29750.00, NULL, 'rechazado'),
(8, 8, 'tarjeta', 38080.00, '2026-08-08 15:00:00', 'completado'),
(9, 9, 'app', 33320.00, '2026-08-09 13:10:00', 'completado'),
(10, 10, 'efectivo', 26180.00, NULL, 'pendiente'),
(11, 11, 'tarjeta', 53550.00, NULL, 'pendiente'),
(12, 12, 'app', 71400.00, '2026-08-12 13:20:00', 'completado');

INSERT INTO `historial_precios` (`id_historial`, `id_pizza`, `precio_anterior`, `precio_nuevo`, `fecha_cambio`) VALUES
(1, 1, 23000.00, 25000.00, '2026-07-01 09:00:00'),
(2, 2, 30000.00, 32000.00, '2026-07-05 09:00:00'),
(3, 5, 42000.00, 45000.00, '2026-07-15 09:00:00');


--MOSTRAR TABLAS
SELECT * FROM persona;
SELECT * FROM cliente;
SELECT * FROM zona;
SELECT * FROM repartidor;
SELECT * FROM ingrediente;
SELECT * FROM pizza;
SELECT * FROM pizzaingrediente;
SELECT * FROM pedido;
SELECT * FROM detallepedido;
SELECT * FROM domicilio;
SELECT * FROM pago;
SELECT * FROM historial_precios;