#!/usr/bin/python

class PData:
    def __init__(self):
        pass

    def parse_head(self,lista):
        str1 = "<thead>"
        for i in lista[0]:
            str1 = str1 + "<th>" + i + "</th>"
        str1 = str1 + "</thead>"
        return str1 

    def parse_rows(self,lista):
        ran1 = len(lista)
        ran2 = len(lista[0])
        string = []
        sfinal = ""
        for z in range(1, ran1):
            str1 = "<tr>"
            str2 = ""
            for i in range(0, ran2):
                str2 = str2 + "<td>" + str(lista[z][i]) + "</td>"
            str1 = str1 + str2 + "</tr>"
            string.append(str1)
        for k in string:
            sfinal = sfinal + k
        return sfinal
