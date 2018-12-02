program Project1;

uses
  Vcl.Forms,
  UntNetwork in 'UntNetwork.pas' {FrmNetwork};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmNetwork, FrmNetwork);
  Application.Run;
end.
