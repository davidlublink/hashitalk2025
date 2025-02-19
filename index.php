<!DOCTYPE html>
    <html>
    <head>
      <link rel="stylesheet" href="index.css">
    </head>
    <body>
        <div style="color: white; font-size:400%;">
<?php

    $dsn = "mysql:host=".$_ENV['MYSQL_HOST'].";dbname=".$_ENV['MYSQL_DB'].";charset=utf8mb4;port=".$_ENV['MYSQL_PORT']."";
    
    // PDO options
    $options = [
        PDO::MYSQL_ATTR_SSL_CA     => $_ENV['SSL_CA_PATH'],
        PDO::MYSQL_ATTR_SSL_CERT   => $_ENV['SSL_CERT_PATH'],
        PDO::MYSQL_ATTR_SSL_KEY    => $_ENV['SSL_KEY_PATH'],
        PDO::ATTR_ERRMODE          => PDO::ERRMODE_EXCEPTION, // Enable exception handling
        PDO::ATTR_EMULATE_PREPARES => false,  // Disable prepared statement emulation
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,  // Fetch results as associative array
    ];

    // Establish the connection
    $pdo = new PDO($dsn, $_ENV['MYSQL_USER'], $_ENV['MYSQL_PASSWORD'], $options);
    
    echo "Connected successfully with SSL!";


    // Prepare and execute the query
    $stmt = $pdo->query("SELECT comment FROM cooltable order by id");

    echo '<h3>';
    // Fetch and display the results
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo $row['comment'] ."  ";
    }

    echo '</h3>';    

?>
   </div>
    <div class="pyro">
    <div class="before"></div>
    <div class="after"></div>
</div>
    </body>
    </html> 