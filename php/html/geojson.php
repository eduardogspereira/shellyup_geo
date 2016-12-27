<?php
if (!empty($_GET)){
    $lat = $_GET["lat"];
    $lng = $_GET["lng"];
    $db = pg_connect('host=localhost dbname=shapes_shelly user=admin password=#drd_prr_0316$');
    if(!$db){
        echo "Error : Can't connect with database.\n";
    } else {
        $query =  "SELECT shape.fld_zone, ST_AsGeoJSON(shape.the_geom) FROM s_fld_haz_ar as shape, ST_GeomFromText('POINT($lng $lat)', 4326) as point WHERE ST_Contains(shape.the_geom, point) LIMIT 1";
        $result = pg_query($db, $query);
        $parse = pg_fetch_row($result);
      	$queryid = "SELECT shape.ogc_fid FROM s_fld_haz_ar as shape, ST_GeomFromText('POINT($lng $lat)', 4326) as point WHERE ST_Contains(shape.the_geom, point) LIMIT 1";
	      $resultid = pg_query($db, $queryid);
	      $parseid = pg_fetch_row($resultid);
	      $geoid = $parseid[0];
	      $querybound = "SELECT ogc_fid FROM s_fld_haz_ar as x INNER JOIN (SELECT the_geom FROM s_fld_haz_ar WHERE ogc_fid = $geoid ) as point ON ST_Touches(point.the_geom, x.the_geom)";
	      $resultbound = pg_query($db, $querybound);
	      $parsebound = pg_fetch_all($resultbound);
        $partmiddle = '';
        foreach($parsebound as $pb){
          $id = $pb["ogc_fid"];
          $querygeom = "SELECT shape.fld_zone, ST_AsGeoJSON(shape.the_geom) FROM s_fld_haz_ar as shape WHERE ogc_fid = $id"; 
          $resultgeom = pg_query($db, $querygeom);
          $parsegeom = pg_fetch_row($resultgeom);
          $recw = ',{"type": "Feature", "properties": {"fld_zone":"' . $parsegeom[0] . '"}, "geometry":' . $parsegeom[1] . '}';
          $partmiddle = $partmiddle.$recw;
        }
	      
        //Building the GeoJSON
        $partone = '{"type": "FeatureCollection", "features": [';
        $partmain = '{"type": "Feature", "properties": {"fld_zone":"'.$parse[0].'"}, "geometry":'.$parse[1].'}';
        $partfinal = ']}';
        echo $partone.$partmain.$partmiddle.$partfinal;
        pg_close($db);
    }

}
?>
