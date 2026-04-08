unit Measurements;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  Classes, SysUtils, ExtCtrls, Math, TASeries, TAGraph, fgl, SptTypes,
  SBDevices, Spectra, Dialogs, DateUtils, Graphics, TAChartUtils, SyncObjs;

const
  SNAPSHOT_COLORS: array[0..12] of TColor = (clRed, clBlue, clGreen, clOlive,
                                             clPurple, clTeal, clMaroon, clLime,
                                             clNavy, clFuchsia, clAqua, clGray,
                                             clSilver);

type
  TSaveCriteria = (scAll, scEveryNth, scTimed);
  TStopCriteria = (scManual, scCount, scTime);
  TStopConditions = set of TStopCriteria;
  TTimeUnits = (tuMilliSeconds, tuSeconds);
  TFileFormat = (ffXML, ffTXT);
  TFileSuffix = (fsTimeStamp, fsCounter);
  TSaveStatus = (sstIdle, sstSaving, sstPaused);

  TSaveConfig = record
    // Saving Configuration
    SaveCriteria: TSaveCriteria;
    SpectrumNumber: Integer;
    SaveTime: Double;
    SaveTimeUnits: TTimeUnits;

    StopCriteria: TStopConditions;
    StopCount: Integer;
    StopTime: Double;
    StopTimeUnits: TTimeUnits;

    FileFormat: TFileFormat;
    SaveDir: String;
    BaseName: String;

    FileSuffix: TFileSuffix;
    Padding: Integer;

    class function CreateDefault: TSaveConfig; static;
  end;

  TPlotExtent = record
    XMin: Double;
    XMax: Double;
    YMin: Double;
    YMax: Double;

    UseXMin: Boolean;
    UseXMax: Boolean;
    UseYMin: Boolean;
    UseYMax: Boolean;
  end;

  // Holds a static snapshot of everything needed to write the file
  TSaveTask = class
    XData: array of Double;
    YData: array of Double;
    FileName: String;
    FileFormat: TFileFormat;

    // Metadata pre-gathered from the main thread
    DateStr: String;
    Usr: String;
    SN: String;
    DarkPresent: Boolean;
    RefPresent: Boolean;
    IntegrationTime: DWord;
    ScansToAverage: Word;
    BoxcarWidth: Byte;
    ElectricDarkEnabled: Boolean;
    StrobeLampEnabled: Boolean;
  end;

  TSaveTaskList = specialize TFPGList<TSaveTask>;

  TSaveQueueThread = class(TThread)
  private
    FQueue: TSaveTaskList;
    FLock: TCriticalSection;
    FEvent: TEvent;

    procedure SaveAsTXT(Task: TSaveTask);
    procedure SaveAsXML(Task: TSaveTask);
    procedure ProcessTask(Task: TSaveTask);
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Enqueue(Task: TSaveTask);
  end;

  TSnapshot = class(TObject)
  private
    FSpectrum: TSpectrum;
    FSerie: TLineSeries;
    FChart: TChart;
  public
    constructor Create(ASpectrum: TSpectrum; AChart: TChart; AColor: TColor);
    destructor Destroy; override;
    property Spectrum: TSpectrum read FSpectrum;
    property Serie: TLineSeries read FSerie;
  end;

  TSnapshotList = specialize TFPGList<TSnapshot>;

  TAcquisition = class(TObject)
  private
    { Private declarations }
    // Queue to save spectra
    FSaveQueue: TSaveQueueThread;

    // Saving Configuration
    FSaveConfig: TSaveConfig;

    // State Tracking
    FSaveStatus: TSaveStatus;
    FIsVisible: Boolean;
    FAcqPaused: Boolean;
    FStartTime: TDateTime;
    FSavedCount: Integer;
    FProcessedCount: Integer;
    FLastSaveTime: TDateTime;

    FSerie: TLineSeries;
    FTimer: TTimer;
    FSpectrometer: TSBSpectrometer;
    FDataType: TDataType;
    FSpectrum: TSpectrum;
    FBackground: TSpectrum;
    FReference: TSpectrum;
    FIsDarkPixel: array of Boolean;

    function ReadSptData(var Spt: TSpectrum): Boolean;

    function GetActive: Boolean;
    function GetIntegrationTime: DWord;
    function GetScansToAverage: Word;
    function GetBoxcarWidth: Byte;
    function GetStrobeLampEnabled: Boolean;
    function GetElectricDarkEnabled: Boolean;
    function GetFmtSpectrum(DataType: TDataType): TSpectrum;

    procedure SetActive(Value: Boolean);
    procedure SetSpectrometer(Value: TSBSpectrometer);
    procedure UpdateDarkPixelCache;
    procedure SetIntegrationTime(Value: DWord);
    procedure SetScansToAverage(Value: Word);
    procedure SetBoxcarWidth(Value: Byte);
    procedure SetStrobeLampEnabled(Value: Boolean);
    procedure SetElectricDarkEnabled(Value: Boolean);

    procedure OnTimerTick(Sender: TObject);
    function ValidateSaveConfig: Boolean;
    procedure SaveToDisk(ASpectrum: TSpectrum);
  protected
    { Protected declarations }
  public
    { Public declarations }
    {@exclude}
    constructor Create(Spectrometer: TSBSpectrometer; IntegrationTime: DWord; ScansToAverage: Word; BoxcarWidth: Byte); overload;
    {@exclude}
    constructor Create(Spectrometer: TSBSpectrometer; IntegrationTime: DWord; ScansToAverage: Word); overload;
    {@exclude}
    constructor Create(Spectrometer: TSBSpectrometer; IntegrationTime: DWord); overload;
    {@exclude}
    constructor Create(Spectrometer: TSBSpectrometer); overload;
    {@exclude}
    destructor  Destroy; override;

    function ReadSpectrum: Boolean;
    function ReadBackground: Boolean;
    function ReadReference: Boolean;

    function HasValidSpectrometer: Boolean;
    function HasValidBackground: Boolean;
    function HasValidReference: Boolean;

    procedure StartSaving;
    procedure PauseSaving;
    procedure StopSaving;

    property IsVisible: Boolean read FIsVisible write FIsVisible;
    property AcqPaused: Boolean read FAcqPaused write FAcqPaused;

    property SaveConfig: TSaveConfig read FSaveConfig write FSaveConfig;
    property ReadyToSave: Boolean read ValidateSaveConfig;
    property SaveStatus: TSaveStatus read FSaveStatus;

    property Serie: TLineSeries read FSerie;

    property Active: Boolean read GetActive write SetActive;

    property Spectrometer: TSBSpectrometer read FSpectrometer write SetSpectrometer;

    property Spectrum: TSpectrum read FSpectrum;
    property Background: TSpectrum read FBackground;
    property Reference: TSpectrum read FReference;

    property FmtSpectrum[DataType: TDataType]: TSpectrum read GetFmtSpectrum;
    property DataType: TDataType read FDataType write FDataType;

    property IntegrationTime: DWord read GetIntegrationTime write SetIntegrationTime;
    property ScansToAverage: Word read GetScansToAverage write SetScansToAverage;
    property BoxcarWidth: Byte read GetBoxcarWidth write SetBoxcarWidth;
    property StrobeLampEnabled: Boolean read GetStrobeLampEnabled write SetStrobeLampEnabled;
    property ElectricDarkEnabled: Boolean read GetElectricDarkEnabled write SetElectricDarkEnabled;
  end;

  TAcquisitionList = specialize TFPGList<TAcquisition>;

  TMeasurement = class(TObject)
  private
    { Private declarations }
    FChart: TChart;
    FAcquisition: TAcquisition;
    FDataType: TDataType;
    FPlotExtent: TPlotExtent;
    FSnapshots: TSnapshotList;

    function GetActive: Boolean;
    function GetIsVisible: Boolean;
    function GetAcquisition: TAcquisition;
    function GetChart: TChart;
    function GetPlotExtent: TPlotExtent;

    procedure SetActive(Value: Boolean);
    procedure SetIsVisible(Value: Boolean);
    procedure SetAcquisition(Value: TAcquisition);
    procedure SetChart(Value: TChart);
    procedure SetPlotExtent(Value: TPlotExtent);
    procedure SetDataType(Value: TDataType);

    function ValidateSaveConfig: Boolean;
    procedure HandleHardwareParamsChanged(Sender: TObject);
  protected
    { Protected declarations }
  public
    { Public declarations }
    {@exclude}
    constructor Create(Chart: TChart);
    {@exclude}
    destructor  Destroy; override;

    function ReadSpectrum: Boolean;
    function ReadBackground: Boolean;
    function ReadReference: Boolean;

    function HasValidSpectrometer: Boolean;
    function HasValidBackground: Boolean;
    function HasValidReference: Boolean;
    function HasSnapshots: Boolean;

    procedure StartSaving;
    procedure PauseSaving;
    procedure StopSaving;

    procedure TakeSnapshot;
    procedure ClearSnapshots;

    procedure RescalePlot;
    procedure RescaleXAxis;
    procedure RescaleYAxis;

    property Active: Boolean read GetActive write SetActive;
    property IsVisible: Boolean read GetIsVisible write SetIsVisible;

    property Acquisition: TAcquisition read GetAcquisition write SetAcquisition;
    property ReadyToSave: Boolean read ValidateSaveConfig;

    procedure AddAcquisition(Spectrometer: TSBSpectrometer); overload;
    procedure AddAcquisition(Spectrometer: TSBSpectrometer; IntegrationTime: DWord; ScansToAverage: Word; BoxcarWidth: Byte); overload;
    procedure ClearAcquisition;

    property Chart: TChart read GetChart write SetChart;
    property PlotExtent: TPlotExtent read GetPlotExtent write SetPlotExtent;
    property DataType: TDataType read FDataType write SetDataType;
    property Snapshots: TSnapshotList read FSnapshots;
  end;

  TMeasurementList = specialize TFPGList<TMeasurement>;

