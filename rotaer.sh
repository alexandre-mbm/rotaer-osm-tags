#!/bin/bash
#
# Copyright (c) 2014 Alexandre Magno <alexandre.mbm@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

UF="RN"

FILE="texto2.txt"

tmp=$(echo $1 | tr [a-z] [A-Z])

case $tmp in
    AC|AL|AP|AM|BA|CE|DF|ES|GO|MA|MT|MS|MG|PA|PB|PR|PE|PI|RJ|RN|RS|RO|RR|SC|SP|SE|TO)
        UF=$tmp
        ;;
    *)
        echo "help:  rotaer.sh <AC|AL|AP|AM|BA|CE|DF|ES|GO|MA|MT|MS|MG|PA|PB|PR|PE|PI|RJ|RN|RS|RO|RR|SC|SP|SE|TO>"
        exit 0
        ;;
esac

awk '
    BEGIN {RS="";FS="\n"}
    
    {
        if ($1 ~ / '$UF' / && $1 ~ / \/ /)
            print $0,"\n"
    }' "$FILE" | 

sed "s/^ *//g" | 
sed "s/^\(.*\) \/ \([^,]*\), \(.*\)\([0-9][0-9] [0-9][0-9] [0-9][0-9].\)\/\([0-9][0-9][0-9] [0-9][0-9] [0-9][0-9].\)/> \1\n\4 \5\n--\nname=\2\n\3/" |
sed "/^[A-Z]\{4\}, [A-Z]\{2\}.*/d" |  # TODO pegar a UF antes (refazer acima com awk)
sed "s/^[A-Z]\{2\} \([A-Z]\{4\}\)[ \t]*$/\1/" | 
sed "s/^\([A-Z]\{4\}\)$/icao=\1/" | 
sed "s/^\([^0-9]*\).*\(UTC-[0-9]*\) \([^.]*\)[^0-9\.]^*\([0-9\.]* ([0-9]*)\)/\1\2\n\3\4/" | 
sed "s/^[ \t]*//" | 
sed "s/^\(.*\) \([0-9\.]* ([0-9]*)\)[ \t]*$/\1\n\2/" | 
sed "/^[A-Z0-9, ]*FR [A-Z0-9, ]*$/s/^.* [0-9][0-9] \([^0-9]*\)[\t ]*$/operator=\1/" | 
sed "s/^\(.*\) \([0-9\.]* ([0-9]*)\)[ \t]*$/\1\n\2/" | 
sed "/^[A-Z0-9, ]*FR [A-Z0-9, ]*$/s/^.*  \([^0-9]*\)[\t ]*$/operator=\1/" | 
sed "/^operator=[ \t]*$/d" | 
sed "/^[A-Z0-9]\{2,3\}[ \t]*$/d" | 
# MIL 		– military
# PRIV 		– private
# PRIV/PUB 	– public		        + fixme:aerodrome=PRIV/PUB
# PUB 		– public
# PUB/MIL 	– public;military
# PUB/REST 	– public		        + fixme:aerodrome=PUB/REST 
#
# INTL		‒ international
# INTL/ALTN	‒ international	        + fixme:aerodrome=INTL/ALTN
awk '
    {
        if($0 ~ /.*UTC-[0-9]*[ \t]*$/)
        {
            intl = "false"
            altn = "false"
            
            if($1 == "INTL")
            {
                intl = "true"
            }
            if($1 == "INTL/ALTN")
            {
                intl = "true"
                altn = "true"
            }
            
            util = $1
            if(intl == "true")
            {
                util = $2
                printf "aerodrome=international;"
            }
            else
            {
                printf "aerodrome="
            }
            
            fixme=""
            if(altn == "true")
                fixme = "fixme:aerodrome=INTL/ALTN, segundo o ROTAER"              
            
            if(util == "MIL")
            {
                print "military"
            }
            if(util == "PRIV")
            {
                print "private"
            }
            if(util == "PRIV/PUB")
            {
                print "public"
                if(altn == "true")
                    fixme = fixme"; PRIV/PUB, segundo o ROTAER"
                else
                    fixme = "fixme:aerodrome="
                    fixme = fixme"PRIV/PUB, segundo o ROTAER"
            }
            if(util == "PUB")
            {
                print "public"
            }
            if(util == "PUB/MIL")
            {
                print "public;military"
            }
            if(util == "PUB/REST")
            {
                print "public"
                if(altn == "true")
                    fixme = fixme"; PUB/REST, segundo o ROTAER"
                else
                    fixme = "fixme:aerodrome="
                    fixme = fixme"PUB/REST, segundo o ROTAER"
            }
            
            if(fixme != "")
                print fixme
        }
        else
        {
            print $0
        }
    }' |

sed "s/^\([0-9\.]*\) ([0-9\.]*)[ \t]*$/ele=\1/" |

# 12 - L9(2.98) (2), 12- (1825x45 ASPH 44/F/A/X/T L14) -L12 - 30

sed "s/^\([0-9A-Z]\{2,3\}\) - .*\(([0-9]*x[0-9]*[a-zA-Z0-9 \/\.,]*)\).* - \([0-9A-Z]\{2,3\}\)[ \t]*$/\1\2\3/" | 

# 12(1825x45 ASPH 44/F/A/X/T L14)30

sed "s/^\([0-9A-Z]\{2,3\}\)(\([0-9]*\)x\([0-9]*\) \([A-Z]*\) .*\([0-9A-Z]\{2,3\}\)$/--\nref=\1\/\5\nlength=\2\nwidth=\3\nsurface=\4/" | 

awk '
    {
        if($0 ~ /^surface=[A-Z]*$/)
        {
            sub(/AÇO/, "metal")
            sub(/CIN/, "ground")
            sub(/MTAL/, "metal")
            sub(/ARE/, "sand")
            sub(/CONC/, "concrete")
            sub(/PAR/, "sett")
            sub(/ARG/, "clay")
            sub(/GRASS/, "grass")
            sub(/PIÇ/, "compacted")
            sub(/ASPH/, "asphalt")
            sub(/GRVL/, "fine_gravel")
            sub(/SAI/, "compacted")
            sub(/BAR/, "compacted")
            sub(/MAC/, "dirt")
            sub(/SIL/, "fine_gravel")
            sub(/TIJ/, "dirt")
            sub(/MAD/, "wood")
            sub(/TER/, "ground")
            print
        }
        else
        {
            print $0
        }
    }' | 
sed "s/^[ \t]*$/###################################################/" | 
sed "s/[ \t]*$//"  # excluindo <spaces>; TODO fix e eliminar esta necessidade

# Erros observados
#
# TODO operador fica isolado, quando a pesquisa UF é muito abrangente

