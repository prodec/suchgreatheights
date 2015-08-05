# suchgreatheights

Este serviço provê conversão de posições no mundo para altitudes retiradas dos arquivos gerados pela missão de topografia por radar da NASA, a [SRTM][srtm]. A qualidade dos resultados daqui depende, portanto, do que é oferecido por esses dados &mdash; no nosso caso, os arquivos da missão SRTM3, em que cada dado no arquivo binário abarca 3 arco-segundos de informação.

Há dois pontos de entrada, apenas:

- `point_altitude(lon, lat)`: recebe longitude e latitude como Floats e retorna a altitude
- `route_profile(route)`: recebe uma rota como LineString GeoJSON e retorna uma altitude para cada ponto

## Rodando

    $ bundle install
    $ bin/server

O serviço abrirá na porta 7331, e responderá tanto por WebSocket quanto por HTTP.

## Usando

### HTTP

  - **[GET]**: /altitude?lat=<float>&lon=<float> - retorna JSON com a estrutura

```
{ altitude: <float> }
```

  - **[GET]**: /profile?route=<json array> - retorna JSON com a seguinte estrutura

```
{ profile: [[<float>, <float>, <float>]...]}
```

  - **[POST]**: /profile, payload: LineString GeoJSON - retorna JSON com a seguinte estrutura

```
{ profile: [[<float>, <float>, <float>]...]}
```

#### Exemplos

  - Buscando altitude de um ponto (GET)

```
$ curl -XGET http://localhost:7331/altitude\?lon\=-42.123123\&lat\=-21.98888
{"altitude":287}
```

  - Buscando perfil (GET)

```
$ curl -XGET http://localhost:7331/profile?route="[[-43.114,-22.321],[-43.124,-22.331]]"
{"profile":[[-43.114,-22.320999999999994,866],[-43.1141,-22.321100003547638,866],[-43.114200000000004,-22.321200007023617,888],[-43.1143,-22.321300010427944,888],[-43.114399999999996,-22.321400013760606,888],[-43.11450000000001,-22.321500017021606,888],[-43.1146,-22.321600020210937,888],[-43.114700000000006,-22.321700023328606,896],[-43.1148,-22.321800026374614,896],[-43.1149,-22.321900029348967,896],[-43.115,-22.322000032251644,912],[-43.1151,-22.32210003508267,912],[-43.1152,-22.32220003784202,912],[-43.115300000000005,-22.322300040529715,912],[-43.11540000000001,-22.32240004314575,912],[-43.115500000000004,-22.322500045690102,875],[-43.1156,-22.32260004816281,875],[-43.115700000000004,-22.322700050563835,875],[-43.11580000000001,-22.32280005289321,875],[-43.115899999999996,-22.322900055150896,882],[-43.116,-22.32300005733693,882],[-43.11610000000001,-22.323100059451303,882],[-43.116200000000006,-22.323200061494006,882],[-43.1163,-22.323300063465048,882],[-43.116400000000006,-22.323400065364414,837],[-43.1165,-22.323500067192125,837],[-43.1166,-22.32360006894815,837],[-43.1167,-22.323700070632523,840],[-43.116800000000005,-22.32380007224523,840],[-43.116899999999994,-22.32390007378626,840],[-43.117000000000004,-22.324000075255615,840],[-43.11710000000001,-22.324100076653316,840],[-43.117200000000004,-22.324200077979327,788],[-43.11730000000001,-22.32430007923369,788],[-43.1174,-22.324400080416385,788],[-43.1175,-22.324500081527404,788],[-43.1176,-22.324600082566747,791],[-43.1177,-22.324700083534427,791],[-43.1178,-22.32480008443043,791],[-43.117900000000006,-22.324900085254765,791],[-43.11800000000001,-22.32500008600744,751],[-43.118100000000005,-22.325100086688433,751],[-43.1182,-22.325200087297752,751],[-43.118300000000005,-22.32530008783541,751],[-43.11840000000001,-22.325400088301386,753],[-43.1185,-22.325500088695687,753],[-43.11860000000001,-22.325600089018323,753],[-43.11870000000001,-22.325700089269294,753],[-43.11880000000001,-22.325800089448563,753],[-43.118900000000004,-22.325900089556196,759],[-43.11900000000001,-22.32600008959214,759],[-43.1191,-22.3261000895564,759],[-43.1192,-22.326200089449003,750],[-43.1193,-22.326300089269925,750],[-43.119400000000006,-22.32640008901917,750],[-43.11950000000001,-22.32650008869674,750],[-43.119600000000005,-22.32660008830263,750],[-43.11970000000001,-22.326700087836848,773],[-43.119800000000005,-22.326800087299397,773],[-43.11990000000001,-22.32690008669026,773],[-43.120000000000005,-22.327000086009456,751],[-43.1201,-22.327100085256976,751],[-43.120200000000004,-22.327200084432818,751],[-43.120300000000015,-22.327300083536986,751],[-43.120400000000004,-22.327400082569472,751],[-43.12050000000001,-22.327500081530275,771],[-43.12060000000001,-22.32760008041941,771],[-43.12070000000001,-22.327700079236866,771],[-43.1208,-22.327800077982648,771],[-43.120900000000006,-22.32790007665674,753],[-43.121,-22.328000075259165,753],[-43.12110000000001,-22.3281000737899,753],[-43.12120000000001,-22.328200072248965,753],[-43.12130000000001,-22.328300070636345,753],[-43.12140000000001,-22.328400068952053,794],[-43.121500000000005,-22.32850006719608,794],[-43.12160000000001,-22.328600065368423,794],[-43.121700000000004,-22.328700063469086,794],[-43.1218,-22.32880006149807,794],[-43.121900000000004,-22.328900059455368,794],[-43.12200000000001,-22.329000057340988,794],[-43.12210000000001,-22.329100055154928,794],[-43.12220000000001,-22.329200052897182,803],[-43.12230000000001,-22.32930005056777,803],[-43.122400000000006,-22.329400048166654,803],[-43.12250000000001,-22.329500045693862,790],[-43.122600000000006,-22.329600043149394,790],[-43.1227,-22.32970004053324,790],[-43.12280000000001,-22.329800037845402,790],[-43.122900000000016,-22.329900035085892,790],[-43.123000000000005,-22.33000003225469,731],[-43.12310000000001,-22.330100029351797,731],[-43.12320000000001,-22.33020002637723,731],[-43.1233,-22.330300023330974,731],[-43.123400000000004,-22.330400020213023,744],[-43.12350000000001,-22.3305000170234,744],[-43.12360000000001,-22.330600013762087,744],[-43.12370000000001,-22.330700010429094,744],[-43.12380000000001,-22.330800007024415,744],[-43.12390000000001,-22.33090000354804,691],[-43.124,-22.331,691]]}
```

  - Buscando perfil (POST)

