CREATE OR REPLACE PACKAGE PKG_VENTA_PROD AS

    FUNCTION CalcularImpuestos(monto NUMBER) RETURN NUMBER;
    FUNCTION ConvertirMoneda(monto_colon NUMBER) RETURN NUMBER;
    FUNCTION GenerarCodigoProducto(nombre_producto VARCHAR2, id_categoria NUMBER) RETURN VARCHAR2;
    FUNCTION VerificarDisponibilidadProducto(p_id_producto NUMBER) RETURN VARCHAR2;
    FUNCTION ObtenerPrecioProducto(p_ID_Producto IN NUMBER) RETURN NUMBER;

    PROCEDURE ObtenerPrecioProductoProc(p_ID_Producto IN NUMBER, p_Precio OUT NUMBER);
    PROCEDURE Listar_VentaProductos(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Insertar_CompraProducto(
        p_ID_Proveedor IN NUMBER, 
        p_ID_Producto IN NUMBER, 
        p_Cantidad_Comprada IN NUMBER, 
        p_Costo_Total IN NUMBER, 
        p_Fecha_Compra IN DATE, 
        p_Result OUT VARCHAR2
    ) ;
END PKG_VENTA_PROD;
/


CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY PKG_VENTA_PROD AS

    FUNCTION CalcularImpuestos(monto NUMBER) RETURN NUMBER IS
        impuestos NUMBER(10, 2);
    BEGIN
        impuestos := monto * 0.13; 
        RETURN impuestos;
    END CalcularImpuestos;

    FUNCTION ConvertirMoneda(monto_colon NUMBER) RETURN NUMBER IS
        monto_dolar NUMBER(10, 2);
    BEGIN
        monto_dolar := monto_colon / 535.00; 
        RETURN monto_dolar;
    END ConvertirMoneda;

    FUNCTION GenerarCodigoProducto(nombre_producto VARCHAR2, id_categoria NUMBER) RETURN VARCHAR2 IS
        codigo VARCHAR2(20);
        nombre_substr VARCHAR2(3);
        id_cat_str VARCHAR2(10);
    BEGIN
        SELECT SUBSTR(nombre_producto, 1, 3)
        INTO nombre_substr
        FROM dual;

        SELECT TO_CHAR(id_categoria)
        INTO id_cat_str
        FROM dual;

        codigo := nombre_substr || '-' || id_cat_str;

        RETURN codigo;
    END GenerarCodigoProducto;

    FUNCTION VerificarDisponibilidadProducto(p_id_producto NUMBER) RETURN VARCHAR2 IS
        cantidad_disponible NUMBER;
        mensaje VARCHAR2(100);
    BEGIN
        SELECT NVL(SUM(Cantidad_Disponible),0) INTO cantidad_disponible
        FROM Inventario
        WHERE ID_Producto = p_id_producto;

        IF cantidad_disponible > 0 THEN
            mensaje := 'Disponible';
        ELSE
            mensaje := 'No Disponible';
        END IF;

        RETURN mensaje;
    END VerificarDisponibilidadProducto;

    FUNCTION ObtenerPrecioProducto(p_ID_Producto IN NUMBER) RETURN NUMBER IS
        v_Precio NUMBER;
    BEGIN
        SELECT Precio INTO v_Precio
        FROM Producto
        WHERE ID_Producto = p_ID_Producto;

        RETURN v_Precio;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN NULL;
    END ObtenerPrecioProducto;

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

        p_Result := '1';

    EXCEPTION
        WHEN OTHERS THEN
            p_Result := 'Error: ' || SQLERRM;
    END Insertar_CompraProducto;

    PROCEDURE ObtenerPrecioProductoProc(p_ID_Producto IN NUMBER, p_Precio OUT NUMBER) IS
    BEGIN
        p_Precio := ObtenerPrecioProducto(p_ID_Producto);
    EXCEPTION
        WHEN OTHERS THEN
            p_Precio := NULL;
    END ObtenerPrecioProductoProc;

END PKG_VENTA_PROD;
