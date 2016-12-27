#!/usr/bin/python
import geocoder

## Geocode the Adress
class GoogleGCode:

    def __init__(self):
        pass

    def gcode(self,addr):
        g = geocoder.google(addr)
        coord = g.latlng
        return coord
