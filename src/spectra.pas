unit Spectra;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, SptTypes;

type
  TSpectrum = class(TObject)
  private
    { Private declarations }
    FDate: TDateTime;
    FIntegrationTime: DWord;
    FScansToAverage: Word;
    FBoxcarWidth: Byte;
    FStrobeLampEnabled: Boolean;
    FElectricDarkEnabled: Boolean;

    FData: TSptData;
    FDataType: TDataType;

    function GetPoints: LongInt;
    function GetData: TSptData;
    function GetXData: DoubleArray;
    function GetYData: DoubleArray;
    function GetX(Index: Integer): Double;
    function GetY(Index: Integer): Double;

    procedure SetPoints(Value: LongInt);
    procedure SetData(Value: TSptData);
    procedure SetXData(Value: DoubleArray);
    procedure SetYData(Value: DoubleArray);
    procedure SetX(Index: Integer; Value: Double);
    procedure SetY(Index: Integer; Value: Double);
  protected
    { Protected declarations }
  public
    { Public declarations }
    {@exclude}
    constructor Create(IntegrationTime: DWord; ScansToAverage: Word; BoxcarWidth: Byte); overload;
    {@exclude}
    constructor Create(IntegrationTime: DWord; ScansToAverage: Word); overload;
    {@exclude}
    constructor Create(IntegrationTime: DWord); overload;
    {@exclude}
    constructor Create; overload;
    {@exclude}
    destructor  Destroy; override;

    function HasSameConditions(Spt: TSpectrum): Boolean;

    property Date: TDateTime read FDate;
    property Points: LongInt read GetPoints write SetPoints;
    property Data: TSptData read GetData write SetData;
    property XData: DoubleArray read GetXData write SetXData;
    property YData: DoubleArray read GetYData write SetYData;

    property X[Index: Integer]: Double read GetX write SetX;
    property Y[Index: Integer]: Double read GetY write SetY;

    property IntegrationTime: DWord read FIntegrationTime write FIntegrationTime;
    property ScansToAverage: Word read FScansToAverage write FScansToAverage;
    property BoxcarWidth: Byte read FBoxcarWidth write FBoxcarWidth;
    property StrobeLampEnabled: Boolean read FStrobeLampEnabled write FStrobeLampEnabled;
    property ElectricDarkEnabled: Boolean read FElectricDarkEnabled write FElectricDarkEnabled;
    property DataType: TDataType read FDataType write FDataType;
  end;

implementation


//*****************************************************************************/
//* Implementation of 'TSpectrum'                                       */
//*****************************************************************************/
constructor TSpectrum.Create(IntegrationTime: DWord; ScansToAverage: Word; BoxcarWidth: Byte); overload;
begin
  FIntegrationTime := IntegrationTime;
  FScansToAverage := ScansToAverage;
  FBoxcarWidth := BoxcarWidth;
  FDataType := dtScope;

  Points := 0;
end;

constructor TSpectrum.Create(IntegrationTime: DWord; ScansToAverage: Word); overload;
begin
  Create(IntegrationTime, ScansToAverage, 0);
end;

constructor TSpectrum.Create(IntegrationTime: DWord); overload;
begin
  Create(IntegrationTime, 1, 0);
end;

constructor TSpectrum.Create; overload;
begin
  Create(100000, 1, 0);
end;

destructor TSpectrum.Destroy;
begin
  Points := 0;

  // Call the parent destructor
  inherited;
end;

function TSpectrum.HasSameConditions(Spt: TSpectrum): Boolean;
begin
  Result := (Self.Points = Spt.Points) and
            (Self.IntegrationTime = Spt.IntegrationTime) and
            (Self.ScansToAverage = Spt.ScansToAverage) and
            (Self.BoxcarWidth = Spt.BoxcarWidth) and
            (Self.StrobeLampEnabled = Spt.StrobeLampEnabled) and
            (Self.ElectricDarkEnabled = Spt.ElectricDarkEnabled);
end;

function TSpectrum.GetPoints: LongInt;
begin
  Result := Min(Length(FData[0]), Length(FData[1]));
end;

function TSpectrum.GetData: TSptData;
var
  i: Integer;
begin
  SetLength(Result[0], Points);
  SetLength(Result[1], Points);
  for i := Low(FData[0]) to High(FData[0]) do
  begin
    Result[0][i] := FData[0][i];
    Result[1][i] := FData[1][i];
  end;
end;

function TSpectrum.GetXData: DoubleArray;
var
  i: Integer;
begin
  SetLength(Result, Points);
  for i := Low(FData[0]) to High(FData[0]) do
    Result[i] := FData[0][i];
end;

function TSpectrum.GetYData: DoubleArray;
var
  i: Integer;
begin
  SetLength(Result, Points);
  for i := Low(FData[1]) to High(FData[1]) do
    Result[i] := FData[1][i];
end;

function TSpectrum.GetX(Index: Integer): Double;
begin
  if (Index >= Low(FData[0])) and (Index <= High(FData[0])) then
    Result := FData[0][Index]
  else
    Result := 0.0;
end;

function TSpectrum.GetY(Index: Integer): Double;
begin
  if (Index >= Low(FData[1])) and (Index <= High(FData[1])) then
    Result := FData[1][Index]
  else
    Result := 0.0;
end;

procedure TSpectrum.SetPoints(Value: LongInt);
begin
  SetLength(FData[0], Value);
  SetLength(FData[1], Value);

  //Set the time of the last modification
  FDate := Now;
end;

procedure TSpectrum.SetData(Value: TSptData);
var
  i: Integer;
begin
  Points := Min(Length(Value[0]), Length(Value[1]));
  for i := Low(Value[0]) to High(Value[0]) do
  begin
    FData[0][i] := Value[0][i];
    FData[1][i] := Value[1][i];
  end;
end;

procedure TSpectrum.SetXData(Value: DoubleArray);
var
  i: Integer;
begin
  Points := Length(Value);
  for i := Low(Value) to High(Value) do
    FData[0][i] := Value[i];
end;

procedure TSpectrum.SetYData(Value: DoubleArray);
var
  i: Integer;
begin
  Points := Length(Value);
  for i := Low(Value) to High(Value) do
    FData[1][i] := Value[i];
end;

procedure TSpectrum.SetX(Index: Integer; Value: Double);
begin
  if (Index >= Low(FData[0])) and (Index <= High(FData[0])) then
    FData[0][Index] := Value;
end;

procedure TSpectrum.SetY(Index: Integer; Value: Double);
begin
  if (Index >= Low(FData[1])) and (Index <= High(FData[1])) then
    FData[1][Index] := Value;
end;

end.

