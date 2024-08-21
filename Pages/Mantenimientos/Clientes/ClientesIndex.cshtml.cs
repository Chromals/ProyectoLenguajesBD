using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using Oracle.ManagedDataAccess.Client;

public class ClientesIndex : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public DataTable? ResultTable { get; private set; }

    public ClientesIndex(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public void OnGet()
    {
        try
        {
            LoadData();
        }
        catch (Exception)
        {
            //System.Diagnostics.Debug.WriteLine($"Error al obtener los clientes: {ex.Message}");
            ResultTable = new DataTable();
        }
    }

    private void LoadData()
    {
        OracleParameter[] parameters =
                    [
                        new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
                    ];

        ResultTable = _oracleDbService.ExecuteStoredProcCursor("CRUD_CLIENTE.Select_All_Cliente", parameters);
    }

    public IActionResult OnPostSaveClient(int pID, string pNom, string pApe1, string pApe2, int pTel, string pCorreo, int pIdDire)
    {
        try
        {
            //System.Diagnostics.Debug.WriteLine($"ID_Cliente: {pID}, Nombre: {pNom}, Apellido_1: {pApe1}, Apellido_2: {pApe2}, Telefono: {pTel}, Correo: {pCorreo}, ID_Direccion: {pIdDire}");

            if (ClienteExiste(pID))
            {

                OracleParameter[] parameters =
                [
                    new OracleParameter("p_ID_Cliente", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_1", OracleDbType.Varchar2, pApe1, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_2", OracleDbType.Varchar2, pApe2, ParameterDirection.Input),
                    new OracleParameter("p_Telefono", OracleDbType.Int32, pTel, ParameterDirection.Input),
                    new OracleParameter("p_Correo", OracleDbType.Varchar2, pCorreo, ParameterDirection.Input),
                    new OracleParameter("p_ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input),
                    new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
                ];

                string res = _oracleDbService.ExecuteStoredProc("CRUD_CLIENTE.Update_Cliente", parameters);

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
                // Insertar cliente
                OracleParameter[] parameters =
                [
                    new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_1", OracleDbType.Varchar2, pApe1, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_2", OracleDbType.Varchar2, pApe2, ParameterDirection.Input),
                    new OracleParameter("p_Telefono", OracleDbType.Int32, pTel, ParameterDirection.Input),
                    new OracleParameter("p_Correo", OracleDbType.Varchar2, pCorreo, ParameterDirection.Input),
                    new OracleParameter("p_ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input),
                    new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
                ];

                string res = _oracleDbService.ExecuteStoredProc("CRUD_CLIENTE.Insert_Cliente", parameters);

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
                        return new JsonResult(new { success = false, message = "No se inserto ningún registro." });
                }
            }

            //return new JsonResult(new { success = true });
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
            OracleParameter[] parameters =
            [
                new OracleParameter("p_ID_Cliente", OracleDbType.Int32, id, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
            ];

            DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_CLIENTE.Select_Cliente", parameters);

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
            //System.Diagnostics.Debug.WriteLine($"ID_Cliente: {id}");

            OracleParameter[] parameters =
                        [
                            new OracleParameter("p_ID_Cliente", OracleDbType.Int32, id, ParameterDirection.Input),
                            new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
                        ];

            string res = _oracleDbService.ExecuteStoredProc("CRUD_CLIENTE.Delete_Cliente", parameters);

            if (res.StartsWith("Error: "))
                return new JsonResult(new { success = false, message = res });
            else
            {
                if (string.IsNullOrWhiteSpace(res))
                {
                    LoadData();
                    return new JsonResult(new { success = true });
                }

                else
                    return new JsonResult(new { success = false, message = "No se eliminó ningún registro." });
            }
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }


    private bool ClienteExiste(int ID_Cliente)
    {
        OracleParameter[] parameters =
        [
            new OracleParameter("p_ID_Cliente", OracleDbType.Int32, ID_Cliente, ParameterDirection.Input),
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        ];

        DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_CLIENTE.Select_Cliente", parameters);

        return dt.Rows.Count > 0;
    }
}
