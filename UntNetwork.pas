unit UntNetwork;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Registry, Winsock,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.ComCtrls, IdBaseComponent,
  IdAntiFreezeBase, Vcl.IdAntiFreeze, Vcl.Imaging.jpeg;

type
  TFrmNetwork = class(TForm)
    edtCaminho: TEdit;
    Label1: TLabel;
    memoInfo: TMemo;
    OpenDialog1: TOpenDialog;
    Image1: TImage;
    lblstatus: TLabel;
    Button1: TButton;
    IdAntiFreeze1: TIdAntiFreeze;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

  type
    PNetResourceArray = ^TNetResourceArray;
    TNetResourceArray = array [0 .. 100] of TNetResource;

  private
    { Private declarations }
  public
    { Public declarations }

  var
    procedure ScanNetworkResources(ResourceType, DisplayType: DWord);
    Function CreateNetResourceList(ResourceType: DWord;NetResource: PNetResource;
             out Entries: DWord; out List: PNetResourceArray): Boolean;
    Function Escreve_Arq(NomeArq, Texto: String): Boolean;
    function RetornaPing(ip: string): string;
    function RetornaMAC(ip: string): string;

  var
    i: integer;

  end;

var
  FrmNetwork: TFrmNetwork;

implementation

{$R *.dfm}

function PegarSaidaDOS(comando, DiretorioTrabalho: string): string;
var
  saSegunranca: TSecurityAttributes;
  siInformacoesInicializacao: TStartupInfo;
  piInformacaoDoProcesso: TProcessInformation;
  hLeitura, hEscrita: THandle;
  bOk, bHandle: Boolean;
  Buffer: array [0 .. 255] of AnsiChar;
  BytesLidos: Cardinal;
  Diretorio: string;
begin
  Result := '';
  with saSegunranca do
  begin
    nLength := SizeOf(saSegunranca);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(hLeitura, hEscrita, @saSegunranca, 0);
  try
    with siInformacoesInicializacao do
    begin
      FillChar(siInformacoesInicializacao,
        SizeOf(siInformacoesInicializacao), 0);
      cb := SizeOf(siInformacoesInicializacao);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_Hide;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE);
      hStdOutput := hEscrita;
      hStdError := hEscrita;
    end;
    Diretorio := DiretorioTrabalho;
    bHandle := CreateProcess(nil, PChar('cmd.exe /c ' + comando), nil, nil,
      True, 0, nil, PChar(Diretorio), siInformacoesInicializacao,
      piInformacaoDoProcesso);
    CloseHandle(hEscrita);
    if bHandle then
    begin
      try
        repeat
          bOk := ReadFile(hLeitura, Buffer, 255, BytesLidos, nil);
          if BytesLidos > 0 then
          begin
            Buffer[BytesLidos] := #0;
            Result := Result + Buffer;
          end;
        until not bOk or (BytesLidos = 0);
        WaitForSingleObject(piInformacaoDoProcesso.hProcess, INFINITE);
      finally
        CloseHandle(piInformacaoDoProcesso.hThread);
        CloseHandle(piInformacaoDoProcesso.hProcess);
      end;
    end;
  finally
    CloseHandle(hLeitura);
  end;
end;

procedure TFrmNetwork.Button1Click(Sender: TObject);
begin
  ScanNetworkResources(RESOURCETYPE_DISK, RESOURCEDISPLAYTYPE_SERVER);
end;

procedure TFrmNetwork.Button2Click(Sender: TObject);
begin
  close;
end;

function TFrmNetwork.CreateNetResourceList (ResourceType: DWord;  NetResource: PNetResource;
         out Entries: DWord;out List: PNetResourceArray): Boolean;
var
  EnumHandle: THandle;
  BufSize: DWord;
  Res: DWord;
begin
  Result := False;
  List := Nil;
  Entries := 0;
  if WNetOpenEnum(RESOURCE_GLOBALNET, ResourceType, 0, NetResource, EnumHandle)
    = NO_ERROR then
  begin
    try
      BufSize := $4000; // 16 kByte
      GetMem(List, BufSize);
      try
        repeat
          Entries := DWord(-1);
          FillChar(List^, BufSize, 0);
          Res := WNetEnumResource(EnumHandle, Entries, List, BufSize);
          if Res = ERROR_MORE_DATA then
          begin
            ReAllocMem(List, BufSize);
          end;
        until Res <> ERROR_MORE_DATA;
        Result := Res = NO_ERROR;
        if not Result then
        begin
          FreeMem(List);
          List := Nil;
          Entries := 0;
        end;
      except
        FreeMem(List);
        raise;
      end;
    finally
      WNetCloseEnum(EnumHandle);
    end;
  end;

