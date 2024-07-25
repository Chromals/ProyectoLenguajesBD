-- Cursor para listar todos los clientes activos
CURSOR cur_ClientesActivos IS
SELECT c.ID_Cliente, c.Nombre, c.Apellido_1, c.Apellido_2
FROM Cliente c
JOIN Venta v ON c.ID_Cliente = v.ID_Cliente
GROUP BY c.ID_Cliente, c.Nombre, c.Apellido_1, c.Apellido_2
HAVING COUNT(v.ID_Venta) > 0;

-- Cursor para listar productos bajos en inventario
CURSOR cur_ProductosBajosEnInventario IS
SELECT p.ID_Producto, p.Nombre, i.Cantidad_Disponible, s.Nombre AS Sucursal
FROM Producto p
JOIN Inventario i ON p.ID_Producto = i.ID_Producto
JOIN Sucursal s ON i.ID_Sucursal = s.ID_Sucursal
WHERE i.Cantidad_Disponible < 6;

-- Cursor para listar devoluciones y sus motivos
CURSOR cur_Devoluciones IS
SELECT d.ID_Devolucion, d.Fecha, d.Motivo, v.ID_Venta
FROM Devolucion d
JOIN Venta v ON d.ID_Venta = v.ID_Venta;

-- Cursor para listar categorías y productos asociados
CURSOR cur_CategoriasProductos IS
SELECT c.Nombre AS Categoria, p.Nombre AS Producto
FROM Categoria c
JOIN Producto p ON c.ID_Categoria = p.ID_Categoria;

-- Cursor para listar ventas por sucursal
CURSOR cur_VentasPorSucursal IS
SELECT v.ID_Venta, v.Fecha, v.Total_Venta, s.Nombre AS Sucursal
FROM Venta v
JOIN Sucursal s ON v.ID_Sucursal = s.ID_Sucursal
ORDER BY s.Nombre, v.Fecha;

-- Cursor para listar productos más vendidos en el último mes
CURSOR cur_ProductosMasVendidosUltimoMes IS
SELECT p.Nombre AS Producto, SUM(v.Cantidad_Vendida) AS Cantidad_Total_Vendida
FROM Venta v
JOIN Producto p ON v.ID_Producto = p.ID_Producto
WHERE v.Fecha >= ADD_MONTHS(SYSDATE, -1)
GROUP BY p.Nombre
ORDER BY SUM(v.Cantidad_Vendida) DESC;

-- Cursor para listar auditorías recientes
CURSOR cur_AuditoriasRecientes IS
SELECT a.id_Auditoria, a.Fecha, a.Operacion, t.Nombre || ' ' || t.Apellido_1 AS Trabajador, a.Detalles
FROM Auditoria a
JOIN Trabajador t ON a.ID_Trabajador = t.ID_Trabajador
ORDER BY a.Fecha DESC;

-- Cursor para listar sucursales con menos ventas
CURSOR cur_SucursalesMenosVentas IS
SELECT s.ID_Sucursal, s.Nombre, COUNT(v.ID_Venta) AS Total_Ventas
FROM Sucursal s
LEFT JOIN Venta v ON s.ID_Sucursal = v.ID_Sucursal
GROUP BY s.ID_Sucursal, s.Nombre
ORDER BY COUNT(v.ID_Venta) ASC;

