# Algoritmo 1: Descoberta de Azimutes

Tipos de dados:

ShapeLinha {
id: inteiro
bus_line_id: inteiro
shp: inteiro
lat: real
lon: real
}

ShapeLinhaEmLinha {
bus_line_id: inteiro
shp: inteiro
lat: real
lon: real
}

PontoLinha {
bus_line_id: inteiro
bus_stop_id: inteiro
lat: real
lon: real
way: texto
seq: inteiro
}

PontsLinhaAzimute {
todas as em PontoLinha...
azimuth: real
}

Entradas:
lsl: Lista de ShapeLinha
lpl: Lista de PontosLinha

Declarações de variáveis:
lspl: Lista de ShapePolilinhas
linha: linha geográfica

Saída:
lpla: Lista de PontsLinhaAzimute

Inicio:

para i de 1 até tamanho de lsl faça:
se lspl[i] existir e lspl[i+1] também
linha = criarLinhaGeografica(
lspl[i].lat, lspl[i].lon, plp[i].lat, plp[i].lon
)
se lspl[i].

para i de 1 até tamanho de shapeLinha faça:

# Código que a professora fez:

Algorithm 2 Criação Dados Azimute
0: procedure AZIMUTE(𝑝𝑜𝑛𝑡𝑜𝑠𝑙𝑖𝑛ℎ𝑎,𝑠ℎ𝑎𝑝𝑒𝑙𝑖𝑛ℎ𝑎*𝑛, 𝑝𝑜𝑛𝑡𝑜𝑠𝑙𝑖𝑛ℎ𝑎𝑎𝑧𝑖𝑚𝑢𝑡𝑒)
0: enquanto 𝑠ℎ𝑎𝑝𝑒𝑙𝑖𝑛ℎ𝑎 em 𝑠ℎ𝑎𝑝𝑒𝑙𝑖𝑛ℎ𝑎*𝑛 faça
0: enquanto 𝑝𝑜𝑛𝑡𝑜 em 𝑝𝑜𝑛𝑡𝑜𝑠𝑙𝑖𝑛ℎ𝑎 faça
0: 𝑝𝑜𝑙𝑖𝑙𝑖𝑛ℎ𝑎 ← 𝑠𝑒𝑔𝑚𝑒𝑛𝑡𝑎𝑟*𝑠ℎ𝑎𝑝𝑒𝑓𝑖𝑙𝑒(𝑠ℎ𝑎𝑝𝑒𝑙𝑖𝑛ℎ𝑎)
0: enquanto 𝑠𝑒𝑛𝑡𝑖𝑑𝑜 em 𝑠ℎ𝑎𝑝𝑒𝑙𝑖𝑛ℎ𝑎*𝑛 faça
0: 𝑑𝑖𝑠𝑡𝑎𝑛𝑐𝑖𝑎𝑝𝑜𝑛𝑡𝑜 ← 𝑐𝑎𝑙𝑐𝑢𝑙𝑎𝑟*𝑑𝑖𝑠𝑡𝑎𝑛𝑐𝑖𝑎(𝑝𝑜𝑛𝑡𝑜,𝑝𝑜𝑙𝑖𝑙𝑖𝑛ℎ𝑎)
0: se 𝑑𝑖𝑠𝑡𝑎𝑛𝑐𝑖𝑎𝑝𝑜𝑛𝑡𝑜 é menor então
0: 𝑠𝑒𝑛𝑡𝑖𝑑𝑜𝑠*𝑠ℎ𝑎𝑝𝑒𝑖𝑑 ← (𝑠ℎ𝑎𝑝𝑒𝑙𝑖𝑛ℎ𝑎)
0: 𝑠ℎ𝑎𝑝𝑒𝑙𝑖𝑛ℎ𝑎*𝑎𝑧𝑖𝑚𝑢𝑡𝑒 ← 𝑐𝑎𝑙𝑐𝑢𝑙𝑎*𝑎𝑧𝑖𝑚𝑢𝑡𝑒(𝑠ℎ𝑎𝑝𝑒𝑙𝑖𝑛ℎ𝑎)
0: 𝑝𝑜𝑛𝑡𝑜𝑠𝑙𝑖𝑛ℎ𝑎*𝑎𝑧𝑖𝑚𝑢𝑡𝑒 ← 𝑐𝑜𝑟𝑟𝑒𝑙𝑎𝑐𝑖𝑜𝑛𝑎(𝑝𝑜𝑛𝑡𝑜𝑠𝑙𝑖𝑛ℎ𝑎, 𝑠ℎ𝑎𝑝𝑒𝑙𝑖𝑛ℎ𝑎*𝑎𝑧𝑖𝑚𝑢𝑡𝑒,𝑠𝑒𝑛𝑡𝑖𝑑𝑜𝑠*𝑠ℎ𝑎𝑝𝑒𝑖𝑑)
0: Return 𝑝𝑜𝑛𝑡𝑜𝑠𝑙𝑖𝑛ℎ𝑎*𝑎𝑧𝑖𝑚𝑢𝑡𝑒

