<!doctype html>
<html>
  <head>
    <title>SHP Finder | Shelly Bo</title>
    <link rel="shortcut icon" href="./static/favicon.ico">
    <link href="https:fonts.googleapis.com/css?family=Playfair+Display|Roboto:100" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="./static/style_main.css">
  </head>
  <body>
    <div class="page">
    <a href="./" class="cmenu"><h1 class="subtitle"><span class="sub">Feature</span> <span class="sub">Search</span> - <span class="sub">Menu</span></h1></a>
    <p class=nav>
    <div class="middle">
    <a href="./latlong.php">Using Lat/Long</a>
    <a href="./gcode.php">Using the Address</a>
    </div>
    <form  action="./gcode.php" method=post>
        <dl>
            <dt>Address:
            <dd><input type=text name=address style="border:1px solid black" required>
            <dd><input type=submit name=Submit>
        </dl>
    </form>
    <div class="notfound">
    <?php
    if (!empty($_GET)){
      echo $_GET["res"];
    }

    if (!empty($_POST)){
      $adr =  $_POST['address'];
      exec("python ./static/gcode.py '$adr'", $output);
      $coord =  str_replace(" ","",str_replace("]","",str_replace("[","",$output[0])));
      if ($coord == ""){
        header("location:./gcode.php"."?res=Coordinate not found.");
      } else {
	$coordparse = explode(",", $coord);
	$lat = $coordparse[0];
	$lng = $coordparse[1];
        $db = pg_connect('host=localhost dbname=shapes_shelly user=admin password=#drd_prr_0316$');
        if(!$db){
          echo "Error : Can't connect with database.\n";
        } else {
          echo "ok";
          $query = "SELECT shape.fld_zone, shape.static_bfe FROM s_fld_haz_ar as shape, ST_GeomFromText('POINT($lng $lat)', 4326) as point WHERE ST_Contains(shape.the_geom, point) LIMIT 1";
          $result = pg_query($db, $query);
          $parse = pg_fetch_row($result);
          if ($parse){
            $fld_zone = $parse[0];
            $static_bfe = $parse[1];
          } else {
            $fld_zone = "No results";
            $static_bfe = "No results";
          }
          header("location:./gmaps.html"."?lat=".$lat."&lng=".$lng."&fld_zone=".$fld_zone."&static_bfe=".$static_bfe);
          pg_close($db);
       }
     }
    }
    ?>
    </div>
    </div>
  </body>
</html>
