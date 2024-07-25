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

    public IActionResult OnGetCliente(int id)
    {
        string query = "SELECT * FROM CLIENTE WHERE ID_Cliente = :Id";
        OracleParameter[] parameters = { new OracleParameter(":Id", id) };

        DataTable resultTable = _oracleDbService.ExecuteQuery(query, parameters);
        if (resultTable.Rows.Count == 0)
        {
            return NotFound();
        }

        DataRow row = resultTable.Rows[0];
        return new JsonResult(new
        {
            ID_Cliente = row["ID_Cliente"],
            Nombre = row["Nombre"],
            Apellido_1 = row["Apellido_1"],
            Apellido_2 = row["Apellido_2"],
            Telefono = row["Telefono"],
            Correo = row["Correo"],
            ID_Direccion = row["ID_Direccion"]
        });
    }

    public IActionResult OnPostCliente(int? ID_Cliente, string Nombre, string Apellido_1, string Apellido_2, int Telefono, string Correo, int ID_Direccion)
    {
        string query;
        OracleParameter[] parameters;

        if (ID_Cliente == null)
        {
            query = "INSERT INTO CLIENTE (Nombre, Apellido_1, Apellido_2, Telefono, Correo, ID_Direccion) VALUES (:Nombre, :Apellido_1, :Apellido_2, :Telefono, :Correo, :ID_Direccion)";
            parameters = new OracleParameter[]
            {
                new OracleParameter(":Nombre", Nombre),
                new OracleParameter(":Apellido_1", Apellido_1),
                new OracleParameter(":Apellido_2", Apellido_2),
                new OracleParameter(":Telefono", Telefono),
                new OracleParameter(":Correo", Correo),
                new OracleParameter(":ID_Direccion", ID_Direccion)
            };
        }
        else
        {
            query = "UPDATE CLIENTE SET Nombre = :Nombre, Apellido_1 = :Apellido_1, Apellido_2 = :Apellido_2, Telefono = :Telefono, Correo = :Correo, ID_Direccion = :ID_Direccion WHERE ID_Cliente = :ID_Cliente";
            parameters = new OracleParameter[]
            {
                new OracleParameter(":Nombre", Nombre),
                new OracleParameter(":Apellido_1", Apellido_1),
                new OracleParameter(":Apellido_2", Apellido_2),
                new OracleParameter(":Telefono", Telefono),
                new OracleParameter(":Correo", Correo),
                new OracleParameter(":ID_Direccion", ID_Direccion),
                new OracleParameter(":ID_Cliente", ID_Cliente)
            };
        }

        _oracleDbService.ExecuteNonQuery(query, parameters);
        return RedirectToPage();
    }

    public IActionResult OnPostDelete(int id)
    {
        string query = "DELETE FROM CLIENTE WHERE ID_Cliente = :Id";
        OracleParameter[] parameters = { new OracleParameter(":Id", id) };

        _oracleDbService.ExecuteNonQuery(query, parameters);
        return RedirectToPage();
    }
}