implementation


class function TSaveConfig.CreateDefault: TSaveConfig;
begin
  with Result do
  begin
    SaveCriteria := scAll;
    SpectrumNumber := 10;
    SaveTime := 1.0;
    SaveTimeUnits := tuSeconds;

    StopCriteria := [scManual];
    StopCount := 10;
    StopTime := 1.0;
    StopTimeUnits := tuSeconds;

    FileFormat := ffTXT;
    SaveDir := '';
    BaseName := '';

    FileSuffix := fsCounter;
    Padding := 5;
  end;
end;

//*****************************************************************************/
//* Implementation of 'TSaveQueueThread'                                      */
//*****************************************************************************/
constructor TSaveQueueThread.Create;
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FQueue := TSaveTaskList.Create;
  FLock := TCriticalSection.Create;
  // Manual reset = False (Auto-reset), InitialState = False
  FEvent := TEvent.Create(nil, False, False, '');
end;

destructor TSaveQueueThread.Destroy;
var
  i: Integer;
begin
  Terminate;
  FEvent.SetEvent; // Wake the thread up so it can see the Terminate flag
  WaitFor;         // Wait for the thread to safely finish its current write

  // Clean up any remaining unwritten tasks
  for i := 0 to FQueue.Count - 1 do
    FQueue[i].Free;

  FQueue.Free;
  FLock.Free;
  FEvent.Free;
  inherited Destroy;
