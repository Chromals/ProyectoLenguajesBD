CREATE OR REPLACE PACKAGE CRUD_SUCURSAL AS
    PROCEDURE Insert_Sucursal(p_Nombre IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Update_Sucursal(p_ID_Sucursal IN NUMBER, p_Nombre IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Delete_Sucursal(p_ID_Sucursal IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Select_All_Sucursal(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Sucursal(p_ID_Sucursal IN NUMBER, p_Result OUT SYS_REFCURSOR);
END CRUD_SUCURSAL;
/

CREATE OR REPLACE PACKAGE BODY CRUD_SUCURSAL AS
    PROCEDURE Insert_Sucursal(p_Nombre IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        INSERT INTO Sucursal (Nombre, ID_Direccion) VALUES (p_Nombre, p_ID_Direccion);
        p_Result := '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_Result:= 'Error: ' || SQLERRM;
    END Insert_Sucursal;

    PROCEDURE Update_Sucursal(p_ID_Sucursal IN NUMBER, p_Nombre IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        UPDATE Sucursal SET Nombre = p_Nombre, ID_Direccion = p_ID_Direccion WHERE ID_Sucursal = p_ID_Sucursal;
        p_Result := '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_Result:= 'Error: ' || SQLERRM;
    END Update_Sucursal;

    PROCEDURE Delete_Sucursal(p_ID_Sucursal IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        DELETE FROM Sucursal WHERE ID_Sucursal = p_ID_Sucursal;
        p_Result := '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_Result:= 'Error: ' || SQLERRM;
    END Delete_Sucursal;

    PROCEDURE Select_All_Sucursal(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Sucursal ORDER BY ID_Sucursal ASC;
    END Select_All_Sucursal;

    PROCEDURE Select_Sucursal(p_ID_Sucursal IN NUMBER, p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Sucursal WHERE ID_Sucursal = p_ID_Sucursal;
    END Select_Sucursal;
END CRUD_SUCURSAL;
/
