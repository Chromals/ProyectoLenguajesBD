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
            string query;
            OracleParameter[] parameters;

            if (TrabajadorExiste(pID))
            {
                query = "UPDATE Trabajador SET Nombre = :Nombre, Apellido_1 = :Apellido_1, Apellido_2 = :Apellido_2, Cargo = :Cargo, Salario = :Salario, Activo = :Activo, Fecha_Inicio = :Fecha_Inicio, ID_Sucursal = :ID_Sucursal, ID_Direccion = :ID_Direccion WHERE ID_Trabajador = :ID_Trabajador";
                parameters = new OracleParameter[]
                {
                    new OracleParameter("ID_Trabajador", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("Apellido_1", OracleDbType.Varchar2, pAp1, ParameterDirection.Input),
                    new OracleParameter("Apellido_2", OracleDbType.Varchar2, pAp2, ParameterDirection.Input),
                    new OracleParameter("Cargo", OracleDbType.Varchar2, pCar, ParameterDirection.Input),
                    new OracleParameter("Salario", OracleDbType.Decimal, pSal, ParameterDirection.Input),
                    new OracleParameter("Activo", OracleDbType.Int32, pAct, ParameterDirection.Input),
                    new OracleParameter("Fecha_Inicio", OracleDbType.Date, pFecIni, ParameterDirection.Input),
                    new OracleParameter("ID_Sucursal", OracleDbType.Int32, pIdSuc, ParameterDirection.Input),
                    new OracleParameter("ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input)
                };
            }
            else
            {
                query = "INSERT INTO Trabajador (ID_Trabajador, Nombre, Apellido_1, Apellido_2, Cargo, Salario, Activo, Fecha_Inicio, ID_Sucursal, ID_Direccion) VALUES (:ID_Trabajador, :Nombre, :Apellido_1, :Apellido_2, :Cargo, :Salario, :Activo, :Fecha_Inicio, :ID_Sucursal, :ID_Direccion)";
                parameters = new OracleParameter[]
                {
                    new OracleParameter("ID_Trabajador", OracleDbType.Int32, pID, ParameterDirection.Input),
                    new OracleParameter("Nombre", OracleDbType.Varchar2, pNom, ParameterDirection.Input),
                    new OracleParameter("Apellido_1", OracleDbType.Varchar2, pAp1, ParameterDirection.Input),
                    new OracleParameter("Apellido_2", OracleDbType.Varchar2, pAp2, ParameterDirection.Input),
                    new OracleParameter("Cargo", OracleDbType.Varchar2, pCar, ParameterDirection.Input),
                    new OracleParameter("Salario", OracleDbType.Decimal, pSal, ParameterDirection.Input),
                    new OracleParameter("Activo", OracleDbType.Int32, pAct, ParameterDirection.Input),
                    new OracleParameter("Fecha_Inicio", OracleDbType.Date, pFecIni, ParameterDirection.Input),
                    new OracleParameter("ID_Sucursal", OracleDbType.Int32, pIdSuc, ParameterDirection.Input),
                    new OracleParameter("ID_Direccion", OracleDbType.Int32, pIdDire, ParameterDirection.Input)
                };
            }

            int rowsAffected = _oracleDbService.ExecuteNonQuery(query, parameters);

            if (rowsAffected > 0)
            {
                return new JsonResult(new { success = true });
            }
            else
            {
                return new JsonResult(new { success = false, message = "No se actualizó ningún registro." });
            }
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
            string query = "DELETE FROM Trabajador WHERE ID_Trabajador = :ID_Trabajador";
            var parameters = new OracleParameter[]
            {
                new OracleParameter("ID_Trabajador", OracleDbType.Int32, id, ParameterDirection.Input)
            };

            int rowsAffected = _oracleDbService.ExecuteNonQuery(query, parameters);

            if (rowsAffected > 0)
            {
                return new JsonResult(new { success = true });
            }
            else
            {
                return new JsonResult(new { success = false, message = "No se eliminó ningún registro." });
            }
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
            string query = "SELECT * FROM Trabajador WHERE ID_Trabajador = :ID_Trabajador";
            var parameters = new OracleParameter[]
            {
                new OracleParameter("ID_Trabajador", OracleDbType.Int32, id, ParameterDirection.Input)
            };

            DataTable dt = _oracleDbService.ExecuteQuery(query, parameters);

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
        string query = "SELECT * FROM Trabajador";
        ResultTable = _oracleDbService.ExecuteQuery(query);
    }

    private bool TrabajadorExiste(int ID_Trabajador)
    {
        string query = "SELECT 1 FROM Trabajador WHERE ID_Trabajador = :ID_Trabajador";
        var parameters = new OracleParameter[]
        {
            new OracleParameter("ID_Trabajador", OracleDbType.Int32, ID_Trabajador, ParameterDirection.Input)
        };

        DataTable dt = _oracleDbService.ExecuteQuery(query, parameters);
        return dt.Rows.Count > 0;
    }
}
