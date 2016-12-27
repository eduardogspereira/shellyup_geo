#!/bin/bash

# Author: Eduardo G. S. Pereira < edu_vcd@hotmail.com >

### VARIABLES
export PGPASSWORD='#drd_prr_0316$'
DB='shapes_shelly'
HOST='127.0.0.1'
USER='admin'
F_SRID='4269'
T_SRID='4326'


### MAIN FUNCTIONS
upload_data () {
    flz=$(ls | grep -w 'gdb')
    echo "This ArcGIS Files are going to be upload on Postgis:"
    echo $flz | sed 's/ /, /g'
    read -p "Are you sure?[Y/y]: " -r 
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
    num_itens=$(echo $flz | sed 's/NFHL/NFHL\n/g' | grep -c "NFHL")
    x=1
        for i in $flz
        do
            echo "Uploading file: "$i "..........." $x/$num_itens "["$( expr $x \* 100 / $num_itens)"%]"
            ogr2ogr -lco GEOMETRY_NAME=the_geom -f "PostgreSQL" -s_srs "EPSG:$F_SRID"\
            -t_srs "EPSG:$T_SRID" PG:"dbname=$DB host=$HOST user=$USER password=#drd_prr_0316$"\
            -update -append $i S_Fld_Haz_Ar -nln s_fld_haz_ar 2> /dev/null 
            psql -U $USER -h $HOST $DB -c "UPDATE s_fld_haz_ar SET file = '$i' WHERE file IS NULL" > /dev/null
        let x=x+1
        done
    else
        exit 0
    fi
}

checkinfo () {
    fls=$(ls | grep -w 'gdb')
    for i in $fls
    do
        echo "================================================================"
        echo "Geodatabase: $i"
        ogrinfo $i S_Fld_Haz_Ar | sed -e '/FID/q' | sed -ne '/Layer name:/,$ p'
        echo " "
    done
}

del_rows () {
    echo -e "\e[7m\e[1m!!! Be careful using this function !!!\e[0m"
    echo -e "This function will \e[31m\e[1mDELETE\e[0m every row that match with the information you give."
    echo " "
    echo "For example:"
    echo "If you type 'NFHL_08', it will delete every row that match 'NFHL_08*'."
    echo "If you type just 'N', it will delete every row that match 'N*'."
    echo " "
    echo "========================"
    read -p "Do you want to continue?[Y/y]: " -r 
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Enter the number that will be used for delete the rows:"
        read -p "NFHL_" -r
        echo "- - -"
        if [ -z "$REPLY" ]
        then
            echo 'You need to provide some information.'
            exit 1
        fi
        psql -U $USER -h $HOST $DB -c "DELETE FROM s_fld_haz_ar WHERE file LIKE 'NFHL_$REPLY%'"
    fi
        
}

### MISCELLANEOUS TOOLS
misce () {
    echo "Miscellaneous Tools:"
    echo "1-) Generate the table schema"
    echo "2-) Check for duplicated data"
    echo "3-) Table statistics"
    echo "4-) Truncate the table"
    read -p "Enter the tool number: " -r
    case "$REPLY" in
        1)
            schema
            ;;
        2) 
            dup_data
            ;;
        3)
            stats
            ;;
        4)
            truncate
            ;;
        *)
            echo "Usage: This option is not valid."
            ;;
    esac
}

schema () {
    echo '- - -'
    echo -e "\e[1mGenerate the table schema\e[0m"
    echo "If the table already exists it will be dropped."
    read -p "Are you sure?[Y/y]: " -r
    if [[ $REPLY =~ ^[Yy]$ ]]
        then
        xy=$(ls | grep -w gdb | sort -r | head -n1)
        if [ ! -z "$xy" ]
        then 
            psql -U $USER -h $HOST $DB -c "DROP TABLE s_fld_haz_ar" &> /dev/null
            ogr2ogr -lco GEOMETRY_NAME=the_geom -f "PostgreSQL" -s_srs "EPSG:$F_SRID"\
            -t_srs "EPSG:$T_SRID" PG:"dbname=$DB host=$HOST user=$USER password=#drd_prr_0316$"\
            -update -append $xy S_Fld_Haz_Ar -nln s_fld_haz_ar 2> /dev/null
            psql -U $USER -h $HOST $DB -c "TRUNCATE TABLE s_fld_haz_ar" > /dev/null
            psql -U $USER -h $HOST $DB -c "ALTER TABLE s_fld_haz_ar ADD COLUMN file varchar(50)" > /dev/null
            echo "Schema created with success!"
        else
            echo 'You need be on a folder with the *.gdb files'
        fi
    fi
}

