unit SBDevices;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Math, SyncObjs, SptTypes, SeaBreeze;

type
  // Procedural types for SeaBreeze API functions to enable generic helpers
  TSBGetCountFunc = function(ID: LongInt; Err: PLongInt): LongInt;
  TSBGetIDsFunc = function(ID: LongInt; Err: PLongInt; IDs: PLongInt; MaxIDs: LongInt): LongInt;
  TSBGetCoeffsFunc = function(DevID, FeatID: LongInt; Err: PLongInt; Buffer: PDouble; Max: LongInt): LongInt;

  // Events
  TSBMessageEvent = procedure(Level: TSBMessageType; const Msg: String) of object;

  TSBSpectrometer = class(TObject)
  private
    FDeviceID: LongInt;
    FSpectrometerID: LongInt;
    FSerialNumberID: LongInt;
    FRevisionID: LongInt;
    FSpectrumProcessingID: LongInt;
    FTECID: LongInt;
    FStrobeLampID: LongInt;
    FPixelBinningID: LongInt;
    FEEPROMID: LongInt;
    FShutterID: LongInt;
    FNonLinearityID: LongInt;
    FStrayLightID: LongInt;
    FContinuousStrobeID: LongInt;
    FIrradCalID: LongInt;

    FStrobeLampEnabled: Boolean;
    FElectricDarkEnabled: Boolean;
    FShutterOpen: Boolean;
    FAcquiring: Boolean;
    FNewDataAvailable: Boolean;
    FContinuousStrobeEnabled: Boolean;

    FIntegrationTime: DWord;
    FScansToAverage: Word;
    FBoxcarWidth: Byte;
    FPixelCount: LongInt;
    FContinuousStrobePeriod: LongInt;
    FAcquisitionDelay: LongInt;
    FTargetTemperature: Double;
    FTriggerMode: Integer;

    FWavelengths, FLatestSpectrum: DoubleArray;
    FBufferLock, FParamsLock: TCriticalSection;
    FAcquireThread: TThread;

    // Shadow variables for thread safety
    FParamsDirty: Boolean;
    FPendingIntegrationTime: Integer;
    FPendingScansToAverage: Integer;
    FPendingBoxcarWidth: Integer;
    FPendingStrobeLamp: Boolean;
    FPendingElectricDark: Boolean;

    FOnParametersChanged: TNotifyEvent;
    FOnSBMessage: TSBMessageEvent;

    function GetDeviceName: String;
    function GetSerialNumber: String;
    function GetHardwareRevision: String;
    function GetSoftwareRevision: String;
    function GetPixelNumber: LongInt;
    function GetDarkPixelNumber: LongInt;
    function GetDarkPixelIndices: LongIntArray;
    function GetElectricDarkEnabled: Boolean;
    function GetWavelengths: DoubleArray;
    function GetSpectrum: DoubleArray;
    function GetMinimumIntegrationTime: LongInt;
    procedure SetIntegrationTime(Value: DWord);
    function GetMaximumIntensity: Double;
    function GetScansToAverage: Word;
    procedure SetScansToAverage(Value: Word);
    function GetBoxcarWidth: Byte;
    procedure SetBoxcarWidth(Value: Byte);
    procedure SetStrobeLampEnabled(Value: Boolean);
    procedure SetElectricDarkEnabled(Value: Boolean);
    function GetEEPROMSlot(SlotNo: LongInt): String;
    function GetTemperature: Double;
    procedure SetTargetTemperature(Value: Double);
    procedure SetTECEnabled(Value: Boolean);
    procedure SetShutterOpen(Value: Boolean);
    procedure SetTriggerMode(Value: Integer);

    { Generic helper for coefficient arrays }
    function GetCoefficients(FeatureID: LongInt; GetFunc: TSBGetCoeffsFunc; MaxCount: Integer): DoubleArray;
    function GetWavelengthCoeffs: DoubleArray;
    //procedure SetWavelengthCoeffs(Value: DoubleArray);
    function GetNonLinearityCoeffs: DoubleArray;
    function GetStrayLightCoeffs: DoubleArray;

    procedure SetAcquisitionDelay(Value: LongInt);
    procedure SetContinuousStrobePeriod(Value: LongInt);
    procedure SetContinuousStrobeEnabled(Value: Boolean);
    procedure ReadWavelengthCoefficients;
    function GetIrradianceCalibrationFactors: DoubleArray;

    procedure SendSBMessage(Level: TSBMessageType; const Msg: String);
    function CheckSBError(Code: LongInt): Boolean;

    procedure CommitIntegrationTime(Value: DWord);
    procedure CommitScansToAverage(Value: Word);
    procedure CommitBoxcarWidth(Value: Byte);
    procedure CommitStrobeLampEnabled(Value: Boolean);
    procedure CommitElectricDarkEnabled(Value: Boolean);
  public
    constructor Create(DevID, SptID, SNID, RevID, SptProcID, TECID,
                       StrobeLampID, PixelBinningID, EEPROMID, ShutterID,
                       NonLinID, StrayID, ContStrobeID, IrradCalID: LongInt);
    destructor Destroy; override;

    function HasNewData: Boolean;
    procedure StartAcquisition;
    procedure StopAcquisition;

    procedure ApplyPendingParameters;

    property DeviceID: LongInt read FDeviceID;
    property SpectrometerID: LongInt read FSpectrometerID;
    property SerialNumberID: LongInt read FSerialNumberID;
    property RevisionID: LongInt read FRevisionID;
    property SpectrumProcessingID: LongInt read FSpectrumProcessingID;
    property ThermoElectricID: LongInt read FTECID;
    property StrobeLampID: LongInt read FStrobeLampID;
    property PixelBinningID: LongInt read FPixelBinningID;
    property EEPROMID: LongInt read FEEPROMID;
    property DeviceName: String read GetDeviceName;
    property SerialNumber: String read GetSerialNumber;
    property HardwareRevision: String read GetHardwareRevision;
    property SoftwareRevision: String read GetSoftwareRevision;
    property EEPROMSlot[SlotNo: LongInt]: String read GetEEPROMSlot;
    property PixelNumber: LongInt read FPixelCount;
    property DarkPixelNumber: LongInt read GetDarkPixelNumber;
    property DarkPixelIndices: LongIntArray read GetDarkPixelIndices;
    property Wavelengths: DoubleArray read FWavelengths;
    property Spectrum: DoubleArray read GetSpectrum;
    property MinimumIntegrationTime: LongInt read GetMinimumIntegrationTime;
    property IntegrationTime: DWord read FIntegrationTime write SetIntegrationTime;
    property MaximumIntensity: Double read GetMaximumIntensity;
    property ScansToAverage: Word read GetScansToAverage write SetScansToAverage;
    property BoxcarWidth: Byte read GetBoxcarWidth write SetBoxcarWidth;
    property StrobeLampEnabled: Boolean read FStrobeLampEnabled write SetStrobeLampEnabled;
    property ElectricDarkEnabled: Boolean read GetElectricDarkEnabled write SetElectricDarkEnabled;
    property Temperature: Double read GetTemperature;
    property TargetTemperature: Double read FTargetTemperature write SetTargetTemperature;
    property ShutterOpen: Boolean read FShutterOpen write SetShutterOpen;
    property WavelengthCoeffs: DoubleArray read GetWavelengthCoeffs;// write SetWavelengthCoeffs;
    property NonLinearityCoeffs: DoubleArray read GetNonLinearityCoeffs;
    property StrayLightCoeffs: DoubleArray read GetStrayLightCoeffs;
    property ContinuousStrobeEnabled: Boolean read FContinuousStrobeEnabled write SetContinuousStrobeEnabled;
    property ContinuousStrobePeriod: LongInt read FContinuousStrobePeriod write SetContinuousStrobePeriod;
    property AcquisitionDelay: LongInt read FAcquisitionDelay write SetAcquisitionDelay;
    property IrradianceFactors: DoubleArray read GetIrradianceCalibrationFactors;
    property TriggerMode: Integer read FTriggerMode write SetTriggerMode;

    property OnSBMessage: TSBMessageEvent read FOnSBMessage write FOnSBMessage;
    property OnParametersChanged: TNotifyEvent read FOnParametersChanged write FOnParametersChanged;
  end;

  TSBDevice = class(TObject)
  private
    FDeviceID: LongInt;
    FSpectrometers: array of TSBSpectrometer;
    FActiveSpectrometerIndex: LongInt;

    FOnSBMessage: TSBMessageEvent;

    function GetName: String;
    function GetNoSpectrometers: Integer;
    function GetActiveSpectrometer: TSBSpectrometer;
    function GetSpectrometer(Index: Integer): TSBSpectrometer;
    procedure SetActiveSpectrometerIndex(Value: Integer);

    { Generic helper to discover any feature type }
    function DiscoverFeatures(GetCount: TSBGetCountFunc; GetIDs: TSBGetIDsFunc;
                              var FeatureIDs: LongIntArray): LongInt;

    function ReadSerialNumberFeatures(var FeatureIDs: LongIntArray): LongInt;
    function ReadRevisionsFeatures(var FeatureIDs: LongIntArray): LongInt;
    function ReadSpectrumProcessingFeatures(var FeatureIDs: LongIntArray): LongInt;
    function ReadThermoElectricFeatures(var FeatureIDs: LongIntArray): LongInt;
    function ReadStrobeLampFeatures(var FeatureIDs: LongIntArray): LongInt;
    function ReadPixelBinningFeatures(var FeatureIDs: LongIntArray): LongInt;
    function ReadEEPROMFeatures(var FeatureIDs: LongIntArray): LongInt;

    procedure SendSBMessage(Level: TSBMessageType; const Msg: String);
    function CheckSBError(Code: LongInt): Boolean;
  public
    constructor Create(ID: LongInt);
    destructor Destroy; override;
    property DeviceID: LongInt read FDeviceID;
    property Name: String read GetName;
    property NoSpectrometers: Integer read GetNoSpectrometers;
    property ActiveSpectrometerIndex: Integer read FActiveSpectrometerIndex write SetActiveSpectrometerIndex;
    property ActiveSpectrometer: TSBSpectrometer read GetActiveSpectrometer;
    property Spectrometers[Index: Integer]: TSBSpectrometer read GetSpectrometer;

    property OnSBMessage: TSBMessageEvent read FOnSBMessage write FOnSBMessage;
  end;

  TSBInterface = class(TObject)
  private
    FDevices: array of TSBDevice;
    FActiveDeviceIndex: LongInt;

    FOnSBMessage: TSBMessageEvent;

    function GetName: String;
    function GetNoDevices: Integer;
    function GetNoSpectrometers: Integer;
    function GetActiveDevice: TSBDevice;
    function GetDevice(Index: Integer): TSBDevice;
    function GetSpectrometer(Index: Integer): TSBSpectrometer;
    procedure SetActiveDeviceIndex(Value: Integer);

    procedure SendSBMessage(Level: TSBMessageType; const Msg: String);
    function CheckSBError(Code: LongInt): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ClearDevices;
    procedure RefreshDevices;
    procedure HardReset;

    property Name: String read GetName;
    property NoDevices: Integer read GetNoDevices;
    property NoSpectrometers: Integer read GetNoSpectrometers;
    property ActiveDeviceIndex: Integer read FActiveDeviceIndex write SetActiveDeviceIndex;
    property ActiveDevice: TSBDevice read GetActiveDevice;
    property Devices[Index: Integer]: TSBDevice read GetDevice;
    property Spectrometers[Index: Integer]: TSBSpectrometer read GetSpectrometer; default;

    property OnSBMessage: TSBMessageEvent read FOnSBMessage write FOnSBMessage;
  end;

  TSBAcquireThread = class(TThread)
  private
    FSpectrometer: TSBSpectrometer;

    function ApplySoftwareBoxcar(const Input: DoubleArray; Width: Integer): DoubleArray;
  protected
    procedure Execute; override;
  public
    constructor Create(ASpectrometer: TSBSpectrometer);
  end;

