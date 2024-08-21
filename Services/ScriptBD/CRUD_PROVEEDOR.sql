CREATE OR REPLACE PACKAGE CRUD_PROVEEDOR AS
    PROCEDURE Insert_Proveedor(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Update_Proveedor(p_ID_Proveedor IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Delete_Proveedor(p_ID_Proveedor IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Select_All_Proveedor(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Proveedor(p_ID_Proveedor IN NUMBER, p_Result OUT SYS_REFCURSOR);
END CRUD_PROVEEDOR;
/

CREATE OR REPLACE PACKAGE BODY CRUD_PROVEEDOR AS
    PROCEDURE Insert_Proveedor(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        INSERT INTO Proveedor (Nombre, Apellido_1, Apellido_2, Telefono, Correo, ID_Direccion)
        VALUES (p_Nombre, p_Apellido_1, p_Apellido_2, p_Telefono, p_Correo, p_ID_Direccion);
        p_Success := 1;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success:= 'Error: ' || SQLERRM;
    END Insert_Proveedor;

    PROCEDURE Update_Proveedor(p_ID_Proveedor IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        UPDATE Proveedor SET Nombre = p_Nombre, Apellido_1 = p_Apellido_1, Apellido_2 = p_Apellido_2, Telefono = p_Telefono, Correo = p_Correo, ID_Direccion = p_ID_Direccion WHERE ID_Proveedor = p_ID_Proveedor;
        p_Success := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success:= 'Error: ' || SQLERRM;
    END Update_Proveedor;

    PROCEDURE Delete_Proveedor(p_ID_Proveedor IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        DELETE FROM Proveedor WHERE ID_Proveedor = p_ID_Proveedor;
        p_Success := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success:= 'Error: ' || SQLERRM;
    END Delete_Proveedor;

    PROCEDURE Select_All_Proveedor(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Proveedor;
    END Select_All_Proveedor;

    PROCEDURE Select_Proveedor(p_ID_Proveedor IN NUMBER, p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Proveedor WHERE ID_Proveedor = p_ID_Proveedor;
    END Select_Proveedor;
END CRUD_PROVEEDOR;
/
