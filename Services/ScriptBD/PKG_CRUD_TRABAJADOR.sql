CREATE OR REPLACE PACKAGE CRUD_TRABAJADOR AS
    PROCEDURE Insert_Trabajador(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Cargo IN VARCHAR2, p_Salario IN NUMBER, p_Activo IN NUMBER, p_Fecha_Inicio IN DATE, p_ID_Sucursal IN NUMBER, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Update_Trabajador(p_ID_Trabajador IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Cargo IN VARCHAR2, p_Salario IN NUMBER, p_Activo IN NUMBER, p_Fecha_Inicio IN DATE, p_ID_Sucursal IN NUMBER, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Delete_Trabajador(p_ID_Trabajador IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Select_All_Trabajador(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Trabajador(p_ID_Trabajador IN NUMBER, p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Trabajador_Login(p_Nombre IN VARCHAR2, p_ID_Trabajador IN NUMBER, p_Result OUT SYS_REFCURSOR);
END CRUD_TRABAJADOR;
/

CREATE OR REPLACE PACKAGE BODY CRUD_TRABAJADOR AS

    PROCEDURE Select_Trabajador_Login(
        p_Nombre IN VARCHAR2,
        p_ID_Trabajador IN NUMBER,
        p_Result OUT SYS_REFCURSOR
    ) AS
    BEGIN
        OPEN p_Result FOR
        SELECT * FROM Trabajador
        WHERE Nombre = p_Nombre AND ID_Trabajador = p_ID_Trabajador;
    END Select_Trabajador_Login;
    

    PROCEDURE Insert_Trabajador(p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Cargo IN VARCHAR2, p_Salario IN NUMBER, p_Activo IN NUMBER, p_Fecha_Inicio IN DATE, p_ID_Sucursal IN NUMBER, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        INSERT INTO Trabajador (Nombre, Apellido_1, Apellido_2, Cargo, Salario, Activo, Fecha_Inicio, ID_Sucursal, ID_Direccion)
        VALUES (p_Nombre, p_Apellido_1, p_Apellido_2, p_Cargo, p_Salario, p_Activo, p_Fecha_Inicio, p_ID_Sucursal, p_ID_Direccion);
        p_Result := 1;
    EXCEPTION
        WHEN OTHERS THEN
            p_Result:= 'Error: ' || SQLERRM;
    END Insert_Trabajador;

    PROCEDURE Update_Trabajador(p_ID_Trabajador IN NUMBER, p_Nombre IN VARCHAR2, p_Apellido_1 IN VARCHAR2, p_Apellido_2 IN VARCHAR2, p_Cargo IN VARCHAR2, p_Salario IN NUMBER, p_Activo IN NUMBER, p_Fecha_Inicio IN DATE, p_ID_Sucursal IN NUMBER, p_ID_Direccion IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        UPDATE Trabajador SET Nombre = p_Nombre, Apellido_1 = p_Apellido_1, Apellido_2 = p_Apellido_2, Cargo = p_Cargo, Salario = p_Salario, Activo = p_Activo, Fecha_Inicio = p_Fecha_Inicio, ID_Sucursal = p_ID_Sucursal, ID_Direccion = p_ID_Direccion WHERE ID_Trabajador = p_ID_Trabajador;
        p_Result := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Result:= 'Error: ' || SQLERRM;
    END Update_Trabajador;

    PROCEDURE Delete_Trabajador(p_ID_Trabajador IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        DELETE FROM Trabajador WHERE ID_Trabajador = p_ID_Trabajador;
        p_Result := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            p_Result:= 'Error: ' || SQLERRM;
    END Delete_Trabajador;

    PROCEDURE Select_All_Trabajador(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Trabajador  ORDER BY ID_Trabajador ASC;
    END Select_All_Trabajador;

    PROCEDURE Select_Trabajador(p_ID_Trabajador IN NUMBER, p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Trabajador WHERE ID_Trabajador = p_ID_Trabajador;
    END Select_Trabajador;
END CRUD_TRABAJADOR;
/
