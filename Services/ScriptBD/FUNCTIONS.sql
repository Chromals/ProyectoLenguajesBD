-- Creación de la Función CalcularDescuentoCliente
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

-- Creación de la Función CalcularImpuestos
CREATE OR REPLACE FUNCTION CalcularImpuestos(monto NUMBER) RETURN NUMBER IS
    impuestos NUMBER(10, 2);
BEGIN
    impuestos := monto * 0.13; -- Porcentaje de impuestos
    RETURN impuestos;
END;
/

-- Creación de la Función CantidadProducto
CREATE OR REPLACE FUNCTION CantidadProducto(id_producto NUMBER) RETURN NUMBER IS
    cantidad NUMBER;
BEGIN
    SELECT COUNT(*) INTO cantidad FROM Producto WHERE ID_Producto = id_producto;
    RETURN cantidad;
END;
/

-- Creación de la Función ConvertirMoneda
CREATE OR REPLACE FUNCTION ConvertirMoneda(monto_colon NUMBER) RETURN NUMBER IS
    monto_dolar NUMBER(10, 2);
BEGIN
    monto_dolar := monto_colon / 535.00; -- Tasa de cambio
    RETURN monto_dolar;
END;
/

-- Creación de la Función GenerarCodigoProducto
CREATE OR REPLACE FUNCTION GenerarCodigoProducto(nombre_producto VARCHAR2, id_categoria NUMBER) RETURN VARCHAR2 IS
    codigo VARCHAR2(20);
BEGIN
    SELECT SUBSTR(nombre_producto, 1, 3) || '-' || TO_CHAR(id_categoria)
    INTO codigo
    FROM dual;
    RETURN codigo;
END;
/

-- Creación de la Función VerificarDisponibilidadProducto
CREATE OR REPLACE FUNCTION VerificarDisponibilidadProducto(id_producto NUMBER) RETURN VARCHAR2 IS
    cantidad_disponible NUMBER;
    mensaje VARCHAR2(100);
BEGIN
    SELECT NVL(SUM(Cantidad_Disponible),0) INTO cantidad_disponible
        FROM Inventario
        WHERE ID_Producto = id_producto;

    IF cantidad_disponible > 0 THEN
        mensaje := 'Disponible';
    ELSE
        mensaje := 'No Disponible';
    END IF;

    RETURN mensaje;
END;
/

-- Creación de la Función calcular el valor total del inventario que pertenecen a una categoría
CREATE OR REPLACE FUNCTION CalcularValorInventarioCategoria(
    p_id_categoria INT
) RETURN NUMBER IS
    v_valor_total NUMBER := 0;
BEGIN
    SELECT SUM(Precio * Cantidad)
    INTO v_valor_total
    FROM Producto
    WHERE ID_Categoria = p_id_categoria;

    RETURN v_valor_total;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE;
END;
/
-- Creación de la Función Calcular salario total de un trabajador
CREATE OR REPLACE FUNCTION CalcularSalarioTotalTrabajador(
    p_id_trabajador IN INT
) RETURN NUMBER IS
    v_salario_total NUMBER;
BEGIN
    SELECT Salario * MONTHS_BETWEEN(SYSDATE, Fecha_Inicio)
    INTO v_salario_total
    FROM Trabajador
    WHERE ID_Trabajador = p_id_trabajador;

    RETURN v_salario_total;
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END;
/

-- Creación de la Función Obtener nombre de un cliente
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

-- Creación de la Función para verificar si aplica la devolución (basada en la fecha):
CREATE OR REPLACE FUNCTION VerificarAplicacionDevolucion(
    p_fecha_compra DATE) RETURN VARCHAR2 IS
    v_aplica_devolucion VARCHAR2(20);
BEGIN
    IF MONTHS_BETWEEN(SYSDATE, p_fecha_compra) > 60 THEN
        v_aplica_devolucion := 'No Aplica';
    ELSE
        v_aplica_devolucion := 'Aplica';
    END IF;
    
    RETURN v_aplica_devolucion;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error';
END;
/

-- Creación de la Función para Verificar si se hace la devolucion 
CREATE OR REPLACE FUNCTION VerificarDevolucion(id_venta NUMBER) RETURN VARCHAR2 IS
    resultado VARCHAR2(1);
BEGIN
    SELECT CASE 
            WHEN COUNT(*) > 0 THEN 'S'
            ELSE 'N'
           END
    INTO resultado
    FROM Devolucion
    WHERE ID_Venta = id_venta;

    RETURN resultado;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error';
END;
/

-- Creación de la Función para Calcular el total de ventas de un producto en una sucursal 
CREATE OR REPLACE FUNCTION CalcularTotalVentasProductoSucursal( p_id_producto IN NUMBER, p_id_sucursal IN NUMBER) RETURN NUMBER IS
    v_total_ventas NUMBER := 0;
BEGIN
    SELECT SUM(Total_Venta)
    INTO v_total_ventas
    FROM Venta
    WHERE ID_Producto = p_id_producto AND ID_Sucursal = p_id_sucursal;

    RETURN v_total_ventas;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE;
END;
/

-- Creación de la Función para Obtener la Cantidad Vendida de un Producto
CREATE OR REPLACE FUNCTION ObtenerCantidadVendidaProducto(p_id_producto IN NUMBER) RETURN NUMBER IS
    v_cantidad_vendida NUMBER := 0;
BEGIN
    SELECT SUM(Cantidad_Vendida)
    INTO v_cantidad_vendida
    FROM Venta
    WHERE ID_Producto = p_id_producto;

    RETURN v_cantidad_vendida;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE;
END;
/

-- Creación de la Función para Calcular el Total de Ventas en un Periodo
CREATE OR REPLACE FUNCTION CalcularTotalVentasPeriodo(p_fecha_inicio IN DATE, p_fecha_fin IN DATE ) RETURN NUMBER IS
    v_total_ventas NUMBER := 0;
BEGIN
    SELECT SUM(Total_Venta)
    INTO v_total_ventas
    FROM Venta
    WHERE Fecha BETWEEN p_fecha_inicio AND p_fecha_fin;

    RETURN v_total_ventas;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE;
END;
/

-- Creación de la Función para Obtener el Producto con Mayor Cantidad Vendida en una Sucursal
CREATE OR REPLACE FUNCTION ProductoMayorCantidadVendidaSucursal(p_id_sucursal IN NUMBER) RETURN VARCHAR2 IS
    v_id_producto NUMBER;
    v_nombre_producto VARCHAR2(200);
BEGIN
    SELECT ID_Producto
    INTO v_id_producto
    FROM (
        SELECT ID_Producto, SUM(Cantidad_Vendida) AS Total_Cantidad
        FROM Venta
        WHERE ID_Sucursal = p_id_sucursal
        GROUP BY ID_Producto
        ORDER BY Total_Cantidad DESC
    )
    WHERE ROWNUM = 1;

    SELECT Nombre
    INTO v_nombre_producto
    FROM Producto
    WHERE ID_Producto = v_id_producto;

    RETURN v_nombre_producto;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Producto no encontrado';
    WHEN OTHERS THEN
        RETURN 'Error en la función';
END;
/
