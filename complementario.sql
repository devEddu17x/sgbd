# 11
START TRANSACTION;
SELECT producto_id, cantidad, version
FROM inventario WHERE producto_id = 2; # vesion = 1

UPDATE inventario
SET cantidad = cantidad+1, version = version+1
WHERE producto_id = 2 AND version = 1;

ROLLBACK;
# 12
START TRANSACTION;
# fila bloquead
SELECT * FROM inventario
WHERE producto_id = 3 FOR UPDATE;

UPDATE inventario
SET cantidad = cantidad +1
WHERE producto_id = 3;
COMMIT;
use dbSistemaGestion;
select current_role();

show grants for 'nuevo_usuario'@'localhost';
SELECT * FROM inventario
WHERE producto_id = 3;

update inventario
set version = 10
where producto_id = 3;