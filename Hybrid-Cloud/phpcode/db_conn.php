<?php  

$sname = "0.0.0.0";
$uname = "cmpadmin";
$password = "Unisys*12345";

$db_name = "hybrid";

$conn  = mysqli_connect($sname, $uname, $password, $db_name);

if (!$conn) {
	echo "Connection failed!";
}