```
$ curl -XPOST -d '{"type": "LineString", "coordinates": [[-43.114,-22.321],[-43.124,-22.331]] }' http://localhost:7331/profile
$ curl -XGET http://localhost:7331/profile?route="[[-43.114,-22.321],[-43.124,-22.331]]"
{"profile":[[-43.114,-22.320999999999994,866],[-43.1141,-22.321100003547638,866],[-43.114200000000004,-22.321200007023617,888],[-43.1143,-22.321300010427944,888],[-43.114399999999996,-22.321400013760606,888],[-43.11450000000001,-22.321500017021606,888],[-43.1146,-22.321600020210937,888],[-43.114700000000006,-22.321700023328606,896],[-43.1148,-22.321800026374614,896],[-43.1149,-22.321900029348967,896],[-43.115,-22.322000032251644,912],[-43.1151,-22.32210003508267,912],[-43.1152,-22.32220003784202,912],[-43.115300000000005,-22.322300040529715,912],[-43.11540000000001,-22.32240004314575,912],[-43.115500000000004,-22.322500045690102,875],[-43.1156,-22.32260004816281,875],[-43.115700000000004,-22.322700050563835,875],[-43.11580000000001,-22.32280005289321,875],[-43.115899999999996,-22.322900055150896,882],[-43.116,-22.32300005733693,882],[-43.11610000000001,-22.323100059451303,882],[-43.116200000000006,-22.323200061494006,882],[-43.1163,-22.323300063465048,882],[-43.116400000000006,-22.323400065364414,837],[-43.1165,-22.323500067192125,837],[-43.1166,-22.32360006894815,837],[-43.1167,-22.323700070632523,840],[-43.116800000000005,-22.32380007224523,840],[-43.116899999999994,-22.32390007378626,840],[-43.117000000000004,-22.324000075255615,840],[-43.11710000000001,-22.324100076653316,840],[-43.117200000000004,-22.324200077979327,788],[-43.11730000000001,-22.32430007923369,788],[-43.1174,-22.324400080416385,788],[-43.1175,-22.324500081527404,788],[-43.1176,-22.324600082566747,791],[-43.1177,-22.324700083534427,791],[-43.1178,-22.32480008443043,791],[-43.117900000000006,-22.324900085254765,791],[-43.11800000000001,-22.32500008600744,751],[-43.118100000000005,-22.325100086688433,751],[-43.1182,-22.325200087297752,751],[-43.118300000000005,-22.32530008783541,751],[-43.11840000000001,-22.325400088301386,753],[-43.1185,-22.325500088695687,753],[-43.11860000000001,-22.325600089018323,753],[-43.11870000000001,-22.325700089269294,753],[-43.11880000000001,-22.325800089448563,753],[-43.118900000000004,-22.325900089556196,759],[-43.11900000000001,-22.32600008959214,759],[-43.1191,-22.3261000895564,759],[-43.1192,-22.326200089449003,750],[-43.1193,-22.326300089269925,750],[-43.119400000000006,-22.32640008901917,750],[-43.11950000000001,-22.32650008869674,750],[-43.119600000000005,-22.32660008830263,750],[-43.11970000000001,-22.326700087836848,773],[-43.119800000000005,-22.326800087299397,773],[-43.11990000000001,-22.32690008669026,773],[-43.120000000000005,-22.327000086009456,751],[-43.1201,-22.327100085256976,751],[-43.120200000000004,-22.327200084432818,751],[-43.120300000000015,-22.327300083536986,751],[-43.120400000000004,-22.327400082569472,751],[-43.12050000000001,-22.327500081530275,771],[-43.12060000000001,-22.32760008041941,771],[-43.12070000000001,-22.327700079236866,771],[-43.1208,-22.327800077982648,771],[-43.120900000000006,-22.32790007665674,753],[-43.121,-22.328000075259165,753],[-43.12110000000001,-22.3281000737899,753],[-43.12120000000001,-22.328200072248965,753],[-43.12130000000001,-22.328300070636345,753],[-43.12140000000001,-22.328400068952053,794],[-43.121500000000005,-22.32850006719608,794],[-43.12160000000001,-22.328600065368423,794],[-43.121700000000004,-22.328700063469086,794],[-43.1218,-22.32880006149807,794],[-43.121900000000004,-22.328900059455368,794],[-43.12200000000001,-22.329000057340988,794],[-43.12210000000001,-22.329100055154928,794],[-43.12220000000001,-22.329200052897182,803],[-43.12230000000001,-22.32930005056777,803],[-43.122400000000006,-22.329400048166654,803],[-43.12250000000001,-22.329500045693862,790],[-43.122600000000006,-22.329600043149394,790],[-43.1227,-22.32970004053324,790],[-43.12280000000001,-22.329800037845402,790],[-43.122900000000016,-22.329900035085892,790],[-43.123000000000005,-22.33000003225469,731],[-43.12310000000001,-22.330100029351797,731],[-43.12320000000001,-22.33020002637723,731],[-43.1233,-22.330300023330974,731],[-43.123400000000004,-22.330400020213023,744],[-43.12350000000001,-22.3305000170234,744],[-43.12360000000001,-22.330600013762087,744],[-43.12370000000001,-22.330700010429094,744],[-43.12380000000001,-22.330800007024415,744],[-43.12390000000001,-22.33090000354804,691],[-43.124,-22.331,691]]}
```

