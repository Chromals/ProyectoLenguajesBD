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
            LoadData();
        }
        catch (Exception ex)
        {
            //System.Diagnostics.Debug.WriteLine($"Error al obtener las direcciones: {ex.Message}");
            ResultTable = null;
        }
    }

    private void LoadData()
    {
        OracleParameter[] parameters =
                    [
                        new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
                    ];

        ResultTable = _oracleDbService.ExecuteStoredProcCursor("CRUD_DIRECCION.Select_All_Direccion", parameters);
        
    }

    public IActionResult OnPostSaveDireccion(int pID, string pProvincia, string pCanton, string pDistrito)
    {
        try
        {
            if (DireccionExiste(pID))
            {
                OracleParameter[] parameters =
                [
                    new OracleParameter("p_ID_Direccion", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("p_Provincia", OracleDbType.Varchar2, pProvincia, ParameterDirection.Input),
                    new OracleParameter("p_Canton", OracleDbType.Varchar2, pCanton, ParameterDirection.Input),
                    new OracleParameter("p_Distrito", OracleDbType.Varchar2, pDistrito, ParameterDirection.Input),
                    new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
                ];

                string res = _oracleDbService.ExecuteStoredProc("CRUD_DIRECCION.Update_Direccion", parameters);

                if (res.StartsWith("Error: "))
                {
                    return new JsonResult(new { success = false, message = res });
                }
                else
                {
                    if (string.IsNullOrWhiteSpace(res))
                    {
                        LoadData();
                        return new JsonResult(new { success = true });

                    }
                    else
                        return new JsonResult(new { success = false, message = "No se actualizo ningún registro." });
                }
            }
            else
            {
                OracleParameter[] parameters =
                [
                    new OracleParameter("p_Provincia", OracleDbType.Varchar2, pProvincia, ParameterDirection.Input),
                    new OracleParameter("p_Canton", OracleDbType.Varchar2, pCanton, ParameterDirection.Input),
                    new OracleParameter("p_Distrito", OracleDbType.Varchar2, pDistrito, ParameterDirection.Input),
                    new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
                ];

                string res = _oracleDbService.ExecuteStoredProc("CRUD_DIRECCION.Insert_Direccion", parameters);
                
                if (res.StartsWith("Error: "))
                {
                    return new JsonResult(new { success = false, message = res });
                }
                else
                {
                    if (string.IsNullOrWhiteSpace(res))
                        return new JsonResult(new { success = true });
                    else
                        return new JsonResult(new { success = false, message = "No se inserto ningún registro." });
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
                new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
            ];

            string res =_oracleDbService.ExecuteStoredProc("CRUD_DIRECCION.Delete_Direccion", parameters);

            if (res.StartsWith("Error: "))
                {
                    return new JsonResult(new { success = false, message = res });
                }
                else
                {
                    if (string.IsNullOrWhiteSpace(res))
                        return new JsonResult(new { success = true });
                    else
                        return new JsonResult(new { success = false, message = "No se elimino ningún registro." });
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
