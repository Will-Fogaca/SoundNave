unit PrincipalUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, Vcl.MPlayer,
  ConstantesUnit, XMLManipUnit, ArquivosUnit, FaseUnit, AlienUnit, JanelinhaUnit, RegPontuacaoUnit, HistoricoUnit,
  Winapi.ActiveX, MMSystem, System.Classes;

type
  Tform_principal = class(TForm)
    painel: TPanel;
    nave: TImage;
    processamento: TTimer;
    tiro: TPanel;
    pontuacao: TLabel;
    energia: TLabel;
    fundo1: TImage;
    fundo2: TImage;
    icone_vida: TImage;
    visor_vidas: TLabel;
    tocador: TMediaPlayer;
    sons: TMediaPlayer;
    ctrl_tocador: TTimer;
    hitbox: TPanel;
    barreira: TPanel;
    cronometro: TTimer;
    tmr_aviso_colisao: TTimer;
    sons_direcionais: TMediaPlayer;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure processamentoTimer(Sender: TObject);
    procedure ctrl_tocadorTimer(Sender: TObject);
    procedure cronometroTimer(Sender: TObject);
    procedure tmr_aviso_colisaoTimer(Sender: TObject);
  private
    function  criar_alien: Alien;
    procedure atirar;
    procedure tratar_tiro_jogador;
    procedure tratar_colisoes;
    function  deu_colisao(a, b: TComponent): Boolean;
    function  testar_colisao(a, b: TControl): Boolean;
    procedure mover_fundo;
    procedure mover_inimigos;
    procedure atualizar_pontos;
    procedure atualizar_energia;
    procedure atualizar_vidas;
    function  icone_alien_por_fase: String;
    procedure morrer;
    procedure limpar_inimigos;
    procedure preparar_fase;
    procedure definir_posicoes_do_alien(var alvo: Alien);
    procedure configurar_fases_pre_programadas;
    procedure configurar_variaveis_de_controle;
    procedure avancar_fase;
    procedure tocar_musica(arquivo: String);
    procedure tocar_som(arquivo: String);
    procedure tratar_tiros_inimigos;
    function  escolher_alien_aleatorio(quant_aliens: Integer): Integer;
    function  contar_tiros_inimigos: Integer;
    procedure mover_tiros_inimigos;
    procedure mover_nave(x, y: Integer);
    procedure inicializar_jogo;
    procedure registrar_historico;
    procedure inicializar_historico;
    procedure salvar_estado;
    function precisa_restaurar: Boolean;
    procedure restaurar_sessao;
    procedure fechar_jogo;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  form_principal: Tform_principal;
  pausa: Boolean;
  movimento_fundo: Integer;
  movimento: Integer;
  tiro_lancado: Boolean;
  limite_tiros_inimigos: Integer;
  n_fase: Integer;
  cont_aliens: Integer;
  pontos: Integer;
  energia_max: Integer;
  cont_energia: Integer;
  vidas: Integer;
  invencivel: Boolean;
  tempo_de_jogo: Integer;
  hist: Historico;
  fase01: Fase;
  fase02: Fase;
  fase03: Fase;
  fase_atual: Fase;
  restaurar: Boolean;
  completar_energia: Boolean;
  fl_aviso_emitido:Boolean;

implementation

uses
  System.Types, System.Generics.Collections;

{$R *.dfm}

procedure depurar(ponto: Integer);
begin
  ShowMessage('Ponto: ' + IntToStr(ponto));
end;

procedure Tform_principal.FormCreate(Sender: TObject);
begin
  restaurar := False;
  completar_energia := True;
  inicializar_jogo();
end;

procedure Tform_principal.inicializar_jogo();
begin
  // Previnindo a piscagem das imagens
  DoubleBuffered := True;
  // Configurando o intervalo de processamento do jogo
  processamento.Interval := INTERVALO_PROCESSAMENTO_MS;
  inicializar_historico();
  configurar_variaveis_de_controle();
  configurar_fases_pre_programadas();
  if(precisa_restaurar() = True) then
  begin
    completar_energia := False;
    restaurar_sessao();
  end;
  atualizar_pontos();
  atualizar_vidas();
  atualizar_energia();
  processamento.Enabled := True;
