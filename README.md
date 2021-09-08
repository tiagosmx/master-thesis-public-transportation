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
Dado um array de MOL (MOL[]) ordenado de forma crescente em MO_TEMPO_1
     
PARA i DE 0 ATÉ tamanho de MOL[] PASSO 1 FAÇA:
  PARA j DE 0 ATÉ tamanho de POA[] PASSO 1 FAÇA:
    E_MENOR <- VERDADEIRO
    SE PO_LINHA_ONIBUS = MOL[i] MO_LINHA_ONIBUS
    E MOL[i].MOL_DIRECAO >= (DIFERENÇA_ANGULO - POA[k] POA_DIRECAO) 
    E MOL[i].MOL_DIRECAO <=  (DIFERENCA_ANGULO + POA[k] POA_DIRECAO)
    E distância em metros entre MOL[i].MO_SEGMENTO_LINHA_COORD e POA[j].PO_COORD < DISTANCIA_MINIMA
    ENTAO
    PARA k DE 0 ATÉ tamanho de MOL[] PASSO 1 FAÇA:
      SE PO_LINHA_ONIBUS = MOL[k] MO_LINHA_ONIBUS
      E MOL[k].MO_TEMPO_1 >= MOL[i].MO_TEMPO_1 - JANELA_DE_TEMPO
      E MOL[k].MO_TEMPO_1 <= MOL[i].MO_TEMPO_1 + JANELA DE TEMPO
      E i != k
      E distância em metros entre MOL[k].MO_SEGMENTO_LINHA_COORD e POA[j].PO_COORD < DISTANCIA_MINIMA
      E MOL[k].MOL_DIRECAO >= (DIFERENÇA_ANGULO - POA[k] POA_DIRECAO) 
      E MOL[k].MOL_DIRECAO <=  (DIFERENCA_ANGULO + POA[k] POA_DIRECAO)
      ENTAO
      SE distância em metros entre MOL[k].MO_SEGMENTO_LINHA_COORD e POA[j].PO_COORD < distância em metros entre MOL[i].MO_SEGMENTO_LINHA_COORD e POA[j].PO_COORD
      ENTAO
      E_MENOR <- FALSO
    FIM PARA
    SE E_MENOR = VERDADEIRO 
    ENTAO 
    Adicione MOL[i] e seu POA[k] juntos em um novo array chamado PASSAGENS_DE_ONIBUS
  FIM PARA
FIM PARA
O array PASSAGENS_DE_ONIBUS conterá uma lista com os momentos em que algoritmo detectou uma passagem de ônibus em um determinado ponto de ônibus.
```