# Código simplificado

```
função ordenar(tabela, nomeDaColuna, ordem):
    ordena a tabela com base na coluna nomeDaColuna usando a ordem (que pode ser crescente ou decrescente)
    retorna tabela ordenada

função criarLinhaGeográfica(pontoGeografico1, pontoGeografico2):
    cria uma linha geográfica a partir de dois pontos geográficos
    retorna linha geográfica

função criarPontoGeográfico(latitude, longitude):
    cria uma um ponto geográfico a partir de latitude e longitude
    retorna ponto geográfico

função calcularTamanhoDaTabela(tabela):
    calcula o tamanho da tabela em quantidade de linhas
    retorna a quantidade de linhas da tabela

função calcularAzimute(pontoGeografico1, pontoGeografico2):
    calcula o ângulo (em radianos), com relação ao norte cartográfico, ao qual um observador
    se coloca ao estar no pontoGeografico1 e olhar em linha reta para o pontoGeografico2
    retorna o azimute em radianos

função agregação agregarPontosEmPolilinhas(nomeDaColuna, nomeDaColunaNova):
    dentro de uma função agregarPorGrupo, na tabela por ela determinada
    percorre todos os elementos da coluna nomeDaColuna e une-os em um só
    novo elemento, transformando vários pontos geográficos em uma polilinha
    e salva-a na tabela com nome definido em nomeDaColunaNova
    retorna uma tabela com valores agregados

função agregarPorGrupo(tabela, funçõesDeAgregação, colunasDeAgrupamento):
    percorre a tabela infomada em tabela agrupando suas linhas com base nas
    colunasDeAgrupamento e aplicando as funções de agregação nas colunas informadas
    em funçõesDeAgregação e criando novas colunas com base nelas
    transforma uma tabela com uma coluna de ponto geográfico em uma tabela com
    todos esses pontos unidos em uma única polilinha usando como limites desta
    polilinha as colunas contidas em colunasDeAgregação
    retorna uma tabela com uma coluna polyline e as colunas informadas em colunasDeAgregação

função agregarSoma(nomeDaColuna, nomeDaColunaNova)
    soma todos os valores presentes em uma coluna desde que pertençam
    a mesma combinação de valores nas colunas de colunasDeAgregação

função criarNovaColuna(tabela, nomeNovaColuna, função)
    cria uma nova coluna em uma tabela aplicando uma função como base
    esta função pode usar outras colunas da tabela como operação
    retorna uma tabela com as colunas originais e a nova coluna

função menorDistanciaEntreElementosGeograficos(elementoGeografico1, elementoGeografico2):
    calcula a menor distância entre dois elementos geográficos que podem ser
    do tipo ponto, linha, polilinha usando a fórmula de Vincenty em metros


início do algoritmo:

parâmetros de entrada (tabela shapeLinha, tabela pontosLinha)
parâmetros de saída (tabela pontosLinhaComAzimutes)

//Colocar no maximo uma ou duas linhas explicando a função

shapeLinha ← ordenar(shapeLinha, id, crescente)
shapeLinha ← ordenar(shapeLinha, bus_line_id, crescente)
shapeLinha ← ordenar(shapeLinha, path_id, crescente)
shapeLinha ← criarNovaColuna(shapeLinha, geo_point, criarPontoGeográfico(lat, lon))
shapePolilinha ← agregarPorGrupo(shapeLinha, agregarPontosEmPolilinhas(geo_point, polylines),[bus_line_id, path_id])
pontosLinha ← criarNovaColuna(pontosLinha, geo_point, criarPontoGeográfico(lat, lon))
para i de 1 até calcularTamanhoDaTabela(shapePolilinha) passo 1 faça
    para j de 1 até calcularTamanhoDaTabela(pontosLinha) passo 1 faça
        se pontosLinha[bus_line_id] = shapePolilinha[bus_line_id]
            shapePolilinhaPontos ← shapePolilinha[i] + pontosLinha[j]
            shapePolilinhaPontos[distance] ← menorDistanciaEntreElementosGeograficos(
                shapePolilinha[i][polylines], pontosLinha[j][geo_point]
            )
        fim se
    fim para
fim para
shapePolilinhaPontosSoma ← agregarPorGrupo(shapePolilinhaPontos, [agregarSoma(distance, sum_distance)],[bus_line_id])
para i de 1 até calcularTamanhoDaTabela(shapePolilinhaPontosSoma) passo 1 faça:
    minDistanceShapePolilinhaPontos[bus_line_id][] ←

```