implementation

{ Global Helpers }

function HexByteToStr(Value: Byte): String;
const
  Digits: array[0..15] of Char = '0123456789ABCDEF';
begin
  Result := Digits[Value shr 4] + Digits[Value and $0F];
end;

//*****************************************************************************/
//* Implementation of 'TSBAcquireThread'                                       */
//*****************************************************************************/

constructor TSBAcquireThread.Create(ASpectrometer: TSBSpectrometer);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FSpectrometer := ASpectrometer;
end;

function TSBAcquireThread.ApplySoftwareBoxcar(const Input: DoubleArray; Width: Integer): DoubleArray;
var
  i, PixelCount, WindowSize: Integer;
  CurrentSum: Double;
  Divisor: Double;
begin
  PixelCount := Length(Input);
  SetLength(Result, PixelCount);
  if (Width <= 0) or (PixelCount = 0) then Exit(Copy(Input));

  // Initial sum for the first window
  CurrentSum := 0;
  for i := 0 to Width do
    if i < PixelCount then
      CurrentSum := CurrentSum + Input[i];

  for i := 0 to PixelCount - 1 do
  begin
    // Calculate effective window boundaries for the divisor
    WindowSize := Min(i + Width, PixelCount - 1) - Max(0, i - Width) + 1;
    Result[i] := CurrentSum/WindowSize;

    // Slide the window: Subtract the element leaving and add the one entering
    if (i - Width >= 0) then
      CurrentSum := CurrentSum - Input[i - Width];
    if (i + Width + 1 < PixelCount) then
      CurrentSum := CurrentSum + Input[i + Width + 1];
  end;
end;

