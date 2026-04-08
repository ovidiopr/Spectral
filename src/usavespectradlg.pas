unit USaveSpectraDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ButtonPanel,
  StdCtrls, Spin, EditBtn, ExtCtrls, restore, Measurements;

type

  { TSaveSpectraDlg }

  TSaveSpectraDlg = class(TForm)
    ButtonPanel: TButtonPanel;
    cbFileFormat: TComboBox;
    chbStopScans: TCheckBox;
    chbStopTime: TCheckBox;
    deDirectory: TDirectoryEdit;
    gbStopSaving: TGroupBox;
    gbSuffix: TGroupBox;
    lblBaseName: TLabel;
    lblPadding: TLabel;
    lblPreview: TLabel;
    lblStopScans: TLabel;
    pnlUnits: TPanel;
    rbasMS: TRadioButton;
    rbasS: TRadioButton;
    rbFileCounter: TRadioButton;
    rbSaveAllScans: TRadioButton;
    rbStopMS: TRadioButton;
    rbStopS: TRadioButton;
    rbTimeStamp: TRadioButton;
    sePadding: TSpinEdit;
    seSaveAvailScan: TFloatSpinEdit;
    seStopScans: TSpinEdit;
    seStopTime: TFloatSpinEdit;
    gbSaveOptions: TGroupBox;
    gbFileOptions: TGroupBox;
    lblSaveScans: TLabel;
    lblFileFormat: TLabel;
    lblDirectory: TLabel;
    rbSaveScans: TRadioButton;
    rbSaveAvailScan: TRadioButton;
    seSaveScans: TSpinEdit;
    txtBaseName: TEdit;
    procedure cbFileFormatChange(Sender: TObject);
    procedure chbStopScansChange(Sender: TObject);
    procedure chbStopTimeChange(Sender: TObject);
    procedure deDirectoryChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure rbasMSChange(Sender: TObject);
    procedure rbasSChange(Sender: TObject);
    procedure rbFileCounterChange(Sender: TObject);
    procedure rbSaveAllScansChange(Sender: TObject);
    procedure rbSaveAvailScanChange(Sender: TObject);
    procedure rbSaveScansChange(Sender: TObject);
    procedure rbStopMSChange(Sender: TObject);
    procedure rbStopSChange(Sender: TObject);
    procedure rbTimeStampChange(Sender: TObject);
    procedure sePaddingChange(Sender: TObject);
    procedure seSaveAvailScanChange(Sender: TObject);
    procedure seSaveScansChange(Sender: TObject);
    procedure seStopScansChange(Sender: TObject);
    procedure seStopTimeChange(Sender: TObject);
    procedure txtBaseNameChange(Sender: TObject);
  private
    { private declarations }
    function GetSaveConfig: TSaveConfig;
    procedure SetSaveConfig(const Value: TSaveConfig);
  public
    { public declarations }
    function Execute: Boolean; overload;
    function Execute(ASaveConfig: TSaveConfig): Boolean; overload;

    property SaveConfig: TSaveConfig read GetSaveConfig write SetSaveConfig;

    procedure UpdateUI(Sender: TObject);
  end;

var
  SaveSpectraDlg: TSaveSpectraDlg;

implementation

{$R *.lfm}

function TSaveSpectraDlg.GetSaveConfig: TSaveConfig;
begin
  with Result do
  begin
    if rbSaveScans.Checked then
      SaveCriteria := scEveryNth
    else if rbSaveAvailScan.Checked then
      SaveCriteria := scTimed
    else
      SaveCriteria := scAll;

    SpectrumNumber := seSaveScans.Value;
    SaveTime := seSaveAvailScan.Value;
    if rbasS.Checked then
      SaveTimeUnits := tuSeconds
    else
      SaveTimeUnits := tuMilliSeconds;

    StopCriteria := [scManual];
    if chbStopScans.Checked then
      StopCriteria := StopCriteria + [scCount];
    if chbStopTime.Checked then
      StopCriteria := StopCriteria + [scTime];

    StopCount := seStopScans.Value;
    StopTime := seStopTime.Value;
    if rbStopS.Checked then
      StopTimeUnits := tuSeconds
    else
      StopTimeUnits := tuMilliSeconds;

    FileFormat := TFileFormat(cbFileFormat.ItemIndex);
    SaveDir := deDirectory.Text;
    BaseName := Trim(txtBaseName.Text);

    if rbTimeStamp.Checked then
      FileSuffix := fsTimeStamp
    else
      FileSuffix := fsCounter;
    Padding := sePadding.Value;
  end;
end;

