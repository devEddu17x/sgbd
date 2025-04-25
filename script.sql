# Ejercicio 1: Utilizando el entorno de trabajo, crea un rol a nivel de base de datos
# llamado db_writer y concédele permisos para realizar operaciones de inserción,
# actualización y eliminación sobre todas las tablas de la base de datos dbSistemaGestion.
# Luego, crea un usuario llamado nuevo_usuario con contraseña segura, asigna el rol
# creado a dicho usuario y configúralo como rol por defecto.

CREATE ROLE 'db_writer';
GRANT INSERT, UPDATE, DELETE ON dbSistemaGestion.* TO 'db_writer';
CREATE USER 'nuevo_usuario'@'localhost' IDENTIFIED BY 'password';

GRANT 'db_writer' TO 'nuevo_usuario'@'localhost';
SET DEFAULT ROLE 'db_writer' TO 'nuevo_usuario'@'localhost';

SHOW GRANTS FOR 'nuevo_usuario'@'localhost';

# Ejercicio 2: Crea un rol denominado analista y otórgale permisos de solo lectura
# (SELECT) sobre la tabla ventas. Luego, crea un usuario usuario_analista y asócialo con el
# rol analista

CREATE ROLE 'analista';
GRANT SELECT ON dbSistemaGestion.ventas TO 'analista';
CREATE USER 'usuario_analista'@'localhost' IDENTIFIED BY 'password';
GRANT 'analista' TO 'usuario_analista'@'localhost';
SET DEFAULT ROLE 'analista' TO 'usuario_analista'@'localhost';

SHOW GRANTS FOR 'usuario_analista'@'localhost';

# Ejercicio 3: El usuario usuario1 (creado en el entorno de la tabla usuarios) se le había
# asignado el permiso para insertar datos en la tabla productos. Revoca ese permiso

CREATE USER 'usuario1'@'localhost' IDENTIFIED BY 'password';
GRANT INSERT ON dbSistemaGestion.productos TO 'usuario1'@'localhost';
REVOKE INSERT ON dbSistemaGestion.productos FROM 'usuario1'@'localhost';

# Ejercicio 4: Implementa un mecanismo de auditoría para la tabla clientes. Utiliza la
# tabla auditoria_clientes y crea un trigger que registre en ella cada operación (INSERT,
# UPDATE o DELETE) realizada sobre la tabla clientes, registrando la acción, el usuario
# responsable (utilizando la función USER()) y la marca de tiempo.
DROP TRIGGER IF EXISTS CLIENTES_INSERT_LOG;
DROP TRIGGER IF EXISTS CLIENTES_UPDATE_LOG;
DROP TRIGGER IF EXISTS CLIENTES_DELETE_LOG;


DELIMITER //
CREATE TRIGGER CLIENTES_INSERT_LOG
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_clientes(accion, usuario, detalles)
    VALUES('INSERT', USER(), CONCAT('nombre_cliente: ', NEW.nombre, ', email_cliente: ', NEW.email));
END;
//

CREATE TRIGGER CLIENTES_UPDATE_LOG
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
	INSERT INTO auditoria_clientes(accion, usuario, detalles)
    VALUES('UPDATE', USER(), CONCAT('nombre_cliente: ', NEW.nombre, ', email_cliente: ', NEW.email));
END;
//

CREATE TRIGGER CLIENTES_DELETE_LOG
AFTER DELETE ON clientes
FOR EACH ROW 
BEGIN
	INSERT INTO auditoria_clientes(accion, usuario, detalles)
    VALUES('DELETE', USER(), CONCAT('nombre_cliente: ', OLD.nombre, ', email_cliente: ', OLD.email));
END;
//
DELIMITER ;

INSERT INTO clientes(nombre, email)
VALUES('edu', 'email@gmail.com');
UPDATE clientes
SET nombre = 'eddu'
WHERE nombre = 'edu';
DELETE FROM clientes
WHERE nombre = 'eddu';
select * from auditoria_clientes;
# Ejercicio 7: Utiizando la tabla pedidos, diseña una transacción que inserte dos
# registros. Simula que la segunda inserción falla (por ejemplo, por un valor negativo en
# cantidad que no cumple una posible validación). Si la segunda inserción falla, se debe
# revertir toda la transacción.

