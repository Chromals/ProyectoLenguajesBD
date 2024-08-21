using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Data;

public class CategoriaIndex : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public CategoriaIndex(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public DataTable? ResultTable { get; set; }

    public void OnGet()
    {
        LoadData();
    }

    public JsonResult OnPostSaveCategoria(int pID, string pNom)
    {
        try
        {
            OracleParameter[] parameters;
            string res = "";

            if (CategoriaExiste(pID))
            {
                parameters =
                [
                new OracleParameter("p_ID_Categoria", OracleDbType.Int32, pID, ParameterDirection.Input),
                new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.Varchar2, 4000, null, ParameterDirection.Output)
                ];
                res = _oracleDbService.ExecuteStoredProc("CRUD_CATEGORIA.Update_Categoria", parameters);
            }
            else
            {
                parameters =
                [
                new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.Varchar2, 4000, null, ParameterDirection.Output)
                ];
                res = _oracleDbService.ExecuteStoredProc("CRUD_CATEGORIA.Insert_Categoria", parameters);
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
                    return new JsonResult(new { success = false, message = "No se realizo ninguna accion con el registro." });
            }
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    public JsonResult OnPostDeleteCategoria(int id)
    {
        try
        {
            OracleParameter[] parameters =
            [
                new OracleParameter("p_ID_Categoria", OracleDbType.Int32, id, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.Varchar2, 4000, null, ParameterDirection.Output)
            ];

            string res = _oracleDbService.ExecuteStoredProc("CRUD_CATEGORIA.Delete_Categoria", parameters);

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
                {
                    return new JsonResult(new { success = false, message = "No se eliminó ningún registro." });
                }
            }
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }
    public IActionResult OnGetEditCategoria(int id)
    {
        try
        {
            OracleParameter[] parameters =
            [
            new OracleParameter("p_ID_Categoria", OracleDbType.Int32, id, ParameterDirection.Input),
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
            ];

            DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_CATEGORIA.Select_Categoria", parameters);

            if (dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];
                var categoria = new
                {
                    ID_Categoria = row["ID_Categoria"],
                    Nombre = row["Nombre"]
                };
                return new JsonResult(categoria);
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
        ResultTable = _oracleDbService.ExecuteStoredProcCursor("CRUD_CATEGORIA.Select_All_Categoria", parameters);
    }

    private bool CategoriaExiste(int ID_Categoria)
    {
        OracleParameter[] parameters =
        [
            new OracleParameter("p_ID_Categoria", OracleDbType.Int32, ID_Categoria, ParameterDirection.Input),
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        ];

        DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_CATEGORIA.Select_Categoria", parameters);
        return dt.Rows.Count > 0;
    }
}
