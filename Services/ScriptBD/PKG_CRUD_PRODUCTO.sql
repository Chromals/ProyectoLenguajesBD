CREATE OR REPLACE PACKAGE CRUD_PRODUCTO AS

    -- Producto procedures
    PROCEDURE Insert_Producto(p_Nombre IN VARCHAR2, p_Descripcion IN VARCHAR2, p_Precio IN NUMBER, p_ID_Categoria IN NUMBER, p_Cantidad IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Update_Producto(p_ID_Producto IN NUMBER, p_Nombre IN VARCHAR2, p_Descripcion IN VARCHAR2, p_Precio IN NUMBER, p_ID_Categoria IN NUMBER, p_Cantidad IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Delete_Producto(p_ID_Producto IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Select_All_Producto(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Producto(p_ID_Producto IN NUMBER, p_Result OUT SYS_REFCURSOR);

END CRUD_PRODUCTO;
/
    
CREATE OR REPLACE PACKAGE BODY CRUD_PRODUCTO AS

    PROCEDURE Insert_Producto(p_Nombre IN VARCHAR2, p_Descripcion IN VARCHAR2, p_Precio IN NUMBER, p_ID_Categoria IN NUMBER, p_Cantidad IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        INSERT INTO Producto (Nombre, Descripcion, Precio, ID_Categoria, cantidad)
        VALUES (p_Nombre, p_Descripcion, p_Precio, p_ID_Categoria, p_Cantidad);
        p_Result := '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := 'Error: ' || SQLERRM;
    END Insert_Producto;

    PROCEDURE Update_Producto(p_ID_Producto IN NUMBER, p_Nombre IN VARCHAR2, p_Descripcion IN VARCHAR2, p_Precio IN NUMBER, p_ID_Categoria IN NUMBER, p_Cantidad IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        UPDATE Producto
        SET Nombre = p_Nombre,
            Descripcion = p_Descripcion,
            Precio = p_Precio,
            ID_Categoria = p_ID_Categoria,
            cantidad = p_Cantidad
        WHERE ID_Producto = p_ID_Producto;
        p_Result := '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := 'Error: ' || SQLERRM;
    END Update_Producto;

    PROCEDURE Delete_Producto(p_ID_Producto IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        DELETE FROM Producto
        WHERE ID_Producto = p_ID_Producto;
        p_Result := '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := 'Error: ' || SQLERRM;
    END Delete_Producto;

    PROCEDURE Select_All_Producto(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Producto ORDER BY ID_Producto ASC;
    END Select_All_Producto;

    PROCEDURE Select_Producto(p_ID_Producto IN NUMBER, p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Producto WHERE ID_Producto = p_ID_Producto;
    END Select_Producto;

END CRUD_PRODUCTO;
/
