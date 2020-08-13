unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient;

type
  TMainForm = class(TForm)
    UDPClient: TIdUDPClient;
    lbDataSelection: TListBox;
    btnBroadcast: TButton;
    pnlBottom: TPanel;
    edtPort: TLabeledEdit;
    procedure btnBroadcastClick(Sender: TObject);
    procedure lbDataSelectionDblClick(Sender: TObject);
  private
    procedure BroadcastSelection;
    function GetSelectedData: String;
    function GetPort: Word;
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.Math, System.SysUtils;

{$R *.dfm}

procedure TMainForm.BroadcastSelection;
begin
  UDPClient.Broadcast(GetSelectedData, GetPort);
end;

procedure TMainForm.btnBroadcastClick(Sender: TObject);
begin
  BroadcastSelection;
end;

function TMainForm.GetPort: Word;
var
  LValue: Integer;
begin
  if not ( Integer.TryParse(edtPort.Text, LValue) and
           InRange(LValue, Result.MinValue, Result.MaxValue) ) then
  begin
    raise ERangeError.CreateFmt('invalid port %d; provide a value between %d and %d',
                                [LValue, Result.MinValue, Result.MaxValue]);
  end;

  Result := LValue;
end;

function TMainForm.GetSelectedData: String;
begin
  Result := lbDataSelection.Items[lbDataSelection.ItemIndex];
end;

procedure TMainForm.lbDataSelectionDblClick(Sender: TObject);
begin
  BroadcastSelection;
end;

end.
