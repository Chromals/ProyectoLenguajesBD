CREATE TABLE Cliente_Audit (
    Audit_ID NUMBER GENERATED ALWAYS AS IDENTITY,
    Audit_Action VARCHAR2(10),
    ID_Cliente NUMBER,
    Nombre VARCHAR2(50),
    Apellido_1 VARCHAR2(50),
    Apellido_2 VARCHAR2(50),
    Telefono NUMBER,
    Correo VARCHAR2(100),
    ID_Direccion NUMBER,
    Audit_Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE OR REPLACE TRIGGER trg_Cliente_Audit
AFTER INSERT OR UPDATE OR DELETE ON Cliente
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO Cliente_Audit (Audit_Action, ID_Cliente, p_Nombre, p_Apellido_1, p_Apellido_2, p_Telefono, p_Correo, ID_Direccion)
        VALUES ('INSERT', :NEW.ID_Cliente, :NEW.Nombre, :NEW.Apellido_1, :NEW.Apellido_2, :NEW.Telefono, :NEW.Correo, :NEW.ID_Direccion);
    ELSIF UPDATING THEN
        INSERT INTO Cliente_Audit (Audit_Action, ID_Cliente, p_Nombre, p_Apellido_1, p_Apellido_2, p_Telefono, p_Correo, ID_Direccion)
        VALUES ('UPDATE', :OLD.ID_Cliente, :NEW.Nombre, :NEW.Apellido_1, :NEW.Apellido_2, :NEW.Telefono, :NEW.Correo, :NEW.ID_Direccion);
    ELSIF DELETING THEN
        INSERT INTO Cliente_Audit (Audit_Action, ID_Cliente, p_Nombre, p_Apellido_1, p_Apellido_2, p_Telefono, p_Correo, ID_Direccion)
        VALUES ('DELETE', :OLD.ID_Cliente, :OLD.Nombre, :OLD.Apellido_1, :OLD.Apellido_2, :OLD.Telefono, :OLD.Correo, :OLD.ID_Direccion);
    END IF;
END trg_Cliente_Audit;
/

CREATE OR REPLACE PACKAGE CRUD_CLIENTE AS

    -- Cliente procedures
    PROCEDURE Insert_Cliente(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT NUMBER);
    PROCEDURE Update_Cliente(p_ID_Cliente IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT NUMBER);
    PROCEDURE Delete_Cliente(p_ID_Cliente IN NUMBER, p_Result OUT NUMBER);
    PROCEDURE Select_All_Cliente(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Cliente(p_ID_Cliente IN NUMBER, p_Result OUT SYS_REFCURSOR);

END CRUD_CLIENTE;
/
    
CREATE OR REPLACE PACKAGE BODY CRUD_CLIENTE AS

    PROCEDURE Insert_Cliente(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT NUMBER) IS
    BEGIN
        INSERT INTO Cliente (Nombre, Apellido_1, Apellido_2, Telefono, Correo, ID_Direccion)
        VALUES (p_Nombre, p_Apellido_1, p_Apellido_2, p_Telefono, p_Correo, p_ID_Direccion);
        p_Result := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := -1;
    END Insert_Cliente;

    PROCEDURE Update_Cliente(p_ID_Cliente IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Telefono IN NUMBER, p_Correo IN VARCHAR2, p_ID_Direccion IN NUMBER, p_Result OUT NUMBER) IS
    BEGIN
        UPDATE Cliente SET Nombre = p_Nombre, Apellido_1 = p_Apellido_1, Apellido_2 = p_Apellido_2, Telefono = p_Telefono, Correo = p_Correo, ID_Direccion = p_ID_Direccion WHERE ID_Cliente = p_ID_Cliente;
        p_Result := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := -1;
    END Update_Cliente;

    PROCEDURE Delete_Cliente(p_ID_Cliente IN NUMBER, p_Result OUT NUMBER) IS
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