end;

// procedure que inicializa os dados do hist�rico de jogo
procedure Tform_principal.inicializar_historico();
begin
  hist := Historico.Create();
  hist.data := '';
  hist.tempo := 0;
  hist.pont_pre := 0;
  hist.pont_pos := 0;
end;

procedure Tform_principal.configurar_variaveis_de_controle();
begin
  pausa := True;
  movimento_fundo := 1;
  movimento := 8;
  tiro_lancado := False;
  limite_tiros_inimigos := 0;
  n_fase := 0;
  cont_aliens := 0;
  pontos := 0;
  energia_max := 100;
  cont_energia := energia_max;
  vidas := 3;
  invencivel := False;
  tempo_de_jogo := 0;
end;

procedure Tform_principal.configurar_fases_pre_programadas();
begin

  // Configurando a Fase 01
  fase01 := Fase.Create;
  fase01.origem_cima := True;
  fase01.origem_baixo := False;
  fase01.origem_esquerda := False;
  fase01.origem_direita := False;
  fase01.caminho_musica := 'Waterflame - Electroman Adventures.mp3';
  fase01.historia := 'COMUNICADO: TU PILOTO DEFESA PLANETA NADAVER ESQUADRAO ABATIDO VOCE ULTIMA ESPERANCA BATALHA';

  // Configurando a Fase 02
  fase02 := Fase.Create;
  fase02.origem_cima := False;
  fase02.origem_baixo := False;
  fase02.origem_esquerda := True;
  fase02.origem_direita := True;
  fase02.caminho_musica := 'Kitsune2 - Never Want to Be a Hero.mp3';
  fase02.historia := 'COMUNICADO: ALIENS PASSARAM ONDA + FORTE CUIDADO DEFESAS SE VIRAM AQUI FOCO FOCO FOCO';

  // Configurando a Fase 03
  fase03 := Fase.Create;
  fase03.origem_cima := True;
  fase03.origem_baixo := False;
  fase03.origem_esquerda := True;
  fase03.origem_direita := True;
  fase03.caminho_musica := 'TomboFry - Grayscale.mp3';
  fase03.historia := 'COMUNICADO: NADAVER VENCER BATALHA MUITAS PERDAS NAO DEIXAR ULTIMA ONDA PASSAR!';

  // Inicializando dados de fase atual
  fase_atual := Fase.Create;
  fase_atual.origem_cima := False;
  fase_atual.origem_baixo := False;
  fase_atual.origem_esquerda := False;
  fase_atual.origem_direita := False;
  fase_atual.caminho_musica := '';
  fase_atual.historia := '';
end;

// Salva o estado do jogo em um formato XML
procedure Tform_principal.salvar_estado();
var
  xml: String;
