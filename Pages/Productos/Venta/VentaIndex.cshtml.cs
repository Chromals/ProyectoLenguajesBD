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

    public JsonResult OnGetProveedores()
    {
        OracleParameter[] parameters =
        {
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        };

        var proveedores = _oracleDbService.ExecuteStoredProcCursor("CRUD_PROVEEDOR.Select_All_Proveedor", parameters);
        var proveedoresList = new List<dynamic>();

        foreach (DataRow row in proveedores.Rows)
        {
            proveedoresList.Add(new { ID_Proveedor = row["ID_Proveedor"], Nombre = row["Nombre"] + " (" + row["ID_Proveedor"] + ")" });
        }

        return new JsonResult(proveedoresList);
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
                return new JsonResult(new { success = false, message = "No se encontró el producto o el precio es inválido."});
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