end;

procedure TSaveQueueThread.Enqueue(Task: TSaveTask);
begin
  FLock.Enter;
  try
    FQueue.Add(Task);
  finally
    FLock.Leave;
  end;
  FEvent.SetEvent; // Signal the thread that there's work to do
end;

procedure TSaveQueueThread.Execute;
var
  Task: TSaveTask;
begin
  while not Terminated do
  begin
    // Sleep until FEvent.SetEvent is called (Wait indefinitely)
    if FEvent.WaitFor(INFINITE) = wrSignaled then
    begin
      // Process everything currently in the queue
      while not Terminated do
      begin
        Task := nil;
        FLock.Enter;
        try
          if FQueue.Count > 0 then
          begin
            Task := FQueue[0];
            FQueue.Delete(0);
          end;
        finally
          FLock.Leave;
        end;

        if Assigned(Task) then
        begin
          try
            ProcessTask(Task);
          finally
            Task.Free; // Free the task memory after writing
          end;
        end
        else
          Break; // Queue is empty, break out and go back to sleep
      end;
    end;
  end;
end;

// Private Format Helpers
procedure TSaveQueueThread.SaveAsTXT(Task: TSaveTask);
var
  SL: TStringList;
  i: Integer;
  Fmt: TFormatSettings;

  function BoolToYesNo(B: Boolean): String;
  begin
    if B then Result := 'Yes' else Result := 'No';
  end;

