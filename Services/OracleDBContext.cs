using System;
using System.Data;
using Microsoft.Extensions.Configuration;
using Oracle.ManagedDataAccess.Client;

public class OracleDBContext
{
    private readonly string _connectionString;

    public OracleDBContext(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("OracleConn") ?? "User Id=HR;Password=123;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.100.92)(PORT=1521))(CONNECT_DATA=(SID=ORCL)))";
    }

    public DataTable ExecuteQuery(string query, OracleParameter[] parameters = null)
    {
        using (OracleConnection connection = new OracleConnection(_connectionString))
        {
            using (OracleCommand command = new OracleCommand(query, connection))
            {
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

    public int ExecuteNonQuery(string query, OracleParameter[] parameters = null)
    {
        using (OracleConnection connection = new OracleConnection(_connectionString))
        {
            using (OracleCommand command = new OracleCommand(query, connection))
            {
                if (parameters != null)
                {
                    command.Parameters.AddRange(parameters);
                }

                connection.Open();
                return command.ExecuteNonQuery();
            }
        }
    }
}
