unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPServer, IdGlobal, IdSocketHandle,
  IdTCPConnection, IdTCPClient, IdHTTP, IdURI;

type
  TDisagJsonLiveUDPService = class(TService)
    UDPServer: TIdUDPServer;
    HTTPClient: TIdHTTP;
    procedure UDPServerUDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceBeforeInstallOrUninstall(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
  private
    FUri: TIdURI;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  DisagJsonLiveUDPService: TDisagJsonLiveUDPService;

implementation

uses
  System.StrUtils, Winapi.WinSvc,
  superobject;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  DisagJsonLiveUDPService.Controller(CtrlCode);
end;

function TDisagJsonLiveUDPService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TDisagJsonLiveUDPService.ServiceAfterInstall(Sender: TService);

  function _GetCommandLine: String;
  begin
    Result := String(CmdLine)
                .Replace('-install', '', [rfReplaceAll, rfIgnoreCase])
                .Replace('/install', '', [rfReplaceAll, rfIgnoreCase]);
  end;

var
  LServiceManager: SC_HANDLE;
  LServiceHandle: SC_HANDLE;
  LCommandLine: String;
begin
  LCommandLine := _GetCommandLine;
  Sender.LogMessage(Format('install with custom command line: %s', [LCommandLine]));

  LServiceManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  try
    LServiceHandle := OpenService(LServiceManager, PChar(Sender.Name), SERVICE_CHANGE_CONFIG);
    try
      ChangeServiceConfig(LServiceHandle,
                          SERVICE_NO_CHANGE, SERVICE_NO_CHANGE, SERVICE_NO_CHANGE,
                          PChar(LCommandLine),
                          nil, nil, nil, nil, nil, nil);
    finally
      CloseServiceHandle(LServiceHandle)
    end;
  finally
    CloseServiceHandle(LServiceManager);
  end;
end;

procedure TDisagJsonLiveUDPService.ServiceBeforeInstallOrUninstall(Sender: TService);
var
  LSwitchValue: String;
begin
  if FindCmdLineSwitch('name', LSwitchValue) then
  begin
    Name := LSwitchValue;
    Sender.LogMessage(Format('%sinstall with custom service name: %s', [IfThen(not Application.Installing, 'un'), LSwitchValue]));
  end;
  if FindCmdLineSwitch('display', LSwitchValue) then
  begin
    DisplayName := LSwitchValue;
    Sender.LogMessage(Format('%sinstall with custom display name: %s', [IfThen(not Application.Installing, 'un'), LSwitchValue]));
  end;
end;

procedure TDisagJsonLiveUDPService.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  FUri.Path     := '/_up';
  FUri.Document := '';
  OutputDebugString(PWideChar(HTTPClient.Get(FUri.GetFullURI)));
end;

procedure TDisagJsonLiveUDPService.ServiceCreate(Sender: TObject);
var
  LUDPPort: String;
  LTargetURI: String;
begin
  if not FindCmdLineSwitch('udp-port', LUDPPort) then
    LUDPPort := '2511';
  UDPServer.DefaultPort      := Word.Parse(LUDPPort);
  UDPServer.BroadcastEnabled := True;
  UDPServer.Active           := True;

  if not FindCmdLineSwitch('target-uri', LTargetURI) then
    LTargetURI := 'http://disag:disag@127.0.0.1:5984';
  FUri := TIdURI.Create(LTargetURI);
  HTTPClient.Request.BasicAuthentication := not FUri.Username.IsEmpty;
  HTTPClient.Request.UserName            := FUri.Username;
  HTTPClient.Request.Password            := FUri.Password;
end;

procedure TDisagJsonLiveUDPService.ServiceDestroy(Sender: TObject);
begin
  FreeAndNil(FUri);
end;

procedure TDisagJsonLiveUDPService.UDPServerUDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  LStream: TStringStream;
  LData: ISuperObject;
begin
  LData := SO(TEncoding.Default.GetString(TBytes(AData)));
  OutputDebugString(PWideChar(LData.AsString));

  if LData.S['MessageType'] <> 'Event' then exit;
  
  FUri.Path     := '/' + LData.S['MessageVerb'];
  FUri.Document := '/' + LData.S['UUID'];

  LStream := TStringStream.Create;
  try
    LData.SaveTo(LStream);
    OutputDebugString(PWideChar(HTTPClient.Put(FUri.GetFullURI, LStream)));
  finally
    LStream.Free;
  end;
end;

end.
