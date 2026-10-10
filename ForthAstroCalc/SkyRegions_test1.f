need simple-tester

include E:\coding\AstroCalc\ForthAstroCalc\SkyRegions.f

depth constant skyregions-test-depth

s" Test Regions" s" REGTEST"
BEGIN-REGIONLIST test-regions
05 35 17 RA -05 -23 -15 Dec 05 00 00 DEGMMSS
	s" m42" s" Orion Nebula region" sky-circle M42-region
23 00 00 RA +15 00 00 Dec 00 30 00 RA +30 00 00 Dec
	s" pegasus" s" Square of Pegasus" sky-strip Pegasus-region
BEGIN-SKY-POLYGON
	23 00 00 RA +10 00 00 Dec SKY-VERTEX
	01 00 00 RA +10 00 00 Dec SKY-VERTEX
	01 00 00 RA +30 00 00 Dec SKY-VERTEX
	23 00 00 RA +30 00 00 Dec SKY-VERTEX
s" ra-wrap" s" RA wrap polygon"
END-SKY-POLYGON RA-wrap-region
s" n-a" s" n/a" sky-default test-n-a
END-REGIONLIST

BEGIN-SKY-POLYGON
	23 00 00 RA +30 00 00 Dec SKY-VERTEX
	01 00 00 RA +30 00 00 Dec SKY-VERTEX
	01 00 00 RA +10 00 00 Dec SKY-VERTEX
	23 00 00 RA +10 00 00 Dec SKY-VERTEX
s" reversed" s" Reversed polygon"
END-SKY-POLYGON reversed-region

include E:\coding\AstroCalc\ForthAstroCalc\SkyRegions_catalogs.f

Tstart

T{ depth }T skyregions-test-depth ==
T{ test-regions regionlist-name hashS }T s" Test Regions" hashS ==
T{ test-regions regionlist-fits-key hashS }T s" REGTEST" hashS ==
T{ first-regionlist }T test-regions ==
T{ test-regions next-regionlist }T interstellarum-regions ==
T{ interstellarum-regions next-regionlist }T visual-regions ==
T{ visual-regions next-regionlist }T deep-sky-regions ==
T{ deep-sky-regions next-regionlist }T 0 ==
T{ M42-region region-id hashS }T s" m42" hashS ==
T{ M42-region region-label hashS }T s" Orion Nebula region" hashS ==

T{ 05 30 00 RA -06 00 00 Dec M42-region region-inside? }T -1 ==
T{ 12 00 00 RA 00 00 00 Dec M42-region region-inside? }T 0 ==
T{ 23 30 00 RA +20 00 00 Dec Pegasus-region region-inside? }T -1 ==
T{ 00 15 00 RA +20 00 00 Dec Pegasus-region region-inside? }T -1 ==
T{ 12 00 00 RA 00 00 00 Dec Pegasus-region region-inside? }T 0 ==
T{ 12 00 00 RA 00 00 00 Dec test-n-a region-inside? }T -1 ==

T{ 00 00 00 RA +20 00 00 Dec RA-wrap-region region-inside? }T -1 ==
T{ 12 00 00 RA +20 00 00 Dec RA-wrap-region region-inside? }T 0 ==
T{ 23 00 00 RA +10 00 00 Dec RA-wrap-region region-inside? }T -1 ==
T{ 00 00 00 RA +20 00 00 Dec reversed-region region-inside? }T -1 ==
T{ 00 00 00 RA +20 00 00 Dec
	RA-wrap-region REGION.DATA0 + @
	RA-wrap-region REGION.DATA1 + @
	spherical_polygon_contains }T 1 ==

T{ 05 40 00 RA -05 00 00 Dec test-regions search-regionlist }T M42-region ==
T{ 23 30 00 RA +20 00 00 Dec test-regions search-regionlist }T Pegasus-region ==
T{ 00 45 00 RA +20 00 00 Dec test-regions search-regionlist }T RA-wrap-region ==
T{ 12 00 00 RA +50 00 00 Dec test-regions search-regionlist }T test-n-a ==

T{ interstellarum-regions regionlist-fits-key hashS }T s" REGATLAS" hashS ==
T{ 21 00 00 RA +75 00 00 Dec interstellarum-regions search-regionlist }T interstellarum-chart-2 ==
T{ 14 00 00 RA +75 00 00 Dec interstellarum-regions search-regionlist }T interstellarum-chart-4 ==
T{ visual-regions regionlist-fits-key hashS }T s" REGVIS" hashS ==
T{ 05 30 00 RA 00 00 00 Dec visual-regions search-regionlist }T orion-quadrant ==
T{ 19 30 00 RA +35 00 00 Dec visual-regions search-regionlist }T summer-triangle ==
T{ deep-sky-regions regionlist-fits-key hashS }T s" REGDEEP" hashS ==
T{ 12 27 00 RA +12 43 00 Dec deep-sky-regions search-regionlist }T virgo-galaxy-cluster ==
T{ 20 30 00 RA +40 00 00 Dec deep-sky-regions search-regionlist }T cygnus-milky-way ==
T{ 00 00 00 RA -60 00 00 Dec deep-sky-regions search-regionlist }T deep-sky-n-a ==

Tend