procedure TSaveSpectraDlg.SetSaveConfig(const Value: TSaveConfig);
begin
  case Value.SaveCriteria of
    scAll: rbSaveAllScans.Checked := True;
    scEveryNth: rbSaveScans.Checked := True;
    scTimed: rbSaveAvailScan.Checked := True;
  end;
  seSaveScans.Value := Value.SpectrumNumber;
  seSaveAvailScan.Value := Value.SaveTime;
  case Value.SaveTimeUnits of
    tuMilliSeconds: rbasMS.Checked := True;
    tuSeconds: rbasS.Checked := True;
  end;

  chbStopScans.Checked := scCount in Value.StopCriteria;
  chbStopTime.Checked := scTime in Value.StopCriteria;

  seStopScans.Value := Value.StopCount;
  seStopTime.Value := Value.StopTime;
  case Value.StopTimeUnits of
    tuMilliSeconds: rbStopMS.Checked := True;
    tuSeconds: rbStopS.Checked := True;
  end;

  cbFileFormat.ItemIndex := Integer(Value.FileFormat);
  deDirectory.Text := Value.SaveDir;
  txtBaseName.Text := Value.BaseName;

  case Value.FileSuffix of
    fsTimeStamp: rbTimeStamp.Checked := True;
    fsCounter: rbFileCounter.Checked := True;
  end;
  sePadding.Value := Value.Padding;

  // Ensure the UI matches the loaded configuration visually
  UpdateUI(Self);
end;

procedure TSaveSpectraDlg.UpdateUI(Sender: TObject);
var
  PreviewStr, SuffixStr, ExtStr, BaseStr: String;
begin
  // Update Enabled/Disabled states based on selection
  seSaveScans.Enabled := rbSaveScans.Checked;

  seSaveAvailScan.Enabled := rbSaveAvailScan.Checked;
  rbasMS.Enabled := rbSaveAvailScan.Checked;
  rbasS.Enabled := rbSaveAvailScan.Checked;

  seStopScans.Enabled := chbStopScans.Checked;

  seStopTime.Enabled := chbStopTime.Checked;
  rbStopMS.Enabled := chbStopTime.Checked;
  rbStopS.Enabled := chbStopTime.Checked;

  sePadding.Enabled := rbFileCounter.Checked;

  // Build the Live Preview String
  if rbTimeStamp.Checked then
    SuffixStr := FormatDateTime('yyyyMMdd_hhmmss_zzz', Now)
  else
    SuffixStr := Format('%.*d', [sePadding.Value, 1]);

  if cbFileFormat.ItemIndex = 0 then // ffXML = 0
    ExtStr := '.xml'
  else                               // ffTXT = 1
    ExtStr := '.txt';

  BaseStr := Trim(txtBaseName.Text);
  if BaseStr = '' then
    BaseStr := '<BaseName>';

  PreviewStr := IncludeTrailingPathDelimiter(deDirectory.Text) +
                BaseStr + '_' + SuffixStr + ExtStr;

  lblPreview.Caption := 'Preview: ' + PreviewStr;
end;

procedure TSaveSpectraDlg.FormCreate(Sender: TObject);
begin
  GlobalWinRestorer.RestoreWin(Self, [svSize, svLocation, svState, svPanels]);
end;

procedure TSaveSpectraDlg.rbasMSChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.rbasSChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.rbFileCounterChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.rbSaveAllScansChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.rbSaveAvailScanChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.rbSaveScansChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.rbStopMSChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.rbStopSChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.rbTimeStampChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.sePaddingChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.seSaveAvailScanChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.seSaveScansChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.seStopScansChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.seStopTimeChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.txtBaseNameChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  // Validation check before allowing the dialog to return mrOK
  if ModalResult = mrOK then
  begin
    if Trim(txtBaseName.Text) = '' then
    begin
      MessageDlg('Please enter a Base Name for the files.', mtWarning, [mbOK], 0);
      txtBaseName.SetFocus;
      CanClose := False;
      Exit;
    end;

    if not DirectoryExists(deDirectory.Text) then
    begin
      MessageDlg('The selected save directory does not exist. Please choose a valid folder.', mtWarning, [mbOK], 0);
      deDirectory.SetFocus;
      CanClose := False;
      Exit;
    end;
  end;
end;

procedure TSaveSpectraDlg.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  GlobalWinRestorer.SaveWin(Self, [svSize, svLocation, svState, svPanels]);
end;

procedure TSaveSpectraDlg.deDirectoryChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.cbFileFormatChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.chbStopScansChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

procedure TSaveSpectraDlg.chbStopTimeChange(Sender: TObject);
begin
  UpdateUI(Sender);
end;

function TSaveSpectraDlg.Execute: Boolean;
begin
  SaveConfig := TSaveConfig.CreateDefault;
  Result := (ShowModal = mrOK);
end;

function TSaveSpectraDlg.Execute(ASaveConfig: TSaveConfig): Boolean;
begin
  SaveConfig := ASaveConfig;
  Result := (ShowModal = mrOK);
end;

end.
