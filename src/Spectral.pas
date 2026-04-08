program Spectral;

{$mode objfpc}{$H+}

uses
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
