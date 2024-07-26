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