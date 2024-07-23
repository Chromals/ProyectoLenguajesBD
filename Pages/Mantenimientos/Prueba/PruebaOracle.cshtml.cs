using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using Oracle.ManagedDataAccess.Client;

public class PruebaOracle : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public DataTable ResultTable { get; private set; }

    public PruebaOracle(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public void OnGet()
    {
        string query = "SELECT * FROM HR.EMPLOYEES";
        ResultTable = _oracleDbService.ExecuteQuery(query);
    }
}