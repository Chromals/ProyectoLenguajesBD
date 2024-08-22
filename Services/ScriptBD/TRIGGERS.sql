-- Creación de triggers
CREATE OR REPLACE TRIGGER Tr_ActualizacionAutomaticaPrecios
AFTER INSERT OR UPDATE ON Producto
FOR EACH ROW
BEGIN
    IF TO_CHAR(SYSDATE, 'MMDD') = '0101' THEN
        UPDATE Producto
        SET Precio = Precio + CalcularImpuestos(Precio)
        WHERE ID_Producto = :NEW.ID_Producto;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER AuditLog_Salario
AFTER UPDATE ON Trabajador
FOR EACH ROW
BEGIN
    IF UPDATING('Salario') THEN
        INSERT INTO Auditoria (Fecha, Operacion, ID_Trabajador, Detalles)
        VALUES (SYSDATE, 'UPDATE', :NEW.ID_Trabajador, 'Salario actualizado');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER actualizar_inventario
AFTER INSERT ON Venta
FOR EACH ROW
BEGIN
    UPDATE Inventario
    SET Cantidad_Disponible = Cantidad_Disponible - :NEW.Cantidad_Vendida
    WHERE ID_Producto = :NEW.ID_Producto
    AND ID_Sucursal = :NEW.ID_Sucursal;
END;
/

--Update inventario despues de devouluciones 
CREATE OR REPLACE TRIGGER TGR_ActualizarInventarioDespuesDevolucion
AFTER INSERT ON Devolucion
FOR EACH ROW
BEGIN
    UPDATE Inventario
    SET Cantidad_Disponible = Cantidad_Disponible + (SELECT Cantidad_Vendida FROM Venta WHERE ID_Venta = :NEW.ID_Venta)
    WHERE ID_Producto = (SELECT ID_Producto FROM Venta WHERE ID_Venta = :NEW.ID_Venta);
END;
/

--Auditar cambios de cargo en trabajadores
CREATE OR REPLACE TRIGGER TGR_RegistrarAuditoriaCambioCargo
AFTER UPDATE OF Cargo ON Trabajador
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (Fecha, Operacion, ID_Trabajador, Detalles)
    VALUES (SYSDATE, 'Cambio de Cargo', :NEW.ID_Trabajador, 'El cargo fue actualizado a ' || :NEW.Cargo);
END;
/