procedure TSBAcquireThread.Execute;
var
  i, j, PixelCount: Integer;
  RawBuffer, Accumulator, Processed: DoubleArray;
  LocalScans, LocalBoxcar, HWReadsRequired: Integer;
  LocalDarkIndices: LongIntArray;
  ErrCode: LongInt;
  DarkPixelAvg: Double;
  IsHWProcessing: Boolean;
  LocalAcquiring: Boolean;
begin
  while not Terminated do
  begin
    FSpectrometer.FParamsLock.Enter;
    try
      LocalAcquiring := FSpectrometer.FAcquiring;
    finally
      FSpectrometer.FParamsLock.Leave;
    end;

    if LocalAcquiring then
    begin
      FSpectrometer.ApplyPendingParameters;

      // Make local copies
      PixelCount := FSpectrometer.PixelNumber;
      LocalScans := Max(1, FSpectrometer.ScansToAverage);
      LocalBoxcar := FSpectrometer.BoxcarWidth;
      LocalDarkIndices := Copy(FSpectrometer.DarkPixelIndices);

      // If SpectrumProcessingID is valid, HW does the work.
      IsHWProcessing := (FSpectrometer.SpectrumProcessingID > 0);

      if IsHWProcessing then
        HWReadsRequired := 1
      else
        HWReadsRequired := LocalScans;

      // Sync internal buffers
      if Length(RawBuffer) <> PixelCount then
      begin
        SetLength(RawBuffer, PixelCount);
        SetLength(Accumulator, PixelCount);
        SetLength(Processed, PixelCount);
      end;

      try
        FillChar(Accumulator[0], PixelCount * SizeOf(Double), 0);

        // Acquisition
        for i := 1 to HWReadsRequired do
        begin
          if Terminated then Exit;
          SB_spectrometer_get_formatted_spectrum(FSpectrometer.DeviceID,
            FSpectrometer.SpectrometerID, @ErrCode, @RawBuffer[0], PixelCount);

          if ErrCode = 0 then
            for j := 0 to PixelCount - 1 do
              Accumulator[j] := Accumulator[j] + RawBuffer[j];
        end;

        // Software processing (only if unsupported in HW)
        for j := 0 to PixelCount - 1 do
          Processed[j] := Accumulator[j]/Max(1, HWReadsRequired);

        // Electric Dark (Usually always software-side)
        if FSpectrometer.ElectricDarkEnabled and (Length(LocalDarkIndices) > 0) then
        begin
          DarkPixelAvg := 0.0;
          for i := 0 to High(LocalDarkIndices) do
            if (LocalDarkIndices[i] >= 0) and (LocalDarkIndices[i] < PixelCount) then
              DarkPixelAvg := DarkPixelAvg + Processed[LocalDarkIndices[i]];

          DarkPixelAvg := DarkPixelAvg / Length(LocalDarkIndices);
          for j := 0 to PixelCount - 1 do Processed[j] := Processed[j] - DarkPixelAvg;
        end;

        // Software Boxcar (Skip if HW did it)
        if (not IsHWProcessing) and (LocalBoxcar > 0) then
          Processed := ApplySoftwareBoxcar(Processed, LocalBoxcar);

        // Thread-safe update
        FSpectrometer.FBufferLock.Enter;
        try
          FSpectrometer.FLatestSpectrum := Copy(Processed);
          FSpectrometer.FNewDataAvailable := True;
        finally
          FSpectrometer.FBufferLock.Leave;
        end;

        if (HWReadsRequired > 1) or (FSpectrometer.IntegrationTime < 10000) then Sleep(1);
      except
        on E: Exception do ;
      end;
    end else Sleep(50);
  end;
end;

//*****************************************************************************/
//* Implementation of 'TSBSpectrometer'                                       */
//*****************************************************************************/

constructor TSBSpectrometer.Create(DevID, SptID, SNID, RevID, SptProcID,
                                   TECID, StrobeLampID, PixelBinningID, EEPROMID,
                                   ShutterID, NonLinID, StrayID, ContStrobeID, IrradCalID: LongInt);
var
  ErrCode: LongInt;
begin
  inherited Create;
  FDeviceID := DevID;
  FSpectrometerID := SptID;
  FSerialNumberID := SNID;
  FRevisionID := RevID;
  FSpectrumProcessingID := SptProcID;
  FTECID := TECID;
  FStrobeLampID := StrobeLampID;
  FPixelBinningID := PixelBinningID;
  FEEPROMID := EEPROMID;
  FShutterID := ShutterID;
  FNonLinearityID := NonLinID;
  FStrayLightID := StrayID;
  FContinuousStrobeID := ContStrobeID;
  FIrradCalID := IrradCalID;

  FIntegrationTime := 100000;
  FPendingIntegrationTime := FIntegrationTime;
  FScansToAverage := 1;
  FPendingScansToAverage := FScansToAverage;
  FBoxcarWidth := 0;
  FPendingBoxcarWidth := FBoxcarWidth;
  FAcquisitionDelay := 0;
  FStrobeLampEnabled := False;
  FPendingStrobeLamp := FStrobeLampEnabled;
  FContinuousStrobeEnabled := False;
  FContinuousStrobePeriod := 0;
  FShutterOpen := True;
  FParamsDirty:= False;
  FTriggerMode := 0;
  SetTriggerMode(0);

  FBufferLock := TCriticalSection.Create;
  FNewDataAvailable := False;
  FAcquiring := False;

  FParamsLock := TCriticalSection.Create;

  FPixelCount := SB_spectrometer_get_formatted_spectrum_length(DeviceID, SpectrometerID, @ErrCode);
  CheckSBError(ErrCode);

  if FEEPROMID >= 0 then ReadWavelengthCoefficients
  else
  begin
    SetLength(FWavelengths, FPixelCount);
    SB_spectrometer_get_wavelengths(DeviceID, SpectrometerID, @ErrCode, @FWavelengths[0], FPixelCount);
    CheckSBError(ErrCode);
  end;

  FAcquireThread := TSBAcquireThread.Create(Self);
  StrobeLampEnabled := False;
  ElectricDarkEnabled := False;
end;

destructor TSBSpectrometer.Destroy;
begin
  if Assigned(FParamsLock) then
  begin
    FParamsLock.Enter;
    try
      FAcquiring := False;
    finally
      FParamsLock.Leave;
    end;
  end;
  if Assigned(FAcquireThread) then
  begin
    FAcquireThread.Terminate;
    FAcquireThread.WaitFor;
    FreeAndNil(FAcquireThread);
  end;
  FreeAndNil(FBufferLock);
  FreeAndNil(FParamsLock);
  inherited;
end;

procedure TSBSpectrometer.SendSBMessage(Level: TSBMessageType; const Msg: String);
begin
  if Assigned(OnSBMessage) then
    OnSBMessage(Level, Msg);
end;

