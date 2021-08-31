# urbs-bus-analysis
Scripts for bus analysis

# Apresentação do software

https://docs.google.com/presentation/d/1_XdgXtFf_zjTPtN2BC2zSDYM9KpuybQBHJZRku1m1kY/

# Bibliotecas / Softwares de Map Matching prontas

## Barefoot - Java

https://github.com/bmwcarit/barefoot
https://github.com/bmwcarit/barefoot/wiki

Requer:

PostgreSQL
PostGIS
Osmosis (converter dados OSM e escrever no banco, utiliza Java)
Python
Mapas do OpenStreetMap

## FMM (Fast Map Matching) - C++ / Python

https://github.com/cyang-kth/fmm

https://fmm-wiki.github.io/

## PgMapMatch ##
Requer:
PostgreSQL
PostGIS
pgRouting
Python
Download de mapa do OpenStreetMap

https://github.com/amillb/pgMapMatch

Faz offline map matching.

Mais lento (mas mais preciso) que o GraphHopper.

## Leuven Map Matching ##
Requer:
Python
Download de mapa do OpenStreetMap

https://github.com/wannesm/LeuvenMapMatching
https://leuvenmapmatching.readthedocs.io/en/latest/

## Valhalla (Antigo Mapzen) ##

https://github.com/valhalla/valhalla

## Project OSRM (Open Source Routing Machine) ##

Requer:
C++
NodeJS (Wrapper em cima do C++)

https://github.com/Project-OSRM/osrm-backend

Curti!

## GraphHopper ##
Requer:

Java 8

https://github.com/graphhopper/map-matching



## Comparação entre soluções prontas

https://gis-ops.com/open-source-routing-engines-and-algorithms-an-overview/

# Explicação dos Algoritmos

Este trabalho consiste em 2 algoritmos:

- Algoritmo 1 que descobre os azimutes dos pontos de ônibus.

Este algoritmo descobre em que direção geográfica (azimute de 0° a 360°) o ônibus está quando este passa por determinado ponto de ônibus. E por quê esta informação é importante? Porque ela não existe no dataset e pontos de ônibus de uma mesma linha de operação podem estar um na frente do outro (principalmente em ruas de mão dupla) o que dificulta distinguir se um ônibus passou por este ponto no sentido correto da rua ou não quando a análise for simplesmente por proximidade. 

- Algoritmo 2 que descobre o horário de passagem dos ônibus em cada ponto de ônibus de sua linha de operação.

Este algoritmo descobre em que momento do tempo um ônibus passou por um ponto de ônibus de sua atual linha de operação.

Glossário, definição de termos e estruturas.

PO, representa todos os dados de um ponto de ônibus em uma linha de ônibus em um sentido de seu trajeto, contendo: 

- PO_ID id do ponto de ônibus 
- PO_COORD coordenada geográfica do ponto de ônibus, 
- PO_SENTIDO sentido, ponto de ônibus final do trajeto em que este ponto de ônibus faz parte, 
- PO_SEQ ordem de visitação deste ponto de ônibus dentro do trajeto, 
- PO_LINHA_ONIBUS linha de ônibus referente a este ponto de ônibus. 

POA, representa os mesmos dados de PO mas com o adicional:

- POA_DIRECAO um ângulo de 0° a 360° que representa a direção ou azimute que o ônibus têm quando passa por esse ponto de ônibus (útil para discriminar em que lado da rua este ônibus está)

SH, representa um segmento de linha que compõe o trajeto do ônibus

- SH_ID id do segmento de linha
- SH_SEGMENTO_LINHA_COORD coordenadas geográficas deste segmento de linha
- SH_ID_TRAJETO id do trajeto em que este segmento de linha está inserido

MO, representa a movimentação espaço-temporal do ônibus, contendo:

- MO_LINHA_ONIBUS linha de ônibus sendo operada por este ônibus 
- MO_ONIBUS código de identificação do ônibus
- MO_TEMPO data e hora no tempo da medição
- MO_COORD localização geográfica do ônibus

MOL, representa um par de MO, formando um segmento de linha da movimentação espaço-temporal consecutiva de um mesmo ônibus MO_ONIBUS operando uma mesma linha de ônibus MO_LINHA_ONIBUS, contendo:

- MO_LINHA_ONIBUS
- MO_ONIBUS
- MO_TEMPO_1
- MO_TEMPO_2
- MO_COORD_1
- MO_COORD_2
- MO_SEGMENTO_LINHA_COORD segmento de linha composto por MO_COORD_1 e MO_COORD_2
- MOL_DIRECAO um ângulo de 0° a 360° que representa direção (ou azimute) em que o ônibus está se movendo

## Explicação do Algoritmo 2

Defina 3 parâmetros:

- DISTANCIA_MÍNIMA, por padrão 20m
- JANELA_DE_TEMPO, por padrão 5 minutos
- DIFERENÇA_ANGULO, por padrão 45 graus

```
Dado um array de MOL ordenado de forma crescente em MO_TEMPO_1
Para cada MOL i
  Para cada MOL j onde 
  MOL j MO_TEMPO_1 estiver entre MOL i MO_TEMPO_1 - JANELA_DE_TEMPO e MOL_TEMPO_1 + JANELA_DE_TEMPO
    Para cada POA k, onde 
    PO_LINHA_ONIBUS = MOL i e j MO_LINHA_ONIBUS 
    e distância em metros entre MOL i e j MO_SEGMENTO_LINHA_COORD e PO_COORD for menor que DISTANCIA_MÍNIMA 
    e MOL i e j MOL_DIRECAO estiver entre DIFERENÇA_ANGULO - POA_DIRECAO e DIFERENCA_ANGULO + POA_DIRECAO
    e se distância em metros entre MOL i MO_SEGMENTO_LINHA_COORD e PO_COORD for a menor distância entre todos MOL j MO_SEGMENTO_LINHA_COORD e PO_COORD
    Adicione MOL i e seu PO em um novo array chamado PASSAGENS_DE_ONIBUS

O array PASSAGENS_DE_ONIBUS conterá uma lista com os momentos em que algoritmo detectou uma passagem de ônibus em um determinado ponto de ônibus.
```
