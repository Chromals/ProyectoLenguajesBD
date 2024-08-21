using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Data;

public class ProductoIndex : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public ProductoIndex(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public DataTable? ResultTable { get; set; }

    public void OnGet()
    {
        LoadData();
    }

    public JsonResult OnPostSaveProducto(int pID_Producto, string pNombre, string pDescripcion, decimal pPrecio, int pID_Categoria, int pCantidad)
{
    try
    {
        string res;
        OracleParameter[] parameters;

        if (ProductoExiste(pID_Producto))
        {
            parameters =
            [
                new OracleParameter("p_ID_Producto", OracleDbType.Int32, pID_Producto, ParameterDirection.Input),
                new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNombre, ParameterDirection.Input),
                new OracleParameter("p_Descripcion", OracleDbType.Varchar2, pDescripcion, ParameterDirection.Input),
                new OracleParameter("p_Precio", OracleDbType.Decimal, pPrecio, ParameterDirection.Input),
                new OracleParameter("p_ID_Categoria", OracleDbType.Int32, pID_Categoria, ParameterDirection.Input),
                new OracleParameter("p_Cantidad", OracleDbType.Int32, pCantidad, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.Varchar2, 4000, null, ParameterDirection.Output)
            ];
            res = _oracleDbService.ExecuteStoredProc("CRUD_PRODUCTO.Update_Producto", parameters);
        }
        else
        {
            parameters =
            [
                new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNombre, ParameterDirection.Input),
                new OracleParameter("p_Descripcion", OracleDbType.Varchar2, pDescripcion, ParameterDirection.Input),
                new OracleParameter("p_Precio", OracleDbType.Decimal, pPrecio, ParameterDirection.Input),
                new OracleParameter("p_ID_Categoria", OracleDbType.Int32, pID_Categoria, ParameterDirection.Input),
                new OracleParameter("p_Cantidad", OracleDbType.Int32, pCantidad, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.Varchar2, 4000, null, ParameterDirection.Output)
            ];
            res = _oracleDbService.ExecuteStoredProc("CRUD_PRODUCTO.Insert_Producto", parameters);
        }

        if (res.StartsWith("Error: "))
        {
            return new JsonResult(new { success = false, message = res });
        }
        else
        {
            if (string.IsNullOrWhiteSpace(res) || Convert.ToInt32(res) > 0)
                return new JsonResult(new { success = true });
            else
                return new JsonResult(new { success = false, message = "No se realizó ninguna acción con el registro." });
        }
    }
    catch (Exception ex)
    {
        return new JsonResult(new { success = false, message = ex.Message });
    }
}


    public JsonResult OnPostDeleteProducto(int id)
    {
        try
        {
            OracleParameter[] parameters =
            [
                new OracleParameter("p_ID_Producto", OracleDbType.Int32, id, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.Varchar2, 4000, null, ParameterDirection.Output)
            ];
            string res = _oracleDbService.ExecuteStoredProc("CRUD_PRODUCTO.Delete_Producto", parameters);

            if (res.StartsWith("Error: "))
            {
                return new JsonResult(new { success = false, message = res });
            }
            else
            {
                if (string.IsNullOrWhiteSpace(res) || Convert.ToInt32(res) > 0)
                {
                    LoadData();
                    return new JsonResult(new { success = true });
                }
                else
                    return new JsonResult(new { success = false, message = "No se eliminó ningún registro." });
            }
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    public IActionResult OnGetEditProducto(int id)
    {
        try
        {
            OracleParameter[] parameters =
            [
                new OracleParameter("p_ID_Producto", OracleDbType.Int32, id, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
            ];

            DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_PRODUCTO.Select_Producto", parameters);

            if (dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];
                var Producto = new
                {
                    ID_Producto = row["ID_Producto"],
                    Nombre = row["Nombre"],
                    Descripcion = row["Descripcion"],
                    Precio = row["Precio"],
                    ID_Categoria = row["ID_Categoria"],
                    Cantidad = row["Cantidad"]
                };
                return new JsonResult(Producto);
            }
            return new JsonResult(null);
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    private void LoadData()
    {
        OracleParameter[] parameters =
        [
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        ];
        ResultTable = _oracleDbService.ExecuteStoredProcCursor("CRUD_PRODUCTO.Select_All_Producto", parameters);
    }

    private bool ProductoExiste(int ID_Producto)
    {
        OracleParameter[] parameters =
        [
            new OracleParameter("p_ID_Producto", OracleDbType.Int32, ID_Producto, ParameterDirection.Input),
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        ];

        DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_PRODUCTO.Select_Producto", parameters);
        return dt.Rows.Count > 0;
    }
}
