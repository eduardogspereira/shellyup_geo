#!/usr/bin/python
import psycopg2
from datetime import datetime

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
        cur.execute("SELECT ST_AsGeoJSON(shape.the_geom) FROM s_fld_haz_ar as shape, \
                     ST_GeomFromText('POINT(%s %s)', 4326) as point\
                     WHERE ST_Contains(shape.the_geom, point) LIMIT 1" % (lng, lat))
        recv = cur.fetchall()
        cur.close()
        recw = recv[0][0]
        i = datetime.now()
        fname = i.strftime('%m%d%H%M%S%f')
        filename = '/var/www/html/geojson/'+fname+'.json'
        target =  open(filename, 'w')
        target.write(recw)
        target.close()
        return (fname)

