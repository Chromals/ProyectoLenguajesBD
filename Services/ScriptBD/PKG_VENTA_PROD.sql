CREATE OR REPLACE PACKAGE PKG_VENTA_PROD AS

    PROCEDURE Devolver_Producto(p_ID_Venta IN NUMBER,p_Motivo IN VARCHAR2,p_Result OUT VARCHAR2);
    PROCEDURE Listar_Ventas(p_Result OUT SYS_REFCURSOR);
    PROCEDURE Listar_Devoluciones(p_Result OUT SYS_REFCURSOR);
    PROCEDURE RealizarVenta(p_id_producto IN NUMBER, p_id_sucursal IN NUMBER, p_id_cliente IN NUMBER,p_id_trabajador IN NUMBER, p_cantidad IN NUMBER, p_total_venta OUT NUMBER, p_Result OUT VARCHAR2);
    
    PROCEDURE ActualizarInventario(p_id_producto IN NUMBER, p_id_sucursal IN NUMBER, p_cantidad_vendida IN NUMBER, p_Result OUT VARCHAR2 );
    
    PROCEDURE RegistrarAuditoria(p_id_trabajador IN NUMBER, p_operacion IN VARCHAR2, p_detalles IN VARCHAR2, p_Result OUT VARCHAR2);

END PKG_VENTA_PROD;
/


CREATE OR REPLACE PACKAGE BODY PKG_VENTA_PROD AS

    PROCEDURE Devolver_Producto(
        p_ID_Venta IN NUMBER,
        p_Motivo IN VARCHAR2,
        p_Result OUT VARCHAR2
    ) IS
    BEGIN
        -- Insertar la devolución
        INSERT INTO Devolucion (ID_Venta, Motivo, Fecha)
        VALUES (p_ID_Venta, p_Motivo, SYSDATE);

        -- Actualizar la cantidad vendida (puedes ajustar según la lógica de negocio)
        UPDATE Venta
        SET Cantidad_Vendida = Cantidad_Vendida - 1 -- Aquí se asume que se devuelve una unidad; ajusta según sea necesario
        WHERE ID_Venta = p_ID_Venta;

        -- Devuelve el éxito
        p_Result := 'Devolución realizada con éxito';
    EXCEPTION
        WHEN OTHERS THEN
            p_Result := 'Error: ' || SQLERRM;
    END Devolver_Producto;
    

    PROCEDURE Listar_Ventas(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR
        SELECT 
            ID_Venta, 
            ID_Producto, 
            ID_Sucursal, 
            ID_Cliente, 
            Cantidad_Vendida, 
            Total_Venta, 
            VerificarAplicacionDevolucion(ID_Venta) AS Aplica_Devolucion,
            VerificarDevolucion(ID_Venta) AS ind_devuelto
        FROM Venta;
    END Listar_Ventas;

    PROCEDURE Listar_Devoluciones(p_Result OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Result FOR
        SELECT * FROM Devolucion;
    END Listar_Devoluciones;

    PROCEDURE RealizarVenta(
        p_id_producto IN NUMBER,
        p_id_sucursal IN NUMBER,
        p_id_cliente IN NUMBER,
        p_id_trabajador IN NUMBER,
        p_cantidad IN NUMBER,
        p_total_venta OUT NUMBER,
        p_Result OUT VARCHAR2
    ) AS
        v_precio_producto NUMBER;
        v_descuento NUMBER;
        v_impuestos NUMBER;
        v_total_sin_descuento NUMBER;
        v_total_con_descuento NUMBER;
        v_cantidad_disponible NUMBER;
    BEGIN
        BEGIN
            v_cantidad_disponible := CantidadProducto(p_id_producto);

            IF v_cantidad_disponible < p_cantidad THEN
                p_Result := 'Error: No hay suficiente inventario disponible para realizar la venta.';
                ROLLBACK;
                RETURN;
            END IF;

            -- Obtener el precio 
            SELECT Precio INTO v_precio_producto
            FROM Producto
            WHERE ID_Producto = p_id_producto;

            v_total_sin_descuento := v_precio_producto * p_cantidad;

            -- Calcular el descuento
            v_descuento := CalcularDescuentoCliente(p_id_cliente);
            v_total_con_descuento := v_total_sin_descuento - (v_total_sin_descuento * v_descuento);

            v_impuestos := CalcularImpuestos(v_total_con_descuento);

            p_total_venta := v_total_con_descuento + v_impuestos;

            -- Hacer la venta
            INSERT INTO Venta (ID_Producto, ID_Sucursal, ID_Cliente, Cantidad_Vendida, Total_Venta, Fecha)
            VALUES (p_id_producto, p_id_sucursal, p_id_cliente, p_cantidad, p_total_venta, SYSDATE);

            ActualizarInventario(p_id_producto, p_id_sucursal, p_cantidad, p_Result);

            RegistrarAuditoria(p_id_trabajador, 'Realizar Venta', 'Venta realizada con éxito al cliente: ' || ObtenerNombreCompletoCliente(p_id_cliente), p_Result);

        EXCEPTION
            WHEN OTHERS THEN
                p_Result := 'Error al realizar la venta: ' || SQLERRM;
                ROLLBACK;
        END;
    END RealizarVenta;

    PROCEDURE ActualizarInventario(
        p_id_producto IN NUMBER,
        p_id_sucursal IN NUMBER,
        p_cantidad_vendida IN NUMBER,
        p_Result OUT VARCHAR2
    ) AS
    BEGIN
        BEGIN
            -- Actualizar la cantidad disponible en inventario
            UPDATE Inventario
            SET Cantidad_Disponible = Cantidad_Disponible - p_cantidad_vendida,
                Fecha_Actualizacion = SYSDATE
            WHERE ID_Producto = p_id_producto
            AND ID_Sucursal = p_id_sucursal;

            IF SQL%ROWCOUNT = 0 THEN
                p_Result := 'Error: No se encontró inventario para el producto en la sucursal especificada.';
                ROLLBACK;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_Result := 'Error al actualizar el inventario: ' || SQLERRM;
                ROLLBACK;
        END;
    END ActualizarInventario;

    PROCEDURE RegistrarAuditoria(
        p_id_trabajador IN NUMBER,
        p_operacion IN VARCHAR2,
        p_detalles IN VARCHAR2,
        p_Result OUT VARCHAR2
    ) AS
    BEGIN
        BEGIN
            INSERT INTO Auditoria (Fecha, Operacion, ID_Trabajador, Detalles)
            VALUES (SYSDATE, p_operacion, p_id_trabajador, p_detalles);

        EXCEPTION
            WHEN OTHERS THEN
                p_Result := 'Error al registrar auditoría: ' || SQLERRM;
        END;
    END RegistrarAuditoria;

END PKG_VENTA_PROD;
/