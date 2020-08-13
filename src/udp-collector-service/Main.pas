unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs;

type
  TMainService = class(TService)
  private
    { Private-Deklarationen }
  public
    function GetServiceController: TServiceController; override;
    { Public-Deklarationen }
  end;

var
  MainService: TMainService;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  MainService.Controller(CtrlCode);
end;

function TMainService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

end.
