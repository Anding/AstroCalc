\ Representative Interstellarum charts, not a complete atlas catalogue.
\ Four-corner footprints use great-circle edges, not exact atlas Dec bounds.
NEED ForthAstroCalc
00 00 00 RA +90 00 00 Dec 12 30 00 DEGMMSS CIRCLE-REGION: chart-1
POLYGON-REGION: chart-2
    20 00 00 RA +67 30 00 Dec ADD-REGION-POINT
    00 00 00 RA +67 30 00 Dec ADD-REGION-POINT
    00 00 00 RA +82 30 00 Dec ADD-REGION-POINT
    20 00 00 RA +82 30 00 Dec ADD-REGION-POINT
POLYGON-REGION: chart-3
    16 00 00 RA +67 30 00 Dec ADD-REGION-POINT
    20 00 00 RA +67 30 00 Dec ADD-REGION-POINT
    20 00 00 RA +82 30 00 Dec ADD-REGION-POINT
    16 00 00 RA +82 30 00 Dec ADD-REGION-POINT
POLYGON-REGION: chart-4
    12 00 00 RA +67 30 00 Dec ADD-REGION-POINT
    16 00 00 RA +67 30 00 Dec ADD-REGION-POINT
    16 00 00 RA +82 30 00 Dec ADD-REGION-POINT
    12 00 00 RA +82 30 00 Dec ADD-REGION-POINT
create REGATLAS chart-1 , chart-2 , chart-3 , chart-4 , 0 ,
