#!/usr/bin/python
from GCoder.GCoder import GoogleGCode
from PGIS.PGIS import PostGISTasks
from ParseData.ParseData import PData
from flask import Flask, request, session, g, redirect, url_for, abort, \
                  render_template, flash
from flask_cors import CORS, cross_origin

# Create the application
app = Flask(__name__)
CORS(app)


## Index Page
@app.route('/')
def menu():
    return render_template('main.html')

## Using Address Page
@app.route('/gcode', methods=['GET','POST'])
def geocoder():
    if request.method == 'POST':
        addr = str(request.form['address'])
        coord = GoogleGCode().gcode(addr)
        pg = PostGISTasks()
        try:
            filename = pg.gjson_pgis(coord[0],coord[1])
            dict_pgis = pg.pgis_intersect(coord[0],coord[1])
            dfld_zone = dict_pgis[0][0]
            dstatic_bfe = dict_pgis[0][1]
        except Exception as e:
            dfld_zone = "No results"
            dstatic_bfe = "No results"
            filename = "No results"
        if coord:
            return redirect(url_for('gmaps', lat=coord[0], lng=coord[1], fld_zone=dfld_zone, static_bfe=dstatic_bfe, fname=filename ))
        else:
            return render_template('gcode.html')
    return render_template('gcode.html')

## Using Lat/Long
@app.route('/latlong', methods=['GET','POST'])
def latlng():
    if request.method == 'POST':
        lat = request.form['latl']
        lng = request.form['lonl']
        print type(lat)
        pg = PostGISTasks()
        dict_pgis = pg.pgis_intersect(lat,lng)
        try:
            dfld_zone = dict_pgis[0][0]
            dstatic_bfe = dict_pgis[0][1]
        except Exception as e:
            dfld_zone = "No results"
            dstatic_bfe = "No results"
        return redirect(url_for('gmaps', lat=lat, lng=lng, fld_zone=dfld_zone, static_bfe=dstatic_bfe))
    return render_template('latlong.html')

## GoogleMaps Page
@app.route('/gmaps/', methods=['GET'])
def gmaps():
    crd = request.args.to_dict()
    lat = crd['lat']
    lng = crd['lng']
    fname = crd['fname']
    static_bfe = crd['static_bfe']
    fld_zone = crd['fld_zone']
    if request.method == 'GET':
        return render_template('gmaps.html', lat=lat, lng=lng, fld_zone=fld_zone, static_bfe=static_bfe, fname=fname)
    else:
        return redirect(url_for('menu'))

if __name__ == '__main__':
    pass
