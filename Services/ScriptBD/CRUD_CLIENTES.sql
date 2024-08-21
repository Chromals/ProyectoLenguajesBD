CREATE OR REPLACE PACKAGE CRUD_CLIENTE AS

    -- Cliente procedures
    PROCEDURE Insert_Cliente(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Update_Cliente(p_ID_Cliente IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Delete_Cliente(p_ID_Cliente IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Select_All_Cliente(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Cliente(p_ID_Cliente IN NUMBER, p_Result OUT SYS_REFCURSOR);

END CRUD_CLIENTE;
/
    
CREATE OR REPLACE PACKAGE BODY CRUD_CLIENTE AS

    PROCEDURE Insert_Cliente(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        INSERT INTO Cliente (Nombre, Apellido_1, Apellido_2, Telefono, Correo, ID_Direccion)
        VALUES (p_Nombre, p_Apellido_1, p_Apellido_2, p_Telefono, p_Correo, p_ID_Direccion);
        p_Result := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := -1;
    END Insert_Cliente;

    PROCEDURE Update_Cliente(p_ID_Cliente IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        UPDATE Cliente SET Nombre = p_Nombre, Apellido_1 = p_Apellido_1, Apellido_2 = p_Apellido_2, Telefono = p_Telefono, Correo = p_Correo, ID_Direccion = p_ID_Direccion WHERE ID_Cliente = p_ID_Cliente;
        p_Result := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := -1;
    END Update_Cliente;

    PROCEDURE Delete_Cliente(p_ID_Cliente IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        DELETE FROM Cliente WHERE ID_Cliente = p_ID_Cliente;
        p_Result := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := -1;
    END Delete_Cliente;

    PROCEDURE Select_All_Cliente(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Cliente;
    END Select_All_Cliente;

    PROCEDURE Select_Cliente(p_ID_Cliente IN NUMBER, p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Cliente WHERE ID_Cliente = p_ID_Cliente;
    END Select_Cliente;

END CRUD_CLIENTE;
/
