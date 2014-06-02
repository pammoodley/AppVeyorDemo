#Create your SQL connection string, and then a connection
$ServerConnectionString = "Data Source=(local)\SQL2012SP1;Initial Catalog=master;User Id=sa;PWD=Password12!"
$ServerConnection = new-object system.data.SqlClient.SqlConnection($ServerConnectionString);


$query = "EXEC sp_configure 'clr enabled', 1;"
$query = $query + "RECONFIGURE;"


$cmd = new-object system.data.sqlclient.sqlcommand($query, $ServerConnection);
$ServerConnection.Open();
if ($cmd.ExecuteNonQuery() -ne -1)
{
    echo "Failed";
}
$ServerConnection.Close();
