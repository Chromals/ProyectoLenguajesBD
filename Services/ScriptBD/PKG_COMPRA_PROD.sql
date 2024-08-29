CREATE OR REPLACE PACKAGE PKG_COMPRA_PROD AS

    PROCEDURE ObtenerPrecioProductoProc(p_ID_Producto IN NUMBER, p_Precio OUT VARCHAR2);
    PROCEDURE Listar_VentaProductos(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Insertar_CompraProducto(
        p_ID_Proveedor IN NUMBER, 
        p_ID_Producto IN NUMBER, 
        p_Cantidad_Comprada IN NUMBER, 
        p_Costo_Total IN NUMBER, 
        p_Fecha_Compra IN DATE, 
        p_Result OUT VARCHAR2
    );
END PKG_COMPRA_PROD;
/


CREATE OR REPLACE PACKAGE BODY PKG_COMPRA_PROD AS

    PROCEDURE Listar_VentaProductos(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR
        SELECT 
            p.ID_Producto, 
            p.Nombre, 
            p.Descripcion, 
            p.Precio, 
            p.ID_Categoria, 
            p.cantidad, 
            VerificarDisponibilidadProducto(p.ID_Producto) AS Disponibilidad 
        FROM Producto p;
    END Listar_VentaProductos;

    PROCEDURE Insertar_CompraProducto(
        p_ID_Proveedor IN NUMBER, 
        p_ID_Producto IN NUMBER, 
        p_Cantidad_Comprada IN NUMBER, 
        p_Costo_Total IN NUMBER, 
        p_Fecha_Compra IN DATE, 
        p_Result OUT VARCHAR2
    ) IS
        v_CostoTotalConImpuestos NUMBER;
        v_CostoTotalDolares NUMBER;
        v_CodigoProducto VARCHAR2(20);
        v_NombreProducto VARCHAR2(100);
        v_ID_Categoria NUMBER;
    BEGIN
        v_CostoTotalConImpuestos := CalcularImpuestos(p_Costo_Total) + p_Costo_Total;

        v_CostoTotalDolares := ConvertirMoneda(v_CostoTotalConImpuestos);

        SELECT Nombre, ID_Categoria
        INTO v_NombreProducto, v_ID_Categoria
        FROM Producto
        WHERE ID_Producto = p_ID_Producto;

        v_CodigoProducto := GenerarCodigoProducto(v_NombreProducto, v_ID_Categoria);

        INSERT INTO CompraProductos (ID_Proveedor, ID_Producto, Cantidad_Comprada, Costo_Total, Fecha_Compra)
        VALUES (p_ID_Proveedor, p_ID_Producto, p_Cantidad_Comprada, v_CostoTotalConImpuestos, p_Fecha_Compra);

        UPDATE Inventario SET Cantidad_Disponible = p_Cantidad_Comprada WHERE ID_Producto = p_ID_Producto;
        
        p_Result := '1';

    EXCEPTION
        WHEN OTHERS THEN
            p_Result := 'Error: ' || SQLERRM;
    END Insertar_CompraProducto;

    PROCEDURE ObtenerPrecioProductoProc(p_ID_Producto IN NUMBER, p_Precio OUT VARCHAR2) IS
        v_Precio NUMBER;
    BEGIN
        v_Precio := ObtenerPrecioProducto(p_ID_Producto);

        p_Precio := TO_CHAR(v_Precio, 'FM999999990.00');
    EXCEPTION
        WHEN OTHERS THEN
            p_Precio := NULL;
    END ObtenerPrecioProductoProc;


END PKG_COMPRA_PROD;
/