function TSBSpectrometer.CheckSBError(Code: LongInt): Boolean;
begin
  Result := (Code < 0);
  if Result then
    SendSBMessage(sbmError, Format('SeaBreeze Error: %s (Code %d)',
                                   [String(SB_get_error_String(Code)), Code]));
end;

function TSBSpectrometer.HasNewData: Boolean;
begin
  FBufferLock.Enter;
  try
    Result := FNewDataAvailable;
  finally
    FBufferLock.Leave;
  end;
end;

procedure TSBSpectrometer.StartAcquisition;
begin
  FParamsLock.Enter;
  try
    FAcquiring := True;
  finally
    FParamsLock.Leave;
  end;
end;

procedure TSBSpectrometer.StopAcquisition;
begin
  FParamsLock.Enter;
  try
    FAcquiring := False;
  finally
    FParamsLock.Leave;
  end;
end;

procedure TSBSpectrometer.ApplyPendingParameters;
var
  HadChanges: Boolean;
  PendIntTime: Integer;
  PendScans:   Integer;
  PendBoxcar:  Integer;
  PendStrobe:  Boolean;
  PendEDark:   Boolean;
begin
  // Snapshot the pending values under the lock, then release
  FParamsLock.Enter;
  try
    if not FParamsDirty then Exit;
    PendIntTime := FPendingIntegrationTime;
    PendScans := FPendingScansToAverage;
    PendBoxcar := FPendingBoxcarWidth;
    PendStrobe := FPendingStrobeLamp;
    PendEDark := FPendingElectricDark;
    FParamsDirty := False;
  finally
    FParamsLock.Leave;
  end;

  HadChanges := False;

  if FIntegrationTime <> PendIntTime then
  begin
    CommitIntegrationTime(PendIntTime);
    HadChanges := True;
  end;

  if FScansToAverage <> PendScans then
  begin
    CommitScansToAverage(PendScans);
    HadChanges := True;
  end;

  if FBoxcarWidth <> PendBoxcar then
  begin
    CommitBoxcarWidth(PendBoxcar);
    HadChanges := True;
  end;

  if FStrobeLampEnabled <> PendStrobe then
  begin
    CommitStrobeLampEnabled(PendStrobe);
    HadChanges := True;
  end;

  if FElectricDarkEnabled <> PendEDark then
  begin
    CommitElectricDarkEnabled(PendEDark);
    HadChanges := True;
  end;

  if HadChanges and Assigned(FOnParametersChanged) then
    FOnParametersChanged(Self);
end;

function TSBSpectrometer.GetDeviceName: String;
const
  MaxChars = 100;
var
  Buf: array[0..99] of Char;
  Err: LongInt;
begin
  SB_get_device_type(FDeviceID, @Err, @Buf[0], MaxChars);
  CheckSBError(Err);
  Result := String(Buf);
end;

function TSBSpectrometer.GetSerialNumber: String;
const
  MaxChars = 100;
var
  Buf: array[0..99] of Char;
  Err: LongInt;
begin
  SB_get_serial_number(DeviceID, SerialNumberID, @Err, @Buf[0], MaxChars);
  CheckSBError(Err);
  Result := String(Buf);
end;

function TSBSpectrometer.GetHardwareRevision: String;
var
  Rev: Byte;
  Err: LongInt;
begin
  if FRevisionID > 0 then
  begin
    Rev := SB_revision_hardware_get(DeviceID, FRevisionID, @Err);
    CheckSBError(Err);
    Result := HexByteToStr(Rev);
  end
  else
    Result := '00';
end;

function TSBSpectrometer.GetSoftwareRevision: String;
var
  Rev: Byte;
  Err: LongInt;
begin
  if FRevisionID > 0 then
  begin
    Rev := SB_revision_firmware_get(DeviceID, FRevisionID, @Err);
    CheckSBError(Err);
    Result := HexByteToStr(Rev);
  end
  else
    Result := '00';
end;

function TSBSpectrometer.GetPixelNumber: LongInt;
var
  Err: LongInt;
begin
  Result := SB_spectrometer_get_formatted_spectrum_length(DeviceID, SpectrometerID, @Err);
  CheckSBError(Err);
end;

function TSBSpectrometer.GetDarkPixelNumber: LongInt;
var
  Err: LongInt;
begin
  Result := SB_spectrometer_get_electric_dark_pixel_count(DeviceID, SpectrometerID, @Err);
  CheckSBError(Err);
end;

function TSBSpectrometer.GetDarkPixelIndices: LongIntArray;
var
  Err, DPN: LongInt;
begin
  DPN := DarkPixelNumber;
  SetLength(Result, DPN);
  if (DPN > 0) then
  begin
    SB_spectrometer_get_electric_dark_pixel_indices(DeviceID, SpectrometerID, @Err, @Result[0], DPN);
    CheckSBError(Err);
  end;
end;

function TSBSpectrometer.GetElectricDarkEnabled: Boolean;
begin
  Result := FElectricDarkEnabled and (DarkPixelNumber > 0);
end;

function TSBSpectrometer.GetWavelengths: DoubleArray;
var
  Err: LongInt;
begin
  SetLength(Result, PixelNumber);
  SB_spectrometer_get_wavelengths(DeviceID, SpectrometerID, @Err, @Result[0], PixelNumber);
  CheckSBError(Err);
end;

function TSBSpectrometer.GetSpectrum: DoubleArray;
begin
  FBufferLock.Enter;
  try
    if Length(FLatestSpectrum) > 0 then
    begin
      Result := Copy(FLatestSpectrum);
      FNewDataAvailable := False;
    end
    else
      SetLength(Result, FPixelCount);
  finally
    FBufferLock.Leave;
  end;
end;

function TSBSpectrometer.GetMinimumIntegrationTime: LongInt;
var
  Err: LongInt;
begin
  Result := SB_spectrometer_get_minimum_integration_time_micros(DeviceID, SpectrometerID, @Err);
  CheckSBError(Err);
end;

procedure TSBSpectrometer.SetIntegrationTime(Value: DWord);
var
  IsAcquiring: Boolean;
begin
  FParamsLock.Enter;
  try
    if Value = FIntegrationTime then Exit;
    IsAcquiring := FAcquiring;
    if IsAcquiring then
    begin
      FPendingIntegrationTime := Value;
      FParamsDirty := True;
    end;
  finally
    FParamsLock.Leave;
  end;

  if not IsAcquiring then
  begin
    CommitIntegrationTime(Value);

    if Assigned(FOnParametersChanged) then
      FOnParametersChanged(Self);
  end;
end;

procedure TSBSpectrometer.CommitIntegrationTime(Value: DWord);
var
  Err: LongInt;
  Tmp: DWord;
begin
  Tmp := Max(Value, MinimumIntegrationTime);
  SB_spectrometer_set_integration_time_micros(DeviceID, SpectrometerID, @Err, Tmp);
  if not CheckSBError(Err) then
  begin
    FIntegrationTime := Tmp;
    FPendingIntegrationTime := Tmp;
  end;
