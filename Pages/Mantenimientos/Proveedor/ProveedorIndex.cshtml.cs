using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System.Data;

public class ProveedorIndex : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public ProveedorIndex(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public DataTable ResultTable { get; set; }

    public void OnGet()
    {
        LoadData();
    }

    public JsonResult OnPostSaveProvider(int pID, string pNom, string pApe1, string pApe2, int pTel, string pCorreo, int pIdDire)
    {
        try
        {
            OracleParameter[] parameters;
            string procedureName;

            if (ProveedorExiste(pID))
            {
                procedureName = "CRUD_PROVEEDOR.Update_Proveedor";
                parameters =
                [
                    new OracleParameter("p_ID_Proveedor", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_1", OracleDbType.Varchar2, pApe1, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_2", OracleDbType.Varchar2, pApe2, ParameterDirection.Input),
                    new OracleParameter("p_Telefono", OracleDbType.Int32, pTel, ParameterDirection.Input),
                    new OracleParameter("p_Correo", OracleDbType.Varchar2, pCorreo, ParameterDirection.Input),
                    new OracleParameter("p_ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input),
                    new OracleParameter("p_Success", OracleDbType.Int32, ParameterDirection.Output)
                ];
            }
            else
            {
                procedureName = "CRUD_PROVEEDOR.Insert_Proveedor";
                parameters =
                [
                    new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_1", OracleDbType.Varchar2, pApe1, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_2", OracleDbType.Varchar2, pApe2, ParameterDirection.Input),
                    new OracleParameter("p_Telefono", OracleDbType.Int32, pTel, ParameterDirection.Input),
                    new OracleParameter("p_Correo", OracleDbType.Varchar2, pCorreo, ParameterDirection.Input),
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

    public JsonResult OnPostDeleteProvider(int id)
    {
        try
        {
            var parameters = new OracleParameter[]
            {
                new OracleParameter("p_ID_Proveedor", OracleDbType.Int32, id, ParameterDirection.Input),
                new OracleParameter("p_Success", OracleDbType.Int32, ParameterDirection.Output)
            };

            _oracleDbService.ExecuteStoredProc("CRUD_PROVEEDOR.Delete_Proveedor", parameters);

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

    public JsonResult OnGetEditProvider(int id)
    {
        try
        {
            var parameters = new OracleParameter[]
            {
                new OracleParameter("p_ID_Proveedor", OracleDbType.Int32, id, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
            };

            DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_PROVEEDOR.Select_Proveedor", parameters);

            if (dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];
                var proveedor = new
                {
                    ID_Proveedor = row["ID_Proveedor"],
                    Nombre = row["Nombre"],
                    Apellido_1 = row["Apellido_1"],
                    Apellido_2 = row["Apellido_2"],
                    Telefono = row["Telefono"],
                    Correo = row["Correo"],
                    ID_Direccion = row["ID_Direccion"]
                };
                return new JsonResult(new { success = true, data = proveedor });
            }
            return new JsonResult(new { success = false, message = "No se encontró el proveedor." });
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

        ResultTable = _oracleDbService.ExecuteStoredProcCursor("CRUD_PROVEEDOR.Select_All_Proveedor", parameters);
    }

    private bool ProveedorExiste(int ID_Proveedor)
    {
        var parameters = new OracleParameter[]
        {
            new OracleParameter("p_ID_Proveedor", OracleDbType.Int32, ID_Proveedor, ParameterDirection.Input),
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        };

        DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_PROVEEDOR.Select_Proveedor", parameters);
        return dt.Rows.Count > 0;
    }
}