begin
  xml := '';
  xml := xml + envelopar_tag(TAG_CONTROLE_PAUSA, BoolToStr(pausa));
  xml := xml + envelopar_tag(TAG_CONTROLE_MOVIMENTO_FUNDO, IntToStr(movimento_fundo));
  xml := xml + envelopar_tag(TAG_CONTROLE_MOVIMENTO, IntToStr(movimento));
  xml := xml + envelopar_tag(TAG_CONTROLE_TIRO_LANCADO, BoolToStr(tiro_lancado));
  xml := xml + envelopar_tag(TAG_CONTROLE_LIMITE_TIROS_INIMIGOS, IntToStr(limite_tiros_inimigos));
  xml := xml + envelopar_tag(TAG_CONTROLE_N_FASE, IntToStr(n_fase));
  xml := xml + envelopar_tag(TAG_CONTROLE_CONT_ALIENS, IntToStr(cont_aliens));
  xml := xml + envelopar_tag(TAG_CONTROLE_PONTOS, IntToStr(pontos));
  xml := xml + envelopar_tag(TAG_CONTROLE_ENERGIA_MAX, IntToStr(energia_max));
  xml := xml + envelopar_tag(TAG_CONTROLE_CONT_ENERGIA, IntToStr(cont_energia));
  xml := xml + envelopar_tag(TAG_CONTROLE_VIDAS, IntToStr(vidas));
  xml := xml + envelopar_tag(TAG_CONTROLE_INVENCIVEL, BoolToStr(invencivel));
  xml := xml + envelopar_tag(TAG_CONTROLE_TEMPO_DE_JOGO, IntToStr(tempo_de_jogo));
  xml := xml + envelopar_tag(TAG_HISTORICO_DATA, hist.data);
  xml := xml + envelopar_tag(TAG_HISTORICO_TEMPO, IntToStr(hist.tempo));
  xml := xml + envelopar_tag(TAG_HISTORICO_PONT_PRE, IntToStr(hist.pont_pre));
  xml := xml + envelopar_tag(TAG_HISTORICO_PONT_POS, IntToStr(hist.pont_pos));
  xml := xml + envelopar_tag(TAG_FASE_ATUAL_CAMINHO_MUSICA, fase_atual.caminho_musica);
  xml := xml + envelopar_tag(TAG_FASE_ATUAL_HISTORIA, fase_atual.historia);
  xml := xml + envelopar_tag(TAG_FASE_ATUAL_ORIGEM_CIMA, BoolToStr(fase_atual.origem_cima));
  xml := xml + envelopar_tag(TAG_FASE_ATUAL_ORIGEM_BAIXO, BoolToStr(fase_atual.origem_baixo));
  xml := xml + envelopar_tag(TAG_FASE_ATUAL_ORIGEM_ESQUERDA, BoolToStr(fase_atual.origem_esquerda));
  xml := xml + envelopar_tag(TAG_FASE_ATUAL_ORIGEM_DIREITA, BoolToStr(fase_atual.origem_direita));
  xml := envelopar_tag(TAG_SESSAO_ESTADO, xml);
  xml := envelopar_tag(TAG_SESSAO_RESTAURAR, BoolToStr(restaurar)) + xml;
  escrever_no_arquivo(ARQ_DADOS_XML, xml, False);
end;

function Tform_principal.icone_alien_por_fase(): String;
begin
  if(n_fase = 1) then
    Result := 'alien1.png';
  if(n_fase = 2) then
    Result := 'alien2.png';
  if(n_fase > 2) then
    Result := 'alien3.png';
end;

function Tform_principal.criar_alien(): Alien;
var
  temp_alien: Alien;
begin
  temp_alien := Alien.Create(form_principal);
  temp_alien.Parent := form_principal;
  temp_alien.Width := TAMANHO_SPRITE;
  temp_alien.Height := TAMANHO_SPRITE;
  temp_alien.Left := form_principal.Width - temp_alien.Width;
  temp_alien.Top := 0;
  temp_alien.Tag := ID_INIMIGO;
  temp_alien.Picture.LoadFromFile(CAMINHO_RECURSOS + icone_alien_por_fase());
  temp_alien.espera_pre_entrada := (1000 Div INTERVALO_PROCESSAMENTO_MS) * (Random(10) + 1);
  temp_alien.espera_pre_entrada_mod := temp_alien.espera_pre_entrada;
  temp_alien.ja_atirou := True;
  Result := temp_alien;
end;

procedure Tform_principal.cronometroTimer(Sender: TObject);
begin
  if(pausa = False) then
    Inc(tempo_de_jogo);
end;

procedure Tform_principal.ctrl_tocadorTimer(Sender: TObject);
begin
  tocador.Play();
end;

// procedure para tocar um efeito sonoro
procedure Tform_principal.tocar_som(arquivo: String);
begin
  sons.FileName := arquivo;
  sons.Open();
  sons.Play();
end;

