CREATE OR REPLACE PACKAGE CRUD_DIRECCION AS
    PROCEDURE Insert_Direccion(p_Provincia IN VARCHAR2, p_Canton IN VARCHAR2, p_Distrito IN VARCHAR2, p_Success OUT NUMBER);
    PROCEDURE Update_Direccion(p_ID_Direccion IN NUMBER, p_Provincia IN VARCHAR2, p_Canton IN VARCHAR2, p_Distrito IN VARCHAR2, p_Success OUT NUMBER);
    PROCEDURE Delete_Direccion(p_ID_Direccion IN NUMBER, p_Success OUT NUMBER);
    PROCEDURE Select_All_Direccion(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Direccion(p_ID_Direccion IN NUMBER, p_Result OUT SYS_REFCURSOR);
END CRUD_DIRECCION;
/

CREATE OR REPLACE PACKAGE BODY CRUD_DIRECCION AS
    PROCEDURE Insert_Direccion(p_Provincia IN VARCHAR2, p_Canton IN VARCHAR2, p_Distrito IN VARCHAR2, p_Success OUT NUMBER) IS
    BEGIN
        INSERT INTO Direccion (Provincia, Canton, Distrito) VALUES (p_Provincia, p_Canton, p_Distrito);
        p_Success := 1;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success := 0;
    END Insert_Direccion;

    PROCEDURE Update_Direccion(p_ID_Direccion IN NUMBER, p_Provincia IN VARCHAR2, p_Canton IN VARCHAR2, p_Distrito IN VARCHAR2, p_Success OUT NUMBER) IS
    BEGIN
        UPDATE Direccion SET Provincia = p_Provincia, Canton = p_Canton, Distrito = p_Distrito WHERE ID_Direccion = p_ID_Direccion;
        p_Success := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success := 0;
    END Update_Direccion;

    PROCEDURE Delete_Direccion(p_ID_Direccion IN NUMBER, p_Success OUT NUMBER) IS
    BEGIN
        DELETE FROM Direccion WHERE ID_Direccion = p_ID_Direccion;
        p_Success := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success := 0;
    END Delete_Direccion;

    PROCEDURE Select_All_Direccion(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Direccion;
    END Select_All_Direccion;

    PROCEDURE Select_Direccion(p_ID_Direccion IN NUMBER, p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Direccion WHERE ID_Direccion = p_ID_Direccion;
    END Select_Direccion;
END CRUD_DIRECCION;
/
