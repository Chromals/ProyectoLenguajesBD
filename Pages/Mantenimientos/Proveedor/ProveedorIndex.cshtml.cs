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

    public IActionResult OnGetEditProvider(int id)
    {
        var query = "SELECT * FROM Proveedor WHERE ID_Proveedor = :ID_Proveedor";
        var parameters = new OracleParameter[]
        {
            new OracleParameter("ID_Proveedor", OracleDbType.Int32, id, ParameterDirection.Input)
        };

        DataTable dt = _oracleDbService.ExecuteQuery(query, parameters);
        if (dt.Rows.Count > 0)
        {
            var row = dt.Rows[0];
            return new JsonResult(new
            {
                iD_Proveedor = row["ID_Proveedor"],
                nombre = row["Nombre"],
                apellido_1 = row["Apellido_1"],
                apellido_2 = row["Apellido_2"],
                telefono = row["Telefono"],
                correo = row["Correo"],
                iD_Direccion = row["ID_Direccion"]
            });
        }
        return new JsonResult(null);
    }

    public IActionResult OnPostSaveProvider(int pID, string pNom, string pApe1, string pApe2, int pTel, string pCorreo, int pIdDire)
    {
        try
        {
            string query;
            OracleParameter[] parameters;

            if (ProveedorExiste(pID))
            {
                query = "UPDATE Proveedor SET Nombre = :Nombre, Apellido_1 = :Apellido_1, Apellido_2 = :Apellido_2, Telefono = :Telefono, Correo = :Correo, ID_Direccion = :ID_Direccion WHERE ID_Proveedor = :ID_Proveedor";
                parameters = new OracleParameter[]
                {
                    new OracleParameter("ID_Proveedor", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("Apellido_1", OracleDbType.Varchar2, pApe1, ParameterDirection.Input),
                    new OracleParameter("Apellido_2", OracleDbType.Varchar2, pApe2, ParameterDirection.Input),
                    new OracleParameter("Telefono", OracleDbType.Int32, pTel, ParameterDirection.Input),
                    new OracleParameter("Correo", OracleDbType.Varchar2, pCorreo, ParameterDirection.Input),
                    new OracleParameter("ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input)
                };
            }
            else
            {
                query = "INSERT INTO Proveedor (ID_Proveedor, Nombre, Apellido_1, Apellido_2, Telefono, Correo, ID_Direccion) VALUES (:ID_Proveedor, :Nombre, :Apellido_1, :Apellido_2, :Telefono, :Correo, :ID_Direccion)";
                parameters = new OracleParameter[]
                {
                    new OracleParameter("ID_Proveedor", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("Apellido_1", OracleDbType.Varchar2, pApe1, ParameterDirection.Input),
                    new OracleParameter("Apellido_2", OracleDbType.Varchar2, pApe2, ParameterDirection.Input),
                    new OracleParameter("Telefono", OracleDbType.Int32, pTel, ParameterDirection.Input),
                    new OracleParameter("Correo", OracleDbType.Varchar2, pCorreo, ParameterDirection.Input),
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

    public IActionResult OnPostDeleteProvider(int id)
    {
        try
        {
            string query = "DELETE FROM Proveedor WHERE ID_Proveedor = :ID_Proveedor";
            var parameters = new OracleParameter[]
            {
                new OracleParameter("ID_Proveedor", OracleDbType.Int32, id, ParameterDirection.Input)
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
        string query = "SELECT * FROM Proveedor";
        ResultTable = _oracleDbService.ExecuteQuery(query);
    }

    private bool ProveedorExiste(int ID_Proveedor)
    {
        string query = "SELECT 1 FROM Proveedor WHERE ID_Proveedor = :ID_Proveedor";
        var parameters = new OracleParameter[]
        {
            new OracleParameter("ID_Proveedor", OracleDbType.Int32, ID_Proveedor, ParameterDirection.Input)
        };

        DataTable dt = _oracleDbService.ExecuteQuery(query, parameters);
        return dt.Rows.Count > 0;
    }
}