procedure Tform_principal.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if(Key = 'p') then
  begin
    pausa := not pausa;
  end;
  if(pausa = False) then
  begin
    // Controles permitidos apenas em modo avan�ado (ap�s a terceira fase)
    if(n_fase > 3) then
    begin
      // Mover para cima
      if(Key = 'w') then
      begin
        if((nave.Top - movimento) > (0 + 48)) then mover_nave(nave.Left, nave.Top - movimento);
      end;
      // Mover para baixo
      if(Key = 's') then
      begin
        if((nave.Top + movimento) < (335 - nave.Height)) then mover_nave(nave.Left, nave.Top + movimento);
      end;
    end;
    // Mover para esquerda
    if(Key = 'a') then
    begin
      if(nave.Left > 0) then mover_nave(nave.Left - movimento, nave.Top);
    end;
    // Mover para direita
    if(Key = 'd') then
    begin
      if(nave.Left < (640 - nave.Width)) then mover_nave(nave.Left + movimento, nave.Top);
    end;
    // Atirar
    if(Key = ' ') then
    begin
      atirar();
    end;
    // Incrementar o n�mero indicador da fase
    if(Key = 'm') then
    begin
      Inc(n_fase);
    end;
    // (Des)Ativar trapa�a da barreira
    if(Key = 'n') then
    begin
      barreira.Visible := not barreira.Visible;
    end;
    // (Des)Ativar invencibilidade
    if(Key = 'b') then
    begin
      invencivel := not invencivel;
    end;
    // Alternar visibilidade da hitbox da nave
    if(Key = 'v') then
    begin
      hitbox.Visible := not hitbox.Visible;
    end;
  end;
end;

procedure Tform_principal.atirar();
begin
  if(tiro_lancado = False) then
  begin
    tiro_lancado := True;
    tocar_som(CAMINHO_RECURSOS + 'Tiro.mp3');
    tiro.Left := (nave.Left + (nave.Width div 2));
    tiro.Top := nave.Top;
    tiro.Visible := True;
  end;
end;

procedure Tform_principal.tratar_tiro_jogador();
begin
  if(tiro_lancado = True) then
  begin
    tiro.Top := tiro.Top - movimento;
    Tiro.Left := (nave.Left + (nave.Width div 2));
    if(tiro.Top < -(tiro.Height)) then
    begin
      tiro_lancado := False;
      tiro.Visible := False;
    end;
  end;
end;


function Tform_principal.escolher_alien_aleatorio(quant_aliens: Integer): Integer;
var
  indice: Integer;
  cont: Integer;
begin
  Result := -1;
  indice := Random(quant_aliens) + 1;
  cont := 0;
  if(quant_aliens > 0) then
  begin
    while(indice > 0) do
    begin
      while(cont < ComponentCount) do
      begin
        if(components[cont].Tag = ID_INIMIGO) then
          Dec(indice);
        if(indice = 0) then
        begin
          Result := cont;
          break;
        end;

        Inc(cont);
      end;

      cont := 0;
    end;
  end;
end;

function Tform_principal.contar_tiros_inimigos(): Integer;
var
  cont: Integer;
begin
  cont := 0;
  Result := 0;
  while(cont < ComponentCount) do
  begin
    if(components[cont].Tag = ID_TIRO_INIMIGO) then
      Inc(Result);
    Inc(cont);
  end;
end;

procedure Tform_principal.mover_tiros_inimigos();
var
  cont: Integer;
  temp_tiro: TControl;
begin
  cont := 0;
  while(cont < ComponentCount) do
  begin
    if(components[cont].Tag = ID_TIRO_INIMIGO) then
    begin
      temp_tiro := components[cont] As TControl;
      temp_tiro.Top := temp_tiro.Top + movimento + (movimento Div 3);
      if(temp_tiro.Top > temp_tiro.Parent.Height) then
        temp_tiro.Free();
    end;
    Inc(cont);
  end;
end;

//Procedure tiro do inimigo
procedure Tform_principal.tratar_tiros_inimigos();
var
  temp_alien: Alien;
  indice: Integer;
begin
  indice := escolher_alien_aleatorio(cont_aliens);
  if(indice >= 0) then
  begin
    temp_alien := components[indice] As Alien;
    if(contar_tiros_inimigos() < limite_tiros_inimigos) then
    begin
      temp_alien.atirar();
    end;
  end;
  mover_tiros_inimigos();
end;

// procedure para mover a nave do jogador de forma padronizada
procedure Tform_principal.mover_nave(x, y: Integer);
begin
  nave.Left := x;
  nave.Top := y;
  hitbox.Left := nave.Left + ((nave.Width Div 2) - (hitbox.Width) Div 2);
  hitbox.Top := nave.Top;
end;

