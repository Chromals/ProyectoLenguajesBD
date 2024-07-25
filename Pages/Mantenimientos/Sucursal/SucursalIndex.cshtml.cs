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

    public IActionResult OnGetEditSucursal(int id)
    {
        var query = "SELECT * FROM Sucursal WHERE ID_Sucursal = :ID_Sucursal";
        var parameters = new OracleParameter[]
        {
            new OracleParameter("ID_Sucursal", OracleDbType.Int32, id, ParameterDirection.Input)
        };

        DataTable dt = _oracleDbService.ExecuteQuery(query, parameters);
        if (dt.Rows.Count > 0)
        {
            var row = dt.Rows[0];
            return new JsonResult(new
            {
                iD_Sucursal = row["ID_Sucursal"],
                nombre = row["Nombre"],
                iD_Direccion = row["ID_Direccion"]
            });
        }
        return new JsonResult(null);
    }

    public IActionResult OnPostSaveSucursal(int pID, string pNom, int pIdDire)
    {
        try
        {
            string query;
            OracleParameter[] parameters;

            if (SucursalExiste(pID))
            {
                query = "UPDATE Sucursal SET Nombre = :Nombre, ID_Direccion = :ID_Direccion WHERE ID_Sucursal = :ID_Sucursal";
                parameters = new OracleParameter[]
                {
                    new OracleParameter("ID_Sucursal", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input)
                };
            }
            else
            {
                query = "INSERT INTO Sucursal (Nombre, ID_Direccion) VALUES (:Nombre, :ID_Direccion)";
                parameters = new OracleParameter[]
                {
                    new OracleParameter("Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input)
                };
            }

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
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    public IActionResult OnPostDeleteSucursal(int id)
    {
        try
        {
            string query = "DELETE FROM Sucursal WHERE ID_Sucursal = :ID_Sucursal";
            var parameters = new OracleParameter[]
            {
                new OracleParameter("ID_Sucursal", OracleDbType.Int32, id, ParameterDirection.Input)
            };

            int rowsAffected = _oracleDbService.ExecuteNonQuery(query, parameters);

            if (rowsAffected > 0)
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
        string query = "SELECT * FROM Sucursal";
        ResultTable = _oracleDbService.ExecuteQuery(query);
    }

    private bool SucursalExiste(int ID_Sucursal)
    {
        string query = "SELECT 1 FROM Sucursal WHERE ID_Sucursal = :ID_Sucursal";
        var parameters = new OracleParameter[]
        {
            new OracleParameter("ID_Sucursal", OracleDbType.Int32, ID_Sucursal, ParameterDirection.Input)
        };

        DataTable dt = _oracleDbService.ExecuteQuery(query, parameters);
        return dt.Rows.Count > 0;
    }
}
