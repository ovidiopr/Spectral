unit URangeDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ButtonPanel,
  StdCtrls, Spin;

type

  { TRangeDlg }

  TRangeDlg = class(TForm)
    ButtonPanel1: TButtonPanel;
    seXMin: TFloatSpinEdit;
    seXMax: TFloatSpinEdit;
    seYMin: TFloatSpinEdit;
    seYMax: TFloatSpinEdit;
    lblXMin: TLabel;
    lblXMax: TLabel;
    lblYMax: TLabel;
    lblYMin: TLabel;
  private
    { private declarations }
    function GetXMin: Double;
    function GetXMax: Double;
    function GetYMin: Double;
    function GetYMax: Double;
    procedure SetXMin(Value: Double);
    procedure SetXMax(Value: Double);
    procedure SetYMin(Value: Double);
    procedure SetYMax(Value: Double);
  public
    { public declarations }
    property XMin: Double read GetXMin write SetXMin;
    property XMax: Double read GetXMax write SetXMax;
    property YMin: Double read GetYMin write SetYMin;
    property YMax: Double read GetYMax write SetYMax;

    function Execute(ValueXmin, ValueXmax, ValueYmin, ValueYmax: Double): Boolean; overload;
    function Execute: Boolean; overload;
  end;

var
  RangeDlg: TRangeDlg;

implementation

{$R *.lfm}

function TRangeDlg.GetXMin: Double;
begin
  Result := seXMin.Value;
end;

function TRangeDlg.GetXMax: Double;
begin
  Result := seXMax.Value;
end;

function TRangeDlg.GetYMin: Double;
begin
  Result := seYMin.Value;
end;

function TRangeDlg.GetYMax: Double;
begin
  Result := seYMax.Value;
end;

procedure TRangeDlg.SetXMin(Value: Double);
begin
  seXMin.Value := Value;
end;

procedure TRangeDlg.SetXMax(Value: Double);
begin
  seXMax.Value := Value;
end;

procedure TRangeDlg.SetYMin(Value: Double);
begin
  seYMin.Value := Value;
end;

procedure TRangeDlg.SetYMax(Value: Double);
begin
  seYMax.Value := Value;
end;

function TRangeDlg.Execute(ValueXmin, ValueXmax, ValueYmin, ValueYmax: Double): Boolean; overload;
begin
  SetXMin(ValueXmin);
  SetXMax(ValueXmax);
  SetYMin(ValueYmin);
  SetYMax(ValueYmax);

  Result := (ShowModal = mrOK);
end;

function TRangeDlg.Execute: Boolean; overload;
begin
  Result := (ShowModal = mrOK);
end;

end.

