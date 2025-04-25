# Vista: vista_detalle_pedidos

#    Muestra el nombre del cliente, nombre del producto, cantidad y precio de cada pedido.

#    Incluye un campo calculado subtotal (cantidad * precio).
drop view vista_detalle_pedidos;
CREATE VIEW vista_detalle_pedidos AS
SELECT c.nombre as cliente, p.nombre as producto, pe.cantidad, pe.precio, (pe.cantidad * pe.precio) as subtotal
FROM clientes c
JOIN pedidos pe on pe.cliente_id = c.id
JOIN productos p on pe.producto_id = p.id;

select * from vista_detalle_pedidos;

# Vista: vista_saldo_clientes

#    Muestra el nombre del cliente, el número de cuenta y su saldo.

#    Útil para reportes financieros.

CREATE VIEW vista_saldo_clientes AS
SELECT c.nombre, cu.saldo, cu.cuenta_numero
FROM clientes c
JOIN cuentas cu on cu.cliente_id = c.id;

select * from vista_saldo_clientes;


# Vista: vista_ventas_diarias

#    Muestra todas las ventas del día actual (utiliza CURDATE()).

#    Incluye cliente, producto, cantidad, total y hora exacta de la venta.
CREATE VIEW vista_ventas_diarias AS
select c.nombre as cliente, p.nombre producto, v.cantidad, v.total, v.fecha
from clientes c
join ventas v on v.cliente_id = c.id
join productos p on v.producto_id = p.id
where DATE(fecha) = CURDATE();

select * from vista_ventas_diarias;

# Vista: vista_inventario_actualizado

#    Muestra el nombre del producto, cantidad actual en inventario y versión.


create view vista_inventario_actualizado as
select p.nombre, i.cantidad, i.version
from productos p
join inventario i on i.producto_id = p.id;

select * from vista_inventario_actualizado;



# PROCEDIMIENTOS


#sp_insertar_pedido

 #   Inserta un nuevo pedido.

  #  Recibe: cliente_id, producto_id, cantidad.

   # Calcula el precio desde la tabla productos y lo inserta.
DELIMITER //
create procedure p_insertar_pedido(IN  v_cliente_id int, in v_producto_id int, in v_cantidad int)
begin
	insert into pedidos(cliente_id, producto_id, cantidad, precio)
    values(v_cliente_id, v_producto_id, v_cantidad, (select precio from productos where id = v_producto_id));
end
//
DELIMITER ;

call p_insertar_pedido(1, 1, 2);

select * from pedidos;

# transferencia
drop procedure p_retiro;
DELIMITER !!
create procedure p_retiro(in v_monto decimal(12,2), in v_cliente_id int, in v_cuenta_numero varchar(20)) 
begin 
	update cuentas
    set saldo = saldo-v_monto
    where cuenta_numero = v_cuenta_numero;
    
    insert into transacciones(cuenta_id, monto, tipo)
    values ((select id from cuentas where cuenta_numero = v_cuenta_numero),
			v_monto, 'retiro');
	
    select * from transacciones
    order by fecha desc
    limit 1;
end
!!
DELIMITER ;


call p_retiro(50, 1, 'ACC1001');

select * from cuentas;
