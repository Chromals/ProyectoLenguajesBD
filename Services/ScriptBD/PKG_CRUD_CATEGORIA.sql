CREATE OR REPLACE PACKAGE CRUD_CATEGORIA AS

    -- Categoría procedures
    PROCEDURE Insert_Categoria(p_Nombre IN VARCHAR2, p_Result OUT VARCHAR2);
    PROCEDURE Update_Categoria(p_ID_Categoria IN NUMBER, p_Nombre IN VARCHAR2, p_Result OUT VARCHAR2);
    PROCEDURE Delete_Categoria(p_ID_Categoria IN NUMBER, p_Result OUT VARCHAR2);
    PROCEDURE Select_All_Categoria(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Select_Categoria(p_ID_Categoria IN NUMBER, p_Result OUT SYS_REFCURSOR);

END CRUD_CATEGORIA;
/
    
CREATE OR REPLACE PACKAGE BODY CRUD_CATEGORIA AS

    PROCEDURE Insert_Categoria(p_Nombre IN VARCHAR2, p_Result OUT VARCHAR2) IS
    BEGIN
        INSERT INTO Categoria (Nombre)
        VALUES (p_Nombre);
        p_Result := '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := 'Error: ' || SQLERRM;
    END Insert_Categoria;

    PROCEDURE Update_Categoria(p_ID_Categoria IN NUMBER, p_Nombre IN VARCHAR2, p_Result OUT VARCHAR2) IS
    BEGIN
        UPDATE Categoria
        SET Nombre = p_Nombre
        WHERE ID_Categoria = p_ID_Categoria;
        p_Result := '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := 'Error: ' || SQLERRM;
    END Update_Categoria;

    PROCEDURE Delete_Categoria(p_ID_Categoria IN NUMBER, p_Result OUT VARCHAR2) IS
    BEGIN
        DELETE FROM Categoria
        WHERE ID_Categoria = p_ID_Categoria;
        p_Result := '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := 'Error: ' || SQLERRM;
    END Delete_Categoria;

    PROCEDURE Select_All_Categoria(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR 
            SELECT ID_Categoria, Nombre, '$' || CalcularValorInventarioCategoria(ID_Categoria) AS Valor_Inventario
                FROM Categoria ORDER BY ID_Categoria ASC;
    END Select_All_Categoria;

    PROCEDURE Select_Categoria(p_ID_Categoria IN NUMBER, p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR SELECT * FROM Categoria WHERE ID_Categoria = p_ID_Categoria;
    END Select_Categoria;

END CRUD_CATEGORIA;
/
