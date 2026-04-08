unit SptTypes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  PByte  = ^Byte;
  PChar  = ^Char;
  PDouble  = ^Double;
  PLongInt  = ^LongInt;
  PSingle  = ^Single;

  ByteArray = Array of Byte;
  LongIntArray = Array of LongInt;
  DoubleArray = Array of Double;

  TSptData = Array [0..1] of DoubleArray;

  TSaveState = (ssUnconfigured, ssConfigured, ssRunning, ssPaused);
  TDataType = (dtScope, dtScopeBgnd, dtAbsorbance, dtTransmittance, dtReflectance, dtIrradiance, dtRaman);

  TSBMessageType = (sbmInfo, sbmWarning, sbmError);
const
  DataTypeNames: Array[0..6] of String = ('Scope', 'Scope - Background', 'Absorbance',
                                          'Transmittance', 'Reflectance', 'Irradiance', 'Raman') ;
  DataTypeUnits: Array[0..6] of String = ('Counts', 'Counts', 'Optical density',
                                          'Transmittance', 'Reflectance', 'Counts', 'Counts') ;

implementation

end.