end;

function TSBSpectrometer.GetMaximumIntensity: Double;
var
  Err: LongInt;
begin
  Result := SB_spectrometer_get_maximum_intensity(DeviceID, SpectrometerID, @Err);
  CheckSBError(Err);
end;

function TSBSpectrometer.GetScansToAverage: Word;
var
  Err: LongInt;
begin
  if (FSpectrumProcessingID > 0) then
  begin
    Result := SB_spectrum_processing_scans_to_average_get(DeviceID, SpectrumProcessingID, @Err);
    if (Err = 5) then
    begin
      FSpectrumProcessingID := -1;
      FScansToAverage := 1;
      Result := 1;
    end
    else
      CheckSBError(Err);
  end
  else
    Result := FScansToAverage;
end;

procedure TSBSpectrometer.SetScansToAverage(Value: Word);
var
  IsAcquiring: Boolean;
begin
  FParamsLock.Enter;
  try
    if Value = FScansToAverage then Exit;
    IsAcquiring := FAcquiring;
    if IsAcquiring then
    begin
      FPendingScansToAverage := Value;
      FParamsDirty := True;
    end;
  finally
    FParamsLock.Leave;
  end;

  if not IsAcquiring then
  begin
    CommitScansToAverage(Value);

    // Notify the system that references are now invalid
    if Assigned(FOnParametersChanged) then
      FOnParametersChanged(Self);
  end;
end;

procedure TSBSpectrometer.CommitScansToAverage(Value: Word);
var
  Err: LongInt;
begin
  if (FSpectrumProcessingID > 0) then
  begin
    SB_spectrum_processing_scans_to_average_set(DeviceID, FSpectrumProcessingID, @Err, Value);
    // Fallback to software if the hardware feature is unsupported (Error 5)
    if (Err = 5) then
      FSpectrumProcessingID := -1;
  end;

  FScansToAverage := Value;
  FPendingScansToAverage := Value;
end;

function TSBSpectrometer.GetBoxcarWidth: Byte;
var
  Err: LongInt;
begin
  if (FSpectrumProcessingID > 0) then
  begin
    Result := SB_spectrum_processing_boxcar_width_get(DeviceID, SpectrumProcessingID, @Err);
    if (Err = 5) then
    begin
      FSpectrumProcessingID := -1;
      FBoxcarWidth := 0;
      Result := 0;
    end
    else
      CheckSBError(Err);
  end
  else
    Result := FBoxcarWidth;
end;

procedure TSBSpectrometer.SetBoxcarWidth(Value: Byte);
var
  IsAcquiring: Boolean;
begin
  FParamsLock.Enter;
  try
    if Value = FBoxcarWidth then Exit;
    IsAcquiring := FAcquiring;
    if IsAcquiring then
    begin
      FPendingBoxcarWidth := Value;
      FParamsDirty := True;
    end;
  finally
    FParamsLock.Leave;
  end;

  if not IsAcquiring then
  begin
    CommitBoxcarWidth(Value);

    // Notify the system that references are now invalid
    if Assigned(FOnParametersChanged) then
      FOnParametersChanged(Self);
  end;
end;

procedure TSBSpectrometer.CommitBoxcarWidth(Value: Byte);
var
  Err: LongInt;
begin
  if (FSpectrumProcessingID > 0) then
  begin
    SB_spectrum_processing_boxcar_width_set(DeviceID, FSpectrumProcessingID, @Err, Value);
    // Fallback to software if HW fails
    if (Err = 5) then
      FSpectrumProcessingID := -1;
  end;

  FBoxcarWidth := Value;
  FPendingBoxcarWidth := Value;
end;

procedure TSBSpectrometer.SetStrobeLampEnabled(Value: Boolean);
var
  IsAcquiring: Boolean;
begin
  FParamsLock.Enter;
  try
    if (Value = FStrobeLampEnabled) then Exit;
    IsAcquiring := FAcquiring;
    if IsAcquiring then
    begin
      FPendingStrobeLamp := Value;
      FParamsDirty := True;
    end;
  finally
    FParamsLock.Leave;
  end;

  if not IsAcquiring then
  begin
    CommitStrobeLampEnabled(Value);

    // Notify the system that references are now invalid
    if Assigned(FOnParametersChanged) then
      FOnParametersChanged(Self);
  end;
end;

procedure TSBSpectrometer.CommitStrobeLampEnabled(Value: Boolean);
var
  Err: LongInt;
begin
  if (FStrobeLampID > 0) then
  begin
    SB_lamp_set_lamp_enable(DeviceID, FStrobeLampID, @Err, Byte(Value));
    if not CheckSBError(Err) then
    begin
      FStrobeLampEnabled := Value;
      FPendingStrobeLamp := Value;
    end;
  end;
end;

procedure TSBSpectrometer.SetElectricDarkEnabled(Value: Boolean);
var
  IsAcquiring: Boolean;
begin
  FParamsLock.Enter;
  try
    if (Value = FElectricDarkEnabled) then Exit;
    IsAcquiring := FAcquiring;
    if IsAcquiring then
    begin
      FPendingElectricDark := Value;
      FParamsDirty := True;
    end;
  finally
    FParamsLock.Leave;
  end;

  if not IsAcquiring then
  begin
    CommitElectricDarkEnabled(Value);

    // Notify the system that references are now invalid
    if Assigned(FOnParametersChanged) then
      FOnParametersChanged(Self);
  end;
end;

procedure TSBSpectrometer.CommitElectricDarkEnabled(Value: Boolean);
begin
  FElectricDarkEnabled := Value and (DarkPixelNumber > 0);
  FPendingElectricDark := FElectricDarkEnabled;
end;

function TSBSpectrometer.GetEEPROMSlot(SlotNo: LongInt): String;
const
  MaxChars = 100;
var
  Buf: array[0..99] of Char;
  Err: LongInt;
begin
  SB_eeprom_read_slot(DeviceID, EEPROMID, @Err, SlotNo, @Buf[0], MaxChars);
  CheckSBError(Err);
  Result := String(Buf);
end;

procedure TSBSpectrometer.SetShutterOpen(Value: Boolean);
var
  Err: LongInt;
begin
  if FShutterID >= 0 then
  begin
    SB_shutter_set_shutter_open(DeviceID, FShutterID, @Err, Byte(Value));
    if Err = 0 then
      FShutterOpen := Value;
  end;
end;

procedure TSBSpectrometer.SetTriggerMode(Value: Integer);
var
  Err: LongInt;
begin
  SB_spectrometer_set_trigger_mode(FDeviceID, FSpectrometerID, @Err, Value);
  if not CheckSBError(Err) then
    FTriggerMode := Value;
end;

function TSBSpectrometer.GetTemperature: Double;
var
  Err: LongInt;
