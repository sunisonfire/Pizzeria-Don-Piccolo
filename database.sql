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