### WebSocket

  - Buscando altitude de um ponto
    - Payload: { "command": "point_altitude", "lat": <float>, "lon": <float> }
    - Resposta: Ver HTTP
  - Buscando perfil de uma rota
    - Payload: { "command": "route_profile", "route": <LineString GeoJSON> }
    - Resposta: Ver HTTP

## Arquitetura atual

O projeto está sendo construído com uma avaliação gradual das necessidades de quem vai usá-lo. A princípio, o cliente é o [trail-blazer][trail-blazer], que apresenta dois casos de uso para isto:

- Observar a altitude sob o mouse, como referência para o planejamento;
- Associar altitudes a rotas de planejamento, verificando assim se um plano de voo pode interceptar algum objeto (e se deve ser alterado para corrigir este fato).

O uso sob mouse depende de latência, que ainda está por verificar. Por ora, todos os tiles são carregados sob demanda em memória. A carga inicial de um ladrilho leva ~175ms, e as chamadas subsequentes são respondidas em 5,8ns.

Foi feita uma tentativa de pré-carregar todos os ladrilhos da América do Sul, que rapidamente se mostrou proibitiva (abandonada depois de superar os 8GB de memória física). A carga sob demanda tenderá a cair no mesmo problema à medida que cresça o uptime da instância e a área de uso, mas a expectativa inicial é que, na prática, possamos ficar um bom tempo sem problemas por conta da área restrita de aplicação nos primeiros momentos.

Caso tenhamos problemas com isto, podemos partir para duas abordagens diferentes:

1. R-Tree com processamento out-of-memory (que pode ser vantajoso com SSDs) ou
2. PostGIS + nearest neighbor.


[srtm]: http://www2.jpl.nasa.gov/srtm/
[trail-blazer]: https://github.com/prodec/trail-blazer