begin
  Result := 0.0;
  if FTECID >= 0 then
    Result := SB_tec_read_temperature_degrees_C(DeviceID, FTECID, @Err);
end;

procedure TSBSpectrometer.SetTargetTemperature(Value: Double);
var
  Err: LongInt;
begin
  if FTECID >= 0 then
  begin
    SB_tec_set_temperature_setpoint_degrees_C(DeviceID, FTECID, @Err, Value);
    if Err = 0 then
    begin
      FTargetTemperature := Value;
      SB_tec_set_enable(DeviceID, FTECID, @Err, 1);
    end;
  end;
end;

procedure TSBSpectrometer.SetTECEnabled(Value: Boolean);
var
  Err: LongInt;
begin
  if FTECID >= 0 then
    SB_tec_set_enable(DeviceID, FTECID, @Err, Byte(Value));
end;

function TSBSpectrometer.GetCoefficients(FeatureID: LongInt; GetFunc: TSBGetCoeffsFunc; MaxCount: Integer): DoubleArray;
var
  Err: LongInt;
  Len: Integer;
begin
  SetLength(Result, 0);
  if FeatureID >= 0 then
  begin
    SetLength(Result, MaxCount);
    Len := GetFunc(FDeviceID, FeatureID, @Err, @Result[0], MaxCount);
    if Len > 0 then SetLength(Result, Len)
    else
      SetLength(Result, 0);
  end;
end;

function TSBSpectrometer.GetWavelengthCoeffs: DoubleArray;
var
  Err: LongInt;
  i: Integer;
  Buf: array[0..31] of ANSIChar;
begin
  // Initialize the array to hold 4 coefficients (C0, C1, C2, C3)
  SetLength(Result, 4);

  // If the device doesn't have an EEPROM feature, return zeros
  if FEEPROMID < 0 then
  begin
    for i := 0 to 3 do
      Result[i] := 0.0;
    Exit;
  end;

  // Ocean Optics EEPROM slots 1 through 4 contain the Wavelength Calibration
  for i := 0 to 3 do
  begin
    // Use the SeaBreeze API to read the slot
    SB_eeprom_read_slot(FDeviceID, FEEPROMID, @Err, i + 1, @Buf[0], 32);

    if Err = 0 then
      // Convert the string from the EEPROM to a double
      Result[i] := StrToFloatDef(StrPas(@Buf[0]), 0.0)
    else
      Result[i] := 0.0;
  end;
end;

//procedure TSBSpectrometer.SetWavelengthCoeffs(Value: DoubleArray);
//var
//  Err: LongInt;
//  i: Integer;
//  S: String;
//begin
//  // Ensure we have the required 4 coefficients (C0, C1, C2, C3)
//  if Length(Value) < 4 then
//    raise Exception.Create('SetWavelengthCoeffs: DoubleArray must contain at least 4 elements.');
//
//  // Check if the device supports EEPROM operations
//  if FEEPROMID < 0 then
//    raise Exception.Create('This device does not support EEPROM wavelength calibration storage.');
//
//  for i := 0 to 3 do
//  begin
//    // Convert double to string with fixed precision (usually 7-10 decimal places for calibration)
//    // SeaBreeze EEPROM slots expect ASCII strings
//    S := FloatToStrF(Value[i], ffFixed, 7, 10);
//
//    // SeaBreeze API to write to the EEPROM slot
//    // Slot numbers for wavelength are 1, 2, 3, and 4
//    SB_eeprom_write_slot(FDeviceID, FEEPROMID, @Err, i + 1, PAnsiChar(AnsiString(S)), Length(S));
//
//    if Err <> 0 then
//    begin
//      CheckSBError(Err); // Log the error using your existing error handler
//      Break;
//    end;
//  end;
//
//  // After writing to EEPROM, we should recalculate the internal wavelength array
//  // so the live spectrum reflects the new calibration immediately
//  ReadWavelengthCoefficients;
//end;

function TSBSpectrometer.GetNonLinearityCoeffs: DoubleArray;
begin
  Result := GetCoefficients(FNonLinearityID, @SB_nonlinearity_coeffs_get, 10);
end;

function TSBSpectrometer.GetStrayLightCoeffs: DoubleArray;
begin
  Result := GetCoefficients(FStrayLightID, @SB_stray_light_coeffs_get, 5);
end;

procedure TSBSpectrometer.ReadWavelengthCoefficients;
var
  Err: LongInt;
  i: Integer;
  Buf: array[0..31] of ANSIChar;
  Coeffs: array[0..3] of Double;
begin
  if FEEPROMID < 0 then Exit;
  for i := 0 to 3 do
  begin
    SB_eeprom_read_slot(FDeviceID, FEEPROMID, @Err, i + 1, @Buf[0], 32);
    if Err = 0 then
      Coeffs[i] := StrToFloatDef(StrPas(@Buf[0]), 0.0)
    else
      Coeffs[i] := 0.0;
  end;
  FBufferLock.Enter;
  try
    SetLength(FWavelengths, FPixelCount);
    for i := 0 to FPixelCount - 1 do
      FWavelengths[i] := Coeffs[0] + Coeffs[1] * i + Coeffs[2] * Power(i, 2) +
        Coeffs[3] * Power(i, 3);
  finally
    FBufferLock.Leave;
  end;
end;

function TSBSpectrometer.GetIrradianceCalibrationFactors: DoubleArray;
var
  Err: LongInt;
  i: Integer;
  Buf: array of single;
begin
  SetLength(Result, FPixelCount);
  if FIrradCalID >= 0 then
  begin
    SetLength(Buf, FPixelCount);
    SB_irrad_calibration_read(FDeviceID, FIrradCalID, @Err, @Buf[0], FPixelCount);
    if Err = 0 then
    begin
      for i := 0 to FPixelCount - 1 do
        Result[i] := Buf[i];
      Exit;
    end;
  end;
  for i := 0 to FPixelCount - 1 do
    Result[i] := 1.0;
end;

procedure TSBSpectrometer.SetAcquisitionDelay(Value: LongInt);
var
  Err: LongInt;
begin
  if FSpectrometerID >= 0 then
  begin
    SB_acquisition_delay_set_delay_microseconds(FDeviceID, FSpectrometerID, @Err, Value);
    if Err = 0 then
      FAcquisitionDelay := Value;
  end;
end;

procedure TSBSpectrometer.SetContinuousStrobePeriod(Value: LongInt);
var
  Err: LongInt;
begin
  if FContinuousStrobeID >= 0 then
  begin
    SB_continuous_strobe_set_continuous_strobe_period_micros(FDeviceID, FContinuousStrobeID, @Err, Value);
    if Err = 0 then
      FContinuousStrobePeriod := Value;
  end;
end;

procedure TSBSpectrometer.SetContinuousStrobeEnabled(Value: Boolean);
var
  Err: LongInt;
  En: Byte;