// procedure que cuida das tarefas a serem realizadas quando a nave do jogador colide
procedure Tform_principal.morrer();
begin
  invencivel := True;
  Dec(vidas);
  tocar_som(CAMINHO_RECURSOS + 'Explosao.mp3');
  cont_energia := energia_max;
  mover_nave(296, 290);
  atualizar_vidas();
  atualizar_energia();
  limpar_inimigos();
  invencivel := False;
end;

// Remove os inimigos da parte vis�vel da tela de forma a dar tempo de rea��o ao jogador
procedure Tform_principal.limpar_inimigos();
var
  cont: Integer;
  temp_alien: Alien;
begin
  cont := 0;
  while(cont < ComponentCount) do
  begin
    if(components[cont].Tag = ID_TIRO_INIMIGO) then
    begin
      components[cont].Free;
      cont := 0;
    end;
    if(components[cont].Tag = ID_INIMIGO) then
    begin
      temp_alien := components[cont] as Alien;
      temp_alien.voltar_pra_origem();
      temp_alien.espera_pre_entrada_mod := temp_alien.espera_pre_entrada;
    end;
    Inc(cont);
  end;
end;

// Tratar Colis�es
procedure Tform_principal.tratar_colisoes();
var
  cont1, cont2: Integer;
  fl_ordem_emitida: Boolean;
begin
  cont1 := 0;
  cont2 := 0;

  fl_ordem_emitida := False;

  while (cont1 < ComponentCount) do
  begin
    if ((components[cont1].Tag = ID_JOGADOR) or (components[cont1].Tag = ID_TIRO_JOGADOR)) then
    begin
      while (cont2 < ComponentCount) do
      begin
        if ((components[cont2].Tag = ID_INIMIGO) or (components[cont2].Tag = ID_TIRO_INIMIGO)) then
        begin
          if deu_colisao(components[cont1], components[cont2]) then
          begin
            if (components[cont1].Tag = ID_JOGADOR) and not invencivel then
            begin
              morrer();
            end;
            if (components[cont1].Tag = ID_TIRO_JOGADOR) and (components[cont1] as TControl).Visible then
            begin
              Inc(pontos, 100);
              atualizar_pontos();
              tocar_som(CAMINHO_RECURSOS + 'Explosao.mp3');
              if (components[cont2].Tag = ID_INIMIGO) then
                Dec(cont_aliens);
              components[cont2].Free();
              if (components[cont1].Name = 'tiro') then
              begin
                tiro.Visible := False;
                tiro.Top := 0;
              end;
            end;
          end;
        end;
        Inc(cont2);
      end;
    end;
    Inc(cont1);
    cont2 := 0;
  end;
end;



// procedure que testa de v�rias formas se houve uma colis�o entre dois componentes
function Tform_principal.deu_colisao(a, b: TComponent): Boolean;
var
  ac, bc: TControl;
begin
  ac := a As TControl;
  bc := b As TControl;
  Result := (testar_colisao(ac, bc) or testar_colisao(bc, ac));
end;

// function que testa colisao
function Tform_principal.testar_colisao(a, b: TControl): Boolean;
begin
  if((a.Left < (b.Left + b.Width)) and ((a.Left + a.Width) > b.Left) and (a.Top < (b.Top + b.Height)) and ((a.Top + a.Height) > b.Top)) then
    Result := True
  else
    Result := False;
end;

procedure Tform_principal.tmr_aviso_colisaoTimer(Sender: TObject);
var
  nave: TControl;
  ds_som: String;
  inimigos, tiros: TList<TControl>;
  abs_inimigo, abs_nave: TPoint;
  i, cont_inimigo_esquerda, cont_inimigo_direita: integer;
  toleranciaX: Integer;
