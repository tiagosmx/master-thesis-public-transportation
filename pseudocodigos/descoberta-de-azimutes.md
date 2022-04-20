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

início do algoritmo:
shapeLinha ← ordenar(shapeLinha, id, crescente)
shapeLinha ← ordenar(shapeLinha, bus_line_id, crescente)
shapeLinha ← ordenar(shapeLinha, path_id, crescente)
para i de 1 até calcularTamanhoDaTabela(shapeLinha) - 1 passo 1 faça
    se linhaAnterior = shapeLinha[i][bus_line_id] então:
        se trajetoAnterior = shapeLinha[i][path_id] então:
            geo_point1 ← criarPontoGeográfico(shapeLinha[i][lat], shapeLinha[i][lon])
            geo_point2 ← criarPontoGeográfico(shapeLinha[i+1][lat], shapeLinha[i+1][lon])
            geo_line ← criarLinhaGeográfica(geo_point1, geo_point2)
            shapeLinha[i][geo_line] ← geo_line
        fim se
    fim se
    linhaAnterior ← shapeLinha[i][bus_line_id]
    trajetoAnterior ← shapeLinha[i][path_id]
```
