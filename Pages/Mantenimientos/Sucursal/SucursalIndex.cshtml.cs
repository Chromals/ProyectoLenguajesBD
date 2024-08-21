using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System.Data;

public class SucursalIndex : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public SucursalIndex(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public DataTable ResultTable { get; set; }

    public void OnGet()
    {
        LoadData();
    }

    public JsonResult OnGetEditSucursal(int id)
    {
        try
        {
            var parameters = new OracleParameter[]
            {
                new OracleParameter("p_ID_Sucursal", OracleDbType.Int32, id, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
            };

            DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_SUCURSAL.Select_Sucursal", parameters);

            if (dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];
                var sucursal = new
                {
                    ID_Sucursal = row["ID_Sucursal"],
                    Nombre = row["Nombre"],
                    ID_Direccion = row["ID_Direccion"]
                };
                return new JsonResult(new { success = true, data = sucursal });
            }
            return new JsonResult(new { success = false, message = "No se encontró la sucursal." });
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    public JsonResult OnPostSaveSucursal(int pID, string pNom, int pIdDire)
    {
        try
        {
            OracleParameter[] parameters;
            string procedureName;

            if (SucursalExiste(pID))
            {
                procedureName = "CRUD_SUCURSAL.Update_Sucursal";
                parameters =
                [
                    new OracleParameter("p_ID_Sucursal", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("p_ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input),
                    new OracleParameter("p_Success", OracleDbType.Int32, ParameterDirection.Output)
                ];
            }
            else
            {
                procedureName = "CRUD_SUCURSAL.Insert_Sucursal";
                parameters =
                [
                    new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("p_ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input),
                    new OracleParameter("p_Success", OracleDbType.Int32, ParameterDirection.Output)
                ];
            }

            _oracleDbService.ExecuteStoredProc(procedureName, parameters);

            int success = Convert.ToInt32(parameters[parameters.Length - 1].Value);
            if (success > 0)
            {
                return new JsonResult(new { success = true });
            }
            else
            {
                return new JsonResult(new { success = false, message = "No se actualizó ningún registro." });
            }
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    public JsonResult OnPostDeleteSucursal(int id)
    {
        try
        {
            var parameters = new OracleParameter[]
            {
                new OracleParameter("p_ID_Sucursal", OracleDbType.Int32, id, ParameterDirection.Input),
                new OracleParameter("p_Success", OracleDbType.Int32, ParameterDirection.Output)
            };

            _oracleDbService.ExecuteStoredProc("CRUD_SUCURSAL.Delete_Sucursal", parameters);

            int success = Convert.ToInt32(parameters[1].Value);
            if (success > 0)
            {
                return new JsonResult(new { success = true });
            }
            else
            {
                return new JsonResult(new { success = false, message = "No se eliminó ningún registro." });
            }
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    private void LoadData()
    {
        var parameters = new OracleParameter[]
        {
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        };

        ResultTable = _oracleDbService.ExecuteStoredProcCursor("CRUD_SUCURSAL.Select_All_Sucursal", parameters);
    }

    private bool SucursalExiste(int ID_Sucursal)
    {
        var parameters = new OracleParameter[]
        {
            new OracleParameter("p_ID_Sucursal", OracleDbType.Int32, ID_Sucursal, ParameterDirection.Input),
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        };

        DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_SUCURSAL.Select_Sucursal", parameters);
        return dt.Rows.Count > 0;
    }
}