begin
  inimigos := TList<TControl>.Create;
  tiros := TList<TControl>.Create;
  try
    // Inicializar os contadores e a toler�ncia
    cont_inimigo_esquerda := 0;
    cont_inimigo_direita := 0;
    toleranciaX := 5; // Toler�ncia de 5 pixels para a verifica��o do eixo X

    // Identificar os inimigos, tiros e a nave
    for i := 0 to form_principal.ComponentCount - 1 do
    begin
      if Components[i] is TControl then
      begin
        if TControl(Components[i]).Tag = ID_INIMIGO then
          inimigos.Add(TControl(Components[i]))
        else if TControl(Components[i]).Tag = ID_TIRO_INIMIGO then
          tiros.Add(TControl(Components[i]))
        else if TControl(Components[i]).Tag = ID_JOGADOR then
          nave := TControl(Components[i]);
      end;
    end;

    abs_nave := nave.ClientToScreen(Point(0,0));
    for i := 0 to inimigos.Count - 1 do
    begin
      abs_inimigo := inimigos[i].ClientToScreen(Point(0, 0));

      // Verifica se o inimigo est� vis�vel, no mesmo eixo X que a nave, e dentro dos limites do formul�rio
      if inimigos[i].Visible and
         (Abs(abs_inimigo.X - abs_nave.X) <= toleranciaX) and // Verifica se o inimigo est� no mesmo eixo X que a nave
         (abs_inimigo.Y >= Self.ClientOrigin.Y) and
         (abs_inimigo.Y <= Self.ClientOrigin.Y + Self.ClientHeight) then
      begin
        if abs_inimigo.Y > abs_nave.Y then
          Inc(cont_inimigo_direita)
        else if abs_inimigo.Y < abs_nave.Y then
          Inc(cont_inimigo_esquerda);
      end;
    end;

    if cont_inimigo_esquerda > cont_inimigo_direita then
    begin
      ds_som := CAMINHO_RECURSOS + '/' + 'direita.mp3';
    end
    else if cont_inimigo_direita > cont_inimigo_esquerda then
    begin
      ds_som := CAMINHO_RECURSOS + '/' + 'esquerda.mp3';
    end;

    try
      sons_direcionais.FileName := ds_som;
      sons_direcionais.Open();
      sons_direcionais.Play();
    except
      on E: Exception do
        OutputDebugString(PChar('Erro ao tentar tocar som: ' + E.Message));
    end;
  finally
    inimigos.Free;
    tiros.Free;
  end;
end;
procedure Tform_principal.mover_fundo();
begin
  fundo1.Top := fundo1.Top + ((movimento Div 2) * (n_fase + 1));
  fundo2.Top := fundo2.Top + ((movimento Div 2) * (n_fase + 1));
  if(fundo1.Top > fundo1.Height) then
    fundo1.Top := -fundo1.Height;
  if(fundo2.Top > fundo2.Height) then
    fundo2.Top := -fundo2.Height;
end;

// Utilidade que move os inimigos pela tela
procedure Tform_principal.mover_inimigos();
var
  cont: Integer;
  temp_alien: Alien;
begin
  cont := 0;
  while(cont < ComponentCount) do
  begin
    if(components[cont].Tag = ID_INIMIGO) then
    begin
      temp_alien := (components[cont] As Alien);
      temp_alien.mover();
    end;
    Inc(cont);
  end;
end;

procedure Tform_principal.atualizar_pontos();
begin
  pontuacao.Caption := 'Pontos: ' + IntToStr(pontos);
end;

procedure Tform_principal.atualizar_energia();
var
  cont: Integer;
  caracteres: Integer;
  limite: Integer;
begin
  cont := 0;
  caracteres := (cont_energia * 100) Div energia_max;
  limite := 100 Div 3;
  caracteres := caracteres Div 3;
  energia.Caption := 'Energia: ';
  while(cont < caracteres) do
  begin
    energia.Caption := energia.Caption + '#';
    Inc(cont);
  end;
  while(cont < limite) do
  begin
    energia.Caption := energia.Caption + '-';
    Inc(cont);
  end;
  if(cont_energia <= 0) then
    morrer();
end;

procedure Tform_principal.atualizar_vidas();
begin
  visor_vidas.Caption := 'x' + IntToStr(vidas);
end;

// Definir as posi��es de origem e movimenta��o de um alien de acordo com as zonas de origem da fase atual
procedure Tform_principal.definir_posicoes_do_alien(var alvo: Alien);
var
  zona: Integer;
  achado: Boolean;
