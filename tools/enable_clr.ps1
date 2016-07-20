$tries = 5;
$pause = 10; # Seconds to wait between tries

While ($tries -gt 0) {
  try {

    $ServerConnectionString = "Data Source=(local)\SQL2014;Initial Catalog=master;User Id=sa;PWD=password12!";
    $ServerConnection = new-object system.data.SqlClient.SqlConnection($ServerConnectionString);


    $query = "exec sp_configure 'clr enabled', 1;`n"
    $query = $query + "RECONFIGURE;`n"
    $cmd = new-object system.data.sqlclient.sqlcommand($query, $ServerConnection);

    $ServerConnection.Open();
    
    "Running:"
    $query

    if ($cmd.ExecuteNonQuery() -ne -1) {
      "SQL Error";
    } else {
      "Success"
    }
    
    $ServerConnection.Close();
    $tries = 0;

  }
  catch {
    "Error:"
    $_.Exception.Message
    "Retry in $pause seconds.  Attempts left: $tries";
    Start-Sleep -s $pause;
  }
  $tries = $tries -1;
}  
