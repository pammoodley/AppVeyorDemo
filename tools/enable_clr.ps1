$tries = 5;

While ($tries -gt 0) {
  try {

    #Create your SQL connection string, and then a connection
    $ServerConnectionString = "Data Source=(local)\SQL2012SP1;Initial Catalog=master;User Id=sa;PWD=Password12!";
    $ServerConnection = new-object system.data.SqlClient.SqlConnection($ServerConnectionString);


    $query = "exec sp_configure 'clr enabled', 1;`n"
    $query = $query + "RECONFIGURE;`n"
    #$query = $query + "GO`n"
    $query
    $cmd = new-object system.data.sqlclient.sqlcommand($query, $ServerConnection);

    $ServerConnection.Open();
    if ($cmd.ExecuteNonQuery() -ne -1) {
        "SQL Failed";
    }
    
    $ServerConnection.Close();
    $tries = 0;

  }
  catch {
    $ErrorMessage = $_.Exception.Message

    "Error."
    $ErrorMessage
    "Retry in 10 seconds.  Attempts left: $tries";
    Start-Sleep -s 10;
  }
  $tries = $tries -1;

}  
