CREATE OR REPLACE PACKAGE CRUD_DIRECCION AS
    PROCEDURE Insert_Direccion(p_Provincia IN VARCHAR2, p_Canton IN VARCHAR2, p_Distrito IN VARCHAR2, p_Result OUT VARCHAR2);
    PROCEDURE Update_Direccion(p_ID_Direccion IN NUMBER, p_Provincia IN VARCHAR2, p_Canton IN VARCHAR2, p_Distrito IN VARCHAR2, p_Result OUT VARCHAR2);
    PROCEDURE Delete_Direccion(p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Select_All_Direccion(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Direccion(p_ID_Direccion IN NUMBER, p_Result OUT SYS_REFCURSOR);
END CRUD_DIRECCION;
/

CREATE OR REPLACE PACKAGE BODY CRUD_DIRECCION AS
    PROCEDURE Insert_Direccion(p_Provincia IN VARCHAR2, p_Canton IN VARCHAR2, p_Distrito IN VARCHAR2, p_Result OUT VARCHAR2) IS
    BEGIN
        INSERT INTO Direccion (Provincia, Canton, Distrito) VALUES (p_Provincia, p_Canton, p_Distrito);
        p_Result := 1;
    EXCEPTION
        WHEN OTHERS THEN
            p_Result:= 'Error: ' || SQLERRM;
    END Insert_Direccion;

    PROCEDURE Update_Direccion(p_ID_Direccion IN NUMBER, p_Provincia IN VARCHAR2, p_Canton IN VARCHAR2, p_Distrito IN VARCHAR2, p_Result OUT VARCHAR2) IS
    BEGIN
        UPDATE Direccion SET Provincia = p_Provincia, Canton = p_Canton, Distrito = p_Distrito WHERE ID_Direccion = p_ID_Direccion;
        p_Result := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Result:= 'Error: ' || SQLERRM;
    END Update_Direccion;

    PROCEDURE Delete_Direccion(p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        DELETE FROM Direccion WHERE ID_Direccion = p_ID_Direccion;
        p_Result := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Result:= 'Error: ' || SQLERRM;
    END Delete_Direccion;

    PROCEDURE Select_All_Direccion(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Direccion ORDER BY ID_Direccion ASC;
    END Select_All_Direccion;

    PROCEDURE Select_Direccion(p_ID_Direccion IN NUMBER, p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Direccion WHERE ID_Direccion = p_ID_Direccion;
    END Select_Direccion;
END CRUD_DIRECCION;
/
