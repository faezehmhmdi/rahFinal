<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <link rel="stylesheet" type="text/css" href="style.css">
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
        <link rel="stylesheet" type="text/css" href="038%20Grid.css">
        <link rel='stylesheet' type='text/css' href='https://cdn.fontcdn.ir/Font/Persian/Nazanin/Nazanin.css'>
    </head>
    <?php
        $hostname = "localhost";
        $username = "root";
        $password = "";
        $db = "rah";
        $dbconnect=mysqli_connect($hostname,$username,$password,$db);
        if ($dbconnect->connect_error) {
            die("Database connection failed: " . $dbconnect->connect_error);
        }
        $query = mysqli_query($dbconnect, "CALL showConfs()");
		function g2p($g_y, $g_m, $g_d)
	{
        $g_days_in_month = array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
        $j_days_in_month = array(31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29);

        $gy = $g_y-1600;
        $gm = $g_m-1;
        $gd = $g_d-1;

        $g_day_no = 365*$gy+floor(($gy+3)/4)-floor(($gy+99)/100)+floor(($gy+399)/400);

        for ($i=0; $i < $gm; ++$i){
            $g_day_no += $g_days_in_month[$i];
        }

        if ($gm>1 && (($gy%4==0 && $gy%100!=0) || ($gy%400==0))){
            /* leap and after Feb */
            ++$g_day_no;
        }

        $g_day_no += $gd;
        $j_day_no = $g_day_no-79;
        $j_np = floor($j_day_no/12053);
        $j_day_no %= 12053;
        $jy = 979+33*$j_np+4*floor($j_day_no/1461);
        $j_day_no %= 1461;

        if ($j_day_no >= 366) {
            $jy += floor(($j_day_no-1)/365);
            $j_day_no = ($j_day_no-1)%365;
        }
        $j_all_days = $j_day_no+1;

        for ($i = 0; $i < 11 && $j_day_no >= $j_days_in_month[$i]; ++$i) {
            $j_day_no -= $j_days_in_month[$i];
        }

        $jm = $i+1;
        $jd = $j_day_no+1;

        return array($jy, $jm, $jd, $j_all_days);
    }
    ?>
    <body>
        <table class="myTable">
            <tr>
            <td>موضوع جلسه</td>
            <td>وضعیت جلسه</td>
            <td>تاریخ شروع</td>
			<td>ساعت شروع</td>
			<td>ساعت پایان</td>
            <td>نام میزبان</td>
            <td>محل برگزاری</td>
            <td>لینک نرم افزار</td>
            <td>مشخصات فنی</td>
            <td>رابط</td>
            <td>شماره تلفن</td>
			<td>شرح جلسه</td>
			<td>مدعوین</td>
            <td>لغو/برقراری</td>
			<td>افزودن/تغییر شرح</td>
            </tr>
        <?php
            while ($row = mysqli_fetch_assoc($query)) {
                echo "<tr id ='detailsRow'>";
                foreach ($row as $field => $value) {
					if ($field == "id"){
						continue;
					}
					if($field == "start_Date"){
						$start_arr = explode ("-", $value);
						$jstart_arr = g2p((int)$start_arr[0], (int)$start_arr[1], (int)$start_arr[2]);
						$value = $jstart_arr[0] . "/" .$jstart_arr[1]. "/". $jstart_arr[2];
					}
					if($field == "isCanceled"){
						if($value == 0){
							$value = "برقرار";
						}
						else {
							$value = "لغو";
						}
					}
						echo "<td>" . $value . "</td>";
                }
                echo '<td><input   type="button"  name="cancel" value ="لغو" onclick="cancel(\''.$row['id'].'\')">
						   <input  type="button"  name="undoCancel" value ="برقراری" onclick="undoCancel(\''.$row['id'].'\')">
						   <input  type="button"  name="delConf" value="حذف" onclick="delConf(\''.$row['id'].'\')"></td>';
               // echo '<td></td>';
				echo '<td>		
							<form method="get" action="addConfDesc.php">
								<input type="text" placeholder="شرح را وارد کنید" name="desc"></input>
								<input type="hidden" name= "id" value="'.$row['id'].'"></input>
								<input type="submit" value="ذخیره"></input>
							</form>
								</td>';
                echo "</tr>";
            }
        ?>
        </table>
    </body>
    <script>
        function cancel(id) {
        const XHR = new XMLHttpRequest();
        XHR.open( "GET", "http://localhost:80/cancel.php?id="+id , false);
        XHR.send( '' );
        alert(XHR.responseText);
        location.reload();
        }

        function undoCancel(id) {
        const XHR = new XMLHttpRequest();
        XHR.open( "GET", "http://localhost:80/undoCancel.php?id="+id , false);
        XHR.send( '' );
        alert(XHR.responseText);
        location.reload();
        }
		
		function delConf(id) {
        const XHR = new XMLHttpRequest();
        XHR.open( "GET", "http://localhost:80/del.php?id="+id , false);
        XHR.send( '' );
        alert(XHR.responseText);
        location.reload();
        }
    </script>
</html>
<?php
?>
