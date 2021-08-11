// representa uma data e hora (timestamp do PostgreSQL)
type DataHora = {};

// representa uma quantidade de tempo, uma duração (interval do PostgreSQL)
type DuracaoDeTempo = {};

// coordenada geográfica em um ponto no mapa, latitude e longitude
type CoordenadaGeografica = {};

// azimute, direção de uma bússola, um ângulo/numero de 0 graus a 360 graus,
// usado para apontar a direção em que um ponto geográfico está apontando
type Azimute = {};

type PontosLinha {
  localizacaoPontoOnibus: CoordenadaGeografica;
  azimute: Azimute;
}

type CoordenadaComDataHora {
  coordenada: CoordenadaGeografica;
  dataHora: Date;
}

type MovimentacaoOnibusEmLinhaComDados {
  inicio: CoordenadaComDataHora;
  fim: CoordenadaComDataHora;
  distanciaAtePonto: MenorDistanciaEntrePontoELinha[];
  azimute: Azimute;
}

type MenorDistanciaEntrePontoELinha {
  distancia: number;
  coordenada: CoordenadaGeografica;
  dataHora: DataHora;
}

/**
 * Função st_closestpoint do PostGIS https://postgis.net/docs/manual-dev/ST_ClosestPoint.html
 * Dado um ponto p1, e uma outra geometria g1 (linha, poligono, area, etc)
 * Retorna um ponto dentro dos limites de g1 que esteja mais próximo o possível de p1
 */
function st_closestpoint(
  ponto: CoordenadaGeografica,
  linhaInicio: CoordenadaGeografica,
  linhaFim: CoordenadaGeografica
): CoordenadaGeografica;

/**
 * Função st_distance do PostGIS https://postgis.net/docs/ST_Distance.html
 * retorna a distancia em metros de um ponto até outro
 */
function st_distance(
  pontoInicio: CoordenadaGeografica,
  pontoFim: CoordenadaGeografica
): number;

/**
 * Dado dois timestamps, retorna o tempo (INTERVAL do PostgreSQL) que há entre eles
 */
function duracaoEntreTimestamps(
  inicio: DataHora,
  fim: DataHora
): DuracaoDeTempo;

/**
 * Dado um timestamp e uma duração de tempo (INTERVAL do PostgreSQL), retorna o timestamp somado
 * com a duração informada
 */
function dataMaisDuracao(inicio: DataHora, duracao: DuracaoDeTempo): Date;

/**
 * Dado um timestamp e uma duração de tempo (INTERVAL do PostgreSQL), retorna o timestamp subtraido
 * com a duração informada
 */

function dataMenosDuracao(inicio: DataHora, duracao: DuracaoDeTempo): Date;

function calcularAzimute(
  coordenadaInicio: CoordenadaGeografica,
  coordenadaFim: CoordenadaGeografica
): Azimute;

/**
 * Retorna a coordenada geográfica sobre uma linha onde tem-se a menor distância até um ponto informado.
 * Retorna também o horário estimado no ponto de menor distância informado.
 */
function menorDistanciaEntrePontoELinha(
  ponto: CoordenadaGeografica,
  linhaInicio: CoordenadaComDataHora,
  linhaFim: CoordenadaComDataHora
): MenorDistanciaEntrePontoELinha {
  var pontoMenorDistancia = st_closestpoint(
    ponto,
    linhaInicio.coordenada,
    linhaFim.coordenada
  );

  var distanciaAtePontoMaisProximo = st_distance(
    linhaInicio.coordenada,
    pontoMenorDistancia
  );
  var distanciaTotal = st_distance(linhaInicio.coordenada, linhaFim.coordenada);
  var razao = distanciaAtePontoMaisProximo / distanciaTotal;
  var duracaoInicioAteFim = duracaoEntreTimestamps(
    linhaFim.dataHora,
    linhaInicio.dataHora
  );
  var dataHoraEstimada = dataMaisDuracao(
    linhaInicio.dataHora,
    duracaoInicioAteFim * razao
  );

  return {
    distancia: distanciaAtePontoMaisProximo,
    coordenada: pontoMenorDistancia,
    dataHora: dataHoraEstimada,
  };
}

function iniciarAlgoritmo() {
  // Essa é a tabela veiculos, que contém a movimentação de um ônibus em uma linha específica
  var movimentacaoOnibus: CoordenadaComDataHora[];
  // Essa é a tabela pontosLinha, que contém os pontos de ônibus de uma linha específica
  var pontosDeOnibus: PontosLinha[];

  // Vetor que guardará as linhas de movimentação do ônibus (ao invés de pontos):
  var movimentacaoOnibusEmLinhaComDados: MovimentacaoOnibusEmLinhaComDados[];

  for (var i = 0; i < movimentacaoOnibus.length - 1; i++) {
    var menoresDistancias: MenorDistanciaEntrePontoELinha[];
    var inicio = movimentacaoOnibus[i];
    var fim = movimentacaoOnibus[i + 1];
    var azimute = calcularAzimute(inicio.coordenada, fim.coordenada);

    for (var j = 0; j < pontosDeOnibus.length; j++) {
      menoresDistancias[j] = menorDistanciaEntrePontoELinha(
        pontosDeOnibus[j].localizacaoPontoOnibus,
        inicio,
        fim
      );
    }

    movimentacaoOnibusEmLinhaComDados[i] = {
      inicio: inicio,
      fim: fim,
      azimute: azimute,
      distanciaAtePonto: menoresDistancias,
    };
  }

  // Duracao limite de tempo para criar a janela
  var duracaoLimite: DuracaoDeTempo = "3 minutos";

  for (var i = 0; i < movimentacaoOnibusEmLinhaComDados.length; i++) {
    var movimentoAtual: MovimentacaoOnibusEmLinhaComDados =
      movimentacaoOnibusEmLinhaComDados[i];
    var movimentosOnibusAtras: MovimentacaoOnibusEmLinhaComDados[];
    var movimentosOnibusAFrente: MovimentacaoOnibusEmLinhaComDados[];

    var eValida = true;

    for (var j = i - 1; j >= 0; j--) {
      var movSelecionada = movimentacaoOnibusEmLinhaComDados[j];
      var dataHoraLimite = dataMenosDuracao(
        movimentoAtual.inicio.dataHora,
        duracaoLimite
      );
      if (movSelecionada.inicio.dataHora > dataHoraLimite) {
        movimentosOnibusAtras.push(movSelecionada);
      }
    }

    for (var j = i + 1; j < movimentacaoOnibusEmLinhaComDados.length; j++) {
      var movSelecionada = movimentacaoOnibusEmLinhaComDados[j];
      var dataHoraLimite = dataMaisDuracao(
        movimentoAtual.inicio.dataHora,
        duracaoLimite
      );
      if (movSelecionada.inicio.dataHora < dataHoraLimite) {
        movimentosOnibusAFrente.push(movSelecionada);
      }
    }

    /*
    - Aqui a janela de tempo está montada
    - Agora é preciso descobrir:
    se pontos de ônibus em que movimentoAtual é o ponto mais próximo quando comparado aos
    movimentosOnibusAtras e movimentosOnibusAFrente
    se a distância em movimentoAtual for menor que 15m
    se o azimute do movimentoAtual está em um limite de 45 graus para esquerda ou para direita em relação ao azimute do ponto de ônibus
    Se todos essas condições forem verdadeiras, o movimentoAtual faz match no ponto de ônibus comparado
    ...
    */
  }
}
