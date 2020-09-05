 <?php
    $hostname = "localhost";
    $username = "root";
    $password = "";
    $db = "rah";
    $dbconnect=mysqli_connect($hostname,$username,$password,$db);
    if ($dbconnect->connect_error) {
        die("Database connection failed: " . $dbconnect->connect_error);
    }
    $query = mysqli_query($dbconnect, "SELECT deleteConf('".$_GET['id']. "');")
        or die (mysqli_error($dbconnect));
    while ($row = mysqli_fetch_array($query)) {
        echo $row[0];
    }
?>