begin
  if FContinuousStrobeID >= 0 then
  begin
    if Value then En := 1
    else
      En := 0;
    SB_continuous_strobe_set_continuous_strobe_enable(FDeviceID, FContinuousStrobeID, @Err, En);
    if Err = 0 then
      FContinuousStrobeEnabled := Value;
  end;
end;

//*****************************************************************************/
//* Implementation of 'TSBDevice'                                             */
//*****************************************************************************/

constructor TSBDevice.Create(ID: LongInt);
var
  i: Integer;
  NoSpt, Err: LongInt;
  SptIDs, SNIDs, RevIDs, SptProcIDs, TECIDs, StrobeLampIDs, PixelBinningIDs,
  EEPROMIDs, ShutterIDs, NonLinIDs, StrayIDs, ContStrobeIDs, IrradCalIDs: LongIntArray;

  function SafeGetID(const IDs: LongIntArray; Index: Integer): LongInt;
  begin
    if (Index >= 0) and (Index < Length(IDs)) then
      Result := IDs[Index]
    else
      Result := -1;
  end;

begin
  if ID < 0 then
  begin
    SendSBMessage(sbmError, 'Cannot open device. Invalid ID!');
    Exit;
  end;
  FDeviceID := ID;
  if SB_open_device(FDeviceID, @Err) > 0 then
  begin
    SendSBMessage(sbmError, 'Error opening device!');
    CheckSBError(Err);
    FDeviceID := -1;
    Exit;
  end;

  SendSBMessage(sbmInfo, Format('Device opened successfully (ID: %d)', [ID]));

  NoSpt := DiscoverFeatures(@SB_get_number_of_spectrometer_features,
                            @SB_get_spectrometer_features, SptIDs);
  if NoSpt <= 0 then
  begin
    SendSBMessage(sbmWarning, 'No spectrometers found!');
    FActiveSpectrometerIndex := -1;
    Exit;
  end;

  FActiveSpectrometerIndex := 0;
  ReadSerialNumberFeatures(SNIDs);
  ReadRevisionsFeatures(RevIDs);
  ReadSpectrumProcessingFeatures(SptProcIDs);
  ReadThermoElectricFeatures(TECIDs);
  ReadStrobeLampFeatures(StrobeLampIDs);
  ReadPixelBinningFeatures(PixelBinningIDs);
  ReadEEPROMFeatures(EEPROMIDs);

  DiscoverFeatures(@SB_get_number_of_shutter_features,
                   @SB_get_shutter_features, ShutterIDs);
  DiscoverFeatures(@SB_get_number_of_nonlinearity_coeffs_features,
                   @SB_get_nonlinearity_coeffs_features, NonLinIDs);
  DiscoverFeatures(@SB_get_number_of_stray_light_coeffs_features,
                   @SB_get_stray_light_coeffs_features, StrayIDs);
  DiscoverFeatures(@SB_get_number_of_continuous_strobe_features,
                   @SB_get_continuous_strobe_features, ContStrobeIDs);
  DiscoverFeatures(@SB_get_number_of_irrad_cal_features,
                   @SB_get_irrad_cal_features, IrradCalIDs);

  SetLength(FSpectrometers, NoSpt);
  for i := 0 to NoSpt - 1 do
  begin
    FSpectrometers[i] := TSBSpectrometer.Create(FDeviceID, SptIDs[i],
      SafeGetID(SNIDs, i), SafeGetID(RevIDs, i), SafeGetID(SptProcIDs, i),
      SafeGetID(TECIDs, i), SafeGetID(StrobeLampIDs, i), SafeGetID(PixelBinningIDs, i),
      SafeGetID(EEPROMIDs, i), SafeGetID(ShutterIDs, i), SafeGetID(NonLinIDs, i),
      SafeGetID(StrayIDs, i), SafeGetID(ContStrobeIDs, i), SafeGetID(IrradCalIDs, i));

    SendSBMessage(sbmInfo, Format('Spectrometer %d initialized (SN: %s)', [i, FSpectrometers[i].SerialNumber]));
  end;
end;

destructor TSBDevice.Destroy;
var
  i: Integer;
  Err: LongInt;
begin
  for i := 0 to NoSpectrometers - 1 do
    FSpectrometers[i].Free;
  if FDeviceID >= 0 then
    SB_close_device(FDeviceID, @Err);
  inherited;
end;

procedure TSBDevice.SendSBMessage(Level: TSBMessageType; const Msg: String);
begin
  if Assigned(OnSBMessage) then
    OnSBMessage(Level, Msg);
end;

function TSBDevice.CheckSBError(Code: LongInt): Boolean;
begin
  Result := (Code < 0);
  if Result then
    SendSBMessage(sbmError, Format('SeaBreeze Error: %s (Code %d)',
                                   [String(SB_get_error_String(Code)), Code]));
end;

function TSBDevice.DiscoverFeatures(GetCount: TSBGetCountFunc; GetIDs: TSBGetIDsFunc; var FeatureIDs: LongIntArray): LongInt;
var
  Err: LongInt;
begin
  Result := GetCount(FDeviceID, @Err);
  CheckSBError(Err);
  if Result > 0 then
  begin
    SetLength(FeatureIDs, Result);
    Result := GetIDs(FDeviceID, @Err, @FeatureIDs[0], Result);
    CheckSBError(Err);
  end
  else
    SetLength(FeatureIDs, 0);
end;

function TSBDevice.ReadSerialNumberFeatures(var FeatureIDs: LongIntArray): LongInt;
begin
  Result := DiscoverFeatures(@SB_get_number_of_serial_number_features,
                             @SB_get_serial_number_features, FeatureIDs);
end;

function TSBDevice.ReadRevisionsFeatures(var FeatureIDs: LongIntArray): LongInt;
begin
  Result := DiscoverFeatures(@SB_get_number_of_revision_features,
                             @SB_get_revision_features, FeatureIDs);
end;

function TSBDevice.ReadSpectrumProcessingFeatures(var FeatureIDs: LongIntArray): LongInt;
begin
  Result := DiscoverFeatures(@SB_get_number_of_spectrum_processing_features,
                             @SB_get_spectrum_processing_features, FeatureIDs);
end;

function TSBDevice.ReadThermoElectricFeatures(var FeatureIDs: LongIntArray): LongInt;
begin
  Result := DiscoverFeatures(@SB_get_number_of_thermo_electric_features,
                             @SB_get_thermo_electric_features, FeatureIDs);
end;

function TSBDevice.ReadStrobeLampFeatures(var FeatureIDs: LongIntArray): LongInt;
begin
  Result := DiscoverFeatures(@SB_get_number_of_lamp_features,
                             @SB_get_lamp_features, FeatureIDs);
end;

function TSBDevice.ReadPixelBinningFeatures(var FeatureIDs: LongIntArray): LongInt;
begin
  Result := DiscoverFeatures(@SB_get_number_of_pixel_binning_features,
                             @SB_get_pixel_binning_features, FeatureIDs);
