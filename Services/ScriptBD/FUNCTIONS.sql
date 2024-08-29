-- Creación de la Función CalcularDescuentoCliente ****************************
CREATE OR REPLACE FUNCTION CalcularDescuentoCliente(id_producto NUMBER) RETURN NUMBER IS
    descuento NUMBER(5, 2);
BEGIN
    SELECT CASE 
            WHEN ID_Categoria IN (1) THEN 0.15
            WHEN ID_Categoria IN (2) THEN 0.05
            WHEN ID_Categoria IN (3) THEN 0.30
            WHEN ID_Categoria IN (4) THEN 0.45
            WHEN ID_Categoria IN (5) THEN 0.15
            WHEN ID_Categoria IN (6, 7, 8) THEN 0.25
            WHEN ID_Categoria IN (9, 10) THEN 0.10
            ELSE 0
           END
    INTO descuento
    FROM Producto WHERE ID_Producto = id_producto;
    RETURN descuento;
END;
/

-- Creación de la Función CalcularImpuestos***************
CREATE OR REPLACE FUNCTION CalcularImpuestos(monto NUMBER) RETURN NUMBER IS
    impuestos NUMBER(10, 2);
BEGIN
    impuestos := monto * 0.13; -- Porcentaje de impuestos
    RETURN impuestos;
END;
/

-- Creación de la Función CantidadProducto ************
CREATE OR REPLACE FUNCTION CantidadProducto(id_producto NUMBER) RETURN NUMBER IS
    cantidad NUMBER;
BEGIN
    SELECT COUNT(*) INTO cantidad FROM Producto WHERE ID_Producto = id_producto;
    RETURN cantidad;
END;
/

-- Creación de la Función ConvertirMoneda******************
CREATE OR REPLACE FUNCTION ConvertirMoneda(monto_colon NUMBER) RETURN NUMBER IS
    monto_dolar NUMBER(10, 2);
BEGIN
    monto_dolar := monto_colon / 535.00; -- Tasa de cambio
    RETURN monto_dolar;
END;
/

-- Creación de la Función GenerarCodigoProducto*********************U
CREATE OR REPLACE FUNCTION GenerarCodigoProducto(nombre_producto VARCHAR2, id_categoria NUMBER) RETURN VARCHAR2 IS
    codigo VARCHAR2(20);
BEGIN
    SELECT SUBSTR(nombre_producto, 1, 3) || '-' || TO_CHAR(id_categoria)
    INTO codigo
    FROM dual;
    RETURN codigo;
END;
/

-- Creación de la Función VerificarDisponibilidadProducto**********************
CREATE OR REPLACE FUNCTION VerificarDisponibilidadProducto(p_id_producto NUMBER) RETURN VARCHAR2 IS
        cantidad_disponible NUMBER;
        mensaje VARCHAR2(100);
    BEGIN
        SELECT NVL(SUM(Cantidad_Disponible),0) INTO cantidad_disponible
        FROM Inventario
        WHERE ID_Producto = p_id_producto;

        IF cantidad_disponible > 0 THEN
            mensaje := 'Disponible';
        ELSE
            mensaje := 'No Disponible';
        END IF;

        RETURN mensaje;
    END;
/

CREATE OR REPLACE FUNCTION ObtenerPrecioProducto(p_ID_Producto IN NUMBER) RETURN NUMBER IS
        v_Precio NUMBER;
    BEGIN
        SELECT Precio INTO v_Precio
        FROM Producto
        WHERE ID_Producto = p_ID_Producto;

        RETURN v_Precio;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN NULL;
    END ObtenerPrecioProducto;

CREATE OR REPLACE FUNCTION CalcularValorInventarioCategoria(
    p_id_categoria INT
) RETURN NUMBER IS
    v_valor_total NUMBER := 0;
BEGIN
    SELECT SUM(Precio * Cantidad)
    INTO v_valor_total
    FROM Producto
    WHERE ID_Categoria = p_id_categoria;

--Obtener nombre de un cliente *********************
CREATE OR REPLACE FUNCTION ObtenerNombreCompletoCliente(
    p_id_cliente IN INT
) RETURN VARCHAR2 IS
    v_nombre_completo VARCHAR2(200);
BEGIN
    SELECT Nombre || ' ' || Apellido_1 || ' ' || Apellido_2
    INTO v_nombre_completo
    FROM Cliente
    WHERE ID_Cliente = p_id_cliente;

    RETURN v_nombre_completo;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error';
END;
/

--Calcular salario total de un trabajador ************************
CREATE OR REPLACE FUNCTION CalcularSalarioTotalTrabajador(
    p_id_trabajador IN INT
) RETURN NUMBER IS
    v_salario_total NUMBER;
BEGIN
    SELECT ROUND(Salario * MONTHS_BETWEEN(SYSDATE, Fecha_Inicio), 2)
    INTO v_salario_total
    FROM Trabajador
    WHERE ID_Trabajador = p_id_trabajador;

    RETURN v_salario_total;
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END;
/

--Calcular el valor del inventario que tiene una categoria especifica************************
CREATE OR REPLACE FUNCTION CalcularValorInventarioCategoria(
    p_id_categoria INT
) RETURN NUMBER IS
    v_valor_total NUMBER := 0;
BEGIN
    SELECT  ROUND(SUM(Precio * Cantidad),2)
    INTO v_valor_total
    FROM Producto
    WHERE ID_Categoria = p_id_categoria;

    RETURN NVL(v_valor_total,0);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE;
END;
/



