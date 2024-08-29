using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Globalization;
using System.Collections.Generic;
using System.Data;
using System.Linq;

public class CompraIndex : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public CompraIndex(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public DataTable? ResultTable { get; set; }

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
        ResultTable = _oracleDbService.ExecuteStoredProcCursor("PKG_COMPRA_PROD.Listar_VentaProductos", parameters);
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

    public IActionResult OnPostRealizarCompra(int idProducto, int cantidad, int idProveedor)
    {
        try
        {
            if (idProducto <= 0 || cantidad <= 0 || idProveedor <= 0)
            {
                return new JsonResult(new { success = false, message = "Datos de la compra no son válidos." });
            }

            OracleParameter[] precioParameters =
            {
                new OracleParameter("p_ID_Producto", idProducto),
                new OracleParameter("p_Precio", OracleDbType.Varchar2, 4000, null, ParameterDirection.Output)
            };

            _oracleDbService.ExecuteStoredProc("PKG_COMPRA_PROD.ObtenerPrecioProductoProc", precioParameters);
            
            string precioProductoStr = precioParameters[1].Value?.ToString() ?? "0";

            var culture = new CultureInfo("en-US"); 
            culture.NumberFormat.CurrencyDecimalSeparator = ".";

            decimal precioProducto = Convert.ToDecimal(precioProductoStr, culture);
            if (precioProducto <= 0)
            {
                return new JsonResult(new { success = false, message = "No se encontró el producto o el precio es inválido."});
            }

            OracleParameter[] compraParameters =
            {
                new OracleParameter("p_ID_Proveedor", idProveedor),
                new OracleParameter("p_ID_Producto", idProducto),
                new OracleParameter("p_Cantidad_Comprada", cantidad),
                new OracleParameter("p_Costo_Total", cantidad * precioProducto),
                new OracleParameter("p_Fecha_Compra", DateTime.Now),
                new OracleParameter("p_Result", OracleDbType.Varchar2, 4000, null, ParameterDirection.Output)
            };

            _oracleDbService.ExecuteStoredProc("PKG_COMPRA_PROD.Insertar_CompraProducto", compraParameters);
            string result = compraParameters[5].Value.ToString();
            LoadData();
            if (result == "1")
            {
                return new JsonResult(new { success = true, message = "Compra realizada con éxito." });
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