end;

function TSBDevice.ReadEEPROMFeatures(var FeatureIDs: LongIntArray): LongInt;
begin
  Result := DiscoverFeatures(@SB_get_number_of_eeprom_features,
                             @SB_get_eeprom_features, FeatureIDs);
end;

function TSBDevice.GetNoSpectrometers: Integer;
begin
  Result := Length(FSpectrometers);
end;

procedure TSBDevice.SetActiveSpectrometerIndex(Value: Integer);
begin
  if ((Value >= 0) and (Value < NoSpectrometers)) then
    FActiveSpectrometerIndex := Value;
end;

function TSBDevice.GetActiveSpectrometer: TSBSpectrometer;
begin
  if FActiveSpectrometerIndex >= 0 then
    Result := FSpectrometers[FActiveSpectrometerIndex]
  else
    Result := nil;
end;

function TSBDevice.GetSpectrometer(Index: Integer): TSBSpectrometer;
begin
  if (Index >= 0) and (Index < Length(FSpectrometers)) then
    Result := FSpectrometers[Index]
  else
    Result := nil;
end;

function TSBDevice.GetName: String;
const
  MaxChars = 100;
var
  Buf: array[0..99] of Char;
  Err: LongInt;
begin
  SB_get_device_type(FDeviceID, @Err, @Buf[0], MaxChars);
  CheckSBError(Err);
  Result := String(Buf);
end;

//*****************************************************************************/
//* Implementation of 'TSBInterface'                                          */
//*****************************************************************************/

constructor TSBInterface.Create;
var
  i: Integer;
  NoDev: LongInt;
  DevIDs: LongIntArray;
begin
  SendSBMessage(sbmInfo, 'Initializing SeaBreeze library...');
  SB_initialize;
  NoDev := SB_probe_devices;
  if NoDev <= 0 then
  begin
    SendSBMessage(sbmWarning, 'No devices found!');
    FActiveDeviceIndex := -1;
  end
  else
  begin
    SendSBMessage(sbmInfo, Format('%d device(s) found. Probing...', [NoDev]));
    SetLength(DevIDs, NoDev);
    NoDev := SB_get_device_ids(@DevIDs[0], NoDev);
    FActiveDeviceIndex := 0;
    SetLength(FDevices, NoDev);
    for i := 0 to NoDev - 1 do FDevices[i] := TSBDevice.Create(DevIDs[i]);
  end;
end;

destructor TSBInterface.Destroy;
var
  i: Integer;
begin
  for i := Low(FDevices) to High(FDevices) do FDevices[i].Free;
  SB_shutdown;
  inherited;
end;

procedure TSBInterface.SendSBMessage(Level: TSBMessageType; const Msg: String);
begin
  if Assigned(OnSBMessage) then
    OnSBMessage(Level, Msg);
end;

function TSBInterface.CheckSBError(Code: LongInt): Boolean;
begin
  Result := (Code < 0);
  if Result then
    SendSBMessage(sbmError, Format('SeaBreeze Error: %s (Code %d)',
                                   [String(SB_get_error_String(Code)), Code]));
end;

procedure TSBInterface.ClearDevices;
var
  i: Integer;
begin
  for i := Low(FDevices) to High(FDevices) do
    if FDevices[i] <> nil then FDevices[i].Free;
  SetLength(FDevices, 0);
  FActiveDeviceIndex := -1;
end;

procedure TSBInterface.RefreshDevices;
var
  i, j, NewNo: LongInt;
  NewIDs: LongIntArray;
  NewDevs: array of TSBDevice;
  Found: Boolean;
begin
  SendSBMessage(sbmInfo, 'Refreshing device list...');

  try
    NewNo := SB_probe_devices;
  except
    on E: Exception do
    begin
      SendSBMessage(sbmError, 'SeaBreeze crashed during probe: ' + E.Message);
      NewNo := 0; // Assume 0 if it failed
    end;
  end;

  if NewNo <= 0 then
  begin
    ClearDevices;
    Exit;
  end;

  SetLength(NewIDs, NewNo);
  NewNo := SB_get_device_ids(@NewIDs[0], NewNo);
  SetLength(NewDevs, NewNo);
  for i := 0 to NewNo - 1 do
  begin
    Found := False;
    for j := Low(FDevices) to High(FDevices) do
      if (FDevices[j] <> nil) and (FDevices[j].DeviceID = NewIDs[i]) then
      begin
        NewDevs[i] := FDevices[j];
        FDevices[j] := nil;
        if FActiveDeviceIndex = j then FActiveDeviceIndex := i;
        Found := True;
        Break;
      end;
    if not Found then NewDevs[i] := TSBDevice.Create(NewIDs[i]);
  end;
  for i := Low(FDevices) to High(FDevices) do if FDevices[i] <> nil then
      FDevices[i].Free;
  FDevices := NewDevs;
  if FActiveDeviceIndex >= Length(FDevices) then FActiveDeviceIndex := 0;
end;

procedure TSBInterface.HardReset;
begin
  SendSBMessage(sbmInfo, 'Performing Hard Reset of SeaBreeze Library...');

  ClearDevices;
  // Tell the SeaBreeze DLL to completely shut down
  SB_shutdown();
  // Re-initialize the library as if the app just started
  SB_initialize();
  // Now probe again
  RefreshDevices;
end;

function TSBInterface.GetName: String;
begin
  Result := 'SeaBreeze';
end;

function TSBInterface.GetNoDevices: Integer;
begin
  Result := Length(FDevices);
end;

function TSBInterface.GetNoSpectrometers: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := Low(FDevices) to High(FDevices) do
    Result := Result + FDevices[i].NoSpectrometers;
end;

function TSBInterface.GetSpectrometer(Index: Integer): TSBSpectrometer;
var
  i, Curr: Integer;
begin
  Result := nil;
  Curr := 0;
  for i := Low(FDevices) to High(FDevices) do
  begin
    if (Index >= Curr) and (Index < Curr + FDevices[i].NoSpectrometers) then
    begin
      Result := FDevices[i].Spectrometers[Index - Curr];
      Exit;
    end;
    Curr := Curr + FDevices[i].NoSpectrometers;
  end;
end;

procedure TSBInterface.SetActiveDeviceIndex(Value: Integer);
begin
  if (Value >= 0) and (Value < NoDevices) then
    FActiveDeviceIndex := Value;
end;

function TSBInterface.GetActiveDevice: TSBDevice;
begin
  if FActiveDeviceIndex >= 0 then
    Result := FDevices[FActiveDeviceIndex]
  else
    Result := nil;
end;

function TSBInterface.GetDevice(Index: Integer): TSBDevice;
begin
  if (Index >= 0) and (Index < Length(FDevices)) then
    Result := FDevices[Index]
  else
    Result := nil;
end;

end.