begin
  zona := 0;
  achado := False;
  // Enquanto n�o tivermos achado
  while(achado = False) do
  begin
    zona := Random(4) + 1;
    case zona of
      ZONA_CIMA    : achado := fase_atual.origem_cima;
      ZONA_BAIXO   : achado := fase_atual.origem_baixo;
      ZONA_ESQUERDA: achado := fase_atual.origem_esquerda;
      ZONA_DIREITA : achado := fase_atual.origem_direita;
    end;
  end;
  case zona of
    ZONA_CIMA    : alvo.atualizar_coordenadas((Random(576) + TAMANHO_SPRITE), -(TAMANHO_SPRITE), 0, (movimento Div 2));
    ZONA_BAIXO   : alvo.atualizar_coordenadas((Random(576) + TAMANHO_SPRITE), (480 + TAMANHO_SPRITE), 0, -(movimento Div 2));
    ZONA_ESQUERDA: alvo.atualizar_coordenadas(-(TAMANHO_SPRITE), (Random(216) + TAMANHO_SPRITE), (movimento Div 2), 0);
    ZONA_DIREITA : alvo.atualizar_coordenadas((640 + TAMANHO_SPRITE), (Random(216) + TAMANHO_SPRITE), -(movimento Div 2), 0);
  end;
end;

// Preparar fase
procedure Tform_principal.preparar_fase();
var
  cont: Integer;
  temp_alien: Alien;
begin
  cont := 0;
  while(cont < cont_aliens) do
  begin
    temp_alien := criar_alien();
    definir_posicoes_do_alien(temp_alien);
    temp_alien.voltar_pra_origem();
    Inc(cont);
  end;
  if(completar_energia = True) then
  begin
    energia_max := (1000 Div INTERVALO_PROCESSAMENTO_MS) * 60 * (n_fase + 1);
    cont_energia := energia_max;
  end;
  completar_energia := True;
  limite_tiros_inimigos := (FATOR_N_ALIENS * n_fase) Div 5;
  tocar_musica(CAMINHO_RECURSOS + fase_atual.caminho_musica);
end;

// Tocar m�sica da fase;
procedure Tform_principal.tocar_musica(arquivo: String);
begin
  tocador.FileName := arquivo;
  tocador.Open();
  tocador.TimeFormat := tfMilliseconds;
  ctrl_tocador.Interval := tocador.Length + 100;
  tocador.Play();
  ctrl_tocador.Enabled := True;
end;

// Avan�o de fases
procedure Tform_principal.avancar_fase();
begin
  Inc(n_fase);
  cont_aliens := (n_fase * FATOR_N_ALIENS);

  case n_fase of
    1: fase_atual := fase01;
    2: fase_atual := fase02;
    3: fase_atual := fase03;
  else
    fase_atual.origem_cima := True;
    fase_atual.origem_baixo := True;
    fase_atual.origem_esquerda := True;
    fase_atual.origem_direita := True;
    fase_atual.caminho_musica := 'Triac - Eat Your Bricks.mp3';
    fase_atual.historia := 'COMUNICADO: Voc� venceu a guerra, agora retorne para casa s�o e salvo.';
  end;
  preparar_fase();
  Sleep(1000);
end;

//Gravar estado da sess�o.
procedure Tform_principal.registrar_historico();
begin
  if((n_fase < 4) and (n_fase > 0)) then
    hist.pont_pre := pontos
  else
    hist.pont_pos := pontos - hist.pont_pre;
  hist.tempo := tempo_de_jogo;
  hist.data := DateToStr(Date);
end;

// Verifica se o jogo foi abortado na sess�o anterior
function Tform_principal.precisa_restaurar(): Boolean;
var
  xml: String;
begin
  xml := ler_do_arquivo(ARQ_DADOS_XML);
  if(Length(xml) > 0) then
    Result := StrToBool(extrair_valor_tag(xml, TAG_SESSAO_RESTAURAR))
  else
  begin
    salvar_estado();
    Result := False;
  end;
end;

// Restaura a sess�o do jogo de acordo com o estado salvo
procedure Tform_principal.restaurar_sessao();
var
  xml: String;
