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
  private
    FUri: TIdURI;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  DisagJsonLiveUDPService: TDisagJsonLiveUDPService;

implementation

uses
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


procedure TDisagJsonLiveUDPService.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  FUri.Path     := '/_up';
  FUri.Document := '';
  OutputDebugString(PWideChar(HTTPClient.Get(FUri.GetFullURI)));
end;

procedure TDisagJsonLiveUDPService.ServiceCreate(Sender: TObject);
begin
  UDPServer.BroadcastEnabled := True;
  UDPServer.DefaultPort      := 2511; // TODO: should be configurable!
  UDPServer.Active           := True;

  HTTPClient.Request.BasicAuthentication := True;    // TODO: should be configurable!
  HTTPClient.Request.UserName            := 'admin'; // TODO: should be configurable!
  HTTPClient.Request.Password            := 'admin'; // TODO: should be configurable!

  FUri := TIdURI.Create('');
  FUri.Protocol := 'http';      // TODO: should be configurable!
  FUri.Host     := '127.0.0.1'; // TODO: should be configurable!
  FUri.Port     := '5984';      // TODO: should be configurable!
end;

procedure TDisagJsonLiveUDPService.ServiceDestroy(Sender: TObject);
begin
  FreeAndNil(FUri);
end;

procedure TDisagJsonLiveUDPService.UDPServerUDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  LStream: TStringStream;
begin
  LStream := TStringStream.Create(TBytes(AData));
  try
    OutputDebugString(PWideChar(LStream.DataString));
    FUri.Path     := '/disag-test'; // TODO: should be configurable!
    FUri.Document := '/' + SO(LStream.DataString).S['UUID'];
    HTTPClient.Put(FUri.GetFullURI, LStream);
  finally
    LStream.Free;
  end;
end;

end.
