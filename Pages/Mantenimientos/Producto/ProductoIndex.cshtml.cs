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

    public JsonResult OnPostSaveProducto(int pID, string pNom, string pAp1, string pAp2, string pCar, decimal pSal, int pAct, DateTime pFecIni, int pIdSuc, int pIdDire)
    {
        try
        {
            OracleParameter[] parameters;
            string res = "";
            if (ProductoExiste(pID))
            {
                parameters =
                [
                    new OracleParameter("p_ID_Producto", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_1", OracleDbType.Varchar2, pAp1, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_2", OracleDbType.Varchar2, pAp2, ParameterDirection.Input),
                    new OracleParameter("p_Cargo", OracleDbType.Varchar2, pCar, ParameterDirection.Input),
                    new OracleParameter("p_Salario", OracleDbType.Decimal, pSal, ParameterDirection.Input),
                    new OracleParameter("p_Activo", OracleDbType.Int32, pAct, ParameterDirection.Input),
                    new OracleParameter("p_Fecha_Inicio", OracleDbType.Date, pFecIni, ParameterDirection.Input),
                    new OracleParameter("p_ID_Sucursal", OracleDbType.Int32, pIdSuc, ParameterDirection.Input),
                    new OracleParameter("p_ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input),
                    new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
                ];
                res = _oracleDbService.ExecuteStoredProc("CRUD_Producto.Update_Producto", parameters);
            }
            else
            {
                parameters =
                [
                    new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_1", OracleDbType.Varchar2, pAp1, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_2", OracleDbType.Varchar2, pAp2, ParameterDirection.Input),
                    new OracleParameter("p_Cargo", OracleDbType.Varchar2, pCar, ParameterDirection.Input),
                    new OracleParameter("p_Salario", OracleDbType.Decimal, pSal, ParameterDirection.Input),
                    new OracleParameter("p_Activo", OracleDbType.Int32, pAct, ParameterDirection.Input),
                    new OracleParameter("p_Fecha_Inicio", OracleDbType.Date, pFecIni, ParameterDirection.Input),
                    new OracleParameter("p_ID_Sucursal", OracleDbType.Int32, pIdSuc, ParameterDirection.Input),
                    new OracleParameter("p_ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input),
                    new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
                ];
                res = _oracleDbService.ExecuteStoredProc("CRUD_Producto.Insert_Producto", parameters);
            }

            if (res.StartsWith("Error: "))
            {
                return new JsonResult(new { success = false, message = res });
            }
            else
            {
                if (string.IsNullOrWhiteSpace(res))
                    return new JsonResult(new { success = true });
                else
                    return new JsonResult(new { success = false, message = "No se realizo ninguna accion con el registro." });
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
                new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
            ];
            string res = _oracleDbService.ExecuteStoredProc("CRUD_Producto.Delete_Producto", parameters);

            if (res.StartsWith("Error: "))
            {
                return new JsonResult(new { success = false, message = res });
            }
            else
            {
                if (string.IsNullOrWhiteSpace(res)){
                    LoadData();
                    return new JsonResult(new { success = true });
                }
                    
                else
                    return new JsonResult(new { success = false, message = "No se elimino ningún registro." });
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

            DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_Producto.Select_Producto", parameters);

            if (dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];
                var Producto = new
                {
                    ID_Producto = row["ID_Producto"],
                    Nombre = row["Nombre"],
                    Apellido_1 = row["Apellido_1"],
                    Apellido_2 = row["Apellido_2"],
                    Cargo = row["Cargo"],
                    Salario = row["Salario"],
                    Activo = row["Activo"],
                    Fecha_Inicio = row["Fecha_Inicio"],
                    ID_Sucursal = row["ID_Sucursal"],
                    ID_Direccion = row["ID_Direccion"]
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
        ResultTable = _oracleDbService.ExecuteStoredProcCursor("CRUD_Producto.Select_All_Producto", parameters);
    }

    private bool ProductoExiste(int ID_Producto)
    {
        OracleParameter[] parameters =
        [
            new OracleParameter("p_ID_Producto", OracleDbType.Int32, ID_Producto, ParameterDirection.Input),
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        ];

        DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_Producto.Select_Producto", parameters);
        return dt.Rows.Count > 0;
    }
}
