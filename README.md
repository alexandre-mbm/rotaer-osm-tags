Esse código está muito **imaturo** mas já oferece uma saída interessante.

O projeto tem por objetivo imediato ensaiar *parsing* com `awk`. O autor está [aprendendo a ferramenta](#estudo-de-awk) e não teve pudor em publicar código não lapidado e que só fora testado minimamente.

# O que ele faz?

Vejamos um exemplo.

Se executamos `rotaer.sh RN`, para o Estado do Rio Grande do Norte, o resultado do comando inclui:

```
[...]

###################################################
> NATAL
05 54 30S 035 14 57W
--
name=Augusto Severo
icao=SBNT
aerodrome=international;public;military
operator=INFRAERO
ele=52
--
ref=12/30
length=1825
width=45
surface=asphalt
--
ref=16L/4R
length=2600
width=45
surface=asphalt
--
ref=16R/4L
length=1800
width=45
surface=asphalt
###################################################
> PARELHAS
06 38 27S 036 39 13W
--
name=Kareli
icao=SDVZ
aerodrome=private
ele=316
--
ref=03/21
length=1058
width=23
surface=compacted
###################################################

[...]
```

Temos dois exemplos de registros. O primeiro é o antigo aeroporto da capital, Natal, com três pistas de pouso e decolagem. O segundo é um pequeno aeródromo do interior do Estado, no município de Parelhas.

## Usando os resultados

1. Seleciona-se blocos de etiquetas de interesse, tais como este:
```
name=Augusto Severo
icao=SBNT
aerodrome=international;public;military
operator=INFRAERO
ele=52
```
2. Copia-se ‒ `Shift+Ctrl+C`, se você usa o [Terminal do GNOME](https://help.gnome.org/users/gnome-terminal/stable/introduction.html.en)

3. No editor [JOSM](http://wiki.openstreetmap.org/wiki/Pt-br:JOSM), faz-se `Editar → Colar Tags` ou `Ctrl+Shift+V`

# Dados

É preciso prepará-los antes de executar o programa.

Faça o download:
```bash
$ wget -c http://www.aisweb.aer.mil.br/arquivos/publicacoes/ROTAER/00-AA0B073C-750B-445B-8618583F4BCBB240.pdf
```

Instale a ferramenta de conversão inicial:
```bash
$ sudo apt-get install poppler-utils
```

Realize a conversão inicial:
```bash
$ pdftotext -f 77 -l 605 -layout -eol unix -q 00-AA0B073C-750B-445B-8618583F4BCBB240.pdf texto2.txt

$ sed -i /DECEA-AIM/d texto2.txt
$ sed -i /ROTAER/d texto2.txt
```

Note que para o rotaer-osm-tags funcionar você precisa ter o arquivo `texto2.txt` que acabou de gerar.

# Como executar

Baixe o programa:
```bash
$ git clone https://github.com/alexandre-mbm/rotaer-osm-tags.git
$ cd rotaer-osm-tags
```

Execute-o sem parâmetros, para obter a Ajuda:
```bash
$ ./rotaer.sh
help:  rotaer.sh <AC|AL|AP|AM|BA|CE|DF|ES|GO|MA|MT|MS|MG|PA|PB|PR|PE|PI|RJ|RN|RS|RO|RR|SC|SP|SE|TO>
```

Experimente este exemplo:
```bash
$ ./rotaer.sh RJ  # para estado do Rio de Janeiro
```

# Licença

O rotaer-osm-tags é disponibilizado sob a [Expat License](LICENSE), também conhecida ambiguamente como "[MIT License](https://en.wikipedia.org/wiki/Expat_License)" — existe mais de uma "licença do MIT".

**Atenção com os dados!** Solucione esta questão ANTES DE MAPEAR:

Os dados externos são colhidos do [AIS](http://www.aisweb.aer.mil.br/?i=publicacoes&tab=rotaer) — Serviço de Informação Aeronáutica — pelo próprio usuário. Não há solicitação e recebimento de permissão para o aproveitamento deles em mapeamento OpenStreetMap. Provavelmente não estão protegidos por direitos autorais segundo a Lei vigente.

Saiba mais no Fórum do OpenStreetMap: [Aeródromos e aeroportos](http://forum.openstreetmap.org/viewtopic.php?id=26104)

# Estudo de awk

Em português:
- [linuxdicas - awk](http://linuxdicas.wikispaces.com/awk)
- [Awk em Exemplos, Parte 1](http://cesarakg.freeshell.org/awk-1.html)
- [Tutorial AWK - Blog do Beraldo](http://rberaldo.com.br/tutorial-awk/)
- [Guia de Referencias do Linux - awk [padrão ação textos]](http://www.uniriotec.br/~morganna/guia/awk.html)
- [Linux: Awk - Uma poderosa ferramenta de análise [Dica]](http://www.vivaolinux.com.br/dica/Awk-Uma-poderosa-ferramenta-de-analise)

Em inglês:
- [The GNU Awk User’s Guide](https://www.gnu.org/software/gawk/manual/html_node/index.html)
- [The GNU Awk User's Guide](http://www.delorie.com/gnu/docs/gawk/gawk_268.html)
- [AWK Language Programming - A User's Guide for GNU AWK](http://www.chemie.fu-berlin.de/chemnet/use/info/gawk/gawk_toc.html)