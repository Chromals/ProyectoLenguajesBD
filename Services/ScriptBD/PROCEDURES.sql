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