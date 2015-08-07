# suchgreatheights

Este serviço provê conversão de posições no mundo para altitudes retiradas dos arquivos gerados pela missão de topografia por radar da NASA, a [SRTM][srtm]. A qualidade dos resultados daqui depende, portanto, do que é oferecido por esses dados &mdash; no nosso caso, os arquivos da missão SRTM3, em que cada dado no arquivo binário abarca 3 arco-segundos de informação.

Há dois pontos de entrada, apenas:

- `point_altitude(lng, lat)`: recebe longitude e latitude como Floats e retorna a altitude
- `route_profile(route)`: recebe uma rota como LineString GeoJSON e retorna uma altitude para cada ponto

## Rodando

    $ bundle install
    $ bin/server

O serviço abrirá na porta 7331, e responderá tanto por WebSocket quanto por HTTP.

## Usando

### HTTP

#### JSON de Altitude
  - **[GET]**: `/altitude?lat=<float>&lng=<float>` - retorna JSON com a estrutura

```
{ altitude: <float> }
```

#### JSON de Perfil
  - **[GET]**: `/profile?route=<json array>` - retorna JSON com a seguinte estrutura

```
{ profile: [[<float>, <float>, <float>]...]}
```

  - **[POST]**: `/profile`, payload: LineString GeoJSON - retorna JSON com a seguinte estrutura

```
{ profile: [[<float>, <float>, <float>]...]}
```

#### Exemplos

  - Buscando altitude de um ponto (GET)

```
$ curl -XGET http://localhost:7331/altitude\?lng\=-42.123123\&lat\=-21.98888
{"altitude":287}
```

  - Buscando perfil (GET)

```
$ curl -XGET http://localhost:7331/profile?route="[[-43.114,-22.321],[-43.124,-22.331]]"
{"profile":[[-43.114,-22.320999999999994,866],...]}
```

  - Buscando perfil (POST)

```
$ curl -XPOST -d '{"type": "LineString", "coordinates": [[-43.114,-22.321],[-43.124,-22.331]] }' http://localhost:7331/profile
$ curl -XGET http://localhost:7331/profile?route="[[-43.114,-22.321],[-43.124,-22.331]]"
{"profile":[[-43.114,-22.320999999999994,866],...]}
```

### WebSocket

  - Buscando altitude de um ponto
    - Payload: `{ "command": "point_altitude", "sent_at": <timestamp>, "payload": { "lat": <float>, "lng": <float> } }`
    - Resposta: `{ "response": "route_profile", "client_sent_at": <timestamp>, "processed_at": <timestamp>, "data": { "altitude": <number> } }` [Ver HTTP](#json-de-altitude)
  - Buscando perfil de uma rota
    - Payload: `{ "command": "route_profile", "sent_at": <timestamp>, "payload": { "route": <LineString GeoJSON> } }`
    - Resposta: `{ "response": "route_profile", "client_sent_at": <timestamp>, "processed_at": <timestamp>, "data": { "profile": <Ver HTTP> } }` ([Ver HTTP para formato do perfil](#json-de-perfil))
  - *Heartbeat*
    - Payload: `{ "command": "ping", "sent_at": <timestamp> }`
    - Resposta: `{ "response": "ping", "client_sent_at": <timestamp>, "processed_at": <timestamp> }`

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