begin
  xml := ler_do_arquivo(ARQ_DADOS_XML);
  if(Length(xml) > 0) then
  begin
    pausa := StrToBool(extrair_valor_tag(xml, TAG_CONTROLE_PAUSA));
    movimento_fundo := StrToInt(extrair_valor_tag(xml, TAG_CONTROLE_MOVIMENTO_FUNDO));
    movimento := StrToInt(extrair_valor_tag(xml, TAG_CONTROLE_MOVIMENTO));
    tiro_lancado := StrToBool(extrair_valor_tag(xml, TAG_CONTROLE_TIRO_LANCADO));
    limite_tiros_inimigos := StrToInt(extrair_valor_tag(xml, TAG_CONTROLE_LIMITE_TIROS_INIMIGOS));
    n_fase := StrToInt(extrair_valor_tag(xml, TAG_CONTROLE_N_FASE));
    cont_aliens := StrToInt(extrair_valor_tag(xml, TAG_CONTROLE_CONT_ALIENS));
    pontos := StrToInt(extrair_valor_tag(xml, TAG_CONTROLE_PONTOS));
    energia_max := StrToInt(extrair_valor_tag(xml, TAG_CONTROLE_ENERGIA_MAX));
    cont_energia := StrToInt(extrair_valor_tag(xml, TAG_CONTROLE_CONT_ENERGIA));
    vidas := StrToInt(extrair_valor_tag(xml, TAG_CONTROLE_VIDAS));
    invencivel := StrToBool(extrair_valor_tag(xml, TAG_CONTROLE_INVENCIVEL));
    tempo_de_jogo := StrToInt(extrair_valor_tag(xml, TAG_CONTROLE_TEMPO_DE_JOGO));
    hist.data := extrair_valor_tag(xml, TAG_HISTORICO_DATA);
    hist.tempo := StrToInt(extrair_valor_tag(xml, TAG_HISTORICO_TEMPO));
    hist.pont_pre := StrToInt(extrair_valor_tag(xml, TAG_HISTORICO_PONT_PRE));
    hist.pont_pos := StrToInt(extrair_valor_tag(xml, TAG_HISTORICO_PONT_POS));
    fase_atual.caminho_musica := extrair_valor_tag(xml, TAG_FASE_ATUAL_CAMINHO_MUSICA);
    fase_atual.historia := extrair_valor_tag(xml, TAG_FASE_ATUAL_HISTORIA);
    fase_atual.origem_cima := StrToBool(extrair_valor_tag(xml, TAG_FASE_ATUAL_ORIGEM_CIMA));
    fase_atual.origem_baixo := StrToBool(extrair_valor_tag(xml, TAG_FASE_ATUAL_ORIGEM_BAIXO));
    fase_atual.origem_esquerda := StrToBool(extrair_valor_tag(xml, TAG_FASE_ATUAL_ORIGEM_ESQUERDA));
    fase_atual.origem_direita := StrToBool(extrair_valor_tag(xml, TAG_FASE_ATUAL_ORIGEM_DIREITA));
    preparar_fase();
  end
  else
    ShowMessage('Erro! Dados do estado inv�lidos! (XML)');
end;

procedure Tform_principal.processamentoTimer(Sender: TObject);
begin
  if(pausa = False) then
  begin
    pausa := True;
    tratar_colisoes();
    mover_fundo();
    mover_inimigos();
    tratar_tiro_jogador();
    tratar_tiros_inimigos();
    Dec(cont_energia);
    atualizar_energia();
    restaurar := True;
    pausa := False;
  end;

  if(cont_aliens <= 0) then
  begin
    processamento.Enabled := False;
    if(n_fase > 0) then
    begin
      Inc(pontos, (cont_energia - ((cont_energia Mod 10) * 10)));
      atualizar_pontos();
    end;
    registrar_historico();
    avancar_fase();
    form_janela.informar_fase(fase_atual);
    form_janela.ShowModal();
    processamento.Enabled := True;
    pausa := False;
  end;
  if(vidas <= 0) then
  begin
    processamento.Enabled := False;
    registrar_historico();
    form_pontuacao.informar_historico(hist);
    form_pontuacao.ShowModal();
    fechar_jogo();
  end;
  salvar_estado();
end;

procedure Tform_principal.fechar_jogo();
begin
  restaurar := False;
  salvar_estado();
  Close();
end;

end.
