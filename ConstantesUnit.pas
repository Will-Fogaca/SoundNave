// Unit com definição de constantes usadas no jogo
unit ConstantesUnit;

interface

const
  // Fim de linha Windows
  CRLF = AnsiString(#13#10);
  // Cabeçalho do arquivo de pontuações
  CABECALHO_ARQ_PONT = 'PONTUAÇÕES' + CRLF + '==========================' + CRLF;
  // Constantes de identificação de elementos interativos
  ID_JOGADOR = 1;
  ID_TIRO_JOGADOR = 2;
  ID_INIMIGO = 3;
  ID_TIRO_INIMIGO = 4;
  // Constantes de configuração de aliens
  TAMANHO_SPRITE = 32;
  FATOR_N_ALIENS = 30;
  // Constantes de zona de aparecimento dos aliens
  ZONA_CIMA = 1;
  ZONA_BAIXO = 2;
  ZONA_ESQUERDA = 3;
  ZONA_DIREITA = 4;
  // Constante com intervalo de ciclo de processamento
  INTERVALO_PROCESSAMENTO_MS = 25;
  // Constante com o caminho base para os recursos do jogo
  CAMINHO_RECURSOS_PROJETO = '../../Recursos/';
  CAMINHO_RECURSOS = 'Recursos/';
  // Arquivos textuais fixos
  ARQ_MANUAL = 'manual.txt';
  ARQ_PONTUACOES = 'pontuacoes.txt';
  // Constantes com nomes de arquivos de controle
  ARQ_DADOS_XML = 'dados.xml';
  // Constantes para manipulação de tags XML
  TAG_CONTROLE_PAUSA = 'controle_pausa';
  TAG_CONTROLE_MOVIMENTO_FUNDO = 'controle_movimento_fundo';
  TAG_CONTROLE_MOVIMENTO = 'controle_movimento';
  TAG_CONTROLE_TIRO_LANCADO = 'controle_tiro_lancado';
  TAG_CONTROLE_LIMITE_TIROS_INIMIGOS = 'controle_limite_tiros_inimigos';
  TAG_CONTROLE_N_FASE = 'controle_n_fase';
  TAG_CONTROLE_CONT_ALIENS = 'controle_cont_aliens';
  TAG_CONTROLE_PONTOS = 'controle_pontos';
  TAG_CONTROLE_ENERGIA_MAX = 'controle_energia_max';
  TAG_CONTROLE_CONT_ENERGIA = 'controle_cont_energia';
  TAG_CONTROLE_VIDAS = 'controle_vidas';
  TAG_CONTROLE_INVENCIVEL = 'controle_invencivel';
  TAG_CONTROLE_TEMPO_DE_JOGO = 'controle_tempo_de_jogo';
  TAG_HISTORICO_DATA = 'hist_data';
  TAG_HISTORICO_TEMPO = 'hist_tempo';
  TAG_HISTORICO_PONT_PRE = 'hist_pont_pre';
  TAG_HISTORICO_PONT_POS = 'hist_pont_pos';
  TAG_FASE_ATUAL_CAMINHO_MUSICA = 'fase_atual_caminho_musica';
  TAG_FASE_ATUAL_HISTORIA = 'fase_atual_historia';
  TAG_FASE_ATUAL_ORIGEM_CIMA = 'fase_atual_origem_cima';
  TAG_FASE_ATUAL_ORIGEM_BAIXO = 'fase_atual_origem_baixo';
  TAG_FASE_ATUAL_ORIGEM_ESQUERDA = 'fase_atual_origem_esquerda';
  TAG_FASE_ATUAL_ORIGEM_DIREITA = 'fase_atual_origem_direita';
  TAG_SESSAO_ESTADO = 'sessao_estado';
  TAG_SESSAO_RESTAURAR = 'sessao_restaurar';

implementation

end.