begin
  Fmt := DefaultFormatSettings;
  Fmt.DecimalSeparator := '.';

  SL := TStringList.Create;
  try
    SL.Add('Spectral Data File');
    SL.Add('++++++++++++++++++++++++++++++++++++');
    SL.Add('Date: ' + Task.DateStr);
    SL.Add('User: ' + Task.Usr);
    SL.Add('Dark Spectrum Present: ' + BoolToYesNo(Task.DarkPresent));
    SL.Add('Reference Spectrum Present: ' + BoolToYesNo(Task.RefPresent));
    SL.Add('Number of Sampled Component Spectra: 1');
    SL.Add('Spectrometers: ' + Task.SN);
    SL.Add(Format('Integration Time (usec): %d (%s)', [Task.IntegrationTime, Task.SN]));
    SL.Add(Format('Spectra Averaged: %d (%s)', [Task.ScansToAverage, Task.SN]));
    SL.Add(Format('Boxcar Smoothing: %d (%s)', [Task.BoxcarWidth, Task.SN]));
    SL.Add(Format('Correct for Electrical Dark: %s (%s)', [BoolToYesNo(Task.ElectricDarkEnabled), Task.SN]));
    SL.Add(Format('Strobe/Lamp Enabled: %s (%s)', [BoolToYesNo(Task.StrobeLampEnabled), Task.SN]));
    SL.Add(Format('Correct for Detector Non-linearity: No (%s)', [Task.SN]));
    SL.Add(Format('Correct for Stray Light: No (%s)', [Task.SN]));
    SL.Add(Format('Number of Pixels in Processed Spectrum: %d', [Length(Task.XData)]));
    SL.Add('>>>>>Begin Processed Spectral Data<<<<<');

    for i := 0 to High(Task.XData) do
      SL.Add(Format('%.2f' + #9 + '%.5f', [Task.XData[i], Task.YData[i]], Fmt));

    SL.Add('>>>>>End Processed Spectral Data<<<<<');
    SL.SaveToFile(Task.FileName);
  finally
    SL.Free;
  end;
end;

procedure TSaveQueueThread.SaveAsXML(Task: TSaveTask);
var
  SL: TStringList;
  i: Integer;
  Fmt: TFormatSettings;

  function BoolToYesNo(B: Boolean): String;
  begin
    if B then Result := 'Yes' else Result := 'No';
  end;

begin
  Fmt := DefaultFormatSettings;
  Fmt.DecimalSeparator := '.';

  SL := TStringList.Create;
  try
    SL.Add('<?xml version="1.0" encoding="UTF-8"?>');
    SL.Add('<SingleSpectrum>');
    SL.Add(Format('  <Header Date="%s" User="%s" SerialNumber="%s" />',
           [Task.DateStr, Task.Usr, Task.SN]));

    SL.Add('  <HardwareConfiguration>');
    SL.Add(Format('    <IntegrationTime units="usec">%d</IntegrationTime>', [Task.IntegrationTime]));
    SL.Add(Format('    <Averages>%d</Averages>', [Task.ScansToAverage]));
    SL.Add(Format('    <Boxcar>%d</Boxcar>', [Task.BoxcarWidth]));
    SL.Add(Format('    <ElectricDarkEnabled>%s</ElectricDarkEnabled>', [BoolToYesNo(Task.ElectricDarkEnabled)]));
    SL.Add(Format('    <StrobeLampEnabled>%s</StrobeLampEnabled>', [BoolToYesNo(Task.StrobeLampEnabled)]));
    SL.Add('  </HardwareConfiguration>');

    SL.Add('  <ProcessingContext>');
    SL.Add(Format('    <DarkPresent>%s</DarkPresent>', [BoolToYesNo(Task.DarkPresent)]));
    SL.Add(Format('    <ReferencePresent>%s</ReferencePresent>', [BoolToYesNo(Task.RefPresent)]));
    SL.Add('  </ProcessingContext>');

    SL.Add('  <Data>');
    for i := 0 to High(Task.XData) do
      SL.Add(Format('    <P x="%.2f" y="%.5f" />', [Task.XData[i], Task.YData[i]], Fmt));
    SL.Add('  </Data>');

    SL.Add('</SingleSpectrum>');
    SL.SaveToFile(Task.FileName);
  finally
    SL.Free;
  end;
end;

// Main Dispatcher
procedure TSaveQueueThread.ProcessTask(Task: TSaveTask);
begin
  try
    case Task.FileFormat of
      ffTXT: SaveAsTXT(Task);
      ffXML: SaveAsXML(Task);
    end;
  except
    on E: Exception do
    begin
      WriteLn('Background Save Error: ' + E.Message);
    end;
  end;
end;

//*****************************************************************************/
//* Implementation of 'TSnapshot'                                             */
//*****************************************************************************/
constructor TSnapshot.Create(ASpectrum: TSpectrum; AChart: TChart; AColor: TColor);
var
  i: Integer;
begin
  FSpectrum := ASpectrum;
  FChart := AChart;

  FSerie := TLineSeries.Create(nil);
  FSerie.SeriesColor := AColor;
  FSerie.Title := 'Snapshot ' + FormatDateTime('hh:nn:ss', Now);

  FSerie.BeginUpdate;
  try
    for i := 0 to FSpectrum.Points - 1 do
      FSerie.AddXY(FSpectrum.X[i], FSpectrum.Y[i]);
  finally
    FSerie.EndUpdate;
  end;

  if FChart <> nil then
    FChart.AddSeries(FSerie);
end;

destructor TSnapshot.Destroy;
begin
  if (FChart <> nil) then
    FChart.RemoveSeries(FSerie);
  FSerie.Free;
  FSpectrum.Free;
  inherited Destroy;
end;


//*****************************************************************************/
//* Implementation of 'TAcquisition'                                          */
//*****************************************************************************/
constructor TAcquisition.Create(Spectrometer: TSBSpectrometer; IntegrationTime: DWord; ScansToAverage: Word; BoxcarWidth: Byte); overload;
begin
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := Max(1, (IntegrationTime div 1000)*ScansToAverage);
  FTimer.OnTimer := @OnTimerTick;

  FSpectrum := TSpectrum.Create(IntegrationTime, ScansToAverage, BoxcarWidth);
  FBackground := TSpectrum.Create(IntegrationTime, ScansToAverage, BoxcarWidth);
  FReference := TSpectrum.Create(IntegrationTime, ScansToAverage, BoxcarWidth);

  FSpectrometer := Spectrometer;

  FSerie := TLineSeries.Create(nil);
  FSerie.Title := 'Reading';

  FSaveQueue := TSaveQueueThread.Create;

  FSaveConfig := TSaveConfig.CreateDefault;
  FSaveStatus := sstIdle;
  FIsVisible := False;
  FAcqPaused := False;
  FProcessedCount := 0;
  FSavedCount := 0;
  FLastSaveTime := 0;
end;

constructor TAcquisition.Create(Spectrometer: TSBSpectrometer; IntegrationTime: DWord; ScansToAverage: Word); overload;
begin
  Create(Spectrometer, IntegrationTime, ScansToAverage, 0);
end;

constructor TAcquisition.Create(Spectrometer: TSBSpectrometer; IntegrationTime: DWord); overload;
begin
  Create(Spectrometer, IntegrationTime, 1, 0);
end;

constructor TAcquisition.Create(Spectrometer: TSBSpectrometer); overload;
begin
  Create(Spectrometer, 100000, 1, 0);
end;

destructor TAcquisition.Destroy;
begin
  Active := False;
  FTimer.Enabled := False;
  FTimer.OnTimer := nil;
  FTimer.Free;

  FSpectrum.Free;
  FBackground.Free;
  FReference.Free;

  FSerie.Free;

  FSaveQueue.Free;

  inherited;
end;

function TAcquisition.ReadSptData(var Spt: TSpectrum): Boolean;
begin
  try
    // Get Wavelengths
    Spt.XData := Spectrometer.Wavelengths;
    // Get Spectrum
    Spt.YData := Spectrometer.Spectrum;
    // Get integration time
    Spt.IntegrationTime := Spectrometer.IntegrationTime;
    // Get the number of scans to average
    Spt.ScansToAverage := Spectrometer.ScansToAverage;
    // Get the boxcar width
    Spt.BoxcarWidth := Spectrometer.BoxcarWidth;
    // Get Strobe Lamp correction
    Spt.StrobeLampEnabled := Spectrometer.StrobeLampEnabled;
    // Get electric dark correction
    Spt.ElectricDarkEnabled := Spectrometer.ElectricDarkEnabled;

    Result := True;
  except
    Result := False;
  end;
end;

function TAcquisition.ReadSpectrum: Boolean;
begin
  Result := ReadSptData(FSpectrum);
end;

function TAcquisition.ReadBackground: Boolean;
begin
  Result := ReadSptData(FBackground);
end;

function TAcquisition.ReadReference: Boolean;
begin
  Result := ReadSptData(FReference);
end;

function TAcquisition.HasValidSpectrometer: Boolean;
begin
  Result := Spectrometer <> nil;
end;

function TAcquisition.HasValidBackground: Boolean;
begin
  Result := (FSpectrum.Points > 0) and FSpectrum.HasSameConditions(FBackground);
end;

function TAcquisition.HasValidReference: Boolean;
begin
  Result := (FSpectrum.Points > 0) and FSpectrum.HasSameConditions(FReference);
end;

procedure TAcquisition.StartSaving;
begin
  // We only start if the configuration is currently valid
  if ValidateSaveConfig then
  begin
    FStartTime := Now;
    FLastSaveTime := 0;
    FSavedCount := 0;
    FSaveStatus := sstSaving;
  end;
end;

procedure TAcquisition.PauseSaving;
begin
  if FSaveStatus = sstSaving then
    FSaveStatus := sstPaused;
end;

procedure TAcquisition.StopSaving;
begin
  FSaveStatus := sstIdle;
end;

function TAcquisition.GetActive: Boolean;
begin
  Result := FTimer.Enabled;
end;

function TAcquisition.GetIntegrationTime: DWord;
begin
  Result := Spectrum.IntegrationTime;
end;

function TAcquisition.GetScansToAverage: Word;
begin
  Result := Spectrum.ScansToAverage;
end;

function TAcquisition.GetBoxcarWidth: Byte;
begin
  Result := Spectrum.BoxcarWidth;
end;

function TAcquisition.GetStrobeLampEnabled: Boolean;
begin
  Result := Spectrum.StrobeLampEnabled;
end;

function TAcquisition.GetElectricDarkEnabled: Boolean;
begin
  Result := Spectrum.ElectricDarkEnabled;
end;

function TAcquisition.GetFmtSpectrum(DataType: TDataType): TSpectrum;
var
  i: Integer;
begin
  Result := TSpectrum.Create(IntegrationTime, ScansToAverage, BoxcarWidth);
  Result.Points := Spectrum.Points;
  Result.DataType := DataType;

  if Result.DataType in [dtAbsorbance, dtTransmittance, dtReflectance, dtIrradiance] then
    if (not Spectrum.HasSameConditions(Background)) or (not Spectrum.HasSameConditions(Reference)) then
      Result.DataType := dtScopeBgnd;

  if Result.DataType = dtScopeBgnd then
    if not Spectrum.HasSameConditions(Background) then
      Result.DataType := dtScope;

  case Result.DataType of
    dtScope, dtRaman: Result.Data := Spectrum.Data;
    dtScopeBgnd: begin
      Result.XData := Spectrum.XData;
      for i := 0 to Spectrum.Points - 1 do
        Result.Y[i] := Spectrum.Y[i] - Background.Y[i];
    end;
    dtAbsorbance: begin
      Result.XData := Spectrum.XData;
      for i := 0 to Spectrum.Points - 1 do
        Result.Y[i] := Log10(Max(1e-10, (Reference.Y[i] - Background.Y[i])/Max(1e-5, Spectrum.Y[i] - Background.Y[i])));
    end;
    dtTransmittance, dtReflectance: begin
      Result.XData := Spectrum.XData;
      for i := 0 to Spectrum.Points - 1 do
        Result.Y[i] := (Spectrum.Y[i] - Background.Y[i])/Max(1e-5, Reference.Y[i] - Background.Y[i]);
    end;
    dtIrradiance: begin  // TODO
      Result.Data := Spectrum.Data;
    end;
    else
      Result.Data := Spectrum.Data;
  end;
end;

procedure TAcquisition.SetActive(Value: Boolean);
begin
  if Value = GetActive then Exit;

  if not Value then
    FSerie.Clear;

  FTimer.Enabled := Value;

  // Link the UI activation to the hardware thread
  if Assigned(FSpectrometer) then
  begin
    if Value then
      FSpectrometer.StartAcquisition
    else
      FSpectrometer.StopAcquisition;
  end;
end;

procedure TAcquisition.SetSpectrometer(Value: TSBSpectrometer);
begin
  FSpectrometer := Value;
  UpdateDarkPixelCache;
end;

procedure TAcquisition.UpdateDarkPixelCache;
var
  i: Integer;
  DPIdx: LongIntArray;
begin
  if FSpectrometer = nil then Exit;

  SetLength(FIsDarkPixel, FSpectrometer.PixelNumber);
  for i := 0 to High(FIsDarkPixel) do FIsDarkPixel[i] := False;

  DPIdx := FSpectrometer.DarkPixelIndices;
  for i := 0 to High(DPIdx) do
    if (DPIdx[i] >= 0) and (DPIdx[i] < Length(FIsDarkPixel)) then
      FIsDarkPixel[DPIdx[i]] := True;
end;

procedure TAcquisition.SetIntegrationTime(Value: DWord);
begin
  FSpectrometer.IntegrationTime := Value;

  FTimer.Interval := Max(1, (IntegrationTime div 1000)*ScansToAverage);
end;

procedure TAcquisition.SetScansToAverage(Value: Word);
begin
  FSpectrometer.ScansToAverage := Value;

  FTimer.Interval := Max(1, (IntegrationTime div 1000)*ScansToAverage);
end;

procedure TAcquisition.SetBoxcarWidth(Value: Byte);
begin
  FSpectrometer.BoxcarWidth := Value;
end;

procedure TAcquisition.SetStrobeLampEnabled(Value: Boolean);
begin
  FSpectrometer.StrobeLampEnabled := Value;
end;

procedure TAcquisition.SetElectricDarkEnabled(Value: Boolean);
begin
  FSpectrometer.ElectricDarkEnabled := Value;
end;

procedure TAcquisition.OnTimerTick(Sender: TObject);
var
  i: Integer;
  FmtSpt: TSpectrum;
  ShouldSave: Boolean;
  ElapsedSecs, LimitSecs, IntervalSecs: Double;
begin
  if Assigned(FSpectrometer) and FSpectrometer.HasNewData and (not FAcqPaused) then
  begin
    if ReadSpectrum then
    begin
      Inc(FProcessedCount);
      FmtSpt := FmtSpectrum[DataType];
      try
        if FIsVisible then
        begin
          FSerie.BeginUpdate;
          try
            FSerie.Clear;
            for i := 0 to FmtSpt.Points - 1 do
              FSerie.AddXY(FmtSpt.X[i], FmtSpt.Y[i]);
          finally
            FSerie.EndUpdate;
          end;
        end;

        if FSaveStatus = sstSaving then
        begin
          ShouldSave := False;

          // Convert Interval to Seconds for comparison
          IntervalSecs := FSaveConfig.SaveTime;
          if FSaveConfig.SaveTimeUnits = tuMilliSeconds then
            IntervalSecs := IntervalSecs/1000;

          case FSaveConfig.SaveCriteria of
            scAll: ShouldSave := True;
            scEveryNth: ShouldSave := (FProcessedCount mod FSaveConfig.SpectrumNumber = 0);
            scTimed: ShouldSave := SecondSpan(Now, FLastSaveTime) >= IntervalSecs;
          end;

          // Check Stop Conditions
          if scCount in FSaveConfig.StopCriteria then
            if FSavedCount >= FSaveConfig.StopCount then
              FSaveStatus := sstIdle;

          if scTime in FSaveConfig.StopCriteria then
          begin
            ElapsedSecs := SecondSpan(Now, FStartTime);
            LimitSecs := FSaveConfig.StopTime;
            if FSaveConfig.StopTimeUnits = tuMilliSeconds then
              LimitSecs := LimitSecs/1000;

            if ElapsedSecs >= LimitSecs then
              FSaveStatus := sstIdle;
          end;

          if ShouldSave and (FSaveStatus = sstSaving) then
          begin
            SaveToDisk(FmtSpt);
            FLastSaveTime := Now;
            Inc(FSavedCount);
          end;
        end;
      finally
        FmtSpt.Free;
      end;
    end;
  end;
end;

function TAcquisition.ValidateSaveConfig: Boolean;
begin
  Result := False;

  // Must have a base name
  if Trim(FSaveConfig.BaseName) = '' then Exit;

  // Directory must exist
  if not DirectoryExists(FSaveConfig.SaveDir) then Exit;

  // If timed saving is used, interval must be positive
  if (FSaveConfig.SaveCriteria = scTimed) and (FSaveConfig.SaveTime <= 0) then Exit;

  Result := True;
end;

procedure TAcquisition.SaveToDisk(ASpectrum: TSpectrum);
var
  FileName, Suffix: String;
  Task: TSaveTask;
  i: Integer;
begin
  // Determine File Suffix
  if FSaveConfig.FileSuffix = fsCounter then
    Suffix := Format('%.*d', [FSaveConfig.Padding, FSavedCount + 1])
  else
    Suffix := FormatDateTime('yyyyMMdd_hhmmss_zzz', Now);

  // Build Full Path
  FileName := IncludeTrailingPathDelimiter(FSaveConfig.SaveDir) +  FSaveConfig.BaseName + '_' + Suffix;

  if FSaveConfig.FileFormat = ffXML then
    FileName := FileName + '.xml'
  else
    FileName := FileName + '.txt';

  // Package everything into a thread-safe task
  Task := TSaveTask.Create;

  // Deep copy the data arrays
  SetLength(Task.XData, ASpectrum.Points);
  SetLength(Task.YData, ASpectrum.Points);
  for i := 0 to ASpectrum.Points - 1 do
  begin
    Task.XData[i] := ASpectrum.X[i];
    Task.YData[i] := ASpectrum.Y[i];
  end;

  Task.FileName := FileName;
  Task.FileFormat := FSaveConfig.FileFormat;

  // Gather Metadata on the main thread safely
  Task.DateStr := FormatDateTime('ddd mmm dd hh:nn:ss yyyy', Now);
  {$IFDEF WINDOWS}
  Task.Usr := GetEnvironmentVariable('USERNAME');
  {$ELSE}
  Task.Usr := GetEnvironmentVariable('USER');
  {$ENDIF}

  Task.SN := FSpectrometer.SerialNumber;
  Task.DarkPresent := Background.HasSameConditions(ASpectrum);
  Task.RefPresent := Reference.HasSameConditions(ASpectrum);
  Task.IntegrationTime := FSpectrometer.IntegrationTime;
  Task.ScansToAverage := FSpectrometer.ScansToAverage;
  Task.BoxcarWidth := FSpectrometer.BoxcarWidth;
  Task.ElectricDarkEnabled := FSpectrometer.ElectricDarkEnabled;
  Task.StrobeLampEnabled := FSpectrometer.StrobeLampEnabled;

  // Hand it off to the background thread
  FSaveQueue.Enqueue(Task);
end;

//*****************************************************************************/
//* Implementation of 'TMeasurement'                                          */
//*****************************************************************************/
constructor TMeasurement.Create(Chart: TChart);
begin
  FAcquisition := nil;
  FSnapshots := TSnapshotList.Create;

  SetChart(Chart);
  FDataType := dtScope;
end;

destructor TMeasurement.Destroy;
begin
  ClearSnapshots;
  FSnapshots.Free;
  ClearAcquisition;
  inherited;
end;

procedure TMeasurement.ClearAcquisition;
begin
  if FAcquisition <> nil then
  begin
    if FChart <> nil then
      FChart.RemoveSeries(FAcquisition.Serie);
    FreeAndNil(FAcquisition);
  end;
end;

procedure TMeasurement.AddAcquisition(Spectrometer: TSBSpectrometer; IntegrationTime: DWord; ScansToAverage: Word; BoxcarWidth: Byte);
begin
  ClearAcquisition; // Ensure we only ever have one

  FAcquisition := TAcquisition.Create(Spectrometer, IntegrationTime, ScansToAverage, BoxcarWidth);
  if Assigned(FAcquisition.Spectrometer) then
    FAcquisition.Spectrometer.OnParametersChanged := @HandleHardwareParamsChanged;
  FAcquisition.DataType := FDataType;

  if FChart <> nil then
    FChart.AddSeries(FAcquisition.Serie);
end;

procedure TMeasurement.AddAcquisition(Spectrometer: TSBSpectrometer);
begin
  AddAcquisition(Spectrometer, 100000, 1, 0);
end;

function TMeasurement.ReadSpectrum: Boolean;
begin
  Result := (FAcquisition <> nil) and FAcquisition.ReadSpectrum;
end;

function TMeasurement.ReadBackground: Boolean;
begin
  Result := (FAcquisition <> nil) and FAcquisition.ReadBackground;
end;

function TMeasurement.ReadReference: Boolean;
begin
  Result := (FAcquisition <> nil) and FAcquisition.ReadReference;
end;

function TMeasurement.HasValidSpectrometer: Boolean;
begin
  Result := (FAcquisition <> nil) and FAcquisition.HasValidSpectrometer;
end;

function TMeasurement.HasValidBackground: Boolean;
begin
  Result := (FAcquisition <> nil) and FAcquisition.HasValidBackground;
end;

function TMeasurement.HasValidReference: Boolean;
begin
  Result := (FAcquisition <> nil) and FAcquisition.HasValidReference;
end;

function TMeasurement.HasSnapshots: Boolean;
begin
  Result := (FSnapshots <> nil) and (FSnapshots.Count > 0);
end;

procedure TMeasurement.StartSaving;
begin
  if (FAcquisition <> nil) then
    FAcquisition.StartSaving;
end;

procedure TMeasurement.PauseSaving;
begin
  if (FAcquisition <> nil) then
    FAcquisition.PauseSaving;
end;

procedure TMeasurement.StopSaving;
begin
  if (FAcquisition <> nil) then
    FAcquisition.StopSaving;
end;

procedure TMeasurement.TakeSnapshot;
var
  Spt: TSpectrum;
  SelectedColor: TColor;
begin
  if (FAcquisition <> nil) and (FAcquisition.Spectrum.Points > 0) then
  begin
    SelectedColor := SNAPSHOT_COLORS[FSnapshots.Count mod Length(SNAPSHOT_COLORS)];

    Spt := FAcquisition.FmtSpectrum[FDataType];
    FSnapshots.Add(TSnapshot.Create(Spt, FChart, SelectedColor));
  end;
end;

procedure TMeasurement.ClearSnapshots;
var
  i: Integer;
begin
  for i := FSnapshots.Count - 1 downto 0 do
    FSnapshots[i].Free;
  FSnapshots.Clear;
end;

procedure TMeasurement.RescalePlot;
var
  Scl: TDoubleRect;
  PlotExt: TPlotExtent;
begin
  if (FChart = nil) or (not FChart.HandleAllocated) then Exit;

  Scl := FChart.GetFullExtent;

  with PlotExt do
  begin
    XMin := Scl.a.X;
    XMax := Scl.b.X;
    YMin := Scl.a.Y;
    YMax := Scl.b.Y;

    UseXMin := False;
    UseXMax := False;
    UseYMin := False;
    UseYMax := False;
  end;

  PlotExtent := PlotExt;
end;

procedure TMeasurement.RescaleXAxis;
var
  Scl: TDoubleRect;
  PlotExt: TPlotExtent;
begin
  if (FChart = nil) or (not FChart.HandleAllocated) then Exit;

  Scl := FChart.GetFullExtent;

  with PlotExt do
  begin
    XMin := Scl.a.X;
    XMax := Scl.b.X;
    YMin := PlotExtent.YMin;
    YMax := PlotExtent.YMax;

    UseXMin := False;
    UseXMax := False;
    UseYMin := PlotExtent.UseYMin;
    UseYMax := PlotExtent.UseYMax;
  end;

  PlotExtent := PlotExt;
end;

procedure TMeasurement.RescaleYAxis;
var
  Scl: TDoubleRect;
  PlotExt: TPlotExtent;
begin
  if (FChart = nil) or (not FChart.HandleAllocated) then Exit;

  Scl := FChart.GetFullExtent;

  with PlotExt do
  begin
    XMin := PlotExtent.XMin;
    XMax := PlotExtent.XMax;
    YMin := Scl.a.Y;
    YMax := Scl.b.Y;

    UseXMin := PlotExtent.UseXMin;
    UseXMax := PlotExtent.UseXMax;
    UseYMin := False;
    UseYMax := False;
  end;

  PlotExtent := PlotExt;
end;

function TMeasurement.GetActive: Boolean;
begin
  Result := (FAcquisition <> nil) and FAcquisition.Active;
end;

function TMeasurement.GetIsVisible: Boolean;
begin
  Result := (FAcquisition <> nil) and FAcquisition.IsVisible;
end;

procedure TMeasurement.SetActive(Value: Boolean);
begin
  if (FChart <> nil) and Value then
    with FChart.Extent do
    begin
      XMin := FPlotExtent.XMin;
      XMax := FPlotExtent.XMax;
      YMin := FPlotExtent.YMin;
      YMax := FPlotExtent.YMax;

      UseXMin := FPlotExtent.UseXMin;
      UseXMax := FPlotExtent.UseXMax;
      UseYMin := FPlotExtent.UseYMin;
      UseYMax := FPlotExtent.UseYMax;
    end;

  if (FAcquisition <> nil) then
    FAcquisition.Active := Value;
end;

procedure TMeasurement.SetIsVisible(Value: Boolean);
begin
  if FAcquisition <> nil then
    FAcquisition.IsVisible := Value;
end;

procedure TMeasurement.SetAcquisition(Value: TAcquisition);
begin
  ClearAcquisition;
  FAcquisition := Value;
end;

procedure TMeasurement.SetChart(Value: TChart);
var
  i: Integer;
begin
  if (FChart <> nil) then
  begin
    if (FAcquisition <> nil) then
      FChart.RemoveSeries(FAcquisition.Serie);
    for i := 0 to FSnapshots.Count - 1 do
      if (FSnapshots[i] <> nil) and (FSnapshots[i].Serie <> nil) then
        FChart.RemoveSeries(FSnapshots[i].Serie);
  end;

  FChart := Value;

  if (FChart <> nil) then
  begin
    if (FAcquisition <> nil) then
      FChart.AddSeries(FAcquisition.Serie);
    for i := 0 to FSnapshots.Count - 1 do
      if (FSnapshots[i] <> nil) and (FSnapshots[i].Serie <> nil) then
        FChart.AddSeries(FSnapshots[i].Serie);

    with FChart.Extent do
    begin
      FPlotExtent.XMin := XMin;
      FPlotExtent.XMax := XMax;
      FPlotExtent.YMin := YMin;
      FPlotExtent.YMax := YMax;

      FPlotExtent.UseXMin := UseXMin;
      FPlotExtent.UseXMax := UseXMax;
      FPlotExtent.UseYMin := UseYMin;
      FPlotExtent.UseYMax := UseYMax;
    end;
  end;
end;

procedure TMeasurement.SetPlotExtent(Value: TPlotExtent);
begin
  FPlotExtent := Value;

  if (FChart <> nil) and Active and FChart.HandleAllocated and FChart.Visible then
    with FChart.Extent do
    begin
      XMin := FPlotExtent.XMin;
      XMax := FPlotExtent.XMax;
      YMin := FPlotExtent.YMin;
      YMax := FPlotExtent.YMax;

      UseXMin := FPlotExtent.UseXMin;
      UseXMax := FPlotExtent.UseXMax;
      UseYMin := FPlotExtent.UseYMin;
      UseYMax := FPlotExtent.UseYMax;
    end;
end;

procedure TMeasurement.SetDataType(Value: TDataType);
begin
  FDataType := Value;
  if (FAcquisition <> nil) then
    FAcquisition.DataType := Value;
end;

function TMeasurement.ValidateSaveConfig: Boolean;
begin
  Result := (FAcquisition <> nil) and FAcquisition.ValidateSaveConfig;
end;

procedure TMeasurement.HandleHardwareParamsChanged(Sender: TObject);
begin
  DataType := dtScope;
  RescalePlot;

  if (FAcquisition <> nil) then
  begin
    // Clean these spectra, that are now invalid
    FAcquisition.Background.Points := 0;
    FAcquisition.Reference.Points := 0;
  end;
end;

function TMeasurement.GetAcquisition: TAcquisition;
begin
  Result := FAcquisition;
end;

function TMeasurement.GetChart: TChart;
begin
  Result := FChart;
end;

function TMeasurement.GetPlotExtent: TPlotExtent;
begin
  Result := FPlotExtent;
end;

end.

