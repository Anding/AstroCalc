\ Representative named catalogues built on SkyRegions.f.
\ Within each list, declare specific regions from highest to lowest priority
\ and finish with exactly one default region.

include E:\coding\AstroCalc\ForthAstroCalc\SkyRegions_interstellarum.f

\ Recognizable naked-eye or wide-field areas.
s" Visual" s" REGVIS"
BEGIN-REGIONLIST visual-regions
04 00 00 RA -15 00 00 Dec 07 00 00 RA +25 00 00 Dec
	s" orion-quadrant" s" Orion quadrant" sky-strip orion-quadrant
BEGIN-SKY-POLYGON
	17 00 00 RA +10 00 00 Dec SKY-VERTEX
	21 30 00 RA +10 00 00 Dec SKY-VERTEX
	22 00 00 RA +55 00 00 Dec SKY-VERTEX
	17 00 00 RA +55 00 00 Dec SKY-VERTEX
s" summer-triangle" s" Summer Triangle"
END-SKY-POLYGON summer-triangle
s" n-a" s" n/a" sky-default visual-n-a
END-REGIONLIST

\ Areas useful when selecting or organizing deep-sky observations.
s" Deep Sky" s" REGDEEP"
BEGIN-REGIONLIST deep-sky-regions
12 27 00 RA +12 43 00 Dec 08 00 00 DEGMMSS
	s" virgo-cluster" s" Virgo galaxy cluster" sky-circle virgo-galaxy-cluster
BEGIN-SKY-POLYGON
	19 00 00 RA +25 00 00 Dec SKY-VERTEX
	22 00 00 RA +25 00 00 Dec SKY-VERTEX
	22 00 00 RA +60 00 00 Dec SKY-VERTEX
	19 00 00 RA +60 00 00 Dec SKY-VERTEX
s" cygnus-milky-way" s" Cygnus Milky Way"
END-SKY-POLYGON cygnus-milky-way
s" n-a" s" n/a" sky-default deep-sky-n-a
END-REGIONLIST
