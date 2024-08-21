using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System.Data;

public class DevolucionIndex : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public DevolucionIndex(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public DataTable? ResultTable { get; set; }

    public void OnGet()
    {
        LoadData();
    }

    private void LoadData()
    {
        var parameters = new OracleParameter[]
        {
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        };

        ResultTable = _oracleDbService.ExecuteStoredProcCursor("PKG_CONSULTAS.Listar_Devoluciones", parameters);
    }
}
