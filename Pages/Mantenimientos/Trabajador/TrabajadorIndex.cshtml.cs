using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Data;

public class TrabajadorIndex : PageModel
{
    private readonly OracleDBContext _oracleDbService;

    public TrabajadorIndex(OracleDBContext oracleDbService)
    {
        _oracleDbService = oracleDbService;
    }

    public DataTable ResultTable { get; set; }

    public void OnGet()
    {
        LoadData();
    }

    public JsonResult OnPostSaveTrabajador(int pID, string pNom, string pAp1, string pAp2, string pCar, decimal pSal, int pAct, DateTime pFecIni, int pIdSuc, int pIdDire)
    {
        try
        {
            OracleParameter[] parameters;

            if (TrabajadorExiste(pID))
            {
                parameters =
                [
                    new OracleParameter("p_ID_Trabajador", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_1", OracleDbType.Varchar2, pAp1, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_2", OracleDbType.Varchar2, pAp2, ParameterDirection.Input),
                    new OracleParameter("p_Cargo", OracleDbType.Varchar2, pCar, ParameterDirection.Input),
                    new OracleParameter("p_Salario", OracleDbType.Decimal, pSal, ParameterDirection.Input),
                    new OracleParameter("p_Activo", OracleDbType.Int32, pAct, ParameterDirection.Input),
                    new OracleParameter("p_Fecha_Inicio", OracleDbType.Date, pFecIni, ParameterDirection.Input),
                    new OracleParameter("p_ID_Sucursal", OracleDbType.Int32, pIdSuc, ParameterDirection.Input),
                    new OracleParameter("p_ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input),
                    new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
                ];
                _oracleDbService.ExecuteStoredProc("CRUD_TRABAJADOR.Update_Trabajador", parameters);
            }
            else
            {
                parameters =
                [
                    new OracleParameter("p_Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_1", OracleDbType.Varchar2, pAp1, ParameterDirection.Input),
                    new OracleParameter("p_Apellido_2", OracleDbType.Varchar2, pAp2, ParameterDirection.Input),
                    new OracleParameter("p_Cargo", OracleDbType.Varchar2, pCar, ParameterDirection.Input),
                    new OracleParameter("p_Salario", OracleDbType.Decimal, pSal, ParameterDirection.Input),
                    new OracleParameter("p_Activo", OracleDbType.Int32, pAct, ParameterDirection.Input),
                    new OracleParameter("p_Fecha_Inicio", OracleDbType.Date, pFecIni, ParameterDirection.Input),
                    new OracleParameter("p_ID_Sucursal", OracleDbType.Int32, pIdSuc, ParameterDirection.Input),
                    new OracleParameter("p_ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input),
                    new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
                ];
                _oracleDbService.ExecuteStoredProc("CRUD_TRABAJADOR.Insert_Trabajador", parameters);
            }

            int success = Convert.ToInt32(parameters.Last().Value);
            return new JsonResult(new { success = success > 0 });
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    public JsonResult OnPostDeleteTrabajador(int id)
    {
        try
        {
            OracleParameter[] parameters =
            [
                new OracleParameter("p_ID_Trabajador", OracleDbType.Int32, id, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.Varchar2, ParameterDirection.Output)
            ];
            _oracleDbService.ExecuteStoredProc("CRUD_TRABAJADOR.Delete_Trabajador", parameters);

            int success = Convert.ToInt32(parameters.Last().Value);
            return new JsonResult(new { success = success > 0 });
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    public JsonResult OnPostGetTrabajador(int id)
    {
        try
        {
            OracleParameter[] parameters =
            [
                new OracleParameter("p_ID_Trabajador", OracleDbType.Int32, id, ParameterDirection.Input),
                new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
            ];

            DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_TRABAJADOR.Select_Trabajador", parameters);

            if (dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];
                var trabajador = new
                {
                    ID_Trabajador = row["ID_Trabajador"],
                    Nombre = row["Nombre"],
                    Apellido_1 = row["Apellido_1"],
                    Apellido_2 = row["Apellido_2"],
                    Cargo = row["Cargo"],
                    Salario = row["Salario"],
                    Activo = row["Activo"],
                    Fecha_Inicio = row["Fecha_Inicio"],
                    ID_Sucursal = row["ID_Sucursal"],
                    ID_Direccion = row["ID_Direccion"]
                };
                return new JsonResult(new { success = true, data = trabajador });
            }
            else
            {
                return new JsonResult(new { success = false, message = "No se encontró el trabajador." });
            }
        }
        catch (Exception ex)
        {
            return new JsonResult(new { success = false, message = ex.Message });
        }
    }

    private void LoadData()
    {
        OracleParameter[] parameters =
        [
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        ];
        ResultTable = _oracleDbService.ExecuteStoredProcCursor("CRUD_TRABAJADOR.Select_All_Trabajador", parameters);
    }

    private bool TrabajadorExiste(int ID_Trabajador)
    {
        OracleParameter[] parameters =
        [
            new OracleParameter("p_ID_Trabajador", OracleDbType.Int32, ID_Trabajador, ParameterDirection.Input),
            new OracleParameter("p_Result", OracleDbType.RefCursor, ParameterDirection.Output)
        ];

        DataTable dt = _oracleDbService.ExecuteStoredProcCursor("CRUD_TRABAJADOR.Select_Trabajador", parameters);
        return dt.Rows.Count > 0;
    }
}
