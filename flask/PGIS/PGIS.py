#!/usr/bin/python
import psycopg2
import time

class PostGISTasks:
    x = ''
    results = []

    def __init__(self):
        self.con = psycopg2.connect("host=127.0.0.1\
                                    dbname=shapes_shelly\
                                    user=admin\
                                    password=#drd_prr_0316$"
                                   )

    def pgis_column(self):
        cur1 = self.con.cursor()
        cur1.execute("SELECT column_name FROM information_schema.columns \
                      WHERE table_name = 's_pol_ar'")
        rec = cur1.fetchall()
        global len_rec
        len_rec = len(rec)  
        self.results.append([])
        for r in range(0, len_rec):
            if rec[r][0] == 'geom':
                self.x = r
            else:
                self.results[0].append(rec[r][0])
        cur1.close() 
         
    def pgis_intersect(self,lat,lng):
        cur = self.con.cursor()
        cur.execute("SELECT shape.fld_zone, shape.static_bfe FROM s_fld_haz_ar as shape, \
                     ST_GeomFromText('POINT(%s %s)', 4326) as point\
                     WHERE ST_Contains(shape.the_geom, point) LIMIT 1" % (lng, lat))
        recv = cur.fetchall()
        cur.close()
        self.con.close()
        return recv

    def gjson_pgis(self,lat,lng):
        cur = self.con.cursor()
        cur.execute("SELECT shape.fld_zone, ST_AsGeoJSON(shape.the_geom) FROM s_fld_haz_ar as shape, \
                     ST_GeomFromText('POINT(%s %s)', 4326) as point\
                     WHERE ST_Contains(shape.the_geom, point) LIMIT 1" % (lng, lat))
        recv = cur.fetchall()
        cur.close()
        
        partone = '{"type": "FeatureCollection", "features": ['
        partmain = '{"type": "Feature", "properties": {"fld_zone":"' + recv[0][0] + '"}, "geometry":\
                   ' + recv[0][1] + '}' 
        partmiddle = self.agjson_pgis(lat, lng)
        partfinal = ']}'
        final = partone+partmain+partmiddle+partfinal
        return final

    def agjson_pgis(self,lat,lng):
        cur = self.con.cursor()
        cur.execute("SELECT shape.ogc_fid FROM s_fld_haz_ar as shape, \
                     ST_GeomFromText('POINT(%s %s)', 4326) as point\
                     WHERE ST_Contains(shape.the_geom, point) LIMIT 1" % (lng, lat))
        ogcid = cur.fetchone()
        cur.execute("SELECT ogc_fid FROM s_fld_haz_ar as x INNER JOIN\
                    (SELECT the_geom FROM s_fld_haz_ar WHERE ogc_fid = %s ) as point\
                    ON ST_Touches(point.the_geom, x.the_geom)" % ogcid[0] )
        ogid = cur.fetchall()
        cur.close()
        allfeatures = ''
        for x in ogid:
          cur = self.con.cursor()
          cur.execute("SELECT shape.fld_zone, ST_AsGeoJSON(shape.the_geom) FROM s_fld_haz_ar as shape \
                       WHERE ogc_fid = %s " % x )
          rev = cur.fetchall()
          cur.close()
          recw = ',{"type": "Feature", "properties": {"fld_zone":"' + rev[0][0] + '"}, "geometry":\
                  ' + rev[0][1] + '}'
          allfeatures = allfeatures + recw
        return str(allfeatures)
