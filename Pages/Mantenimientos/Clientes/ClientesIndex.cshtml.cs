using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using Oracle.ManagedDataAccess.Client;

public class ClientesIndex : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public DataTable ResultTable { get; private set; }

    public ClientesIndex(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public void OnGet()
    {
        string query = "SELECT * FROM CLIENTE";
        ResultTable = _oracleDbService.ExecuteQuery(query);
    }

    public IActionResult OnPostSaveClient(int pID, string pNom, string pApe1, string pApe2, int pTel, string pCorreo, int pIdDire)
    {
        try
        {
            if (ClienteExiste(pID))
            {
                //System.Diagnostics.Debug.WriteLine($"ID_Cliente: {pID}, Nombre: {pNom}, Apellido_1: {pApe1}, Apellido_2: {pApe2}, Telefono: {pTel}, Correo: {pCorreo}, ID_Direccion: {pIdDire}");
                
                string query = "UPDATE CLIENTE SET Nombre = :Nombre, Apellido_1 = :Apellido_1, Apellido_2 = :Apellido_2, Telefono = :Telefono, Correo = :Correo, ID_Direccion = :ID_Direccion WHERE ID_Cliente = :ID_Cliente";
                OracleParameter[] parameters = new OracleParameter[]
                {
                    new OracleParameter("ID_Cliente", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("Apellido_1", OracleDbType.Varchar2, pApe1, ParameterDirection.Input),
                    new OracleParameter("Apellido_2", OracleDbType.Varchar2, pApe2, ParameterDirection.Input),
                    new OracleParameter("Telefono", OracleDbType.Int32, pTel, ParameterDirection.Input),
                    new OracleParameter("Correo", OracleDbType.Varchar2, pCorreo, ParameterDirection.Input),
                    new OracleParameter("ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input)
                };
                
                int rowsAffected = _oracleDbService.ExecuteNonQuery(query, parameters);
                //System.Diagnostics.Debug.WriteLine($"Filas afectadas por la actualización: {rowsAffected}");

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
                // Insertar cliente
                string query = "INSERT INTO CLIENTE (ID_Cliente, Nombre, Apellido_1, Apellido_2, Telefono, Correo, ID_Direccion) VALUES (:ID_Cliente, :Nombre, :Apellido_1, :Apellido_2, :Telefono, :Correo, :ID_Direccion)";
                OracleParameter[] parameters = new OracleParameter[]
                {
                    new OracleParameter("ID_Cliente", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("Apellido_1", OracleDbType.Varchar2, pApe1, ParameterDirection.Input),
                    new OracleParameter("Apellido_2", OracleDbType.Varchar2, pApe2, ParameterDirection.Input),
                    new OracleParameter("Telefono", OracleDbType.Int32, pTel, ParameterDirection.Input),
                    new OracleParameter("Correo", OracleDbType.Varchar2, pCorreo, ParameterDirection.Input),
                    new OracleParameter("ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input)
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

    public IActionResult OnGetEditClient(int id)
    {
        try
        {
            string query = "SELECT * FROM CLIENTE WHERE ID_Cliente = :ID_Cliente";
            OracleParameter[] parameters = new OracleParameter[]
            {
                new OracleParameter("ID_Cliente", id)
            };

            DataTable dt = _oracleDbService.ExecuteQuery(query, parameters);
            if (dt.Rows.Count == 1)
            {
                DataRow row = dt.Rows[0];
                var clientData = new
                {
                    ID_Cliente = row["ID_Cliente"],
                    Nombre = row["Nombre"],
                    Apellido_1 = row["Apellido_1"],
                    Apellido_2 = row["Apellido_2"],
                    Telefono = row["Telefono"],
                    Correo = row["Correo"],
                    ID_Direccion = row["ID_Direccion"]
                };
                return new JsonResult(clientData);
            }
            return new JsonResult(null);
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    public IActionResult OnPostDeleteClient(int id)
    {
        try
        {
            string query = "DELETE FROM CLIENTE WHERE ID_Cliente = :ID_Cliente";
            OracleParameter[] parameters = new OracleParameter[]
            {
                new OracleParameter("ID_Cliente", id)
            };

            _oracleDbService.ExecuteNonQuery(query, parameters);
            return new JsonResult(new { success = true });
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }


    private bool ClienteExiste(int ID_Cliente)
    {
        string query = "SELECT * FROM CLIENTE WHERE ID_Cliente = :ID_Cliente";
        OracleParameter[] parameters = new OracleParameter[]
        {
            new OracleParameter("ID_Cliente", ID_Cliente)
        };

        DataTable dt = _oracleDbService.ExecuteQuery(query, parameters);
        return dt.Rows.Count > 0;
    }
}
