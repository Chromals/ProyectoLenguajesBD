using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Data;
using System.Net;

public class IniciarSesion : PageModel
{

    private readonly OracleDBContext _oracleDbService;

    public IniciarSesion(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    [BindProperty]
    public string nombre { get; set; }
    [BindProperty]
    public string id { get; set; }
    public string Result { get; set; }
    public DataTable ResultTable { get; private set; }
    
    public void OnGet()
    {
    }

    public async Task<IActionResult> OnPostFormLogin()
    {
         try
        {
            var parameters = new OracleParameter[]
            {
                new OracleParameter("p_Nombre", OracleDbType.Varchar2, nombre, ParameterDirection.Input),
                new OracleParameter("p_ID_Trabajador", OracleDbType.Int32, id, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
            };

            // Llama al procedimiento almacenado para verificar el inicio de sesión
            ResultTable = _oracleDbService.ExecuteStoredProcCursor("CRUD_TRABAJADOR.Select_Trabajador_Login", parameters);

            if (ResultTable.Rows.Count > 0)
            {
                Result = "Login successful!";
                return Redirect("/Comun/MenuPrincipal");
            }
            else
            {
                Result = "Login failed. Invalid username or password.";
                return Page();
            }
        }
        catch (Exception ex)
        {
            Result = $"Error: {ex.Message}";
            return Page();
        }
    
    }
}