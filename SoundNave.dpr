program SoundNave;

uses
  Vcl.Forms,
  PrincipalUnit in 'PrincipalUnit.pas' {form_principal},
  JanelinhaUnit in 'JanelinhaUnit.pas' {form_janela},
  AlienUnit in 'AlienUnit.pas',
  ConstantesUnit in 'ConstantesUnit.pas',
  FaseUnit in 'FaseUnit.pas',
  RegPontuacaoUnit in 'RegPontuacaoUnit.pas' {form_pontuacao},
  HistoricoUnit in 'HistoricoUnit.pas',
  XMLManipUnit in 'XMLManipUnit.pas',
  ArquivosUnit in 'ArquivosUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tform_principal, form_principal);
  Application.CreateForm(Tform_janela, form_janela);
  Application.CreateForm(Tform_pontuacao, form_pontuacao);
  Application.Run;
end.
