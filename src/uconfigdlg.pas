unit UConfigDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ButtonPanel,
  ComCtrls, Spin, StdCtrls, ValEdit, Buttons, SBDevices, SptTypes;

type

  { TConfigurationDlg }

  TConfigurationDlg = class(TForm)
    btnResetCal: TBitBtn;
    btnUpdateCal: TBitBtn;
    btnSaveTEC: TButton;
    btnApplyAdqChanges: TButton;
    btnUpdateNow: TButton;
    ButtonPanel: TButtonPanel;
    chbDark: TCheckBox;
    chbTempUpdates: TCheckBox;
    chbStrobe: TCheckBox;
    chbFan: TCheckBox;
    chbTEC: TCheckBox;
    chbShowStatusBar: TCheckBox;
    cbTriggerMode: TComboBox;
    gbAcquisition: TGroupBox;
    gbBoardTemp: TGroupBox;
    gbDetectorTemp: TGroupBox;
    gbTrigger: TGroupBox;
    gbIrradiance: TGroupBox;
    gbTEC: TGroupBox;
    bgWavelength: TGroupBox;
    gbVersionInfo: TGroupBox;
    gbTECSettings: TGroupBox;
    lblTrigger: TLabel;
    lblHardRevTxt: TLabel;
    lblHardRev: TLabel;
    lblSoftRevTxt: TLabel;
    lblSoftRev: TLabel;
    lblModTxt: TLabel;
    lblSerTxt: TLabel;
    lblModel: TLabel;
    lblSerial: TLabel;
    lblDetectorTemp: TLabel;
    lblUpdateInterval: TLabel;
    lblTemp: TLabel;
    lblBoxcar: TLabel;
    lblIntTime: TLabel;
    lblNoScans: TLabel;
    PageControl: TPageControl;
    rbMS: TRadioButton;
    rboC: TRadioButton;
    rbS: TRadioButton;
    rbK: TRadioButton;
    seBoxcar: TSpinEdit;
    seIntTime: TFloatSpinEdit;
    seTemp: TFloatSpinEdit;
    seNoScans: TSpinEdit;
    seUpdateinterval: TSpinEdit;
    tsVersionInfo: TTabSheet;
    tsWavelength: TTabSheet;
    tsTEC: TTabSheet;
    tsIrradiance: TTabSheet;
    tsTrigger: TTabSheet;
    tsBoardTemp: TTabSheet;
    tsAcquisition: TTabSheet;
    vleWavelength: TValueListEditor;
    procedure btnApplyAdqChangesClick(Sender: TObject);
    procedure btnResetCalClick(Sender: TObject);
    procedure rbMSChange(Sender: TObject);
    procedure rbSChange(Sender: TObject);
    //procedure btnUpdateCalClick(Sender: TObject);
  private
    { private declarations }
    FSpectrometer: TSBSpectrometer;
    function GetSpectrometer: TSBSpectrometer;
    function GetIntegrationTime: DWord;
    function GetScansToAverage: Word;
    function GetBoxcarWidth: Byte;
    function GetStrobeLampEnabled: Boolean;
    function GetElectricDarkEnabled: Boolean;
    function GetTriggerMode: Integer;
    procedure SetSpectrometer(Value: TSBSpectrometer);
    procedure SetIntegrationTime(Value: DWord);
    procedure SetScansToAverage(Value: Word);
    procedure SetBoxcarWidth(Value: Byte);
    procedure SetStrobeLampEnabled(Value: Boolean);
    procedure SetElectricDarkEnabled(Value: Boolean);
    procedure SetTriggerMode(Value: Integer);

    procedure LoadWavelengthCalibration;
  public
    { public declarations }
    property Spectrometer: TSBSpectrometer read GetSpectrometer write SetSpectrometer;
    property IntegrationTime: DWord read GetIntegrationTime write SetIntegrationTime;
    property ScansToAverage: Word read GetScansToAverage write SetScansToAverage;
    property BoxcarWidth: Byte read GetBoxcarWidth write SetBoxcarWidth;
    property StrobeLampEnabled: Boolean read GetStrobeLampEnabled write SetStrobeLampEnabled;
    property ElectricDarkEnabled: Boolean read GetElectricDarkEnabled write SetElectricDarkEnabled;
    property TriggerMode: Integer read GetTriggerMode write SetTriggerMode;

    function Execute: Boolean;
  end;

var
  ConfigurationDlg: TConfigurationDlg;

implementation

{$R *.lfm}

procedure TConfigurationDlg.btnApplyAdqChangesClick(Sender: TObject);
begin
  FSpectrometer.IntegrationTime := IntegrationTime;
  FSpectrometer.ScansToAverage := ScansToAverage;
  FSpectrometer.BoxcarWidth := BoxcarWidth;

  FSpectrometer.StrobeLampEnabled := StrobeLampEnabled;
  FSpectrometer.ElectricDarkEnabled := ElectricDarkEnabled;
end;

procedure TConfigurationDlg.btnResetCalClick(Sender: TObject);
begin
  LoadWavelengthCalibration;
end;

procedure TConfigurationDlg.rbMSChange(Sender: TObject);
begin
  if rbMS.Checked then
    seIntTime.Value := seIntTime.Value*1000;
end;

procedure TConfigurationDlg.rbSChange(Sender: TObject);
begin
  if rbS.Checked then
    seIntTime.Value := seIntTime.Value/1000;
end;

