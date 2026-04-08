unit uMain;

{$mode objfpc}{$H+}

interface

uses LCLIntf, LCLType, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  Dialogs, Buttons, ExtCtrls, ComCtrls, TAGraph, TAChartUtils, TATools, ClipBrd,
  ActnList, StdCtrls, Spin, FileUtil, Restore, LazFileUtils, RTTIGrids,
  TAChartAxis, SptTypes, SBDevices, URangeDlg, UConfigDlg, USaveSpectraDlg,
  Measurements;

type
  { TfrmSpectral }
  TfrmSpectral = class(TForm)
    AbsorbanceAction: TAction;
    ClearSnapshotsAction: TAction;
    chbStrobe: TCheckBox;
    chbElectricDark: TCheckBox;
    gbIntTime: TGroupBox;
    gbAverageScans: TGroupBox;
    gbBoxcar: TGroupBox;
    StartSaveAllItem: TMenuItem;
    StopSaveAllItem: TMenuItem;
    RefreshItem: TMenuItem;
    pnlIntTimeUnits: TPanel;
    rbIntTimeMS: TRadioButton;
    rbIntTimeS: TRadioButton;
    seBoxcar: TSpinEdit;
    seAverageScans: TSpinEdit;
    seIntTime: TFloatSpinEdit;
    StopSaveAllAction: TAction;
    StartSaveAllAction: TAction;
    btnAbsorbance: TToolButton;
    btnBgnd: TToolButton;
    btnClearSnapshots: TToolButton;
    btnIntensity: TToolButton;
    btnNumeric: TToolButton;
    btnRaman: TToolButton;
    btnReference: TToolButton;
    btnReflectance: TToolButton;
    btnRescaleAll: TToolButton;
    btnRescaleXAxis: TToolButton;
    btnRescaleYAxis: TToolButton;
    btnScope: TToolButton;
    btnSptSnapshot: TToolButton;
    btnSubsBgnd: TToolButton;
    btnTransmittance: TToolButton;
    MemoLog: TMemo;
    pcMain: TPageControl;
    RefreshDevicesAction: TAction;
    ChartToolset: TChartToolset;
    AxisClickTool: TAxisClickTool;
    RamanItem: TMenuItem;
    RamanAction: TAction;
    RescaleXAxisItem: TMenuItem;
    RescaleYAxisItem: TMenuItem;
    RescaleAllItem: TMenuItem;
    NumericItem: TMenuItem;
    N5: TMenuItem;
    RescaleXAxisAction: TAction;
    RescaleYAxisAction: TAction;
    RescaleAllAction: TAction;
    NumericAction: TAction;
    BottomAxisAction: TAction;
    btnConfSave: TToolButton;
    btnPauseSave: TToolButton;
    btnStartSave: TToolButton;
    btnStopSave: TToolButton;
    LeftAxisAction: TAction;
    DeviceMenu: TMenuItem;
    RunStopItem: TMenuItem;
    RunStopAction: TAction;
    CopyItem: TMenuItem;
    CutItem: TMenuItem;
    N4: TMenuItem;
    PasteItem: TMenuItem;
    PasteAction: TAction;
    CutAction: TAction;
    CopyAction: TAction;
    IrradianceAction: TAction;
    IrradianceItem: TMenuItem;
    ReflectanceItem: TMenuItem;
    ReflectanceAction: TAction;
    btnSaveAs: TToolButton;
    btnCopy: TToolButton;
    btnCut: TToolButton;
    btnPaste: TToolButton;
    MainSplitter: TSplitter;
    sp01: TToolButton;
    sp02: TToolButton;
    sp03: TToolButton;
    SpeedButton1: TSpeedButton;
    SptToolBar: TToolBar;
    TabControl: TTabControl;
    pnlSpectrometer: TPanel;
    MainPlot: TChart;
    btnStartSaveAll: TToolButton;
    btnStopSaveAll: TToolButton;
    tsLog: TTabSheet;
    tsSpectra: TTabSheet;
    tb01: TToolButton;
    btnRunStop: TToolButton;
    TIPropertyGrid: TTIPropertyGrid;
    tb03: TToolButton;
    btnRefresh: TToolButton;
    TransmittanceItem: TMenuItem;
    TransmittanceAction: TAction;
    ConfigDeviceAction: TAction;
    AbsorbanceItem: TMenuItem;
    ScopeBgndItem: TMenuItem;
    ScopeBgndAction: TAction;
    ScopeAction: TAction;
    DevicesItem: TMenuItem;
    ScopeItem: TMenuItem;
    View: TMenuItem;
    ReferenceItem: TMenuItem;
    ReferenceAction: TAction;
    BackgroundAction: TAction;
    ConfigureAction: TAction;
    ImageList: TImageList;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    ClearSnapshotsItem: TMenuItem;
    BackgroundItem: TMenuItem;
    N3: TMenuItem;
    N2: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    Edit1: TMenuItem;
    UndoItem: TMenuItem;
    StatusBar: TStatusBar;
    ActionList: TActionList;
    NewAction: TAction;
    SaveAction: TAction;
    ExitAction: TAction;
    OpenAction: TAction;
    SaveAsAction: TAction;
    HelpAboutAction: TAction;
    MainToolBar: TToolBar;
    btnOpen: TToolButton;
    btnSave: TToolButton;
    BtnUndo: TToolButton;
    btnNew: TToolButton;
    ImageList16: TImageList;
    UndoAction: TAction;
    AcquisitionMenu: TMenuItem;
    tb04: TToolButton;
    btnDevices: TToolButton;
    tb05: TToolButton;
    BtnAbout: TToolButton;
    SaveConfigureAction: TAction;
    ConfigureSaveItem: TMenuItem;
    tb02: TToolButton;
    StartSaveAction: TAction;
    PauseSaveAction: TAction;
    StopSaveAction: TAction;
    SnapshotAction: TAction;
    StartSaveItem: TMenuItem;
    PauseSaveItem: TMenuItem;
    StopSaveItem: TMenuItem;
    SnapshotItem: TMenuItem;
    RedoAction: TAction;
    BtnRedo: TToolButton;
    RedoItem: TMenuItem;
    OpenImageDlg: TOpenDialog;
    SaveDataDlg: TSaveDialog;
    OpenMeasurementDlg: TOpenDialog;
    SaveMeasurementDlg: TSaveDialog;
    procedure AbsorbanceActionExecute(Sender: TObject);
    procedure AbsorbanceActionUpdate(Sender: TObject);
    procedure BackgroundActionExecute(Sender: TObject);
    procedure AxisClickToolClick(ASender: TChartTool; Axis: TChartAxis; AHitInfo: TChartAxisHitTests);
    procedure BackgroundActionUpdate(Sender: TObject);
    procedure chbElectricDarkChange(Sender: TObject);
    procedure chbStrobeChange(Sender: TObject);
    procedure ClearSnapshotsActionExecute(Sender: TObject);
    procedure ClearSnapshotsActionUpdate(Sender: TObject);
    procedure CopyClpBrdItemClick(Sender: TObject);
    procedure ConfigDeviceActionExecute(Sender: TObject);
    procedure ConfigDeviceActionUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IrradianceActionExecute(Sender: TObject);
    procedure IrradianceActionUpdate(Sender: TObject);
    procedure MainPlotMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure NewActionExecute(Sender: TObject);
    procedure NumericActionExecute(Sender: TObject);
    procedure NumericActionUpdate(Sender: TObject);
    procedure OpenActionExecute(Sender: TObject);
    procedure PauseSaveActionExecute(Sender: TObject);
    procedure PauseSaveActionUpdate(Sender: TObject);
    procedure RamanActionExecute(Sender: TObject);
    procedure RamanActionUpdate(Sender: TObject);
    procedure rbIntTimeMSChange(Sender: TObject);
    procedure rbIntTimeSChange(Sender: TObject);
    procedure ReferenceActionExecute(Sender: TObject);
    procedure ReferenceActionUpdate(Sender: TObject);
    procedure ReflectanceActionExecute(Sender: TObject);
    procedure ReflectanceActionUpdate(Sender: TObject);
    procedure RefreshDevicesActionExecute(Sender: TObject);
    procedure RefreshDevicesActionUpdate(Sender: TObject);
    procedure RescaleAllActionExecute(Sender: TObject);
    procedure RescaleAllActionUpdate(Sender: TObject);
    procedure RescaleXAxisActionExecute(Sender: TObject);
    procedure RescaleXAxisActionUpdate(Sender: TObject);
    procedure RescaleYAxisActionExecute(Sender: TObject);
    procedure RescaleYAxisActionUpdate(Sender: TObject);
    procedure RunStopActionExecute(Sender: TObject);
    procedure RunStopActionUpdate(Sender: TObject);
    procedure SaveActionExecute(Sender: TObject);
    procedure SaveActionUpdate(Sender: TObject);
    procedure SaveAsActionExecute(Sender: TObject);
    procedure HelpAboutActionExecute(Sender: TObject);
    procedure ExitActionExecute(Sender: TObject);
    procedure SaveConfigureActionExecute(Sender: TObject);
    procedure SaveConfigureActionUpdate(Sender: TObject);
    procedure ScopeActionExecute(Sender: TObject);
    procedure ScopeActionUpdate(Sender: TObject);
    procedure ScopeBgndActionExecute(Sender: TObject);
    procedure ScopeBgndActionUpdate(Sender: TObject);
    procedure seAverageScansEditingDone(Sender: TObject);
    procedure seBoxcarEditingDone(Sender: TObject);
    procedure seIntTimeEditingDone(Sender: TObject);
    procedure SnapshotActionExecute(Sender: TObject);
    procedure SnapshotActionUpdate(Sender: TObject);
    procedure StartSaveActionExecute(Sender: TObject);
    procedure StartSaveActionUpdate(Sender: TObject);
    procedure StartSaveAllActionExecute(Sender: TObject);
    procedure StartSaveAllActionUpdate(Sender: TObject);
    procedure StopSaveActionExecute(Sender: TObject);
    procedure StopSaveActionUpdate(Sender: TObject);
    procedure StopSaveAllActionExecute(Sender: TObject);
    procedure StopSaveAllActionUpdate(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure TransmittanceActionExecute(Sender: TObject);
    procedure TransmittanceActionUpdate(Sender: TObject);

    procedure HandleSBMessages(Level: TSBMessageType; const Msg: String);
  private
    { Private declarations }
    FSBInterface: TSBInterface;
    FMeasurements: TMeasurementList;
    FMeasurementFileName: TFileName;
    FSaveState: TSaveState;
    FCanUndo: Boolean;
    FCanRedo: Boolean;
    FIsChanged: Boolean;

    function GetIniName: TFileName;
    procedure UpdateComponents;

    procedure SetMeasurementFileName(Value: TFileName);
    procedure SetSaveState(Value: TSaveState);
    procedure SetActiveDataType(Value: TDataType);

    function GetSpectrometerFound: Boolean;
    function GetValidBackground: Boolean;
    function GetValidReference: Boolean;
    function GetActiveMeasurement: TMeasurement;
    function GetActiveDataType: TDataType;
  public
    { Public declarations }
    property MeasurementFileName: TFileName read FMeasurementFileName write SetMeasurementFileName;
    property SpectrometerFound: Boolean read GetSpectrometerFound;
    property ValidBackground: Boolean read GetValidBackground;
    property ValidReference: Boolean read GetValidReference;
    property ActiveMeasurement: TMeasurement read GetActiveMeasurement;
    property SaveState: TSaveState read FSaveState write SetSaveState;
    property ActiveDataType: TDataType read GetActiveDataType write SetActiveDataType;
    property CanUndo: Boolean read FCanUndo write FCanUndo;
    property CanRedo: Boolean read FCanRedo write FCanRedo;
    property IsChanged: Boolean read FIsChanged write FIsChanged;

    procedure Initialize;
    function OpenMeasurement(S: String): Boolean;
    procedure SaveMeasurement(FileName: TFileName);
  end;

var
  frmSpectral : TfrmSpectral;

const
  AppFullName = 'Spectral';

implementation

{$R *.lfm}

uses uAbout;

// Beginning of general functions
function DataTypeToString(Value: TDataType): String;
begin
  Result := DataTypeNames[Integer(Value)]
end;

function TfrmSpectral.GetIniName: TFileName;
var
  Path : TFileName;
begin
  Result := AppFullName + '.ini';

  Path := GetUserDir + '.spectral' + PathDelim;
  if not ForceDirectories(Path) then
    Path := '';

  Result := Path + Result;
end;

procedure TfrmSpectral.UpdateComponents;
begin
  gbIntTime.Enabled := SpectrometerFound and (ActiveMeasurement <> nil);// and (not ActiveMeasurement.Active);
  gbAverageScans.Enabled := SpectrometerFound and (ActiveMeasurement <> nil);// and (not ActiveMeasurement.Active);
  gbBoxcar.Enabled := SpectrometerFound and (ActiveMeasurement <> nil);// and (not ActiveMeasurement.Active);
  chbStrobe.Enabled := SpectrometerFound and (ActiveMeasurement <> nil);// and (not ActiveMeasurement.Active);
  chbElectricDark.Enabled := SpectrometerFound and (ActiveMeasurement <> nil);// and (not ActiveMeasurement.Active);
end;

procedure TfrmSpectral.HandleSBMessages(Level: TSBMessageType; const Msg: String);
begin
  MemoLog.Lines.Add(Format('[%s] %s', [TimeToStr(Now), Msg]));

  if Level = sbmError then
    MessageDlg('Critical Error: ' + Msg, mtError, [mbOK], 0);
end;

procedure TfrmSpectral.SetMeasurementFileName(Value: TFileName);
begin
  FMeasurementFileName := Value;

  if FMeasurementFileName = '' then
    frmSpectral.Caption := AppFullName
  else
    frmSpectral.Caption := AppFullName + ' - ' + ExtractFileName(FMeasurementFileName);
end;

procedure TfrmSpectral.SetSaveState(Value: TSaveState);
begin
  FSaveState := Value;
end;

procedure TfrmSpectral.SetActiveDataType(Value: TDataType);
begin
  if ActiveMeasurement <> nil then
  begin
    ActiveMeasurement.DataType := Value;
    MainPlot.LeftAxis.Title.Caption := DataTypeUnits[Integer(Value)];
  end;
end;

function TfrmSpectral.GetSpectrometerFound: Boolean;
begin
  Result := FSBInterface.NoSpectrometers > 0;
end;

function TfrmSpectral.GetValidBackground: Boolean;
begin
  Result := (ActiveMeasurement <> nil) and ActiveMeasurement.HasValidBackground;
end;

function TfrmSpectral.GetValidReference: Boolean;
begin
  Result := (ActiveMeasurement <> nil) and ActiveMeasurement.HasValidReference;
end;

function TfrmSpectral.GetActiveMeasurement: TMeasurement;
begin
  if (FMeasurements.Count > 0) and(TabControl.TabIndex >= 0) and
     (TabControl.TabIndex < FMeasurements.Count) then
    Result := FMeasurements[TabControl.TabIndex]
  else
    Result := nil;
end;

function TfrmSpectral.GetActiveDataType: TDataType;
begin
  if ActiveMeasurement <> nil then
    Result := ActiveMeasurement.DataType
  else
    Result := dtScope;
end;

function TfrmSpectral.OpenMeasurement(S: String): Boolean;
begin

end;

procedure TfrmSpectral.SaveMeasurement(FileName: TFileName);
begin
end;

procedure TfrmSpectral.Initialize;
begin
  // Initialize everything
  MeasurementFileName := '';
  SaveState := ssUnconfigured;
  if ActiveMeasurement <> nil then
    ActiveDataType := ActiveMeasurement.DataType;
  CanUndo := False;
  CanRedo := False;
  IsChanged := False;
end;
// End of general functions

// Beginning of file functions
procedure TfrmSpectral.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  //Verify that the measurement is saved before closing
    if IsChanged then
      Case MessageDlg('The measurement ''' + ExtractFileName(MeasurementFileName) + ''' was modified. Do you want to save it?',
                     mtInformation,[mbYes, mbNo, mbCancel], 0) of
        mrYes : begin
          frmSpectral.SaveActionExecute(frmSpectral);
          CanClose := True;
        end;
        mrNo : begin
          CanClose := True;
        end;
        mrCancel : begin
          CanClose := False;
        end;
      end;
end;

procedure TfrmSpectral.CopyClpBrdItemClick(Sender: TObject);
begin
  //Clipboard.AsText := Format('%.2f,%.4f', [ConvertCoords(TmpPoint.X, TmpPoint.Y).X, ConvertCoords(TmpPoint.X, TmpPoint.Y).Y])
end;

procedure TfrmSpectral.ConfigDeviceActionExecute(Sender: TObject);
//var i: Integer;
begin
  //for i := 0 to 16 do
  //  ShowMessage(FSBInterface.ActiveDevice.ActiveSpectrometer.EEPROMSlot[i]);
  ConfigurationDlg.Spectrometer := ActiveMeasurement.Acquisition.Spectrometer;
  if ConfigurationDlg.Execute then
  begin
    with ActiveMeasurement.Acquisition.Spectrometer do
    begin
      IntegrationTime := ConfigurationDlg.IntegrationTime;
      ScansToAverage := ConfigurationDlg.ScansToAverage;
      BoxcarWidth := ConfigurationDlg.BoxcarWidth;

      StrobeLampEnabled := ConfigurationDlg.StrobeLampEnabled;
      ElectricDarkEnabled := ConfigurationDlg.ElectricDarkEnabled;

      TriggerMode := ConfigurationDlg.TriggerMode;
    end;

    TabControlChange(Self);
  end;
end;

procedure TfrmSpectral.ConfigDeviceActionUpdate(Sender: TObject);
begin
  ConfigDeviceAction.Enabled := SpectrometerFound and (ActiveMeasurement <> nil) and (not ActiveMeasurement.Active);
end;

procedure TfrmSpectral.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
var
  i,
  nCount     : Integer;
  acFileName : String;
begin
//Open dragged files
  nCount := Length(FileNames);
  for i := 0 to nCount - 1 do
  begin
    acFileName := FileNames[i];
    MeasurementFileName := acFileName;//StrPas(acFileName);
    OpenMeasurement(MeasurementFileName);
  end;
end;

procedure TfrmSpectral.FormCreate(Sender: TObject);
begin
  // Standard window restoration
  GlobalWinRestorer := TWinRestorer.create(GetIniName, WHATSAVE_ALL);
  GlobalWinRestorer.RestoreWin(Self, [svSize, svLocation, svState, svPanels]);

  // Initialize SeaBreeze
  FSBInterface := TSBInterface.Create;
  FSBInterface.OnSBMessage := @HandleSBMessages;

  // Initialize the list of measurements
  FMeasurements := TMeasurementList.Create;

  RefreshDevicesActionExecute(Self);
  TabControlChange(Self);
end;

procedure TfrmSpectral.FormClose(Sender: TObject);
var
  i: Integer;
begin
  // Save and release window restorer
  if Assigned(GlobalWinRestorer) then
  begin
    GlobalWinRestorer.SaveWin(Self, [svSize, svLocation, svState, svPanels]);
    FreeAndNil(GlobalWinRestorer);
  end;

  // Clean up Measurement objects
  if Assigned(FMeasurements) then
  begin
    for i := 0 to FMeasurements.Count - 1 do
      FMeasurements[i].Free;
    FMeasurements.Free;
  end;

  // Shut down hardware and free the interface
  // This stops all background threads safely
  FreeAndNil(FSBInterface);
end;

procedure TfrmSpectral.FormShow(Sender: TObject);
begin
  {$ifdef darwin}
  // This fixes a bug in MacOs (TabControl is not following the Align 'alClient')
  frmSpectral.Width := frmSpectral.Width + 1;
  frmSpectral.Width := frmSpectral.Width - 1;
  {$endif}
end;

// End of form functions

// Beginning of file functions
procedure TfrmSpectral.NewActionExecute(Sender: TObject);
begin
//Create a new measurement
  Initialize;
  MeasurementFileName := 'noname.spm';
end;

procedure TfrmSpectral.OpenActionExecute(Sender: TObject);
var
  i     : Integer;
begin
//Open the measurement
  if OpenMeasurementDlg.Execute then
  begin
    for i := 0 to OpenMeasurementDlg.Files.Count - 1 do
      OpenMeasurement(OpenMeasurementDlg.Files[i]);
  end;
end;

procedure TfrmSpectral.SaveActionExecute(Sender: TObject);
var
  S : Boolean;
begin
  // Save the measurement
  SaveMeasurementDlg.FileName := MeasurementFileName;
  if FileExistsUTF8(SaveMeasurementDlg.FileName) then
    S := True
  else
    S := SaveMeasurementDlg.Execute;
  if S then SaveMeasurement(SaveMeasurementDlg.FileName);
end;

procedure TfrmSpectral.SaveActionUpdate(Sender: TObject);
begin
  SaveAction.Enabled := IsChanged;
end;

procedure TfrmSpectral.SaveAsActionExecute(Sender: TObject);
begin
  // Save the measurement with a different name
  SaveMeasurementDlg.FileName := MeasurementFileName;
  if SaveMeasurementDlg.Execute then SaveMeasurement(SaveMeasurementDlg.FileName);
end;

procedure TfrmSpectral.ExitActionExecute(Sender: TObject);
begin
  Close;
end;
// End of file functions

// Beginning of adquisition actions
procedure TfrmSpectral.SaveConfigureActionExecute(Sender: TObject);
begin
  if (ActiveMeasurement <> nil) then
    if SaveSpectraDlg.Execute(ActiveMeasurement.Acquisition.SaveConfig) then
    begin
      ActiveMeasurement.Acquisition.SaveConfig := SaveSpectraDlg.SaveConfig;
      SaveState := ssConfigured;
    end;
end;

procedure TfrmSpectral.SaveConfigureActionUpdate(Sender: TObject);
begin
  SaveConfigureAction.Enabled := (ActiveMeasurement <> nil) and
                                 (ActiveMeasurement.Acquisition <> nil) and
                                 (ActiveMeasurement.Acquisition.SaveStatus in [sstIdle, sstPaused]);
end;

procedure TfrmSpectral.StartSaveActionExecute(Sender: TObject);
begin
  ActiveMeasurement.StartSaving;
  MemoLog.Lines.Add(Format('Saving started for %s', [ActiveMeasurement.Acquisition.Spectrometer.SerialNumber]));
end;

procedure TfrmSpectral.StartSaveActionUpdate(Sender: TObject);
begin
  StartSaveAction.Enabled := (ActiveMeasurement <> nil) and
                             (ActiveMeasurement.Acquisition <> nil) and
                             (ActiveMeasurement.Acquisition.SaveStatus in [sstIdle, sstPaused]) and
                             (ActiveMeasurement.Acquisition.ReadyToSave);
end;

procedure TfrmSpectral.StartSaveAllActionExecute(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FMeasurements.Count - 1 do
    FMeasurements[i].StartSaving;

  MemoLog.Lines.Add('Start command sent to all validly configured spectrometers.');
end;

procedure TfrmSpectral.StartSaveAllActionUpdate(Sender: TObject);
var
  i: Integer;
  AtLeastOneValid: Boolean;
begin
  AtLeastOneValid := False;

  for i := 0 to FMeasurements.Count - 1 do
    if FMeasurements[i].ReadyToSave then
    begin
      AtLeastOneValid := True;
      Break;
    end;

  StartSaveAllAction.Enabled := AtLeastOneValid;
end;

procedure TfrmSpectral.PauseSaveActionExecute(Sender: TObject);
begin
  if ActiveMeasurement <> nil then
    ActiveMeasurement.PauseSaving;
end;

procedure TfrmSpectral.PauseSaveActionUpdate(Sender: TObject);
begin
  PauseSaveAction.Enabled := (ActiveMeasurement <> nil) and
                             (ActiveMeasurement.Acquisition <> nil) and
                             (ActiveMeasurement.Acquisition.SaveStatus = sstSaving);
end;

procedure TfrmSpectral.StopSaveActionExecute(Sender: TObject);
begin
  if ActiveMeasurement <> nil then
    ActiveMeasurement.StopSaving;
end;

procedure TfrmSpectral.StopSaveActionUpdate(Sender: TObject);
begin
  StopSaveAction.Enabled := (ActiveMeasurement <> nil) and
                            (ActiveMeasurement.Acquisition <> nil) and
                            (ActiveMeasurement.Acquisition.SaveStatus in [sstSaving, sstPaused]);
end;

procedure TfrmSpectral.StopSaveAllActionExecute(Sender: TObject);
var i: Integer;
begin
  for i := 0 to FMeasurements.Count - 1 do
    FMeasurements[i].StopSaving;

  MemoLog.Lines.Add('Saving stopped for all spectrometers.');
end;

procedure TfrmSpectral.StopSaveAllActionUpdate(Sender: TObject);
var
  i: Integer;
  AtLeastOneActive: Boolean;
begin
  AtLeastOneActive := False;

  for i := 0 to FMeasurements.Count - 1 do
  begin
    if (FMeasurements[i].Acquisition <> nil) and
       (FMeasurements[i].Acquisition.SaveStatus in [sstSaving, sstPaused]) then
    begin
      AtLeastOneActive := True;
      Break;
    end;
  end;

  StopSaveAllAction.Enabled := AtLeastOneActive;
end;

procedure TfrmSpectral.TabControlChange(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FMeasurements.Count - 1 do
    if FMeasurements[i] <> nil then
      FMeasurements[i].IsVisible := (i = TabControl.TabIndex);

  if (ActiveMeasurement <> nil) then
  begin
    ActiveDataType := ActiveMeasurement.DataType;

    if (ActiveMeasurement.Acquisition <> nil) and
        Assigned(ActiveMeasurement.Acquisition.Spectrometer) then
    begin
      with ActiveMeasurement.Acquisition.Spectrometer do
      begin
        if (IntegrationTime >= 1000000) then
        begin
          rbIntTimeS.Checked := True;
          seIntTime.Value := IntegrationTime div 1000000;
        end
        else
        begin
          rbIntTimeMS.Checked := True;
          seIntTime.Value := IntegrationTime div 1000;
        end;

        seAverageScans.Value := ScansToAverage;
        seBoxcar.Value := BoxcarWidth;

        chbStrobe.Checked := StrobeLampEnabled;
        chbElectricDark.Checked := ElectricDarkEnabled;
      end;
    end;
  end;

  UpdateComponents;
end;

procedure TfrmSpectral.SnapshotActionExecute(Sender: TObject);
begin
  if ActiveMeasurement <> nil then
  begin
    ActiveMeasurement.TakeSnapshot;
    MemoLog.Lines.Add(FormatDateTime('[hh:nn:ss] ', Now) + 'Snapshot captured for: ' + TabControl.Tabs[TabControl.TabIndex]);
    MainPlot.Invalidate;
  end;
end;

procedure TfrmSpectral.SnapshotActionUpdate(Sender: TObject);
begin
  SnapshotAction.Enabled := (ActiveMeasurement <> nil) and
                             ActiveMeasurement.HasValidSpectrometer and
                             ActiveMeasurement.Active;
end;

procedure TfrmSpectral.BackgroundActionExecute(Sender: TObject);
begin
  ActiveMeasurement.ReadBackground;
end;

procedure TfrmSpectral.ReferenceActionExecute(Sender: TObject);
begin
  ActiveMeasurement.ReadReference;
end;

procedure TfrmSpectral.ReferenceActionUpdate(Sender: TObject);
begin
  ReferenceAction.Enabled := (ActiveMeasurement <> nil) and
                              ActiveMeasurement.HasValidSpectrometer and
                              ActiveMeasurement.Active;
end;

procedure TfrmSpectral.RunStopActionExecute(Sender: TObject);
begin
  if (ActiveMeasurement <> nil) then
  begin
    ActiveMeasurement.Active := not ActiveMeasurement.Active;
    ActiveMeasurement.IsVisible := True;

    if ActiveMeasurement.Active then
    begin
      RunStopAction.Caption := '&Stop adquisition';
      RunStopAction.Hint := 'Stop|Stop adquisition';
      RunStopAction.ImageIndex := 20;

      StatusBar.Panels[2].Text := 'Status: Acquiring...'
    end
    else
    begin
      RunStopAction.Caption := '&Run adquisition';
      RunStopAction.Hint := 'Run|Run adquisition with the active device(s)';
      RunStopAction.ImageIndex := 19;

      StatusBar.Panels[2].Text := 'Status: Stopped';
    end;

    StatusBar.Panels[3].Text := Format('Active Device: %s', [ActiveMeasurement.Acquisition.Spectrometer.SerialNumber]);
  end
  else
    StatusBar.Panels[3].Text := 'No devices. Click Refresh.';

  UpdateComponents;
end;

procedure TfrmSpectral.RunStopActionUpdate(Sender: TObject);
begin
  RunStopAction.Enabled := SpectrometerFound;
  RunStopAction.Checked := (ActiveMeasurement <> nil) and ActiveMeasurement.Active;
end;

// End of adquisition actions

// Beginning of view actions
procedure TfrmSpectral.ScopeActionExecute(Sender: TObject);
begin
  ActiveDataType := dtScope;
  ActiveMeasurement.RescalePlot;
end;

procedure TfrmSpectral.ScopeActionUpdate(Sender: TObject);
begin
  ScopeAction.Enabled := (ActiveMeasurement <> nil) and ActiveMeasurement.HasValidSpectrometer;
  ScopeAction.Checked := (ActiveDataType = dtScope);
end;

procedure TfrmSpectral.ScopeBgndActionExecute(Sender: TObject);
begin
  ActiveDataType := dtScopeBgnd;
  ActiveMeasurement.RescalePlot;
end;

procedure TfrmSpectral.ScopeBgndActionUpdate(Sender: TObject);
begin
  ScopeBgndAction.Enabled := (ActiveMeasurement <> nil) and
                              ActiveMeasurement.HasValidSpectrometer and
                              ActiveMeasurement.HasValidBackground;
  ScopeBgndAction.Checked := (ActiveDataType = dtScopeBgnd);
end;

procedure TfrmSpectral.seAverageScansEditingDone(Sender: TObject);
begin
  with ActiveMeasurement.Acquisition.Spectrometer do
    if (seAverageScans.Value <> ScansToAverage) then
      ScansToAverage := seAverageScans.Value;
end;

procedure TfrmSpectral.seBoxcarEditingDone(Sender: TObject);
begin
  with ActiveMeasurement.Acquisition.Spectrometer do
    if (seBoxcar.Value <> BoxcarWidth) then
      BoxcarWidth := seBoxcar.Value;
end;

procedure TfrmSpectral.seIntTimeEditingDone(Sender: TObject);
var
  NewIntTime: DWord;
begin
  if rbIntTimeMS.Checked then
    NewIntTime := DWord(Round(seIntTime.Value*1000))
  else
    NewIntTime := DWord(Round(seIntTime.Value*1000000));

  with ActiveMeasurement.Acquisition.Spectrometer do
    if (NewIntTime <> IntegrationTime) then
      IntegrationTime := NewIntTime;
end;

procedure TfrmSpectral.AbsorbanceActionExecute(Sender: TObject);
var
  Scale: TDoubleRect;
  PlotExtent: TPlotExtent;
begin
  ActiveDataType := dtAbsorbance;

  Scale := MainPlot.GetFullExtent;

  with PlotExtent do
  begin
    XMin := Scale.a.X;
    XMax := Scale.b.X;
    YMin := 0.0;
    YMax := 2.0;

    UseXMin := False;
    UseXMax := False;
    UseYMin := True;
    UseYMax := True;
  end;

  ActiveMeasurement.PlotExtent := PlotExtent;
end;

procedure TfrmSpectral.AbsorbanceActionUpdate(Sender: TObject);
begin
  AbsorbanceAction.Enabled := (ActiveMeasurement <> nil) and
                               ActiveMeasurement.HasValidSpectrometer and
                               ActiveMeasurement.HasValidBackground and
                               ActiveMeasurement.HasValidReference;
  AbsorbanceAction.Checked := (ActiveDataType = dtAbsorbance);
end;

procedure TfrmSpectral.TransmittanceActionExecute(Sender: TObject);
var
  Scale: TDoubleRect;
  PlotExtent: TPlotExtent;
begin
  ActiveDataType := dtTransmittance;

  Scale := MainPlot.GetFullExtent;

  with PlotExtent do
  begin
    XMin := Scale.a.X;
    XMax := Scale.b.X;
    YMin := 0.0;
    YMax := 1.1;

    UseXMin := False;
    UseXMax := False;
    UseYMin := True;
    UseYMax := True;
  end;

  ActiveMeasurement.PlotExtent := PlotExtent;
end;

procedure TfrmSpectral.TransmittanceActionUpdate(Sender: TObject);
begin
  TransmittanceAction.Enabled := (ActiveMeasurement <> nil) and
                                  ActiveMeasurement.HasValidSpectrometer and
                                  ActiveMeasurement.HasValidBackground and
                                  ActiveMeasurement.HasValidReference;
  TransmittanceAction.Checked := (ActiveDataType = dtTransmittance);
end;

procedure TfrmSpectral.ReflectanceActionExecute(Sender: TObject);
var
  Scale: TDoubleRect;
  PlotExtent: TPlotExtent;
begin
  ActiveDataType := dtReflectance;

  Scale := MainPlot.GetFullExtent;

  with PlotExtent do
  begin
    XMin := Scale.a.X;
    XMax := Scale.b.X;
    YMin := 0.0;
    YMax := 1.1;

    UseXMin := False;
    UseXMax := False;
    UseYMin := True;
    UseYMax := True;
  end;

  ActiveMeasurement.PlotExtent := PlotExtent;
end;

procedure TfrmSpectral.ReflectanceActionUpdate(Sender: TObject);
begin
  ReflectanceAction.Enabled := (ActiveMeasurement <> nil) and
                                ActiveMeasurement.HasValidSpectrometer and
                                ActiveMeasurement.HasValidBackground and
                                ActiveMeasurement.HasValidReference;
  ReflectanceAction.Checked := (ActiveDataType = dtReflectance);
end;

procedure TfrmSpectral.RefreshDevicesActionExecute(Sender: TObject);
var
  i: Integer;
  NewMeas: TMeasurement;
begin
  RunStopAction.Checked := False;

  // Clean up
  for i := 0 to FMeasurements.Count - 1 do
    FMeasurements[i].Free;

  FMeasurements.Clear;
  TabControl.Tabs.Clear;

  FSBInterface.HardReset;

  // Build new measurement objects
  for i := 0 to FSBInterface.NoSpectrometers - 1 do
  begin
    NewMeas := TMeasurement.Create(MainPlot);
    NewMeas.AddAcquisition(FSBInterface.Spectrometers[i]);

    FMeasurements.Add(NewMeas);

    TabControl.Tabs.Add(Format('Spec %d (%s)', [i, FSBInterface.Spectrometers[i].SerialNumber]));
  end;

  if SpectrometerFound then
    TabControl.TabIndex := 0
  else
    TabControl.TabIndex := -1;

  Initialize;
end;

procedure TfrmSpectral.RefreshDevicesActionUpdate(Sender: TObject);
begin
  RefreshDevicesAction.Enabled := (ActiveMeasurement = nil) or (not ActiveMeasurement.Active);
end;

procedure TfrmSpectral.IrradianceActionExecute(Sender: TObject);
begin
  ActiveDataType := dtIrradiance;
  ActiveMeasurement.RescalePlot;
end;

procedure TfrmSpectral.IrradianceActionUpdate(Sender: TObject);
begin
  IrradianceAction.Enabled := False;
end;

procedure TfrmSpectral.RamanActionExecute(Sender: TObject);
begin
  ActiveDataType := dtRaman;
  ActiveMeasurement.RescalePlot;
end;

procedure TfrmSpectral.RamanActionUpdate(Sender: TObject);
begin
  RamanAction.Enabled := False;
end;

procedure TfrmSpectral.rbIntTimeMSChange(Sender: TObject);
begin
  if rbIntTimeMS.Checked then
    seIntTime.Value := seIntTime.Value*1000;
end;

procedure TfrmSpectral.rbIntTimeSChange(Sender: TObject);
begin
  if rbIntTimeS.Checked then
  seIntTime.Value := seIntTime.Value/1000;
end;

// End of view actions

// Beginning of plot actions
procedure TfrmSpectral.MainPlotMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Pos: TDoublePoint;
begin
  if (MainPlot.Width > 0) and (MainPlot.Height > 0) and MainPlot.HandleAllocated then
  begin
    try
      Pos := MainPlot.ImageToGraph(Point(X,Y));
      StatusBar.Panels[1].Text := Format('%8.2f,%8.2f', [Pos.X, Pos.Y]);
    except
      StatusBar.Panels[1].Text := '---';
    end;
  end;
end;

procedure TfrmSpectral.AxisClickToolClick(ASender: TChartTool;
  Axis: TChartAxis; AHitInfo: TChartAxisHitTests);
begin
  if TIPropertyGrid.TIObject <> Axis then
  begin
    TIPropertyGrid.TIObject := Axis;
    TIPropertyGrid.Visible := True;
    MainSplitter.Visible := True;
  end
  else
  begin
    TIPropertyGrid.TIObject := nil;
    TIPropertyGrid.Visible := False;
    MainSplitter.Visible := False;
  end;
end;

procedure TfrmSpectral.BackgroundActionUpdate(Sender: TObject);
begin
  BackgroundAction.Enabled := (ActiveMeasurement <> nil) and
                               ActiveMeasurement.HasValidSpectrometer and
                               ActiveMeasurement.Active;
end;

procedure TfrmSpectral.chbElectricDarkChange(Sender: TObject);
begin
  if (ActiveMeasurement <> nil) then
    with ActiveMeasurement.Acquisition.Spectrometer do
      if (ElectricDarkEnabled <> chbElectricDark.Checked) then
        ElectricDarkEnabled := chbElectricDark.Checked;
end;

procedure TfrmSpectral.chbStrobeChange(Sender: TObject);
begin
  if (ActiveMeasurement <> nil) then
    with ActiveMeasurement.Acquisition.Spectrometer do
      if (StrobeLampEnabled <> chbStrobe.Checked) then
        StrobeLampEnabled := chbStrobe.Checked;
end;

procedure TfrmSpectral.ClearSnapshotsActionExecute(Sender: TObject);
begin
  if (ActiveMeasurement <> nil) and
     (MessageDlg('Clear all snapshots for this tab?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    ActiveMeasurement.ClearSnapshots;
    MemoLog.Lines.Add(FormatDateTime('[hh:nn:ss] ', Now) + 'Snapshots cleared.');
    MainPlot.Invalidate;
  end;
end;

procedure TfrmSpectral.ClearSnapshotsActionUpdate(Sender: TObject);
begin
  ClearSnapshotsAction.Enabled := (ActiveMeasurement <> nil) and ActiveMeasurement.HasSnapshots;
end;

// End of plot actions

// Beginning of zoom actions
procedure TfrmSpectral.NumericActionExecute(Sender: TObject);
var
  Scale: TDoubleRect;
  PlotExtent: TPlotExtent;
begin
  Scale := MainPlot.LogicalExtent;
  if RangeDlg.Execute(Scale.a.X, Scale.b.X, Scale.a.Y, Scale.b.Y) then
  begin
    with PlotExtent do
    begin
      XMin := RangeDlg.XMin;
      XMax := RangeDlg.XMax;
      YMin := RangeDlg.YMin;
      YMax := RangeDlg.YMax;

      UseXMin := True;
      UseXMax := True;
      UseYMin := True;
      UseYMax := True;
    end;

    ActiveMeasurement.PlotExtent := PlotExtent;
  end;
end;

procedure TfrmSpectral.NumericActionUpdate(Sender: TObject);
begin
  NumericAction.Enabled := (ActiveMeasurement <> nil) and
                            ActiveMeasurement.HasValidSpectrometer;
end;

procedure TfrmSpectral.RescaleAllActionExecute(Sender: TObject);
begin
  ActiveMeasurement.RescalePlot;
end;

procedure TfrmSpectral.RescaleAllActionUpdate(Sender: TObject);
begin
  RescaleAllAction.Enabled := (ActiveMeasurement <> nil) and
                               ActiveMeasurement.HasValidSpectrometer;
end;

procedure TfrmSpectral.RescaleXAxisActionExecute(Sender: TObject);
begin
  ActiveMeasurement.RescaleXAxis;
end;

procedure TfrmSpectral.RescaleXAxisActionUpdate(Sender: TObject);
begin
  RescaleXAxisAction.Enabled := (ActiveMeasurement <> nil) and
                                 ActiveMeasurement.HasValidSpectrometer;
end;

procedure TfrmSpectral.RescaleYAxisActionExecute(Sender: TObject);
begin
  ActiveMeasurement.RescaleYAxis;
end;

procedure TfrmSpectral.RescaleYAxisActionUpdate(Sender: TObject);
begin
  RescaleYAxisAction.Enabled := (ActiveMeasurement <> nil) and
                                 ActiveMeasurement.HasValidSpectrometer;
end;

// End of zoom actions

procedure TfrmSpectral.HelpAboutActionExecute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

end.
