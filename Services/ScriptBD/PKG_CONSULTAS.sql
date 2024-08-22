CREATE OR REPLACE PACKAGE PKG_CONSULTAS AS

    -- Procedimientos para seleccionar todos los registros
    PROCEDURE Select_All_Auditoria(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_All_CompraProductos(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_All_Devolucion(p_Result OUT SYS_REFCURSOR);

    -- Procedimientos que usan cursores predefinidos
    PROCEDURE Listar_Devoluciones(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Listar_Auditorias_Recientes(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Listar_CompraProductos(p_Result OUT SYS_REFCURSOR);

END PKG_CONSULTAS;
/

CREATE OR REPLACE PACKAGE BODY PKG_CONSULTAS AS

    PROCEDURE Select_All_Auditoria(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Auditoria ORDER BY id_Auditoria ASC;
    END Select_All_Auditoria;

    PROCEDURE Select_All_CompraProductos(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM CompraProductos ORDER BY ID_Compra_Producto ASC;
    END Select_All_CompraProductos;

    PROCEDURE Select_All_Devolucion(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Devolucion ORDER BY ID_Devolucion ASC;
    END Select_All_Devolucion;

    PROCEDURE Listar_Devoluciones(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR
        SELECT d.ID_Devolucion, d.Fecha, d.Motivo, v.ID_Venta
        FROM Devolucion d
        JOIN Venta v ON d.ID_Venta = v.ID_Venta;
    END Listar_Devoluciones;

    PROCEDURE Listar_Auditorias_Recientes(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR
        SELECT a.id_Auditoria, a.Fecha, a.Operacion, t.Nombre || ' ' || t.Apellido_1 AS Trabajador, a.Detalles
        FROM Auditoria a
        JOIN Trabajador t ON a.ID_Trabajador = t.ID_Trabajador
        ORDER BY a.Fecha DESC;
    END Listar_Auditorias_Recientes;

    PROCEDURE Listar_CompraProductos(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR
        SELECT cp.ID_Compra_Producto, cp.ID_Proveedor, cp.Cantidad_Comprada, cp.Costo_Total, cp.Fecha_Compra, p.Nombre AS Nombre_Producto
        FROM CompraProductos cp
        JOIN Producto p ON cp.ID_Producto = p.ID_Producto;
    END Listar_CompraProductos;

END PKG_CONSULTAS;
/