# dado que la tabla pedidos no tiene constraint para validar cantidad positiva:
ALTER TABLE pedidos ADD CONSTRAINT check_precio CHECK (cantidad > 0);

START TRANSACTION;
INSERT INTO pedidos(cliente_id, producto_id, cantidad, precio)
VALUES (1, 1, 2, 100);
INSERT INTO pedidos(cliente_id, producto_id, cantidad, precio)
VALUES (1, 1, -50, 100);
COMMIT;
ROLLBACK;

# Ejercicio 8: Explica en tus propias palabras qué es la consistencia en una transacción y
# utiliza el siguiente ejemplo: una transferencia entre dos cuentas (utiliza la tabla
# cuentas). Se debe garantizar que la suma total de fondos se mantenga constante.
select * from cuentas;
START TRANSACTION;

# Supononiendo el caso de que la cuenta ACC1001 transfiere a la cuenta ACC1002
# le corresponde disminuir su saldo
UPDATE cuentas SET saldo = saldo - 200 WHERE cuenta_numero = 'ACC1001';

# Y a la cuenta destino le corresponde aumentar su saldo en la misma cantidad
UPDATE cuentas SET saldo = saldo + 200 WHERE cuenta_numero = 'ACC1002';
# Guardar cambios si no hay fallos
COMMIT;
# Restablecer el estado de las cuentas si algo sale mal
ROLLBACK;

# Ejercicio 9: Utlizando la tabla clientes, realiza una actualización en la que se modifique
# un dato (por ejemplo, se aumente un saldo o se cambie un dato descrip?vo) y confirma
# la transacción. Explica cómo, tras el COMMIT, el dato permanece incluso si se produce
# un fallo en el sistema

START TRANSACTION;
UPDATE clientes set email = 'juanperez@gmail.com' where id = 1;
COMMIT;

# Ejercicio 10: Implementa una transacción que realice una transferencia de fondos entre
# dos cuentas, utilizando las tablas cuentas y transacciones. Deberás comprobar que se
# cumplan:
# • Atomicidad: Se realizan ambos movimientos o ninguno.
# • Consistencia: La suma total de fondos permanece igual.
# • Aislamiento: La transacción no afecta a otras concurrentes.
# • Durabilidad: Los cambios son permanentes tras el COMMIT.

START TRANSACTION;

# Obtneiendo suma inicial de saldo
SELECT sum(saldo) as total
FROM cuentas
WHERE cuenta_numero = 'ACC1002' OR cuenta_numero = 'ACC1001';

# Transferencia de 500 de ACC1002 hacia ACC1001
UPDATE cuentas SET saldo = saldo - 500 WHERE cuenta_numero = 'ACC1002';
UPDATE cuentas SET saldo = saldo + 500 WHERE cuenta_numero = 'ACC1001';

# COmprobando que la suma de saldo de ambos sea igual
SELECT sum(saldo) as total
FROM cuentas
WHERE cuenta_numero = 'ACC1002' OR cuenta_numero = 'ACC1001';

COMMIT;

# Ejercicio 11: Utlizando la tabla inventario (que cuenta con una columna version), simula
# un escenario en el que dos transacciones intentan actualizar la cantidad de un
# producto. En el caso de que la versión del registro haya cambiado, se debe abortar la
# transacción (o reintentarse).

START TRANSACTION;
SELECT producto_id, cantidad, version
FROM inventario WHERE producto_id = 2; # vesion = 1

UPDATE inventario
SET cantidad = cantidad+1, version = version+1
WHERE producto_id = 2 AND version = 1;
COMMIT;
ROLLBACK;

# Ejercicio 12: Diseña un escenario en el que dos transacciones intenten modificar la
# misma fila de la tabla inventario. U?liza el bloqueo explícito mediante SELECT ... FOR
# UPDATE para evitar conflictos.

SELECT * FROM INVENTARIO;

START TRANSACTION;
# fila bloquead
SELECT * FROM inventario
WHERE producto_id = 3 FOR UPDATE;

UPDATE inventario
SET cantidad = cantidad +1
WHERE producto_id = 3;
COMMIT;
ROLLBACK;
