-- Creación de procedimientos almacenados en el esquema Mantenimientos



create or replace PROCEDURE BuscarProductosXNomXCat(
    p_nombre_producto IN VARCHAR2 DEFAULT NULL,
    p_id_categoria IN INT DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
BEGIN
    IF p_nombre_producto IS NOT NULL THEN
        -- Buscar por nombre de producto
        OPEN p_cursor FOR SELECT * FROM Producto WHERE Nombre LIKE '%' || p_nombre_producto || '%';
    ELSIF p_id_categoria IS NOT NULL THEN
        -- Buscar por categoría
        OPEN p_cursor FOR SELECT * FROM Producto WHERE ID_Categoria = p_id_categoria;
    ELSE
        -- No se especificó ni nombre ni categoría
        p_error :='Por favor, especifique un nombre de producto o una categoría para buscar.';
         --DBMS_OUTPUT.PUT_LINE('Por favor, especifique un nombre de producto o una categoría para buscar.');
    END IF;
    EXCEPTION 
        WHEN OTHERS THEN
        p_error:= 'Error en el procedure BuscarProductosXNomXCat  '|| SQLERRM;
END;

create or replace PROCEDURE CalcImpuestosxCantProd(
    p_id_producto IN INT,
     p_resultado OUT NUMBER,
     p_error OUT VARCHAR2) 
AS
    v_cantidad_productos INT;
    v_impuestos NUMBER;
BEGIN
    -- Obtener la cantidad de productos
    SELECT Cantidad INTO v_cantidad_productos FROM Producto WHERE ID_Producto = p_id_producto;

    -- Calcular los impuestos según la cantidad de productos
    IF v_cantidad_productos < 30 THEN
        v_impuestos := CALCULARIMPUESTOS(v_cantidad_productos * 10); -- Aplica un 10% 
    ELSIF v_cantidad_productos > 100 THEN
        v_impuestos := CalcularImpuestos(v_cantidad_productos * 15); -- Aplica un 15% 
    ELSE
        v_impuestos := CalcularImpuestos(v_cantidad_productos * 13); -- Aplica un 13% por defecto
    END IF;

    p_resultado := v_impuestos;

EXCEPTION 
    WHEN OTHERS THEN
    p_error :='Error en el procedimiento CalcImpuestosxCantProd ' || SQLERRM;

END;

create or replace PROCEDURE CalcularDescuentoClienteXID(
    p_id_cliente IN INT,
    p_id_producto IN INT,
    p_resultado OUT NUMBER,
    p_error OUT VARCHAR2
) AS
    v_descuento NUMBER;
    
BEGIN
    SELECT CalcularDescuentoCliente(p_id_producto)
    INTO v_descuento
    FROM Cliente C
    INNER JOIN Venta V ON C.ID_Cliente = V.ID_Cliente
    WHERE C.ID_Cliente = p_id_cliente;

    p_resultado := v_descuento;
    

EXCEPTION 
    WHEN OTHERS THEN
    p_error :='Error en el procedimiento CalcularDescuentoClienteXID ' || SQLERRM;
END;


create or replace PROCEDURE CalcularValorTotalVentas (

p_resultado OUT NUMBER,
p_error OUT VARCHAR2)
AS
    v_total NUMBER;
    
BEGIN
    SELECT SUM(Total_Venta)
    INTO v_total
    FROM Venta;

    p_resultado := v_total;
    
EXCEPTION 
    WHEN OTHERS THEN
    p_error :='Error en el procedimiento CalcularValorTotalVentas ' || SQLERRM;
END;
/

create or replace PROCEDURE ListarVentasEntreFechas(
    p_fecha_inicio IN DATE,
    p_fecha_fin IN DATE,
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS

    
BEGIN
    OPEN p_cursor FOR 
        SELECT ID_Venta, ID_Producto, Cantidad_Vendida, Total_Venta, Fecha
        FROM Venta
        WHERE Fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
        
EXCEPTION 
    WHEN OTHERS THEN
    p_error :='Error en el procedimiento ListarVentasEntreFechas ' || SQLERRM;
END;
/

CREATE OR REPLACE PROCEDURE RegistrarDevolucionProducto(
    p_id_venta INT,
    p_motivo VARCHAR2,
    p_fecha DATE
) AS
    v_cantidad_devuelta INT;
BEGIN
    INSERT INTO Devolucion (ID_Venta, Motivo, Fecha)
    VALUES (p_id_venta, p_motivo, p_fecha);

    -- Actualizar el inventario
    SELECT Cantidad_Vendida INTO v_cantidad_devuelta FROM Venta WHERE ID_Venta = p_id_venta;

    UPDATE Producto
    SET Cantidad = Cantidad + v_cantidad_devuelta
    WHERE ID_Producto = (SELECT ID_Producto FROM Venta WHERE ID_Venta = p_id_venta);
END;
/

CREATE OR REPLACE PROCEDURE RegistrarVenta(
    p_id_producto INT,
    p_id_sucursal INT,
    p_id_cliente INT,
    p_cantidad INT,
    p_monto_total NUMBER,
    p_fecha_venta DATE
) AS
BEGIN
    INSERT INTO Venta (ID_Producto, ID_Sucursal, ID_Cliente, Cantidad_Vendida, Total_Venta, Fecha)
    VALUES (p_id_producto, p_id_sucursal, p_id_cliente, p_cantidad, p_monto_total, p_fecha_venta);

    UPDATE Producto
    SET Cantidad = Cantidad - p_cantidad
    WHERE ID_Producto = p_id_producto;
END;
/

CREATE OR REPLACE PROCEDURE CalcularPromedioVentasXProducto(
    p_id_producto IN NUMBER,
    p_promedio OUT NUMBER,
    p_error OUT VARCHAR2
) AS
BEGIN
    SELECT AVG(Cantidad_Vendida)
    INTO p_promedio
    FROM Venta
    WHERE ID_Producto = p_id_producto;
EXCEPTION
    WHEN OTHERS THEN
        p_promedio := -1;
        p_error:= 'Error al calcular el promedio de ventas: ' || SQLERRM;
END;
/

CREATE OR REPLACE PROCEDURE CalcularIngresosTotalesXSucursal(
    p_id_sucursal IN NUMBER,
    p_ingresos_totales OUT NUMBER,
    p_error OUT VARCHAR2
) AS
BEGIN
    SELECT SUM(Total_Venta)
    INTO p_ingresos_totales
    FROM Venta
    WHERE ID_Sucursal = p_id_sucursal;
EXCEPTION
    WHEN OTHERS THEN
        p_ingresos_totales := -1;
       p_error:= 'Error al calcular los ingresos totales: ' || SQLERRM;
END;
/

CREATE OR REPLACE PROCEDURE ObtenerProductosMasVendidos(
    p_fecha_inicio IN DATE,
    p_fecha_fin IN DATE,
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
BEGIN
    OPEN p_cursor FOR 
        SELECT p.Nombre AS Producto, SUM(v.Cantidad_Vendida) AS Cantidad_Total_Vendida
            FROM Venta v
            JOIN Producto p ON v.ID_Producto = p.ID_Producto
        WHERE v.Fecha BETWEEN p_fecha_inicio AND p_fecha_fin
            GROUP BY p.Nombre
            ORDER BY SUM(v.Cantidad_Vendida) DESC;
EXCEPTION
    WHEN OTHERS THEN
        p_error:= 'Error al obtener los productos más vendidos: ' || SQLERRM;
END;
/



SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE ListarProductosPorSucursal(
    p_id_sucursal  IN NUMBER,
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
BEGIN
    OPEN p_cursor  FOR 
    SELECT p.Nombre AS Producto, i.Cantidad_Disponible
    FROM Producto p
    JOIN Inventario i ON p.ID_Producto = i.ID_Producto
    WHERE i.ID_Sucursal = p_id_sucursal;
EXCEPTION
    WHEN OTHERS THEN
        p_error:= 'Error al obtener los productos por sucursal ' || SQLERRM;
END;
/


CREATE OR REPLACE PROCEDURE RegistrarCompraProductoProveedor(
    p_id_proveedor IN INT,
    p_id_producto IN INT,
    p_cantidad_comprada IN INT,
    p_costo_total IN NUMBER,
    p_fecha_compra IN DATE,
    p_sucursal IN NUMBER,
    p_error OUT VARCHAR2
) AS
BEGIN
    INSERT INTO CompraProductos (ID_Proveedor, ID_Producto, Cantidad_Comprada, Costo_Total, Fecha_Compra)
    VALUES (p_id_proveedor, p_id_producto, p_cantidad_comprada, p_costo_total, p_fecha_compra);
    UPDATE Inventario
    SET Cantidad_Disponible = Cantidad_Disponible + p_cantidad_comprada
    WHERE ID_Producto = p_id_producto AND id_sucursal=p_sucursal;
EXCEPTION
    WHEN OTHERS THEN
        p_error:= 'Error al registrar la compra del producto al proveedor' || SQLERRM;
END;
/


CREATE OR REPLACE PROCEDURE CalcularValorInventarioPorSucursal(
    p_id_sucursal IN INT,
    p_resultado OUT NUMBER,
    p_error OUT VARCHAR2
) AS
    v_valor_total NUMBER;
BEGIN
    SELECT SUM(p.Precio * i.Cantidad_Disponible)
    INTO v_valor_total
    FROM Inventario i
    JOIN Producto p ON i.ID_Producto = p.ID_Producto
    WHERE i.ID_Sucursal = p_id_sucursal;

    p_resultado := v_valor_total;
    
    EXCEPTION
    WHEN OTHERS THEN
        p_error:= 'Error al calcular valor del inventario por sucursal' || SQLERRM;
END;
/

CREATE OR REPLACE PROCEDURE GenerarReporteVentasMensuales(
    p_fecha_inicio IN DATE,
    p_fecha_fin IN DATE,
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT
            s.Nombre AS Sucursal,
            TO_CHAR(v.Fecha, 'YYYY-MM') AS Mes,
            SUM(v.Total_Venta) AS Total_Ventas
        FROM Venta v
        JOIN Sucursal s ON v.ID_Sucursal = s.ID_Sucursal
        WHERE v.Fecha BETWEEN p_fecha_inicio AND p_fecha_fin
        GROUP BY s.Nombre, TO_CHAR(v.Fecha, 'YYYY-MM')
        ORDER BY s.Nombre, TO_CHAR(v.Fecha, 'YYYY-MM');
    CLOSE p_cursor;
    p_error := NULL;
EXCEPTION
    WHEN OTHERS THEN
        p_error := 'Error al generar el reporte de ventas mensuales: ' || SQLERRM;
END;
/

--Trabajadores Activos / con cursor
CREATE OR REPLACE PROCEDURE ProcesarTrabajadoresActivos IS
    v_nombre_trabajador VARCHAR2(50);
    v_apellido_trabajador VARCHAR2(50);
    v_nombre_sucursal VARCHAR2(50);
BEGIN
    OPEN cur_TrabajadoresActivosPorSucursal;

    LOOP
        FETCH cur_TrabajadoresActivosPorSucursal INTO v_nombre_trabajador, v_apellido_trabajador, v_nombre_sucursal;

        EXIT WHEN cur_TrabajadoresActivosPorSucursal%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Trabajador: ' || v_nombre_trabajador || ' ' || v_apellido_trabajador || ' - Sucursal: ' || v_nombre_sucursal);
        
    END LOOP;

    -- Cerrar el cursor después de terminar
    CLOSE cur_TrabajadoresActivosPorSucursal;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en ProcesarTrabajadoresActivos: ' || SQLERRM);
END;
/

--Devoluciones por mes / con cursor
CREATE OR REPLACE PROCEDURE ProcesarDevolucionesPorMes IS
    v_id_devolucion NUMBER;
    v_motivo VARCHAR2(300);
    v_mes VARCHAR2(7);
BEGIN
    OPEN cur_DevolucionesPorMes;

    LOOP
        FETCH cur_DevolucionesPorMes INTO v_id_devolucion, v_motivo, v_mes;

        EXIT WHEN cur_DevolucionesPorMes%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Devolución ID: ' || v_id_devolucion || ' - Motivo: ' || v_motivo || ' - Mes: ' || v_mes);

        
    END LOOP;

    -- Cerrar el cursor después de terminar
    CLOSE cur_DevolucionesPorMes;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en ProcesarDevolucionesPorMes: ' || SQLERRM);
END;
/


--Listar compras por proveedor / Con cursor

CREATE OR REPLACE PROCEDURE ProcesarComprasPorProveedor IS
    v_nombre_producto VARCHAR2(50);
    v_cantidad_comprada NUMBER;
    v_nombre_proveedor VARCHAR2(50);
BEGIN
    OPEN cur_ComprasPorProveedor;

    LOOP
        FETCH cur_ComprasPorProveedor INTO v_nombre_producto, v_cantidad_comprada, v_nombre_proveedor;

        EXIT WHEN cur_ComprasPorProveedor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Producto: ' || v_nombre_producto || ' - Cantidad Comprada: ' || v_cantidad_comprada || ' - Proveedor: ' || v_nombre_proveedor);

        
    END LOOP;

    -- Cerrar el cursor después de terminar
    CLOSE cur_ComprasPorProveedor;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en ProcesarComprasPorProveedor: ' || SQLERRM);
END;
/

--Mostrar Productos bajos en stock / Con cursor

CREATE OR REPLACE PROCEDURE ProcesarProductosConStockBajo IS
    v_nombre_producto VARCHAR2(50);
    v_cantidad_disponible NUMBER;
    v_nombre_sucursal VARCHAR2(50);
BEGIN
    OPEN cur_ProductosConStockBajo;

    LOOP
        FETCH cur_ProductosConStockBajo INTO v_nombre_producto, v_cantidad_disponible, v_nombre_sucursal;

        EXIT WHEN cur_ProductosConStockBajo%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Producto: ' || v_nombre_producto || ' - Stock: ' || v_cantidad_disponible || ' - Sucursal: ' || v_nombre_sucursal);


        
    END LOOP;

    -- Cerrar el cursor después de terminar
    CLOSE cur_ProductosConStockBajo;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en ProcesarProductosConStockBajo: ' || SQLERRM);
END;
/

-- Obtiene clientes que han realizado al menos una compra
CREATE OR REPLACE PROCEDURE ListarClientesActivos(
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
    CURSOR cur_ClientesActivos IS
    SELECT c.ID_Cliente, c.Nombre, c.Apellido_1, c.Apellido_2
    FROM Cliente c
    JOIN Venta v ON c.ID_Cliente = v.ID_Cliente
    GROUP BY c.ID_Cliente, c.Nombre, c.Apellido_1, c.Apellido_2
    HAVING COUNT(v.ID_Venta) > 0;
BEGIN
    OPEN p_cursor FOR cur_ClientesActivos;
    p_error := NULL;
EXCEPTION
    WHEN OTHERS THEN
        p_error := 'Error al listar los clientes activos: ' || SQLERRM;
END;
/

 
--este cursor Lista los productos con stock bajo en diferentes sucursales.
CREATE OR REPLACE PROCEDURE ListarProductosBajosEnInventario(
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
    CURSOR cur_ProductosBajosEnInventario IS
    SELECT p.ID_Producto, p.Nombre, i.Cantidad_Disponible, s.Nombre AS Sucursal
    FROM Producto p
    JOIN Inventario i ON p.ID_Producto = i.ID_Producto
    JOIN Sucursal s ON i.ID_Sucursal = s.ID_Sucursal
    WHERE i.Cantidad_Disponible < 6;
BEGIN
    OPEN p_cursor FOR cur_ProductosBajosEnInventario;
    p_error := NULL;
EXCEPTION
    WHEN OTHERS THEN
        p_error := 'Error al listar los productos bajos en inventario: ' || SQLERRM;
END;
/


--Lista las devoluciones con sus detalles.
CREATE OR REPLACE PROCEDURE ListarDevoluciones(
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
    CURSOR cur_Devoluciones IS
    SELECT d.ID_Devolucion, d.Fecha, d.Motivo, v.ID_Venta
    FROM Devolucion d
    JOIN Venta v ON d.ID_Venta = v.ID_Venta;
BEGIN
    OPEN p_cursor FOR cur_Devoluciones;
    p_error := NULL;
EXCEPTION
    WHEN OTHERS THEN
        p_error := 'Error al listar las devoluciones: ' || SQLERRM;
END;
/


--Con este cursor se Obtienen productos por categoría.
CREATE OR REPLACE PROCEDURE ListarCategoriasProductos(
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
    CURSOR cur_CategoriasProductos IS
    SELECT c.Nombre AS Categoria, p.Nombre AS Producto
    FROM Categoria c
    JOIN Producto p ON c.ID_Categoria = p.ID_Categoria;
BEGIN
    OPEN p_cursor FOR cur_CategoriasProductos;
    p_error := NULL;
EXCEPTION
    WHEN OTHERS THEN
        p_error := 'Error al listar las categorías y productos: ' || SQLERRM;
END;
/


--con el cursor se Obtienen ventas agrupadas por sucursal.
CREATE OR REPLACE PROCEDURE ListarVentasPorSucursal(
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
    CURSOR cur_VentasPorSucursal IS
    SELECT v.ID_Venta, v.Fecha, v.Total_Venta, s.Nombre AS Sucursal
    FROM Venta v
    JOIN Sucursal s ON v.ID_Sucursal = s.ID_Sucursal
    ORDER BY s.Nombre, v.Fecha;
BEGIN
    OPEN p_cursor FOR cur_VentasPorSucursal;
    p_error := NULL;
EXCEPTION
    WHEN OTHERS THEN
        p_error := 'Error al listar las ventas por sucursal: ' || SQLERRM;
END;
/


--Lista los productos más vendidos en el último mes.
CREATE OR REPLACE PROCEDURE ListarProductosMasVendidosUltimoMes(
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
    CURSOR cur_ProductosMasVendidosUltimoMes IS
    SELECT p.Nombre AS Producto, SUM(v.Cantidad_Vendida) AS Cantidad_Total_Vendida
    FROM Venta v
    JOIN Producto p ON v.ID_Producto = p.ID_Producto
    WHERE v.Fecha >= ADD_MONTHS(SYSDATE, -1)
    GROUP BY p.Nombre
    ORDER BY SUM(v.Cantidad_Vendida) DESC;
BEGIN
    OPEN p_cursor FOR cur_ProductosMasVendidosUltimoMes;
    p_error := NULL;
EXCEPTION
    WHEN OTHERS THEN
        p_error := 'Error al listar los productos más vendidos del último mes: ' || SQLERRM;
END;

--Con este cursor se obtienen auditorías recientes.
CREATE OR REPLACE PROCEDURE ListarAuditoriasRecientes(
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
    CURSOR cur_AuditoriasRecientes IS
    SELECT a.id_Auditoria, a.Fecha, a.Operacion, t.Nombre || ' ' || t.Apellido_1 AS Trabajador, a.Detalles
    FROM Auditoria a
    JOIN Trabajador t ON a.ID_Trabajador = t.ID_Trabajador
    ORDER BY a.Fecha DESC;
BEGIN
    OPEN p_cursor FOR cur_AuditoriasRecientes;
    p_error := NULL;
EXCEPTION
    WHEN OTHERS THEN
        p_error := 'Error al listar las auditorías recientes: ' || SQLERRM;
END;
/


 --Obtiene sucursales con menos ventas.
CREATE OR REPLACE PROCEDURE ListarSucursalesMenosVentas(
    p_cursor OUT SYS_REFCURSOR,
    p_error OUT VARCHAR2
) AS
    CURSOR cur_SucursalesMenosVentas IS
    SELECT s.ID_Sucursal, s.Nombre, COUNT(v.ID_Venta) AS Total_Ventas
    FROM Sucursal s
    LEFT JOIN Venta v ON s.ID_Sucursal = v.ID_Sucursal
    GROUP BY s.ID_Sucursal, s.Nombre
    ORDER BY COUNT(v.ID_Venta) ASC;
BEGIN
    OPEN p_cursor FOR cur_SucursalesMenosVentas;
    p_error := NULL;
EXCEPTION
    WHEN OTHERS THEN
        p_error := 'Error al listar las sucursales con menos ventas: ' || SQLERRM;
END;
/


