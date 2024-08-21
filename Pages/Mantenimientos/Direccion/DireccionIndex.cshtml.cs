using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using Oracle.ManagedDataAccess.Client;

public class DireccionIndex : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public DataTable ResultTable { get; private set; }

    public DireccionIndex(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public void OnGet()
    {
        try
        {
            OracleParameter[] parameters =
            [
                new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
            ];

            ResultTable = _oracleDbService.ExecuteStoredProcCursor("CRUD_DIRECCION.Select_All_Direccion", parameters);
        }
        catch (Exception ex)
        {
            //System.Diagnostics.Debug.WriteLine($"Error al obtener las direcciones: {ex.Message}");
            ResultTable = null;
        }
    }

    public IActionResult OnPostSaveDireccion(int pID, string pProvincia, string pCanton, string pDistrito)
    {
        try
        {
            if (DireccionExiste(pID))
            {
                OracleParameter[] parameters = new OracleParameter[]
                {
                    new OracleParameter("p_ID_Direccion", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("p_Provincia", OracleDbType.Varchar2, pProvincia, ParameterDirection.Input),
                    new OracleParameter("p_Canton", OracleDbType.Varchar2, pCanton, ParameterDirection.Input),
                    new OracleParameter("p_Distrito", OracleDbType.Varchar2, pDistrito, ParameterDirection.Input),
                    new OracleParameter("p_Success", OracleDbType.Int32, ParameterDirection.Output)
                };

                _oracleDbService.ExecuteStoredProc("CRUD_DIRECCION.Update_Direccion", parameters);

                int success = Convert.ToInt32(parameters[4].Value);
                if (success > 0)
                {
                    return new JsonResult(new { success = true });
                }
                else
                {
                    return new JsonResult(new { success = false, message = "No se actualizó ningún registro." });
                }
            }
            else 
            {
                OracleParameter[] parameters = new OracleParameter[]
                {
                    new OracleParameter("p_Provincia", OracleDbType.Varchar2, pProvincia, ParameterDirection.Input),
                    new OracleParameter("p_Canton", OracleDbType.Varchar2, pCanton, ParameterDirection.Input),
                    new OracleParameter("p_Distrito", OracleDbType.Varchar2, pDistrito, ParameterDirection.Input),
                    new OracleParameter("p_Success", OracleDbType.Int32, ParameterDirection.Output)
                };

                _oracleDbService.ExecuteStoredProc("CRUD_DIRECCION.Insert_Direccion", parameters);

                int success = Convert.ToInt32(parameters[3].Value);
                if (success > 0)
                {
                    return new JsonResult(new { success = true });
                }
                else
                {
                    return new JsonResult(new { success = false, message = "No se insertó ningún registro." });
                }
            }
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    public IActionResult OnGetEditDireccion(int id)
    {
        try
        {
            OracleParameter[] parameters =
            [
                new OracleParameter("p_ID_Direccion", id),
                new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
            ];

            DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_DIRECCION.Select_Direccion", parameters);

            if (dt.Rows.Count == 1)
            {
                DataRow row = dt.Rows[0];
                var direccionData = new
                {
                    ID_Direccion = row["ID_Direccion"],
                    Provincia = row["Provincia"],
                    Canton = row["Canton"],
                    Distrito = row["Distrito"]
                };
                return new JsonResult(direccionData);
            }
            return new JsonResult(null);
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    public IActionResult OnPostDeleteDireccion(int id)
    {
        try
        {
            OracleParameter[] parameters =
            [
                new OracleParameter("p_ID_Direccion", id),
                new OracleParameter("p_Success", OracleDbType.Int32, ParameterDirection.Output)
            ];

            _oracleDbService.ExecuteStoredProc("CRUD_DIRECCION.Delete_Direccion", parameters);

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

    private bool DireccionExiste(int ID_Direccion)
    {
        try
        {
            OracleParameter[] parameters =
            [
                new OracleParameter("p_ID_Direccion", ID_Direccion),
                new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
            ];

            DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_DIRECCION.Select_Direccion", parameters);
            return dt.Rows.Count > 0;
        }
        catch
        {
            return false;
        }
    }
}
