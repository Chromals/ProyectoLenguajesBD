using System;
using System.Data;
using Microsoft.Extensions.Configuration;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;

public class OracleDBContext
{
    private readonly string _connectionString;

    public OracleDBContext(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("OracleConn") ?? "User Id=HR;Password=123;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.100.92)(PORT=1521))(CONNECT_DATA=(SID=ORCL)))";
    }

    public DataTable ExecuteStoredProcCursor(string storedProcName, OracleParameter[]? parameters = null)
    {
        using (OracleConnection connection = new OracleConnection(_connectionString))
        {
            using (OracleCommand command = new OracleCommand(storedProcName, connection))
            {
                command.CommandType = CommandType.StoredProcedure;

                if (parameters != null)
                {
                    command.Parameters.AddRange(parameters);
                }

                using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                {
                    DataTable resultTable = new DataTable();
                    adapter.Fill(resultTable);
                    return resultTable;
                }
            }
        }
    }

    public string ExecuteStoredProc(string storedProcName, OracleParameter[]? parameters = null)
    {
        using (var connection = new OracleConnection(_connectionString))
        {
            connection.Open();
            //System.Diagnostics.Debug.WriteLine($"Conexión abierta: {connection.State == ConnectionState.Open}");

            using (var command = new OracleCommand(storedProcName, connection))
            {
                command.CommandType = CommandType.StoredProcedure;

                if (parameters != null)
                {
                    command.Parameters.AddRange(parameters);
                }

                int rowsAffected = command.ExecuteNonQuery();


                var resultParam = parameters?.FirstOrDefault(p => p.Direction == ParameterDirection.Output);
                if (resultParam != null)
                {
                    return resultParam.Value.ToString() ?? rowsAffected.ToString();
                }

                return rowsAffected.ToString();

            }
        }

    }
}
