need simple-tester

include E:\coding\AstroCalc\ForthAstroCalc\SkyRegions.f

BEGIN-REGIONSET is-where?
                                                    s" no region"           sky-default anywhere?
05 35 17 RA -05 23 15 Dec 05 00 00 DEGMMSS          s" Orion Nebula region" sky-circle M42?
00 00 00 RA  00 00 00 Dec 02 00 00 RA  20 00 00 Dec s" Pisces region"       sky-strip Pisces?
23 00 00 RA  15 00 00 Dec 00 30 00 RA  30 00 00 Dec s" Square of Pegasus"   sky-strip Pegasus?
END-REGIONSET

Tstart

T{ 00 30 00 RA 10 00 00 Dec Pisces? nip nip }T -1 ==
T{ 12 00 00 RA 00 00 00 Dec Pisces? }T 0 ==
T{ 00 00 00 RA 45 00 00 Dec Pegasus? }T 0 ==
T{ 12 00 00 RA 00 00 00 Dec Pegasus? }T 0 ==
T{ 23 30 00 RA 20 00 00 Dec Pegasus? nip nip }T -1 ==
T{ 00 00 00 RA 20 00 00 Dec Pegasus? nip nip }T -1 ==
T{ 00 15 00 RA 20 00 00 Dec Pegasus? nip nip }T -1 ==
T{ 05 30 00 RA -06 00 00 Dec M42? nip nip }T -1 ==
T{ 12 00 00 RA 00 00 00 Dec M42? }T 0 ==
T{ 12 00 00 RA 00 00 00 Dec anywhere? nip nip }T -1 ==
T{ 00 00 00 RA 00 00 00 Dec is-where? hashS }T s" Pisces region" hashS ==
T{ 05 40 00 RA -05 00 00 Dec is-where? hashS }T s" Orion Nebula region" hashS ==
T{ 12 00 00 RA 50 00 00 Dec is-where? hashS }T s" no region" hashS ==

Tend