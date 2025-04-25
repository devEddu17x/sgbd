-- Crear la base de datos y seleccionarla
CREATE DATABASE IF NOT EXISTS dbSistemaGestion;
USE dbSistemaGestion;
-- Tabla de Roles
DROP TABLE IF EXISTS roles;
CREATE TABLE roles (
id INT AUTO_INCREMENT PRIMARY KEY,
role_name VARCHAR(50) NOT NULL UNIQUE
);
-- Tabla de Usuarios (para gestionar usuarios de la aplicación)
DROP TABLE IF EXISTS usuarios;
CREATE TABLE usuarios (
id INT AUTO_INCREMENT PRIMARY KEY,
username VARCHAR(50) NOT NULL UNIQUE,
password VARCHAR(255) NOT NULL,
role_id INT,
FOREIGN KEY (role_id) REFERENCES roles(id)
);
-- Tabla de Clientes
DROP TABLE IF EXISTS clientes;
CREATE TABLE clientes (
id INT AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
email VARCHAR(100) NOT NULL UNIQUE
);
-- Tabla de Productos
DROP TABLE IF EXISTS productos;
CREATE TABLE productos (
id INT AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
precio DECIMAL(10,2) NOT NULL
);
-- Tabla de Pedidos (representa órdenes de compra)
DROP TABLE IF EXISTS pedidos;
CREATE TABLE pedidos (
id INT AUTO_INCREMENT PRIMARY KEY,
cliente_id INT NOT NULL,
producto_id INT NOT NULL,
cantidad INT NOT NULL,
precio DECIMAL(10,2) NOT NULL,
FOREIGN KEY (cliente_id) REFERENCES clientes(id),
FOREIGN KEY (producto_id) REFERENCES productos(id)
);
-- Tabla de Ventas (para ejercicios donde se requiera solo lectura en ventas)
DROP TABLE IF EXISTS ventas;
CREATE TABLE ventas (
id INT AUTO_INCREMENT PRIMARY KEY,
cliente_id INT NOT NULL,
producto_id INT NOT NULL,
cantidad INT NOT NULL,
total DECIMAL(10,2) NOT NULL,
fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (cliente_id) REFERENCES clientes(id),
FOREIGN KEY (producto_id) REFERENCES productos(id)
);
-- Tabla de Cuentas (simula cuentas bancarias)
DROP TABLE IF EXISTS cuentas;
CREATE TABLE cuentas (
id INT AUTO_INCREMENT PRIMARY KEY,
cuenta_numero VARCHAR(20) NOT NULL UNIQUE,
saldo DECIMAL(12,2) NOT NULL,
cliente_id INT NOT NULL,
FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
-- Tabla de Transacciones (registro de movimientos en cuentas)
DROP TABLE IF EXISTS transacciones;
CREATE TABLE transacciones (
id INT AUTO_INCREMENT PRIMARY KEY,
cuenta_id INT NOT NULL,
monto DECIMAL(12,2) NOT NULL,
tipo VARCHAR(20) NOT NULL,
fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (cuenta_id) REFERENCES cuentas(id)
);
-- Tabla de Inventario (para control de existencias y versión para concurrencia optimista)
DROP TABLE IF EXISTS inventario;
CREATE TABLE inventario (
id INT AUTO_INCREMENT PRIMARY KEY,
producto_id INT NOT NULL,
cantidad INT NOT NULL,
version INT DEFAULT 1,
FOREIGN KEY (producto_id) REFERENCES productos(id)
);
-- Tabla de Auditoría para la tabla clientes
DROP TABLE IF EXISTS auditoria_clientes;
CREATE TABLE auditoria_clientes (
id INT AUTO_INCREMENT PRIMARY KEY,
accion VARCHAR(50),
usuario VARCHAR(50),
fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
detalles TEXT
);
-- Tablas adicionales para ejercicios de manejo de errores (tabla1 y tabla2)
DROP TABLE IF EXISTS tabla1;
CREATE TABLE tabla1 (
id INT AUTO_INCREMENT PRIMARY KEY,
columnaA VARCHAR(50),
columnaB VARCHAR(50)
);
DROP TABLE IF EXISTS tabla2;
CREATE TABLE tabla2 (
id INT AUTO_INCREMENT PRIMARY KEY,
columnaX VARCHAR(50),
columnaY VARCHAR(50)
);
-- Insertar datos en roles
INSERT INTO roles (role_name) VALUES
('db_writer'),
('analista'),
('financiero'),
('administrativo');
-- Insertar datos en usuarios (simulación de usuarios de la aplicación)
INSERT INTO usuarios (username, password, role_id) VALUES
('nuevo_usuario', 'pass123', 1),
('usuario_analista', 'pass456', 2),
('usuario1', 'securepass', 4);
-- Insertar datos en clientes
INSERT INTO clientes (nombre, email) VALUES
('Juan Perez', 'juanperez@mail.com'),
('Maria Lopez', 'marialopez@mail.com');
-- Insertar datos en productos
INSERT INTO productos (nombre, precio) VALUES
('Laptop', 1500.00),
('Mouse', 25.00),
('Teclado', 45.00);
-- Insertar datos en pedidos
INSERT INTO pedidos (cliente_id, producto_id, cantidad, precio) VALUES
(1, 1, 1, 1500.00),
(2, 2, 2, 50.00);
-- Insertar datos en ventas
INSERT INTO ventas (cliente_id, producto_id, cantidad, total) VALUES
(1, 3, 1, 45.00),
(2, 1, 1, 1500.00);
-- Insertar datos en cuentas
INSERT INTO cuentas (cuenta_numero, saldo, cliente_id) VALUES
('ACC1001', 5000.00, 1),
('ACC1002', 3000.00, 2);
-- Insertar datos en transacciones
INSERT INTO transacciones (cuenta_id, monto, tipo) VALUES
(1, 1000.00, 'deposito'),
(2, 500.00, 'retiro');
-- Insertar datos en inventario
INSERT INTO inventario (producto_id, cantidad, version) VALUES
(1, 10, 1),
(2, 100, 1),
(3, 50, 1);
-- Insertar datos en tablas adicionales
INSERT INTO tabla1 (columnaA, columnaB) VALUES ('valor1', 'valor2');
INSERT INTO tabla2 (columnaX, columnaY) VALUES ('valor3', 'valor4');