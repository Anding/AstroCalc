\ Representative J2000 catalogues. Lists keep their declared priority.
include "%idir%\SkyRegions_interstellarum.f"

04 00 00 RA -15 00 00 Dec 07 00 00 RA +25 00 00 Dec STRIP-REGION: orion-quadrant
POLYGON-REGION: summer-triangle
    17 00 00 RA +10 00 00 Dec ADD-REGION-POINT
    21 30 00 RA +10 00 00 Dec ADD-REGION-POINT
    22 00 00 RA +55 00 00 Dec ADD-REGION-POINT
    17 00 00 RA +55 00 00 Dec ADD-REGION-POINT
END-POLYGON
create REGVIS orion-quadrant , summer-triangle , 0 ,

12 27 00 RA +12 43 00 Dec 08 00 00 DEGMMSS CIRCLE-REGION: virgo-cluster
POLYGON-REGION: cygnus-milky-way
    19 00 00 RA +25 00 00 Dec ADD-REGION-POINT
    22 00 00 RA +25 00 00 Dec ADD-REGION-POINT
    22 00 00 RA +60 00 00 Dec ADD-REGION-POINT
    19 00 00 RA +60 00 00 Dec ADD-REGION-POINT
END-POLYGON
create REGDEEP virgo-cluster , cygnus-milky-way , 0 ,
create atlas-regionlists REGATLAS , REGVIS , REGDEEP , 0 ,
