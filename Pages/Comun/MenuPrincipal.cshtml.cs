using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Data;
using System.Net;

public class MenuPrincipal : PageModel
{

    private readonly OracleDBContext _oracleDbService;

    public MenuPrincipal(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public void OnGet()
    {
    }

    
}