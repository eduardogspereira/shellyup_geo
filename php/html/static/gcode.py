#!/usr/bin/python3
import geocoder
import sys

try:
    g = geocoder.google(sys.argv[1])
    coord = g.latlng
    print (coord)
except Exception as e:
    print ("No results")
