CREATE TABLE Proveedor_Audit (
    Audit_ID NUMBER GENERATED ALWAYS AS IDENTITY,
    Audit_Action VARCHAR2(10),
    ID_Proveedor NUMBER,
    Nombre VARCHAR2(50),
    Apellido_1 VARCHAR2(50),
    Apellido_2 VARCHAR2(50),
    Telefono NUMBER,
    Correo VARCHAR2(100),
    ID_Direccion NUMBER,
    Audit_Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE OR REPLACE TRIGGER trg_Proveedor_Audit
AFTER INSERT OR UPDATE OR DELETE ON Proveedor
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO Proveedor_Audit (Audit_Action, ID_Proveedor, p_Nombre, p_Apellido_1, p_Apellido_2, p_Telefono, p_Correo, ID_Direccion)
        VALUES ('INSERT', :NEW.ID_Proveedor, :NEW.Nombre, :NEW.Apellido_1, :NEW.Apellido_2, :NEW.Telefono, :NEW.Correo, :NEW.ID_Direccion);
    ELSIF UPDATING THEN
        INSERT INTO Proveedor_Audit (Audit_Action, ID_Proveedor, p_Nombre, p_Apellido_1, p_Apellido_2, p_Telefono, p_Correo, ID_Direccion)
        VALUES ('UPDATE', :OLD.ID_Proveedor, :NEW.Nombre, :NEW.Apellido_1, :NEW.Apellido_2, :NEW.Telefono, :NEW.Correo, :NEW.ID_Direccion);
    ELSIF DELETING THEN
        INSERT INTO Proveedor_Audit (Audit_Action, ID_Proveedor, p_Nombre, p_Apellido_1, p_Apellido_2, p_Telefono, p_Correo, ID_Direccion)
        VALUES ('DELETE', :OLD.ID_Proveedor, :OLD.Nombre, :OLD.Apellido_1, :OLD.Apellido_2, :OLD.Telefono, :OLD.Correo, :OLD.ID_Direccion);
    END IF;
END trg_Proveedor_Audit;
/

CREATE OR REPLACE PACKAGE CRUD_PROVEEDOR AS
    PROCEDURE Insert_Proveedor(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Success OUT NUMBER);
    PROCEDURE Update_Proveedor(p_ID_Proveedor IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Success OUT NUMBER);
    PROCEDURE Delete_Proveedor(p_ID_Proveedor IN NUMBER, p_Success OUT NUMBER);
    PROCEDURE Select_All_Proveedor(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Proveedor(p_ID_Proveedor IN NUMBER, p_Result OUT SYS_REFCURSOR);
END CRUD_PROVEEDOR;
/

CREATE OR REPLACE PACKAGE BODY CRUD_PROVEEDOR AS
    PROCEDURE Insert_Proveedor(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Success OUT NUMBER) IS
    BEGIN
        INSERT INTO Proveedor (Nombre, Apellido_1, Apellido_2, Telefono, Correo, ID_Direccion)
        VALUES (p_Nombre, p_Apellido_1, p_Apellido_2, p_Telefono, p_Correo, p_ID_Direccion);
        p_Success := 1;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success := 0;
    END Insert_Proveedor;

    PROCEDURE Update_Proveedor(p_ID_Proveedor IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Success OUT NUMBER) IS
    BEGIN
        UPDATE Proveedor SET Nombre = p_Nombre, Apellido_1 = p_Apellido_1, Apellido_2 = p_Apellido_2, Telefono = p_Telefono, Correo = p_Correo, ID_Direccion = p_ID_Direccion WHERE ID_Proveedor = p_ID_Proveedor;
        p_Success := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success := 0;
    END Update_Proveedor;

    PROCEDURE Delete_Proveedor(p_ID_Proveedor IN NUMBER, p_Success OUT NUMBER) IS
    BEGIN
        DELETE FROM Proveedor WHERE ID_Proveedor = p_ID_Proveedor;
        p_Success := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success := 0;
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
