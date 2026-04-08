program spectral;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Forms, Interfaces, tachartlazaruspkg,
  SysUtils, Messages, uMain, URangeDlg,
  UConfigDlg, USaveSpectraDlg, uAbout,
  Restore;

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmSpectral, frmSpectral);
  Application.CreateForm(TRangeDlg, RangeDlg);
  Application.CreateForm(TConfigurationDlg, ConfigurationDlg);
  Application.CreateForm(TSaveSpectraDlg, SaveSpectraDlg);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
