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
            string query = $"SELECT * FROM TRABAJADOR WHERE NOMBRE = :nombre AND ID_TRABAJADOR = :id ";
            var parameters = new OracleParameter[]
            {
                new OracleParameter("nombre", nombre),
                new OracleParameter("id", id)
            };

            ResultTable = _oracleDbService.ExecuteQuery(query, parameters);

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