DROP DATABASE IF EXISTS `thepizzeria_don_piccolo`;
CREATE DATABASE `thepizzeria_don_piccolo` 
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE thepizzeria_don_piccolo;

CREATE TABLE persona (
  id_persona  INT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL,
  apellido    VARCHAR(100) NOT NULL,
  telefono    VARCHAR(20)  NOT NULL,
  direccion   VARCHAR(150) NOT NULL,
  correo      VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE zona (
  id_zona INT AUTO_INCREMENT PRIMARY KEY,
  nombre  VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE cliente (
  id_persona INT PRIMARY KEY,
  CONSTRAINT fk_cliente_persona FOREIGN KEY (id_persona)
    REFERENCES persona(id_persona) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE repartidor (
  id_persona INT PRIMARY KEY,
  id_zona    INT NOT NULL,
  estado     ENUM('disponible','no_disponible') NOT NULL DEFAULT 'disponible',
  CONSTRAINT fk_repartidor_persona FOREIGN KEY (id_persona)
    REFERENCES persona(id_persona) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_repartidor_zona FOREIGN KEY (id_zona)
    REFERENCES zona(id_zona) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pizza (
  id_pizza     INT AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(100) NOT NULL,
  tamano       ENUM('pequena','mediana','grande','familiar') NOT NULL,
  precio_base  DOUBLE NOT NULL,
  tipo         ENUM('vegetariana','especial','clasica') NOT NULL,
  disponible   TINYINT(1) NOT NULL DEFAULT 1,
  CHECK (precio_base > 0)
) ENGINE=InnoDB;

CREATE TABLE ingrediente (
  id_ingrediente  INT AUTO_INCREMENT PRIMARY KEY,
  nombre          VARCHAR(100) NOT NULL,
  disponible      TINYINT(1) NOT NULL DEFAULT 1,
  stock_actual    DOUBLE NOT NULL DEFAULT 0,
  stock_minimo    DOUBLE NOT NULL DEFAULT 0,
  costo_unitario  DOUBLE NOT NULL DEFAULT 0,
  CHECK (stock_actual >= 0),
  CHECK (stock_minimo >= 0)
) ENGINE=InnoDB;

CREATE TABLE pizzaingrediente (
  id_pizza            INT NOT NULL,
  id_ingrediente      INT NOT NULL,
  cantidad_necesaria  DOUBLE NOT NULL,
  PRIMARY KEY (id_pizza, id_ingrediente),
  CONSTRAINT fk_pi_pizza FOREIGN KEY (id_pizza)
    REFERENCES pizza(id_pizza) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pi_ingrediente FOREIGN KEY (id_ingrediente)
    REFERENCES ingrediente(id_ingrediente) ON DELETE CASCADE ON UPDATE CASCADE,
  CHECK (cantidad_necesaria > 0)
) ENGINE=InnoDB;

CREATE TABLE pedido (
  id_pedido     INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente    INT NOT NULL,
  fecha_hora    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  metodo_pago   ENUM('efectivo','tarjeta','app') NOT NULL,
  estado        ENUM('pendiente','en_preparacion','entregado','cancelado') NOT NULL DEFAULT 'pendiente',
  lugar         ENUM('local','domicilio') NOT NULL,
  subtotal      DOUBLE NOT NULL DEFAULT 0,
  total         DOUBLE NOT NULL DEFAULT 0,
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente(id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_pedido_cliente (id_cliente),
  INDEX idx_pedido_fecha (fecha_hora)
) ENGINE=InnoDB;

CREATE TABLE detallepedido (
  id_detalle       INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido        INT NOT NULL,
  id_pizza         INT NOT NULL,
  cantidad         INT NOT NULL DEFAULT 1,
  precio_unitario  DOUBLE NOT NULL,
  subtotal         DOUBLE AS (cantidad * precio_unitario) STORED,
  CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido)
    REFERENCES pedido(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_detalle_pizza FOREIGN KEY (id_pizza)
    REFERENCES pizza(id_pizza) ON DELETE RESTRICT ON UPDATE CASCADE,
  CHECK (cantidad > 0),
  INDEX idx_detalle_pedido (id_pedido),
  INDEX idx_detalle_pizza (id_pizza)
) ENGINE=InnoDB;

CREATE TABLE domicilio (
  id_domicilio   INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido      INT NOT NULL,
  id_repartidor  INT NULL,
  id_zona        INT NOT NULL,
  hora_salida    DATETIME NULL,
  hora_entrega   DATETIME NULL,
  distancia_km   DOUBLE NULL,
  costo_envio    DOUBLE NOT NULL,
  CONSTRAINT fk_domicilio_pedido FOREIGN KEY (id_pedido)
    REFERENCES pedido(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_domicilio_repartidor FOREIGN KEY (id_repartidor)
    REFERENCES repartidor(id_persona) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_domicilio_zona FOREIGN KEY (id_zona)
    REFERENCES zona(id_zona) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT uq_domicilio_pedido UNIQUE (id_pedido),
  INDEX idx_domicilio_repartidor (id_repartidor),
  INDEX idx_domicilio_zona (id_zona)
) ENGINE=InnoDB;

CREATE TABLE pago (
  id_pago      INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido    INT NOT NULL,
  metodo       ENUM('efectivo','tarjeta','app') NOT NULL,
  monto        DOUBLE NOT NULL,
  fecha_pago   DATETIME NULL,
  estado_pago  ENUM('pendiente','completado','rechazado') NOT NULL DEFAULT 'pendiente',
  CONSTRAINT fk_pago_pedido FOREIGN KEY (id_pedido)
    REFERENCES pedido(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT uq_pago_pedido UNIQUE (id_pedido)
) ENGINE=InnoDB;

CREATE TABLE historial_precios (
  id_historial     INT AUTO_INCREMENT PRIMARY KEY,
  id_pizza         INT NOT NULL,
  precio_anterior  DOUBLE NOT NULL,
  precio_nuevo     DOUBLE NOT NULL,
  fecha_cambio     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_historial_pizza FOREIGN KEY (id_pizza)
    REFERENCES pizza(id_pizza) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_historial_pizza (id_pizza)
) ENGINE=InnoDB;

--Datitos de insert:
INSERT INTO zona (nombre) VALUES
('Norte'),
('Centro'),
('Sur');

INSERT INTO persona (nombre, apellido, telefono, direccion, correo) VALUES
('Ana', 'Torres', '3001112233', 'Calle 10 #5-20', 'ana.torres@mail.com'),
('Carlos', 'Ramírez', '3002223344', 'Carrera 15 #8-40', 'carlos.ramirez@mail.com'),
('Laura', 'Gómez', '3003334455', 'Avenida 30 #12-10', 'laura.gomez@mail.com'),
('Andrés', 'Pérez', '3004445566', 'Calle 45 #20-15', 'andres.perez@mail.com'),
('Diana', 'Ruiz', '3005556677', 'Carrera 7 #22-30', 'diana.ruiz@mail.com'),
('Miguel Ángel', 'Soto', '3006667788', 'Calle 80 #33-12', 'miguel.soto@mail.com'),
('Sofía', 'Herrera', '3007778899', 'Carrera 50 #18-25', 'sofia.herrera@mail.com'),
('Jorge', 'Londoño', '3008889900', 'Calle 100 #40-05', 'jorge.londono@mail.com');

INSERT INTO cliente (id_persona) VALUES (1), (2), (3), (7), (8);

INSERT INTO repartidor (id_persona, id_zona, estado) VALUES
(4, 1, 'disponible'),
(5, 2, 'disponible'),
(6, 3, 'disponible');

INSERT INTO pizza (nombre, tamano, precio_base, tipo) VALUES
('Margarita', 'mediana', 32000, 'clasica'),
('Pepperoni', 'mediana', 35000, 'clasica'),
('Hawaiana', 'grande', 40000, 'especial'),
('Vegetariana Deluxe', 'grande', 38000, 'vegetariana'),
('Cuatro Quesos', 'familiar', 45000, 'especial');

INSERT INTO ingrediente (nombre, stock_actual, stock_minimo, costo_unitario) VALUES
('Masa', 500, 50, 1500),
('Salsa de tomate', 300, 30, 800),
('Queso mozzarella', 200, 40, 3000),
('Pepperoni', 150, 20, 4000),
('Jamón', 100, 20, 3500),
('Piña', 10, 15, 2000),
('Champiñones', 6, 15, 2500),
('Pimentón', 70, 15, 1800);

INSERT INTO pizzaingrediente (id_pizza, id_ingrediente, cantidad_necesaria) VALUES
(1, 1, 1), (1, 2, 1), (1, 3, 1),
(2, 1, 1), (2, 2, 1), (2, 3, 1), (2, 4, 2),
(3, 1, 1), (3, 2, 1), (3, 3, 1), (3, 5, 2), (3, 6, 2),
(4, 1, 1), (4, 2, 1), (4, 3, 1), (4, 7, 2), (4, 8, 2),
(5, 1, 1), (5, 2, 1), (5, 3, 3);

INSERT INTO pedido (id_cliente, fecha_hora, metodo_pago, estado, lugar, subtotal, total) VALUES
(1, '2026-08-03 12:00:00', 'tarjeta',  'entregado',      'domicilio', 99000, 123760.00),
(2, '2026-08-05 13:00:00', 'efectivo', 'entregado',      'domicilio', 75000, 96390.00),
(1, '2026-08-06 13:20:00', 'efectivo', 'entregado',      'local',     40000, 47600.00),
(3, '2026-08-07 18:00:00', 'tarjeta',  'cancelado',      'local',     32000, 38080.00),
(1, '2026-08-10 19:00:00', 'app',      'entregado',      'domicilio', 83000, 104720.00),
(7, '2026-08-14 19:50:00', 'app',      'entregado',      'domicilio', 76000, 98770.00),
(1, '2026-08-15 20:10:00', 'efectivo', 'entregado',      'local',     70000, 83300.00),
(1, '2026-08-20 12:30:00', 'tarjeta',  'pendiente',      'domicilio', 32000, 44030.00),
(8, '2026-08-22 20:15:00', 'efectivo', 'pendiente',      'domicilio', 77000, 98770.00),
(1, '2026-08-25 21:00:00', 'app',      'en_preparacion', 'local',     45000, 53550.00);

INSERT INTO detallepedido (id_pedido, id_pizza, cantidad, precio_unitario) VALUES
(1, 1, 2, 32000), (1, 2, 1, 35000),
(2, 3, 1, 40000), (2, 2, 1, 35000),
(3, 3, 1, 40000),
(4, 1, 1, 32000),
(5, 4, 1, 38000), (5, 5, 1, 45000),
(6, 4, 2, 38000),
(7, 2, 2, 35000),
(8, 1, 1, 32000),
(9, 5, 1, 45000), (9, 1, 1, 32000),
(10, 5, 1, 45000);

INSERT INTO domicilio (id_pedido, id_repartidor, id_zona, hora_salida, hora_entrega, distancia_km, costo_envio) VALUES
(1, 4, 1, '2026-08-03 12:15:00', '2026-08-03 12:45:00', 3.2, 5000),
(2, 5, 2, '2026-08-05 13:10:00', '2026-08-05 13:40:00', 4.1, 6000),
(5, 4, 1, '2026-08-10 19:05:00', '2026-08-10 19:30:00', 2.8, 5000),
(6, 6, 3, '2026-08-14 20:00:00', '2026-08-14 20:35:00', 5.0, 7000),
(8, 4, 1, NULL, NULL, NULL, 5000),
(9, 5, 2, NULL, NULL, NULL, 6000);

INSERT INTO pago (id_pedido, metodo, monto, fecha_pago, estado_pago) VALUES
(1, 'tarjeta',  123760.00, '2026-08-03 12:05:00', 'completado'),
(2, 'efectivo', 96390.00,  '2026-08-05 13:05:00', 'completado'),
(3, 'efectivo', 47600.00,  '2026-08-06 13:25:00', 'completado'),
(4, 'tarjeta',  38080.00,  NULL,                  'rechazado'),
(5, 'app',      104720.00, '2026-08-10 19:02:00', 'completado'),
(6, 'app',      98770.00,  '2026-08-14 19:52:00', 'completado'),
(7, 'efectivo', 83300.00,  '2026-08-15 20:12:00', 'completado'),
(8, 'tarjeta',  44030.00,  NULL,                  'pendiente'),
(9, 'efectivo', 98770.00,  NULL,                  'pendiente'),
(10, 'app',     53550.00,  NULL,                  'pendiente');

--MOSTRAR TABLAS
SELECT * FROM persona;
SELECT * FROM zona;
SELECT * FROM cliente;
SELECT * FROM repartidor;
SELECT * FROM pizza;
SELECT * FROM ingrediente;
SELECT * FROM pizzaingrediente;
SELECT * FROM pedido;
SELECT * FROM detallepedido;
SELECT * FROM domicilio;
SELECT * FROM pago;
SELECT * FROM historial_precios;