end;

Function TFrmNetwork.Escreve_Arq(NomeArq, Texto: String): Boolean;
var
  sArquivo: tStrings;
  i: integer;
Begin
  Try
    sArquivo := tStringList.Create;
    sArquivo.LoadFromFile(NomeArq);
    sArquivo.Add(Texto);
    sArquivo.SaveToFile(NomeArq);
    Result := True;
  except
    Result := False;
  end
End;

function TFrmNetwork.RetornaMAC(ip: string): string;
var
  auxMac, cmd, aux: string;
  iPos, tam: integer;

begin
  cmd := 'arp -a ' + ip;
  auxMac := PegarSaidaDOS(cmd, ExtractFilePath(edtCaminho.Text));

  iPos := Pos(ip, auxMac);
  if iPos > 0 then
    auxMac := Copy(auxMac, Pos(ip, auxMac), Length(auxMac));

  iPos := 0;
  tam := Length(ip);
  iPos := Pos(ip, auxMac);

  auxMac := StringReplace(auxMac, 'dinƒmico', '', [rfReplaceAll]);
  auxMac := StringReplace(auxMac, ip, '', [rfReplaceAll]);
  auxMac := StringReplace(auxMac, '#$D#$A', '', [rfReplaceAll]);
  auxMac := StringReplace(auxMac, ' ', '', [rfReplaceAll]);
  auxMac := StringReplace(auxMac, '27---0x11', '', [rfReplaceAll]);
  auxMac := StringReplace(auxMac, 'Endere‡oIPEndere‡of¡sicoTipo', '',
    [rfReplaceAll]);
  auxMac := StringReplace(auxMac, '5---0xc', '', [rfReplaceAll]);

  Result := auxMac;

end;

function TFrmNetwork.RetornaPing(ip: string): string;
var
  aux, cmd: string;
  iPos: integer;
begin
  ip := StringReplace(ip, '\\', '', [rfReplaceAll]);
  cmd := 'ping -4 ' + ip;
  aux := PegarSaidaDOS(cmd, ExtractFilePath(edtCaminho.Text));

  // Pega a posição que começa com [127.0.0.1
  iPos := Pos('[', aux);
  if iPos > 0 then
    aux := Copy(aux, Pos('[', aux) + 1, Length(aux));

  iPos := 0;
  iPos := Pos(']', aux);

  delete(aux, iPos, Length(aux));
  Result := aux;
end;

procedure TFrmNetwork.ScanNetworkResources(ResourceType, DisplayType: DWord);

procedure ScanLevel(NetResource: PNetResource);
  var
    Entries: DWord;
    NetResourceList: PNetResourceArray;
    i: integer;
    aux,auxMaster, auxIP, auxMac: string;
  begin
    auxMaster:= EmptyStr;
    if CreateNetResourceList(ResourceType, NetResource, Entries, NetResourceList)
    then
      try
        for i := 0 to integer(Entries) - 1 do
        begin
          if (DisplayType = RESOURCEDISPLAYTYPE_GENERIC) or
            (NetResourceList[i].dwDisplayType = DisplayType) then
          begin
            if not (NetResourceList[i].lpRemoteName =  '\\BOSCO') then
            Begin

              Application.ProcessMessages;

              // RetornaNome
              auxMaster:= NetResourceList[i].lpRemoteName;
              auxMaster:= StringReplace(auxMaster,'\\','',[rfReplaceAll]);
              aux := auxMaster;
              aux := 'Nome da máquina ' + aux;
              memoInfo.Lines.Add(aux);
              aux := EmptyStr;

              Application.ProcessMessages;

              // Retorna IP
              auxIP := RetornaPing(NetResourceList[i].lpRemoteName);
              aux := 'IP da máquina ' + auxIP;
              memoInfo.Lines.Add(aux);
              aux := EmptyStr;

              Application.ProcessMessages;

              // Retorna MAC
              auxMac := RetornaMAC(auxIP);
              aux := 'MAC da máquina ' + auxMac;
              memoInfo.Lines.Add(aux);

              // retirando os '-'
              auxMac := StringReplace(auxMac,'-','',[rfReplaceAll]);
              auxMaster:= auxMaster+',';
              auxMac := auxMac;
              Escreve_Arq(edtCaminho.Text, auxMaster);
              Escreve_Arq(edtCaminho.Text, auxMac);

              Application.ProcessMessages;
            End;
          end;
          if (NetResourceList[i].dwUsage and RESOURCEUSAGE_CONTAINER) <> 0 then
            ScanLevel(@NetResourceList[i]);
        end;
      finally
        FreeMem(NetResourceList);
      end;
  end;
begin
  ScanLevel(Nil);
end;

end.
