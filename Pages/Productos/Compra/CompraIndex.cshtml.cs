using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Data;

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
        [
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        ];
        ResultTable = _oracleDbService.ExecuteStoredProcCursor("PKG_COMPRA_PROD.Listar_VentaProductos", parameters);
    }

    public JsonResult OnGetProveedores()
    {
        OracleParameter[] parameters =
        [
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        ];

        var proveedores = _oracleDbService.ExecuteStoredProcCursor("CRUD_PROVEEDOR.Select_All_Proveedor", parameters);
        var proveedoresList = new List<dynamic>();

        foreach (DataRow row in proveedores.Rows)
        {
            proveedoresList.Add(new { ID_Proveedor = row["ID_Proveedor"], Nombre = row["Nombre"]+"("+row["ID_Proveedor"]+")" });
        }

        return new JsonResult(proveedoresList);
    }

    public IActionResult OnPostRealizarCompra([FromBody] dynamic compra)
    {
        try
        {
            int idProducto = (int)compra.idProducto;
            int cantidad = (int)compra.cantidad;
            int idProveedor = (int)compra.idProveedor;

            OracleParameter[] precioParameters =
            {
                new OracleParameter("p_ID_Producto", idProducto),
                new OracleParameter("p_Precio", OracleDbType.Decimal, ParameterDirection.Output)
            };

            _oracleDbService.ExecuteStoredProc("PKG_COMPRA_PROD.ObtenerPrecioProductoProc", precioParameters);
            decimal precioProducto = Convert.ToDecimal(precioParameters[1].Value);

            if (precioProducto == 0)
            {
                return new JsonResult(new { success = false, message = "No se encontró el producto o el precio es inválido." });
            }

            OracleParameter[] compraParameters =
            {
                new OracleParameter("p_ID_Proveedor", idProveedor),
                new OracleParameter("p_ID_Producto", idProducto),
                new OracleParameter("p_Cantidad_Comprada", cantidad),
                new OracleParameter("p_Costo_Total", cantidad * precioProducto),
                new OracleParameter("p_Fecha_Compra", DateTime.Now),
                new OracleParameter("p_Result", OracleDbType.Varchar2, 4000, ParameterDirection.Output)
            };

            _oracleDbService.ExecuteStoredProc("PKG_COMPRA_PROD.Insertar_CompraProducto", compraParameters);
            string result = compraParameters[5].Value.ToString();

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
