CREATE OR REPLACE PACKAGE CRUD_TRABAJADOR AS
    PROCEDURE Insert_Trabajador(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Cargo IN VARCHAR2, p_Salario IN NUMBER, p_Activo IN NUMBER, p_Fecha_Inicio IN DATE, p_ID_Sucursal IN NUMBER, p_ID_Direccion IN NUMBER, p_Success OUT NUMBER);
    PROCEDURE Update_Trabajador(p_ID_Trabajador IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Cargo IN VARCHAR2, p_Salario IN NUMBER, p_Activo IN NUMBER, p_Fecha_Inicio IN DATE, p_ID_Sucursal IN NUMBER, p_ID_Direccion IN NUMBER, p_Success OUT NUMBER);
    PROCEDURE Delete_Trabajador(p_ID_Trabajador IN NUMBER, p_Success OUT NUMBER);
    PROCEDURE Select_All_Trabajador(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Trabajador(p_ID_Trabajador IN NUMBER, p_Result OUT SYS_REFCURSOR);
END CRUD_TRABAJADOR;
/

CREATE OR REPLACE PACKAGE BODY CRUD_TRABAJADOR AS
    PROCEDURE Insert_Trabajador(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Cargo IN VARCHAR2, p_Salario IN NUMBER, p_Activo IN NUMBER, p_Fecha_Inicio IN DATE, p_ID_Sucursal IN NUMBER, p_ID_Direccion IN NUMBER, p_Success OUT NUMBER) IS
    BEGIN
        INSERT INTO Trabajador (Nombre, Apellido_1, Apellido_2, Cargo, Salario, Activo, Fecha_Inicio, ID_Sucursal, ID_Direccion)
        VALUES (p_Nombre, p_Apellido_1, p_Apellido_2, p_Cargo, p_Salario, p_Activo, p_Fecha_Inicio, p_ID_Sucursal, p_ID_Direccion);
        p_Success := 1;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success := 0;
    END Insert_Trabajador;

    PROCEDURE Update_Trabajador(p_ID_Trabajador IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Cargo IN VARCHAR2, p_Salario IN NUMBER, p_Activo IN NUMBER, p_Fecha_Inicio IN DATE, p_ID_Sucursal IN NUMBER, p_ID_Direccion IN NUMBER, p_Success OUT NUMBER) IS
    BEGIN
        UPDATE Trabajador SET Nombre = p_Nombre, Apellido_1 = p_Apellido_1, Apellido_2 = p_Apellido_2, Cargo = p_Cargo, Salario = p_Salario, Activo = p_Activo, Fecha_Inicio = p_Fecha_Inicio, ID_Sucursal = p_ID_Sucursal, ID_Direccion = p_ID_Direccion WHERE ID_Trabajador = p_ID_Trabajador;
        p_Success := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success := 0;
    END Update_Trabajador;

    PROCEDURE Delete_Trabajador(p_ID_Trabajador IN NUMBER, p_Success OUT NUMBER) IS
    BEGIN
        DELETE FROM Trabajador WHERE ID_Trabajador = p_ID_Trabajador;
        p_Success := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Success := 0;
    END Delete_Trabajador;

    PROCEDURE Select_All_Trabajador(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Trabajador;
    END Select_All_Trabajador;

    PROCEDURE Select_Trabajador(p_ID_Trabajador IN NUMBER, p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Trabajador WHERE ID_Trabajador = p_ID_Trabajador;
    END Select_Trabajador;
END CRUD_TRABAJADOR;
/