//procedure TConfigurationDlg.btnUpdateCalClick(Sender: TObject);
//var
//  NewCoeffs: DoubleArray;
//begin
//  if FSpectrometer = nil then Exit;
//
//  if MessageDlg('Write to EEPROM?', 'Are you sure you want to save these coefficients to the hardware?  This change is irreversible.',
//    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
//
//  SetLength(NewCoeffs, 4);
//  try
//    NewCoeffs[0] := StrToFloat(vleWavelength.Values['Intercept']);
//    NewCoeffs[1] := StrToFloat(vleWavelength.Values['1st Coefficient']);
//    NewCoeffs[2] := StrToFloat(vleWavelength.Values['2nd Coefficient']);
//    NewCoeffs[3] := StrToFloat(vleWavelength.Values['3rd Coefficient']);
//
//    FSpectrometer.WavelengthCoeffs := NewCoeffs;
//    ShowMessage('Hardware calibration updated successfully.');
//  except
//    on E: Exception do
//      MessageDlg('Error', 'Invalid numeric format: ' + E.Message, mtError, [mbOK], 0);
//  end;
//end;

function TConfigurationDlg.GetSpectrometer: TSBSpectrometer;
begin
  Result := FSpectrometer;
end;

function TConfigurationDlg.GetIntegrationTime: DWord;
begin
  if rbMS.Checked then
    Result := DWord(Round(seIntTime.Value*1000))
  else
    Result := DWord(Round(seIntTime.Value*1000000));
end;

function TConfigurationDlg.GetScansToAverage: Word;
begin
  Result := Word(seNoScans.Value);
end;

function TConfigurationDlg.GetBoxcarWidth: Byte;
begin
  Result := Byte(seBoxcar.Value);
end;

function TConfigurationDlg.GetStrobeLampEnabled: Boolean;
begin
  Result := chbStrobe.Checked;
end;

function TConfigurationDlg.GetElectricDarkEnabled: Boolean;
begin
  Result := chbDark.Checked;
end;

function TConfigurationDlg.GetTriggerMode: Integer;
begin
  Result := cbTriggerMode.ItemIndex;
end;

procedure TConfigurationDlg.SetSpectrometer(Value: TSBSpectrometer);
begin
  FSpectrometer := Value;

  IntegrationTime := FSpectrometer.IntegrationTime;
  ScansToAverage := FSpectrometer.ScansToAverage;
  BoxcarWidth := FSpectrometer.BoxcarWidth;

  StrobeLampEnabled := FSpectrometer.StrobeLampEnabled;
  ElectricDarkEnabled := FSpectrometer.ElectricDarkEnabled;

  TriggerMode := FSpectrometer.TriggerMode;

  LoadWavelengthCalibration;

  lblModel.Caption := FSpectrometer.DeviceName;
  lblSerial.Caption := FSpectrometer.SerialNumber;
  lblHardRev.Caption := FSpectrometer.HardwareRevision;
  lblSoftRev.Caption := FSpectrometer.SoftwareRevision;
end;

procedure TConfigurationDlg.SetIntegrationTime(Value: DWord);
begin
  if Value > 1000000 then
  begin
    rbS.Checked := True;
    seIntTime.Value := FSpectrometer.IntegrationTime/1000000;
  end
  else
  begin
    rbMS.Checked := True;
    seIntTime.Value := FSpectrometer.IntegrationTime/1000;
  end;
end;

procedure TConfigurationDlg.SetScansToAverage(Value: Word);
begin
  seNoScans.Value := Value;
end;

procedure TConfigurationDlg.SetBoxcarWidth(Value: Byte);
begin
  seBoxcar.Value := Value;
end;

procedure TConfigurationDlg.SetStrobeLampEnabled(Value: Boolean);
begin
  chbStrobe.Checked := Value;
end;

procedure TConfigurationDlg.SetElectricDarkEnabled(Value: Boolean);
begin
  chbDark.Checked := Value;
end;

procedure TConfigurationDlg.SetTriggerMode(Value: Integer);
begin
  if (Value >= 0) and (Value < cbTriggerMode.Items.Count) then
    cbTriggerMode.ItemIndex := Value
  else
    cbTriggerMode.ItemIndex := 0;
end;

procedure TConfigurationDlg.LoadWavelengthCalibration;
var
  Coeffs: DoubleArray;
begin
  if FSpectrometer = nil then Exit;

  try
    Coeffs := FSpectrometer.WavelengthCoeffs;

    // Clear and populate or just update existing keys
    vleWavelength.Values['Intercept'] := FloatToStrF(0, ffFixed, 7, 10);
    vleWavelength.Values['1st Coefficient'] := FloatToStrF(0, ffFixed, 7, 10);
    vleWavelength.Values['2nd Coefficient'] := FloatToStrF(0, ffFixed, 7, 10);
    vleWavelength.Values['3rd Coefficient'] := FloatToStrF(0, ffFixed, 7, 10);

    // Populate with actual hardware values
    if Length(Coeffs) > 0 then
      vleWavelength.Values['Intercept'] := FloatToStr(Coeffs[0]);
    if Length(Coeffs) > 1 then
      vleWavelength.Values['1st Coefficient'] := FloatToStr(Coeffs[1]);
    if Length(Coeffs) > 2 then
      vleWavelength.Values['2nd Coefficient'] := FloatToStr(Coeffs[2]);
    if Length(Coeffs) > 3 then
      vleWavelength.Values['3rd Coefficient'] := FloatToStr(Coeffs[3]);

  except
    on E: Exception do
      ShowMessage('Error reading calibration: ' + E.Message);
  end;
end;

function TConfigurationDlg.Execute: Boolean;
begin
  Result := (ShowModal = mrOK);
end;

end.