truncate () {
    echo '- - -'
    echo -e '\e[1mTruncate the table\e[0m'
    echo "This function will erase all rows from the table."
    read -p "Do you want to continue?[Y/y] :" -r
    if [[ $REPLY =~ ^[Yy]$ ]]
        then
        psql -U $USER -h $HOST $DB -c "TRUNCATE TABLE s_fld_haz_ar" > /dev/null
    fi
}

stats () {
    echo '- - -'
    echo -e '\e[1mTable statistics\e[0m'
    echo -ne "Collecting info .............................. [0%]\\r"
    CT=$(psql -U $USER -h $HOST $DB -c "SELECT COUNT(*) FROM s_fld_haz_ar" | grep '[0-9]' | grep -v 'row')
    echo -ne "Collecting info .............................. [25%]\\r"
    SZ=$(psql -U $USER -h $HOST $DB -c "SELECT pg_size_pretty(pg_total_relation_size('s_fld_haz_ar'))" | grep '[0-9]' | grep -v 'row')
    echo -ne "Collecting info .............................. [50%]\\r"
    NL=$(psql -U $USER -h $HOST $DB -c "SELECT COUNT(*) FROM s_fld_haz_ar WHERE file IS NULL" | grep '[0-9]' | grep -v 'row')
    echo -ne "Collecting info .............................. [75%]\\r"
    FL=$(psql -U $USER -h $HOST $DB -c "SELECT file FROM s_fld_haz_ar GROUP BY file" | grep [0-9] | grep -v 'row')
    echo -ne "Collecting info .............................. [100%]\\r"
    echo ""
    echo "Features: "$CT
    echo "Size: "$SZ
    echo "Features without source: "$NL" feature(s)"
    echo "Uploaded files:"
    echo $FL | sed 's/ /\n/g' | sed 's/^/+-- /'
}

dup_data () {
    echo '- - -'
    echo -e '\e[1mCheck for duplicated data\e[0m'
    echo 'This function will check for duplicated data on PostGIS.'
    echo -e "This is a \e[1m\e[34mSAFE TOOL\e[0m and will improve the performance of the database."
    echo -ne "Checking for duplicated data ..................... [35%]\\r"
    psql -U $USER -h $HOST $DB -c "SELECT a.ogc_fid, b.ogc_fid FROM s_fld_haz_ar AS a, s_fld_haz_ar AS b\
    WHERE ST_Equals(a.the_geom, b.the_geom) AND a.fld_zone = b.fld_zone AND a.static_bfe = b.static_bfe AND\
    a.ogc_fid <> b.ogc_fid" > /tmp/chkfile.temp
    rm -f /tmp/gdb2postgis.temp 2> /dev/null 
    touch /tmp/gdb2postgis.temp
    TABLE=$(cat /tmp/chkfile.temp | grep '[0-9]' | grep -v 'rows')
    PARSE=$(echo $TABLE | sed 's/ | /-/g' | sed 's/ /\n/g')
    for i in $PARSE
    do
        y=$(echo $i | cut -f1 -d'-')
        x=$(cat /tmp/gdb2postgis.temp | grep $y)
        if [ -z "$x" ]
        then
            echo $i >> /tmp/gdb2postgis.temp
        fi
    done
    echo -ne "Checking for duplicated data ..................... [55%]\\r"
    sleep 3
    COUNT=$(cat /tmp/gdb2postgis.temp | wc -l)
    echo -ne "Checking for duplicated data ..................... [100%]\\r"
    echo ""
    if [ $COUNT -eq 0 ]
    then
        echo "No duplicate data were found!"
    else
        read -p "$COUNT rows are going to be delete. Continue?[Y/y]: " -r
        k=1
        for i in $(cat /tmp/gdb2postgis.temp | cut -f1 -d'-')
        do
            echo -ne "Deleting duplicate data: ........... ["$( expr $k \* 100 / $COUNT)"%]\\r"
            psql -U $USER -h $HOST $DB -c "DELETE FROM s_fld_haz_ar WHERE ogc_fid = $i" > /dev/null
            let k=k+1
        done
        echo ""
        rm -f /tmp/gdb2postgis.temp
        rm -f /tmp/chkkfile.temp
        echo "Duplicated data successfully removed!"
    fi
}


### CASE
case "$1" in
    upload)
        upload_data
        ;;
    info)
        checkinfo
        ;;
    delete)
        del_rows
        ;;
    misc)
        misce
        ;;
    *)
        echo "Usage: ./gdb2postgis {upload|info|delete|misc}"
        echo "   |- upload:   Going to upload the ArcGIS files from the currently folder to PostGIS."
        echo "   |- info:     Will collect the information from the ArcGIS files from the currently folder."
        echo "   |- detele:   Will delete all rows based on information you enter. !!!Be careful!!!"
        echo "   |- misc:     Some miscellaneous tools that may help."
        ;;
esac
