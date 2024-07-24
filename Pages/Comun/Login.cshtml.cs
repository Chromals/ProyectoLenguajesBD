using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Data;

public class Login : PageModel
{

    private readonly OracleDBContext _oracleDbService;

    public Login(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    [BindProperty]
    public string usuario { get; set; }
    [BindProperty]
    public string contrasena { get; set; }
    public string Result { get; set; }
    public DataTable ResultTable { get; private set; }
    
    public void OnGet()
    {
    }

    public void OnPostFormLogin()
    {
        try
        {
            string query = $"SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID = :usuario ";//AND PASSWORD = :contrasena
            var parameters = new OracleParameter[]
            {
                new OracleParameter("usuario", usuario),
                //new OracleParameter("contrasena", contrasena)
            };

            ResultTable = _oracleDbService.ExecuteQuery(query, parameters);

            if (ResultTable.Rows.Count > 0)
            {
                Result = "Login successful!";
            }
            else
            {
                Result = "Login failed. Invalid username or password.";
            }

            
        }
        catch (Exception ex)
        {
            Result = $"Error: {ex.Message}";
        }
    }
}