1 - com a tabela `shapeLinha'', transforme todos os pontos de um mesmo identificador de shape (SHP, shape id) em uma polilinha, que representará todo o segmento de trajeto de uma linha (o caminho completo do terminal X até terminal Y), representado pelas polilinhas de cores distintas da Figura \ref{fig:shape-linha-216};

2 - a partir da tabela `pontosLinha'', meça a menor distância de cada ponto de ônibus para cada polilinha em `shapeLinha'' identificadas por seu SHP; com o dado anterior, realize uma agregação e some as distâncias agrupadas em cada shape id (SHP) e cada sentido (SENTIDO);

3 - para cada sentido (SENTIDO), escolha o shape id (SHP) em que a soma das distâncias seja a menor entre os outros shape ids, neste ponto já é possível saber qual SHP em `shapeLinha'' equivale a cada sentido (SENTIDO) em `pontosLinha''; crie uma tabela `sentidos + shape id'' com o resultado anterior;

4- utilizando a tabela `shapeLinha'' calcule o azimute de cada segmento de trajeto, semelhante às setas da Figura \ref{fig:shape-linha-216} e armazene-o crie uma nova tabela chamada `shapeLinha + azimutes'' com os dados da etapa anterior; correlacione a tabela `pontosLinha'' com a `shapeLinha + azimutes'' usando a `sentidos + shape id''. Neste momento cada ponto de ônibus já contém um azimute. salve os dados da etapa anterior em uma nova tabela chamada `pontosLinha + azimutes''

1 - A entrada do algoritmo são as tabelas shapeLinha e pontosLinha
2 - Com a tabela shapeLinha, crie uma coluna 'point' formada pelas coordenadas geográficas em 'lat' e 'lon'

-- legado::::
para i de 1 até calcularTamanhoDaTabela(shapeLinha) - 1 passo 1 faça
proximaLinha ← shapeLinha[i+1][bus_line_id]
proximoTrajeto ← shapeLinha[i+1][path_id]
se proximaLinha = shapeLinha[i][bus_line_id] então:
se proximoTrajeto = shapeLinha[i][path_id] então:
geo_point1 ← criarPontoGeográfico(shapeLinha[i][lat], shapeLinha[i][lon])
geo_point2 ← criarPontoGeográfico(shapeLinha[i+1][lat], shapeLinha[i+1][lon])
shapeLinha[i][geo_line] ← criarLinhaGeográfica(geo_point1, geo_point2)
shapeLinha[i][azimuth] ← calcularAzimute(geo_point1, geo_point2)
fim se
fim se
