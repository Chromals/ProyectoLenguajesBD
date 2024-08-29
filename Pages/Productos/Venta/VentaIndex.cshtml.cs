using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Globalization;
using System.Collections.Generic;
using System.Data;
using System.Linq;

public class VentaIndex : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public VentaIndex(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public DataTable? ResultTable { get; set; }

    public DataTable? ResultTableDevoluciones { get; set; }

    public void OnGet()
    {
        LoadData();
    }

    private void LoadData()
    {
        OracleParameter[] parameters =
        {
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        };
        ResultTable = _oracleDbService.ExecuteStoredProcCursor("PKG_VENTA_PROD.Listar_Ventas", parameters);
        ResultTableDevoluciones = _oracleDbService.ExecuteStoredProcCursor("PKG_VENTA_PROD.Listar_Devoluciones", parameters);

    }

    public JsonResult OnGetProductos()
    {
        OracleParameter[] parameters =
        {
        new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
    };

        var productos = _oracleDbService.ExecuteStoredProcCursor("CRUD_PRODUCTO.Select_All_Producto", parameters);
        var productosList = new List<dynamic>();

        foreach (DataRow row in productos.Rows)
        {
            productosList.Add(new
            {
                ID_Producto = row["ID_Producto"],
                Nombre = row["Nombre"] + " (" + row["ID_Producto"] + ")"
            });
        }

        return new JsonResult(productosList);
    }

    public JsonResult OnGetSucursales()
    {
        OracleParameter[] parameters =
        {
        new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
    };

        var sucursales = _oracleDbService.ExecuteStoredProcCursor("CRUD_SUCURSAL.Select_All_Sucursal", parameters);
        var sucursalesList = new List<dynamic>();

        foreach (DataRow row in sucursales.Rows)
        {
            sucursalesList.Add(new
            {
                ID_Sucursal = row["ID_Sucursal"],
                Nombre = row["Nombre"] + " (" + row["ID_Sucursal"] + ")"
            });
        }

        return new JsonResult(sucursalesList);
    }

    public JsonResult OnGetClientes()
    {
        OracleParameter[] parameters =
        {
        new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
    };

        var clientes = _oracleDbService.ExecuteStoredProcCursor("CRUD_CLIENTE.Select_All_Cliente", parameters);
        var clientesList = new List<dynamic>();

        foreach (DataRow row in clientes.Rows)
        {
            clientesList.Add(new
            {
                ID_Cliente = row["ID_Cliente"],
                Nombre = row["Nombre"] + " (" + row["ID_Cliente"] + ")"
            });
        }

        return new JsonResult(clientesList);
    }


    public JsonResult OnGetTrabajadores()
    {
        OracleParameter[] parameters =
        {
        new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
    };

        var trabajadores = _oracleDbService.ExecuteStoredProcCursor("CRUD_TRABAJADOR.Select_All_Trabajador", parameters);
        var trabajadoresList = new List<dynamic>();

        foreach (DataRow row in trabajadores.Rows)
        {
            trabajadoresList.Add(new
            {
                ID_Trabajador = row["ID_Trabajador"],
                Nombre = row["Nombre"] + " (" + row["ID_Trabajador"] + ")"
            });
        }

        return new JsonResult(trabajadoresList);
    }




    public IActionResult OnPostRealizarVenta()
    {
        int idProducto = Convert.ToInt32(Request.Form["idProducto"]);
        int idSucursal = Convert.ToInt32(Request.Form["idSucursal"]);
        int idCliente = Convert.ToInt32(Request.Form["idCliente"]);
        int idTrabajador = Convert.ToInt32(Request.Form["idTrabajador"]);
        int cantidad = Convert.ToInt32(Request.Form["cantidad"]);

        if (idProducto <= 0 || idSucursal <= 0 || idCliente <= 0|| idTrabajador <= 0|| cantidad <= 0)
        {
            return new JsonResult(new { success = false, message = "Datos de la venta no son válidos." });
        }

        OracleParameter[] parameters = 
        {
            new OracleParameter("p_id_producto", OracleDbType.Int32) { Value = idProducto },
            new OracleParameter("p_id_sucursal", OracleDbType.Int32) { Value = idSucursal },
            new OracleParameter("p_id_cliente", OracleDbType.Int32) { Value = idCliente },
            new OracleParameter("p_id_trabajador", OracleDbType.Int32) { Value = idTrabajador },
            new OracleParameter("p_cantidad", OracleDbType.Int32) { Value = cantidad },
            new OracleParameter("p_total_venta", OracleDbType.Decimal, 18) { Direction = ParameterDirection.Output },
            new OracleParameter("p_Result", OracleDbType.Varchar2, 4000) { Direction = ParameterDirection.Output }
        };

        try
        {
            var result = _oracleDbService.ExecuteStoredProc("PKG_VENTA_PROD.RealizarVenta", parameters);

            decimal totalVenta = Convert.ToDecimal(parameters.First(p => p.ParameterName == "p_total_venta").Value);
            string resultMessage = parameters.First(p => p.ParameterName == "p_Result").Value.ToString();

            if (resultMessage.Contains("Error:"))
            {
                return new JsonResult(new { success = false, message = resultMessage });
            }
            else
            {
                return new JsonResult(new { success = true, message = $"Venta realizada con éxito. Total: {totalVenta:C}" });
            }
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = $"Error al realizar la venta: {ex.Message}" });
        }
    }

    public IActionResult OnPostDevolverProducto(int ventaId, string motivo)
    {
        try
        {
            if (ventaId <= 0 || string.IsNullOrEmpty(motivo))
            {
                return new JsonResult(new { success = false, message = "Datos de la devolución no son válidos." });
            }

            OracleParameter[] devolverParameters =
            {
            new OracleParameter("p_ID_Venta", ventaId),
            new OracleParameter("p_Motivo", motivo),
            new OracleParameter("p_Result", OracleDbType.Varchar2, 4000, null, ParameterDirection.Output)
        };

            _oracleDbService.ExecuteStoredProc("PKG_VENTA_PROD.Devolver_Producto", devolverParameters);
            string result = devolverParameters[2].Value.ToString();

            if (result.StartsWith("Error"))
            {
                return new JsonResult(new { success = false, message = result });
            }

            return new JsonResult(new { success = true, message = result });
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }


    public IActionResult OnPostRealizarVenta(int idProducto, int cantidad, int idProveedor)
    {
        try
        {
            if (idProducto <= 0 || cantidad <= 0 || idProveedor <= 0)
            {
                return new JsonResult(new { success = false, message = "Datos de la Venta no son válidos." });
            }

            OracleParameter[] precioParameters =
            {
                new OracleParameter("p_ID_Producto", idProducto),
                new OracleParameter("p_Precio", OracleDbType.Varchar2, 4000, null, ParameterDirection.Output)
            };

            _oracleDbService.ExecuteStoredProc("PKG_Venta_PROD.ObtenerPrecioProductoProc", precioParameters);

            string precioProductoStr = precioParameters[1].Value?.ToString() ?? "0";

            var culture = new CultureInfo("en-US");
            culture.NumberFormat.CurrencyDecimalSeparator = ".";

            decimal precioProducto = Convert.ToDecimal(precioProductoStr, culture);
            if (precioProducto <= 0)
            {
                return new JsonResult(new { success = false, message = "No se encontró el producto o el precio es inválido." });
            }

            OracleParameter[] VentaParameters =
            {
                new OracleParameter("p_ID_Proveedor", idProveedor),
                new OracleParameter("p_ID_Producto", idProducto),
                new OracleParameter("p_Cantidad_Ventada", cantidad),
                new OracleParameter("p_Costo_Total", cantidad * precioProducto),
                new OracleParameter("p_Fecha_Venta", DateTime.Now),
                new OracleParameter("p_Result", OracleDbType.Varchar2, 4000, null, ParameterDirection.Output)
            };

            _oracleDbService.ExecuteStoredProc("PKG_Venta_PROD.Insertar_VentaProducto", VentaParameters);
            string result = VentaParameters[5].Value.ToString();

            if (result == "1")
            {
                return new JsonResult(new { success = true, message = "Venta realizada con éxito." });
            }
            else
            {
                return new JsonResult(new { success = false, message = result });
            }
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }
}
