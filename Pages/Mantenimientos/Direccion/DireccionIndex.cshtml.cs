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
        string query = "SELECT * FROM DIRECCION";
        ResultTable = _oracleDbService.ExecuteQuery(query);
    }

    public IActionResult OnPostSaveDireccion(int pID, string pProvincia, string pCanton, string pDistrito)
    {
        try
        {
            if (DireccionExiste(pID))
            {
                string query = "UPDATE DIRECCION SET Provincia = :Provincia, Canton = :Canton, Distrito = :Distrito WHERE ID_Direccion = :ID_Direccion";
                OracleParameter[] parameters = new OracleParameter[]
                {
                    new OracleParameter("ID_Direccion", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("Provincia", OracleDbType.Varchar2, pProvincia, ParameterDirection.Input),
                    new OracleParameter("Canton", OracleDbType.Varchar2, pCanton, ParameterDirection.Input),
                    new OracleParameter("Distrito", OracleDbType.Varchar2, pDistrito, ParameterDirection.Input)
                };
                
                int rowsAffected = _oracleDbService.ExecuteNonQuery(query, parameters);

                if (rowsAffected > 0)
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
                string query = "INSERT INTO DIRECCION (ID_Direccion, Provincia, Canton, Distrito) VALUES (:ID_Direccion, :Provincia, :Canton, :Distrito)";
                OracleParameter[] parameters = new OracleParameter[]
                {
                    new OracleParameter("ID_Direccion", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("Provincia", OracleDbType.Varchar2, pProvincia, ParameterDirection.Input),
                    new OracleParameter("Canton", OracleDbType.Varchar2, pCanton, ParameterDirection.Input),
                    new OracleParameter("Distrito", OracleDbType.Varchar2, pDistrito, ParameterDirection.Input)
                };
                _oracleDbService.ExecuteNonQuery(query, parameters);
            }

            return new JsonResult(new { success = true });
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
            string query = "SELECT * FROM DIRECCION WHERE ID_Direccion = :ID_Direccion";
            OracleParameter[] parameters = new OracleParameter[]
            {
                new OracleParameter("ID_Direccion", id)
            };

            DataTable dt = _oracleDbService.ExecuteQuery(query, parameters);
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
            string query = "DELETE FROM DIRECCION WHERE ID_Direccion = :ID_Direccion";
            OracleParameter[] parameters = new OracleParameter[]
            {
                new OracleParameter("ID_Direccion", id)
            };

            _oracleDbService.ExecuteNonQuery(query, parameters);
            return new JsonResult(new { success = true });
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    private bool DireccionExiste(int ID_Direccion)
    {
        string query = "SELECT * FROM DIRECCION WHERE ID_Direccion = :ID_Direccion";
        OracleParameter[] parameters = new OracleParameter[]
        {
            new OracleParameter("ID_Direccion", ID_Direccion)
        };

        DataTable dt = _oracleDbService.ExecuteQuery(query, parameters);
        return dt.Rows.Count > 0;
    }
}
