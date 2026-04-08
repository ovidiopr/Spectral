unit SeaBreeze;

{$mode objfpc}{$H+}

interface

uses Forms, DynLibs, SysUtils, Types, Dialogs;

const
{$ifdef Windows}
  SBLibraryName = 'SeaBreeze.' + SharedSuffix;
{$else}
  SBLibraryName = 'libseabreeze.' + SharedSuffix;
{$endif}

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


{************************************************* }  {*
 * @file    SeaBreezeAPI.h
 * @date    February 2015
 * @author  Ocean Optics, Inc., Kirk Clendinning, Heliospectra
 *
 * This is an interface to SeaBreeze that allows
 * the user to connect to devices over USB and other buses.
 * This is intended as a usable and extensible API.
 *
 * This provides a C interface to help with linkage.
 *
 * LICENSE:
 *
 * SeaBreeze Copyright (C) 2014, Ocean Optics Inc
 *
 * Permission is hereby granted, free of Charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject
 * to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ****************************************************** }

{*
 * This should be called prior to any other SB_call.  The API may
 * recover gracefully if this is not called, but future releases may assume
 * this is called first.  This should be called synchronously -- a Single
 * thread should call this.
 *}
procedure SB_initialize;

{*
 * This may be called to free up any allocated memory being held by the
 * driver interface.  After this is called by any thread, SB_initialize
 * should be called again before any other SB_ functions are used.
 *}
procedure SB_shutdown;

{*
 * This specifies to the driver that a device of the given type might be
 * found on the network at a given address and port.  The driver will add
 * the device type and location to the set of those that can be opened.
 *
 * @param deviceTypeName (Input) The name of a type of device.  This can be
 *      one of the following: Jaz
 *
 * @param ipAddress (Input) The IPv4 address of the device.  This should be
 * in "dotted quads" notation, such as "192.168.1.100".
 *
 * @param port (Input) The network port to open on the device.  This will
 * depend on the device type; consult its datasheet.
 *
 * @return zero on success, non-zero on error
 *}
function SB_add_TCPIPv4_device_location(deviceTypeName: PChar; ipAddress: PChar; port: DWord): LongInt;

{*
 * This specifies to the driver that a device of the given type might be
 * found on a particular RS232 bus (e.g. a COM port).  The driver will add
 * the device type and location to the set of those that can be opened.
 *
 * @param deviceTypeName (Input) The name of a type of device.  This can be
 *      one of the following: QE-PRO, STS.
 *
 * @param deviceBusPath (Input) The location of the device on the RS232 bus.
 *      This will be a platform-specific location.  Under Windows, this may
 *      be COM1, COM2, etc.  Under Linux, this might be /dev/ttyS0, /dev/ttyS1,
 *      etc.
 *
 * @param baud (Input) Baud rate at which to open the device.  This should
 *      be specified as the rate itself, e.g. 9600, 57600, or 115200.
 *
 * @return zero on success, non-zero on error
 *}
function SB_add_RS232_device_location(deviceTypeName: PChar; deviceBusPath: PChar; baud: DWord): LongInt;

{*
 * This causes a search for known devices on all buses that support
 * autodetection.  This does NOT automatically open any device -- that must
 * still be done with the SB_open_device() function.  Note that this
 * should only be done by one thread at a time, and it is recommended that
 * other threads avoid calling SB_get_number_of_device_ids() or
 * SB_get_device_ids() while this is executing.  Ideally, a Single thread
 * should be designated for all device discovery/get actions, and
 * separate worker threads can be used for each device discovered.
 *
 * @return the total number of devices that have been found
 *      automatically.  If called repeatedly, this will always return the
 *      number of devices most recently found, even if they have been
 *      found or opened previously.
 *}
function SB_probe_devices: LongInt;

{*
 * This returns the total number of devices that are known either because
 * they have been specified with SB_add_RS232_device_location or
 * because they were probed on some bus.  This can be used to bound the
 * number of device references that can be gotten with
 * SB_get_device_ids().
 *
 * @return the total number of devices references that are available
 *      through SB_get_device_ids().
 *}
function SB_get_number_of_device_ids: LongInt;

{*
 * This will populate the provided Buffer with up to max_ids of device
 * references.  These references must be used as the first parameter to
 * most of the other SB_ calls.  Each uniquely identifies a Single
 * device instance.
 *
 * @param ids (Output) an array of long integers that will be overwritten
 *           with the unique IDs of each known device.  Note that these
 *           devices will not be open by default.
 * @param max_ids (Input) the maximum number of IDs that may be written
 *           to the array
 *
 * @return The total number of device IDs that were written to the array.
 *      This may be zero on error.
 *}
function SB_get_device_ids(ids: PLongInt; max_ids: DWord): LongInt;

{*
 * This function opens a device attached to the system.  The device must
 * be provided as a location ID from the SB_get_device_ids()
 * function.  Such locations can either be specified or probed using the
 * other methods in this interface.
 *
 * @param id (Input) The location ID of a device to try to open.  Only IDs
 *      that have been returned by a previous call to seabreeze_get_device_ids()
 *      are valid.
 * @param errorCode (Output) A pointer to an integer that can be used for
 *      storing error codes.
 *
 * @return 0 if it opened a device successfully, or 1 if no device was opened
 *      (in which case the errorCode variable will be set).
 *}
function SB_open_device(id: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function closes the spectrometer attached to the system.
 *
 * @param id (Input) The location ID of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 *
 *}
procedure SB_close_device(id: LongInt; errorCode: PLongInt);

{*
 * This function returns a description of the error denoted by
 * errorCode.
 *
 * @param errorCode (Input) The integer error code to look up.  Error codes
 *      may not be zero, but can be any non-zero integer (positive or
 *      negative).
 *
 * @return Char *: A description in the form of a string that describes
 *      what the error was.
 *}
(* Const before type ignored *)
function SB_get_error_string(errorCode: LongInt): PChar;

{*
 * This function copies a string denoting the type of the device into the
 * provided Buffer.
 *
 * @param id (Input) The location ID of a device previously opened with
 *      SB_get_device_locations().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.  This may be NULL.
 * @param Buffer (Output) Pointer to a user Buffer that the name will be
 *      stored into.  This may be one of the following:
 *      \li NONE: Used if no spectrometer is found (errorCode will also be set)
 *      \li HR2000: Represents an HR2000 spectrometer
 *      \li HR2000PLUS: Represents an HR2000+ spectrometer
 *      \li HR4000: Represents an HR4000 spectrometer
 *      \li JAZ: Represents a Jaz spectrometer
 *      \li MAYA2000: Represents a MAYA2000 spectrometer
 *      \li MAYA2000PRO: Represents a MAYA2000PRO spectrometer
 *      \li MAYALSL: Represents a Maya-LSL spectrometer
 *      \li NIRQUEST256: Represents an NIRQUEST256 spectrometer
 *      \li NIRQUEST512: Represents an NIRQUEST512 spectrometer
 *      \li QE65000: Represents a QE65000 spectrometer
 *      \li STS: Represents an STS spectrometer
 *      \li Torus: Represents a Torus spectrometer
 *      \li USB2000: Represents a USB2000 spectrometer
 *      \li USB2000PLUS: Represents a USB2000+ spectrometer
 *      \li USB4000: Represents a USB4000 spectrometer
 *
 * @param length (Input) Maximum number of Bytes that may be written to the
 *      Buffer
 *
 * @return integral number of Bytes actually written to the user Buffer
 *}
function SB_get_device_type(id: LongInt; errorCode: PLongInt; Buffer: PChar; length: DWord): LongInt;

{*
 * This function returns the usb endpoint for the type specified.
 * If the type is not supported by the device, a zero is returned.
 * 0 is normally the control endpoint. That value is not valid in this context.
 *
 * @param deviceID (Input)  The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @return the usb endpoint address.
 *}
function SB_get_device_usb_endpoint_primary_out(id: LongInt; errorCode: PLongInt): Byte;

{*
 * This function returns the usb endpoint for the type specified.
 * If the type is not supported by the device, a zero is returned.
 * 0 is normally the control endpoint. That value is not valid in this context.
 *
 * @param deviceID (Input)  The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @return the usb endpoint address.
 *}
function SB_get_device_usb_endpoint_primary_in(id: LongInt; errorCode: PLongInt): Byte;

{*
 * This function returns the usb endpoint for the type specified.
 * If the type is not supported by the device, a zero is returned.
 * 0 is normally the control endpoint. That value is not valid in this context.
 *
 * @param deviceID (Input)  The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @return the usb endpoint address.
 *}
function SB_get_device_usb_endpoint_secondary_out(id: LongInt; errorCode: PLongInt): Byte;

{*
 * This function returns the usb endpoint for the type specified.
 * If the type is not supported by the device, a zero is returned.
 * 0 is normally the control endpoint. That value is not valid in this context.
 *
 * @param deviceID (Input)  The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @return the usb endpoint address.
 *}
function SB_get_device_usb_endpoint_secondary_in(id: LongInt; errorCode: PLongInt): Byte;

{*
 * This function returns the usb endpoint for the type specified.
 * If the type is not supported by the device, a zero is returned.
 * 0 is normally the control endpoint. That value is not valid in this context.
 *
 * @param deviceID (Input)  The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @return the usb endpoint address.
 *}
function SB_get_device_usb_endpoint_secondary_in2(id: LongInt; errorCode: PLongInt): Byte;

{*
 * This function returns the total number of raw usb bus access feature
 * instances available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of raw usb bus access features that will be
 *      returned by a call to SB_get_raw_usb_bus_access_features().
 *}
function SB_get_number_of_raw_usb_bus_access_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each raw usb bus access feature
 * instance for this device.  The IDs are only valid when used with the
 * deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) a preallocated array to hold returned feature handles
 * @param max_features (Input) length of the preallocated Buffer
 *
 * @return the number of raw usb bus access feature IDs that were copied.
 *}
function SB_get_raw_usb_bus_access_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function reads out a raw usb access from the spectrometer's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of an irradiance calibration
 *        feature.  Valid IDs can be found with the
 *        SB_get_raw_usb_access_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param Buffer (Output) preallocated array to hold an unsigned Char Buffer
 * @param Buffer_length (Input) size of the preallocated Buffer (should equal pixel count)
 * @param endpoint (Input) a USB endpoint gotten from one of the
 *         SB_get_device_usb_endpoint_xxx_xxx() type calls.
 *
 * @return the number of floats read from the device into the Buffer
 *}
function SB_raw_usb_bus_access_read(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PByte; Buffer_length: LongInt;
           endpoint: Byte): LongInt;

{*
 * This function writes a Buffer of unsigned Chars to the specified USB endpoint
 * if the feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of an raw usb bus access
 *        feature.  Valid IDs can be found with the
 *        SB_get_raw_usb_bus_access_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param Buffer (Output) a pointer to unsigned Char values to send to the usb endpoint
 * @param Buffer_length (Input) number of calibration factors to write
 * @param endpoint (Input) a USB endpoint gotten from one of the
 *         SB_get_device_usb_endpoint_xxx_xxx() type calls.
 *
 * @return the number of floats written from the Buffer to the device
 *}
function SB_raw_usb_bus_access_write(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PByte; Buffer_length: LongInt;
           endpoint: Byte): LongInt;

{*
 * This function returns the total number of serial number instances available
 * in the indicated device.  Each instance may refer to a different module.
 *
 * @param deviceID (Input)  The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @return the number of serial_number features that will be returned
 *  by a call to SB_get_serial_number_features().
 *}
function SB_get_number_of_serial_number_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each serial number instance for this
 * device.  Each instance refers to a Single serial number feature.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for
 *      storing error codes.
 * @param features (Output) a pre-allocated array to hold the list of
 *      supported serial number features
 * @param max_features (Input) size of the preallocated output array
 * @return the number of serial number feature IDs that were copied.
 *}
function SB_get_serial_number_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This reads the device's serial number and fills the
 * provided array (up to the given length) with it.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a serial
 *      number feature.  Valid IDs can be found with the
 *      SB_get_serial_number_features() function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param Buffer (Output)  A pre-allocated array of Characters that the
 *      serial number will be copied into
 * @param Buffer_length (Input) The number of values to copy into the Buffer
 *      (this should be no larger than the number of Chars allocated in
 *      the Buffer)
 *
 * @return the number of Bytes written into the Buffer
 *}
function SB_get_serial_number(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;

{*
 * This reads the possible maximum length of the device's serial number
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a serial
 *      number feature.  Valid IDs can be found with the
 *      SB_get_serial_number_features() function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 *
 * @return the length of the serial number in an unsigned Character Byte
 *}
function SB_get_serial_number_maximum_length(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte;

{*
 * This function returns the total number of spectrometer instances available
 * in the indicated device.  Each instance refers to a Single optical bench.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @return the number of spectrometer features that will be returned
 *  by a call to SB_get_spectrometer_features().
 *}
function SB_get_number_of_spectrometer_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each spectrometer instance for this
 * device.  Each instance refers to a Single optical bench.  The IDs are only
 * valid when used with the deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for
 *      storing error codes.
 * @param features (Output) a preallocated output array to hold the features
 * @param max_features (Input) size of the preallocated output array
 * @return Returns the number of spectrometer feature IDs that were copied.
 *}
function SB_get_spectrometer_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function sets the trigger mode for the specified device.
 * Note that requesting an unsupported mode will result in an error.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a
 *      spectrometer feature.  Valid IDs can be found with the
 *      SB_get_spectrometer_features() function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param mode (Input) a trigger mode (0 = normal, 1 = software,
 *      2 = synchronization, 3 = external hardware, etc - check your
 *      particular spectrometer's Data Sheet)
 *}
procedure SB_spectrometer_set_trigger_mode(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; mode: LongInt);

{*
 * This function sets the integration time for the specified device.
 * This function should not be responsible for performing stability
 * scans.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a
 *      spectrometer feature.  Valid IDs can be found with the
 *      SB_get_spectrometer_features() function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param integration_time_micros (Input) The new integration time in
 *      units of microseconds
 *}
procedure SB_spectrometer_set_integration_time_micros(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; integration_time_micros: DWord);

{*
 * This function returns the smallest integration time setting,
 * in microseconds, that is valid for the spectrometer.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a
 *      spectrometer feature.  Valid IDs can be found with the
 *      SB_get_spectrometer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used
 *      for storing error codes.
 * @return Returns minimum legal integration time in microseconds if > 0.
 *      On error, returns -1 and errorCode will be set accordingly.
 *}
function SB_spectrometer_get_minimum_integration_time_micros(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns the maximum pixel intensity for the
 * spectrometer.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a
 *      spectrometer feature.  Valid IDs can be found with the
 *      SB_get_spectrometer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used
 *      for storing error codes.
 * @return Returns maximum pixel intensity if > 0.
 *      On error, returns -1 and errorCode will be set accordingly.
 *}
function SB_spectrometer_get_maximum_intensity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Double;

{*
 * This returns an integer denoting the number of pixels in a
 * formatted spectrum (as returned by get_formatted_spectrum(...)).
 *
 * @param deviceID (Input)  The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a spectrometer
 *      feature.  Valid IDs can be found with the SB_get_spectrometer_features()
 *      function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 *
 * @return the length of a formatted spectrum.
 *}
function SB_spectrometer_get_formatted_spectrum_length(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This acquires a spectrum and returns the answer in formatted
 *     floats.  In this mode, auto-nulling should be automatically
 *     performed for devices that support it.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a
 *      spectrometer feature.  Valid IDs can be found with the
 *      SB_get_spectrometer_features() function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param Buffer (Output) A Buffer (with memory already allocated) to
 *      hold the spectral data
 * @param Buffer_length (Input) The length of the Buffer
 *
 * @return the number of floats read into the Buffer
 *}
function SB_spectrometer_get_formatted_spectrum(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PDouble; Buffer_length: LongInt): LongInt;

{*
 * This returns an integer denoting the length of a raw spectrum
 * (as returned by get_unformatted_spectrum(...)).
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      open_spectrometer().
 * @param featureID (Input) The ID of a particular instance of a
 *      spectrometer feature.  Valid IDs can be found with the
 *      SB_get_spectrometer_features() function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 *
 * @return the length of an unformatted spectrum.
 *}
function SB_spectrometer_get_unformatted_spectrum_length(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This acquires a spectrum and returns the answer in raw,
 * unformatted Bytes.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      open_spectrometer().
 * @param featureID (Input) The ID of a particular instance of a spectrometer
 *      feature.  Valid IDs can be found with the SB_get_spectrometer_features()
 *      function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param Buffer (Output) A Buffer (with memory already allocated) to hold
 *      the spectral data
 * @param Buffer_length (Input) The length of the Buffer
 *
 * @return the number of Bytes read into the Buffer
 *}
function SB_spectrometer_get_unformatted_spectrum(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PByte; Buffer_length: LongInt): LongInt;

{*
 * This computes the wavelengths for the spectrometer and fills in the
 * provided array (up to the given length) with those values.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      open_spectrometer().
 * @param featureID (Input) The ID of a particular instance of a spectrometer
 *      feature.  Valid IDs can be found with the SB_get_spectrometer_features()
 *      function.
 * @param errorCode (Ouput) pointer to an integer that can be used for storing
 *      error codes.
 * @param wavelengths (Output) A pre-allocated array of Doubles that the wavelengths
 *      will be copied into
 * @param length (Input) The number of values to copy into the wavelength array
 *      (this should be no larger than the number of Doubles allocated in the wavelengths
 *      array)
 *
 * @return the number of Bytes written into the wavelength Buffer
 *}
function SB_spectrometer_get_wavelengths(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; wavelengths: PDouble; length: LongInt): LongInt;

{*
 * This returns the number of pixels that are electrically active but
 * optically masked (a.k.a. electric dark pixels).  Note that not all
 * detectors have optically masked pixels; in that case, this function
 * will return zero.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a spectrometer
 *      feature.  Valid IDs can be found with the SB_get_spectrometer_features()
 *      function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of pixels that can be retrieved by the
 *      SB_spectrometer_get_electric_dark_pixel_indices() function.
 *}
function SB_spectrometer_get_electric_dark_pixel_count(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This fills in the provided array (up to the given length) with the indices
 * of the pixels that are electrically active but optically masked
 * (a.k.a. electric dark pixels).  Note that not all detectors have optically
 * masked pixels; in that case, this function will return zero.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a spectrometer
 *      feature.  Valid IDs can be found with the SB_get_spectrometer_features()
 *      function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param indices (Output) A pre-allocated array of ints that the pixel indices
 *      will be copied into
 * @param length (Input) The number of values to copy into the indices array
 *      (this should be no larger than the number of ints allocated in the indices
 *      array)
 *
 * @return the number of Bytes written into the indices Buffer
 *}
function SB_spectrometer_get_electric_dark_pixel_indices(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; indices: PLongInt; length: LongInt): LongInt;

{*
 * This function returns the total number of pixel binning instances available
 * in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 *
 * @return the number of pixel binning features that will be returned by a call
 *      to SB_get_pixel_binning_features().
 *}
function SB_get_number_of_pixel_binning_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each pixel binning feature for this
 * device.  The IDs are only valid when used with the deviceID used to
 * obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for
 *      storing error codes.
 * @param features (Output) a pre-populated array to hold the returned
 *      feature handles
 * @param max_features (Input) size of the pre-allocated array
 *
 * @return the number of pixel binning feature IDs that were copied.
 *}
function SB_get_pixel_binning_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function sets the pixel binning factor on the device.
 *
 *  @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 *  @param featureID (Input) The ID of a particular instance of a pixel binning feature.
 *        Valid IDs can be found with the SB_get_pixel_binning_features() function.
 *  @param errorCode (Output) A pointer to an integer that can be used for
 *      storing error codes.
 *  @param factor (Input) The desired pixel binning factor.
 *}
procedure SB_binning_set_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; factor: Byte);

{*
 * This function gets the pixel binning factor on the device.
 *
 *  @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 *  @param featureID (Input) The ID of a particular instance of a pixel binning feature.
 *        Valid IDs can be found with the SB_get_pixel_binning_features() function.
 *  @param errorCode (Output) A pointer to an integer that can be used for
 *      storing error codes.
 *
 * @return the pixel binning factor for the specified feature.
 *}
function SB_binning_get_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte;

{*
 * This function sets the default pixel binning factor on the device.
 *
 *  @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 *  @param featureID (Input) The ID of a particular instance of a pixel binning feature.
 *        Valid IDs can be found with the SB_get_pixel_binning_features() function.
 *  @param errorCode (Output)A pointer to an integer that can be used for
 *      storing error codes.
 *  @param factor (Input) The desired default pixel binning factor.
 *}
procedure SB_binning_set_default_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; factor: Byte);

{*
 * This function resets the default pixel binning factor on the device back to the factory default.
 *
 *  @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 *  @param featureID (Input) The ID of a particular instance of a pixel binning feature.
 *        Valid IDs can be found with the SB_get_pixel_binning_features() function.
 *  @param errorCode (Output)A pointer to an integer that can be used for
 *      storing error codes.
 *}
procedure SB_binning_reset_default_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt);

{*
 * This function gets the default pixel binning factor on the device.
 *
 *  @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 *  @param featureID (Input) The ID of a particular instance of a pixel binning feature.
 *        Valid IDs can be found with the SB_get_pixel_binning_features() function.
 *  @param errorCode (Output)A pointer to an integer that can be used for
 *      storing error codes.
 *
 * @return the default pixel binning factor for the specified feature.
 *}
function SB_binning_get_default_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte;

{*
 * This function gets the maximum pixel binning factor on the device.
 *
 *  @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 *  @param featureID (Input) The ID of a particular instance of a pixel binning feature.
 *        Valid IDs can be found with the SB_get_pixel_binning_features() function.
 *  @param errorCode (Output)A pointer to an integer that can be used for
 *      storing error codes.
 *
 * @return the maximum pixel binning factor for the specified feature.
 *}
function SB_binning_get_max_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte;

{*
 * This function returns the total number of shutter instances available
 * in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 *
 * @return the number of shutter features that will be returned by a call
 *      to SB_get_shutter_features().
 *}
function SB_get_number_of_shutter_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each shutter instance for this
 * device.  The IDs are only valid when used with the deviceID used to
 * obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for
 *      storing error codes.
 * @param features (Output) a pre-populated array to hold the returned
 *      feature handles
 * @param max_features (Input) size of the pre-allocated array
 *
 * @return the number of shutter feature IDs that were copied.
 *}
function SB_get_shutter_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function sets the shutter state on the device.
 *
 *  @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 *  @param featureID (Input) The ID of a particular instance of a shutter feature.
 *        Valid IDs can be found with the SB_get_shutter_features() function.
 *  @param errorCode (Output)A pointer to an integer that can be used for
 *      storing error codes.
 *  @param opened (Input) A boolean used for denoting the desired state
 *      (opened/closed) of the shutter.   If the value of
 *      opened is non-zero, then the shutter will open.  If
 *      the value of opened is zero, then the shutter will close.
 *}
procedure SB_shutter_set_shutter_open(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; opened: Byte);

{*
 * This function returns the total number of light source instances available
 * in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 *
 * @return the number of light source features that will be returned
 *      by a call to SB_get_light_source_features().
 *}
function SB_get_number_of_light_source_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each light source instance for this
 * device.  The IDs are only valid when used with the deviceID used to
 * obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param features (Output) pre-allocated Buffer that will receive the IDs of the
 *      feature instances
 * @param max_features (Input) the maximum number of elements that can be
 *      copied into the provided features array
 *
 * @return the number of light source feature IDs that were copied.
 *}
function SB_get_light_source_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function gets the number of light sources that are represented by
 * the given featureID.  Such light sources could be individual LEDs,
 * light bulbs, lasers, etc.  Each of these light sources may have different
 * capabilities, such as programmable intensities and enables, which should
 * be queried before they are used.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input)  The ID of a particular instance of a light source
 *      feature.  Valid IDs can be found with SB_get_light_source_features().
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 *
 * @return the number of light sources (e.g. bulbs) in the indicated feature
 *}
function SB_light_source_get_count(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;

{*
 * Queries whether the indicated light source within the given feature
 * instance has a usable enable/disable control.  If this returns 0
 * (meaning no enable available) then calling SB_light_source_set_enable()
 * or SB_light_source_is_enabled() is likely to result in an error.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a light source
 *      feature.  Valid IDs can be found with the SB_get_light_source_features()
 *      function.
 * @param errorCode (Ouput)  A pointer to an integer that can be used for
 *      storing error codes.
 * @param light_source_index (Input) Which of potentially many light sources
 *      (LEDs, lasers, light bulbs) within the indicated feature instance to query
 *
 * @return 0 to indicate specified light source cannot be enabled/disabled,
 *         1 to indicate specified light source can be enabled/disabled with
 *                       SB_light_source_set_enable()
 *}
function SB_light_source_has_enable(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Byte;

{*
 * Queries whether the indicated light source within the given feature
 * instance is enabled (energized).
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a light source feature.  Valid
 *        IDs can be found with the SB_get_light_source_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param light_source_index (Input) Which of potentially many light sources (LEDs, lasers,
 *      light bulbs) within the indicated feature instance to query
 *
 * @return 0 to indicate specified light source is disabled (should emit no light),
 *         1 to indicate specified light source is enabled (should emit light depending
 *                       on configured intensity setting)
 *}
function SB_light_source_is_enabled(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Byte;

{*
 * Attempts to enable or disable the indicated light source within the given
 * feature instance.  Not all light sources have an enable/disable control,
 * and this capability can be queried with SB_light_source_has_enable().
 * Note that an enabled light source should emit light according to its last
 * (or default) intensity setting which might be the minimum; in this case,
 * the light source might appear to remain off.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a light source feature.  Valid
 *        IDs can be found with the SB_get_light_source_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param light_source_index (Input) Which of potentially many light sources (LEDs, lasers,
 *      light bulbs) within the indicated feature instance to query
 * @param enable (Input) Whether to enable the light source.  A value of zero will attempt
 *      to disable the light source, and any other value will enable it.
 *}
procedure SB_light_source_set_enable(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt; enable: Byte);

{*
 * Queries whether the indicated light source within the given feature
 * instance has a usable intensity control.  If this returns 0
 * (meaning no control available) then calling SB_light_source_set_intensity()
 * or SB_light_source_get_intensity() is likely to result in an error.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a light source feature.  Valid
 *        IDs can be found with the SB_get_light_source_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param light_source_index (Input) Which of potentially many light sources (LEDs, lasers,
 *      light bulbs) within the indicated feature instance to query
 *
 * @return 0 to indicate specified light source cannot have its intensity changed,
 *         1 to indicate the specified light source can have its intensity controlled
 *                       with SB_light_source_set_intensity()
 *}
function SB_light_source_has_variable_intensity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Byte;

{*
 * Queries the intensity level of the indicated light source within the
 * given feature instance.  The intensity is normalized over the
 * range [0, 1], with 0 as the minimum and 1 as the maximum.
 *
 * SAFETY WARNING: a light source at its minimum intensity (0) might still
 * emit light, and in some cases, this may be harmful radiation.  A value
 * of 0 indicates the minimum of the programmable range for the light source,
 * and does not necessarily turn the light source off.  To disable a light
 * source completely, use SB_light_source_set_enable() if the device
 * supports this feature, or provide some other mechanism to allow the light
 * to be disabled or blocked by the operator.
 *
 * In some cases, the intensity may refer to the duty cycle of a pulsed
 * light source instead of a continuous power rating.  The actual power output
 * of the light source might not vary linearly with the reported intensity,
 * so independent measurement or calibration of the light source may be
 * necessary.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a light source feature.  Valid
 *        IDs can be found with the SB_get_light_source_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param light_source_index (Input) Which of potentially many light sources (LEDs, lasers,
 *      light bulbs) within the indicated feature instance to query
 *
 * @return Real-valued result (as a Double-precision floating point number) over
 *  the range [0, 1] where 0 represents the minimum programmable intensity
 *  level and 1 indicates the maximum.  Note that the minimum intensity level
 *  might still allow the light source to produce light.
 *}
function SB_light_source_get_intensity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Double;

{*
 * Sets the intensity level of the indicated light source within the
 * given feature instance.  The intensity is normalized over the
 * range [0, 1], with 0 as the minimum and 1 as the maximum.
 *
 * SAFETY WARNING: a light source at its minimum intensity (0) might still
 * emit light, and in some cases, this may be harmful radiation.  A value
 * of 0 indicates the minimum of the programmable range for the light source,
 * and does not necessarily turn the light source off.  To disable a light
 * source completely, use SB_light_source_set_enable() if the device
 * supports this feature, or provide some other mechanism to allow the light
 * to be disabled or blocked by the operator.
 *
 * In some cases, the intensity may refer to the duty cycle of a pulsed
 * light source instead of a continuous power rating.  The actual power output
 * of the light source might not vary linearly with the reported intensity,
 * so independent measurement or calibration of the light source may be
 * necessary.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a light source feature.  Valid
 *        IDs can be found with the SB_get_light_source_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param light_source_index (Input) Which of potentially many light sources (LEDs, lasers,
 *      light bulbs) within the indicated feature instance to query
 * @param intensity (Input) The target intensity of the light source in the range [0, 1]
 *}
procedure SB_light_source_set_intensity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt; intensity: Double);

{
 * This function returns the total number of strobe/lamp instances available
 * in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of strobe/lamp features that will be returned
 *      by a call to SB_get_strobe_lamp_features().
 *}
{ There is not code in seabreezeAPI.cpp for this function. Perhaps it was not finished }
{ int }
{SB_get_number_of_strobe_lamp_features(long deviceID, int *errorCode); }
{
 * This function returns IDs for accessing each strobe/lamp instance for this
 * device.  The IDs are only valid when used with the deviceID used to
 * obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) a preallocated array to hold returned feature handles
 * @param max_features (Input) length of the preallocated Buffer
 *
 * @return the number of strobe/lamp feature IDs that were copied.
 *}
{ There is not code in seabreezeAPI.cpp for this function. Perhaps it was not finished. }
{ int }
{SB_get_strobe_lamp_features(long deviceID, int *errorCode, long *features, }
{        int max_features); }
{*
 * This function returns the total number of lamp instances available
 * in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of lamp features that will be returned
 *      by a call to SB_get_lamp_features().
 *}
function SB_get_number_of_lamp_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each lamp instance for this
 * device.  The IDs are only valid when used with the deviceID used to
 * obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) a preallocated array to hold returned feature handles
 * @param max_features (Input) length of the preallocated Buffer
 *
 * @return the number of lamp feature IDs that were copied.
 *}
function SB_get_lamp_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function sets the strobe enable on the spectrometer.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a lamp feature.  Valid
 *        IDs can be found with the SB_get_lamp_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param lamp_enable (Input) A Character used for denoting the desired value
 *      (high/low) of the strobe-enable pin.   If the value of
 *      strobe_enable is zero, then the pin should be set low.  If
 *      the value of strobe_enable is non-zero, then the pin should be
 *      set high.
 *}
procedure SB_lamp_set_lamp_enable(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; lamp_enable: Byte);

{*
 * This function returns the total number of continuous strobe instances
 * available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of continuous strobe features that will be returned
 *      by a call to SB_get_continuous_strobe_features().
 *}
function SB_get_number_of_continuous_strobe_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each continuous strobe instance
 * for this device.  The IDs are only valid when used with the deviceID
 * used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) a preallocated array to hold returned feature handles
 * @param max_features (Input) length of the preallocated Buffer
 *
 * @return the number of continuous strobe feature IDs that were copied.
 *}
function SB_get_continuous_strobe_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function sets the continuous strobe enable state on the device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a continuous strobe feature.
 *        Valid IDs can be found with the SB_get_continuous_strobe_features()
 *        function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 * @param enable (Input) A boolean used for denoting the desired state
 *        (on/off) of the continuous strobe generator.   If the value of
 *        enable is nonzero, then the continuous strobe will operate.  If
 *        the value of enable is zero, then the continuous strobe will stop.
 *        Note that on some devices the continuous strobe enable is tied to other
 *        enables (such as lamp enable or Single strobe enable) which may cause
 *        side effects.
 *}
procedure SB_continuous_strobe_set_continuous_strobe_enable(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; enable: Byte);

{*
 * This function sets the continuous strobe period on the device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a continuous strobe feature.
 *        Valid IDs can be found with the SB_get_continuous_strobe_features()
 *        function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param period_micros (Input) The new period of the continous strobe measured in microseconds
 *}
procedure SB_continuous_strobe_set_continuous_strobe_period_micros(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; period_micros: DWord);

{*
 * This function returns the total number of EEPROM instances available
 * in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of EEPROM features that will be returned
 *  by a call to SB_get_eeprom_features().
 *}
function SB_get_number_of_eeprom_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each EEPROM instance for this
 * device.  The IDs are only valid when used with the deviceID used to
 * obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) a preallocated array to hold returned feature handles
 * @param max_features (Input) length of the preallocated Buffer
 *
 * @return the number of EEPROM feature IDs that were copied.
 *}
function SB_get_eeprom_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function reads a string out of the device's EEPROM slot
 * and returns the result.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of an EEPROM feature.  Valid
 *        IDs can be found with the SB_get_eeprom_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param slot_number (Input) The number of the slot to read out.  Possible
 *      values are 0 through 17.
 * @param Buffer (Output)  A Buffer (with memory already allocated) to hold the
 *      value read out of the EEPROM slot
 * @param Buffer_length (Input) The length of the Buffer
 *
 * @return the number of Bytes read from the EEPROM slot into the Buffer
 *}
 {*
  * Meaning of EEPROM slots
  * CAUTION: not all spectrometers follow these conventions. Be sure to check the data sheets for your spectrometer.
     0 - serial number (this slot may not be written by the customer)
     1 - wavelength calibration coefficient - 0th order (aka "intercept")
     2 - wavelength calibration coefficient - 1st order
     3 - wavelength calibration coefficient - 2nd order
     4 - wavelength calibration coefficient - 3rd order
     5 - stray light constant
     6 - non-linearity correction coefficient - 0th order
     7 - non-linearity correction coefficient - 1st order
     8 - non-linearity correction coefficient - 2nd order
     9 - non-linearity correction coefficient - 3rd order
     10 - non-linearity correction coefficient - 4th order
     11 - non-linearity correction coefficient - 5th order
     12 - non-linearity correction coefficient - 6th order
     13 - non-linearity correction coefficient - 7th order
     14 - polynomial order of non-linearity calibration
     15 - optical bench configuration (not writable by the customer)
     Format: gg fff sss
     gg: grating number
     fff: filter wavelength
     sss: slit size
     16 - USB2000 configuration (not writable by the customer)
     Format: A W L V
     A: array coating manufacturer
     W: array wavelength (VIS, UV, OFLV)
     L: L2 lens installed
     V: CPLD version
 *}
function SB_eeprom_read_slot(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; slot_number: LongInt; Buffer:PByte;
           Buffer_length: LongInt): LongInt;

{*
 * This function returns the total number of irradiance calibration
 * instances available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of irradiance calibration features that will be
 *      returned by a call to SB_get_irrad_cal_features().
 *}
function SB_get_number_of_irrad_cal_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each irradiance calibration
 * instance for this device.  The IDs are only valid when used with the
 * deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) a preallocated array to hold returned feature handles
 * @param max_features (Input) length of the preallocated Buffer
 *
 * @return the number of irradiance calibration feature IDs that were copied.
 *}
function SB_get_irrad_cal_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function reads out an irradiance calibration from the spectrometer's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of an irradiance calibration
 *        feature.  Valid IDs can be found with the
 *        SB_get_irrad_cal_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param Buffer (Output) preallocated array to hold irradiance calibration scalars (one per pixel)
 * @param Buffer_length (Input) size of the preallocated Buffer (should equal pixel count)
 *
 * @return the number of floats read from the device into the Buffer
 *}
function SB_irrad_calibration_read(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PSingle; Buffer_length: LongInt): LongInt;

{*
 * This function writes an irradiance calibration to the device's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of an irradiance calibration
 *        feature.  Valid IDs can be found with the
 *        SB_get_irrad_cal_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param Buffer (Output) array of floating point values to store into the device
 * @param Buffer_length (Input) number of calibration factors to write
 *
 * @return the number of floats written from the Buffer to the device
 *}
function SB_irrad_calibration_write(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PSingle; Buffer_length: LongInt): LongInt;

{*
 * This function checks for an irradiance collection area in the device's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of an irradiance calibration
 *        feature.  Valid IDs can be found with the
 *        SB_get_irrad_cal_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return 0 if no collection area available, 1 if available.
 *}
function SB_irrad_calibration_has_collection_area(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function reads an irradiance collection area from the device's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of an irradiance calibration
 *        feature.  Valid IDs can be found with the
 *        SB_get_irrad_cal_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return float: collection area (usually in units of cm^2) read from device
 *}
function SB_irrad_calibration_read_collection_area(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Single;

{*
 * This function writes an irradiance collection area to the spectrometer's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of an irradiance calibration
 *        feature.  Valid IDs can be found with the
 *        SB_get_irrad_cal_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param area (Input) collection area to save to spectrometer, presumably in cm^2
 *}
procedure SB_irrad_calibration_write_collection_area(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; area: Single);

{*
 * This function returns the total number of thermoelectric cooler (TEC)
 * instances available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of TEC features that will be returned by a call to
 *      SB_get_thermoelectric_features().
 *}
function SB_get_number_of_thermo_electric_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each thermoelectric cooler
 * (TEC) instance for this device.  The IDs are only valid when used with
 * the deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) preallocated array to hold feature handles
 * @param max_features (Input) size of the preallocated array
 *
 * @return the number of TEC feature IDs that were copied.
 *}
function SB_get_thermo_electric_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function reads the actual temperature of the TEC and returns the value in
 * degrees celsius.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of an thermoelectric cooler
 *        feature.  Valid IDs can be found with the
 *        SB_get_thermo_electric_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return Double: The TEC temperature in degrees celsius.
 *}
function SB_tec_read_temperature_degrees_C(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Double;

{*
 * This function sets the target (setpoint) TEC temperature.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of an thermoelectric cooler
 *        feature.  Valid IDs can be found with the
 *        SB_get_thermo_electric_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param temperature_degrees_celsius (Input) desired temperature,
 *      in degrees celsius.
 *}
procedure SB_tec_set_temperature_setpoint_degrees_C(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; temperature_degrees_celsius: Double);

{*
 * This function enables the TEC feature on the device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of an thermoelectric cooler
 *        feature.  Valid IDs can be found with the
 *        SB_get_thermo_electric_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param tec_enable (Input) A Character that denotes the desired TEC enable
 *      state.  If the value of tec_enable is zero, the TEC should
 *      be disabled.  If the value of tec_enable is non-zero, the TEC
 *      should be enabled.
 *}
procedure SB_tec_set_enable(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; tec_enable: Byte);

{*
 * This function returns the total number of nonlinearity coefficient feature
 * instances available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of features that will be returned by a call to
 *      SB_get_nonlinearity_coeffs_features().
 *}
function SB_get_number_of_nonlinearity_coeffs_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each nonlinearity coefficient
 * feature instance for this device.  The IDs are only valid when used with
 * the deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) preallocated array to hold returned feature handles
 * @param max_features (Input) size of preallocated array
 *
 * @return the number of nonlinearity coefficient feature IDs that were copied.
 *}
function SB_get_nonlinearity_coeffs_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function reads out nonlinearity coefficients from the device's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a nonlinearity coefficient
 *        feature.  Valid IDs can be found with the
 *        SB_get_nonlinearity_coeffs_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param Buffer (Output) preallocated Buffer to store NLC coefficients
 * @param max_length (Input) size of preallocated Buffer
 *
 * @return the number of Doubles read from the device into the Buffer
 *}
function SB_nonlinearity_coeffs_get(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PDouble; max_length: LongInt): LongInt;

{*
 * This function returns the total number of temperature feature
 * instances available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of features that will be returned by a call to
 *      SB_get_temperature_features().
 *}
function SB_get_number_of_temperature_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each temperature
 * feature instance for this device.  The IDs are only valid when used with
 * the deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) preallocated array to hold returned feature handles
 * @param max_features (Input) size of preallocated array
 *
 * @return the number of temperature feature IDs that were copied.
 *}
function SB_get_temperature_features(deviceID: LongInt; errorCode: PLongInt; temperatureFeatures: PLongInt; max_features: LongInt): LongInt;

{*
 * This function reads out an the number of indexed temperatures available from the
 *  device's internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a temperature
 *        feature.  Valid IDs can be found with the
 *        SB_get_temperature_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of temperatures available as an unsigned Char
 *}
function SB_temperature_count_get(deviceID: LongInt; temperatureFeatureID: LongInt; errorCode: PLongInt): Byte;

{*
 * This function reads out an indexed temperature from the device's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a temperature
 *        feature.  Valid IDs can be found with the
 *        SB_get_temperature_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param index (Input) An index for the device's temperature sensors
 *
 * @return the temperature as a Double
 *}
function SB_temperature_get(deviceID: LongInt; temperatureFeatureID: LongInt; errorCode: PLongInt; index: LongInt): Double;

{*
 * This function reads out all temperatures from the device's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a temperature
 *        feature.  Valid IDs can be found with the
 *        SB_get_temperature_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param Buffer (Output) preallocated Buffer to store temperatures
 * @param max_length (Input) size of preallocated Buffer
 *
 * @return the number of Doubles read from the device into the Buffer
 *}
function SB_temperature_get_all(deviceID: LongInt; temperatureFeatureID: LongInt; errorCode: PLongInt; Buffer: PDouble; max_length: LongInt): LongInt;

{*
 * This function returns the total number of spectrum processing feature
 * instances available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of features that will be returned by a call to
 *      SB_get_spectrum_processing_features().
 *}
function SB_get_number_of_spectrum_processing_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each spectrum processing
 * feature instance for this device.  The IDs are only valid when used with
 * the deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) preallocated array to hold returned feature handles
 * @param max_features (Input) size of preallocated array
 *
 * @return the number of spectrum processing feature IDs that were copied.
 *}
function SB_get_spectrum_processing_features(deviceID: LongInt; errorCode: PLongInt; spectrumProcessingFeatures: PLongInt; max_features: LongInt): LongInt;

{*
 * This function reads out an the number of scans to average from the
 *  device's internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a spectrum processing
 *        feature.  Valid IDs can be found with the
 *        SB_get_spectrum_processing_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of scans to average as an unsigned short integer
 *}
function SB_spectrum_processing_scans_to_average_get(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt): Word;

{*
 * This function sets the number of scans to average in the the device's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a spectrum processing
 *        feature.  Valid IDs can be found with the
 *        SB_get_spectrum_processing_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param scansToAverage (Input) The number of spectrum scans used to generate a less
 *		noisy spectrum due to averaging
 *
 * @return void
 *}
procedure SB_spectrum_processing_scans_to_average_set(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt; scansToAverage: Word);

{*
 * This function reads out an the width of the boxcar filter from the
 *  device's internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a spectrum processing
 *        feature.  Valid IDs can be found with the
 *        SB_get_spectrum_processing_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the width of the boxcar filter an unsigned Char (values typically 0-15)
 *}
function SB_spectrum_processing_boxcar_width_get(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt): Byte;

{*
 * This function sets width of the boxcar filter in the the device's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a spectrum processing
 *        feature.  Valid IDs can be found with the
 *        SB_get_spectrum_processing_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param boxcarWidth (Input) The width of the boxcar smoothing function to be used.
 *			Values are typically 1 to 15.
 *
 * @return void
 *}
procedure SB_spectrum_processing_boxcar_width_set(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt; boxcarWidth: Byte);

{*
 * This function returns the total number of revision feature
 * instances available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of features that will be returned by a call to
 *      SB_get_revision_features().
 *}
function SB_get_number_of_revision_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each revision
 * feature instance for this device.  The IDs are only valid when used with
 * the deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) preallocated array to hold returned feature handles
 * @param max_features (Input) size of preallocated array
 *
 * @return the number of revision feature IDs that were copied.
 *}
function SB_get_revision_features(deviceID: LongInt; errorCode: PLongInt; revisionFeatures: PLongInt; max_features: LongInt): LongInt;

{*
 * This function reads out the hardware revision from the device's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a temperature
 *        feature.  Valid IDs can be found with the
 *        SB_get_revision_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the hardware revision as one unsigned Char Byte. (Note that both Ocean View and SpectraSuite display the hex value.)
 *}
function SB_revision_hardware_get(deviceID: LongInt; revisionFeatureID: LongInt; errorCode: PLongInt): Byte;

{*
 * This function reads out the firmware revision from the device's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a temperature
 *        feature.  Valid IDs can be found with the
 *        SB_get_revision_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the firmware revision as two unsigned short int Bytes (Note that both Ocean View and SpectraSuite display the hex value.)
 *}
function SB_revision_firmware_get(deviceID: LongInt; revisionFeatureID: LongInt; errorCode: PLongInt): Word;

{*
 * This function returns the total number of optical bench feature
 * instances available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of features that will be returned by a call to
 *      SB_get_optical_bench_features().
 *}
function SB_get_number_of_optical_bench_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each optical bench
 * feature instance for this device.  The IDs are only valid when used with
 * the deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) preallocated array to hold returned feature handles
 * @param max_features (Input) size of preallocated array
 *
 * @return the number of optical bench feature IDs that were copied.
 *}
function SB_get_optical_bench_features(deviceID: LongInt; errorCode: PLongInt; opticalBenchFeatures: PLongInt; max_features: LongInt): LongInt;

{*
 * This function reads out the optical bench fiber diameter in microns
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param opticalBenchFeatureID (Input) The ID of a particular instance of a optical
 *        bench feature.  Valid IDs can be found with the
 *        SB_get_optical_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the fiber diameter in microns
 *}
function SB_optical_bench_get_fiber_diameter_microns(deviceID: LongInt; opticalBenchFeatureID: LongInt; errorCode: PLongInt): Word;

{*
 * This function reads out the optical bench slit width in microns
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param opticalBenchFeatureID (Input) The ID of a particular instance of a optical
 *        bench feature.  Valid IDs can be found with the
 *        SB_get_optical_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the slit width in microns
 *}
function SB_optical_bench_get_slit_width_microns(deviceID: LongInt; opticalBenchFeatureID: LongInt; errorCode: PLongInt): Word;

{*
 * This reads the optical bench ID and fills the
 * provided array (up to the given length) with it.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param opticalBenchFeatureID (Input) The ID of a particular instance of a serial
 *      number feature.  Valid IDs can be found with the
 *      SB_get_optical_bench_features() function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param Buffer (Output)  A pre-allocated array of Characters that the
 *      serial number will be copied into
 * @param Buffer_length (Input) The number of values to copy into the Buffer
 *      (this should be no larger than the number of Chars allocated in
 *      the Buffer)
 *
 * @return the number of Bytes written into the Buffer
 *}
function SB_optical_bench_get_id(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;

{*
 * This reads the optical bench Serial Number and fills the
 * provided array (up to the given length) with it.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param opticalBenchFeatureID (Input) The ID of a particular instance of a serial
 *      number feature.  Valid IDs can be found with the
 *      SB_get_optical_bench_features() function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param Buffer (Output)  A pre-allocated array of Characters that the
 *      serial number will be copied into
 * @param Buffer_length (Input) The number of values to copy into the Buffer
 *      (this should be no larger than the number of Chars allocated in
 *      the Buffer)
 *
 * @return the number of Bytes written into the Buffer
 *}
function SB_optical_bench_get_serial_number(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;

{*
 * This reads the optical bench Coating and fills the
 * provided array (up to the given length) with it.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param opticalBenchFeatureID (Input) The ID of a particular instance of a serial
 *      number feature.  Valid IDs can be found with the
 *      SB_get_optical_bench_features() function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param Buffer (Output)  A pre-allocated array of Characters that the
 *      serial number will be copied into
 * @param Buffer_length (Input) The number of values to copy into the Buffer
 *      (this should be no larger than the number of Chars allocated in
 *      the Buffer)
 *
 * @return the number of Bytes written into the Buffer
 *}
function SB_optical_bench_get_coating(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;

{*
 * This reads the optical bench filter and fills the
 * provided array (up to the given length) with it.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param opticalBenchFeatureID (Input) The ID of a particular instance of a serial
 *      number feature.  Valid IDs can be found with the
 *      SB_get_optical_bench_features() function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param Buffer (Output)  A pre-allocated array of Characters that the
 *      serial number will be copied into
 * @param Buffer_length (Input) The number of values to copy into the Buffer
 *      (this should be no larger than the number of Chars allocated in
 *      the Buffer)
 *
 * @return the number of Bytes written into the Buffer
 *}
function SB_optical_bench_get_filter(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;

{*
 * This reads the optical bench grating and fills the
 * provided array (up to the given length) with it.
 *
 * @param deviceID (Input) The index of a device previously opened with
 *      SB_open_device().
 * @param opticalBenchFeatureID (Input) The ID of a particular instance of a serial
 *      number feature.  Valid IDs can be found with the
 *      SB_get_optical_bench_features() function.
 * @param errorCode (Output) pointer to an integer that can be used for
 *      storing error codes.
 * @param Buffer (Output)  A pre-allocated array of Characters that the
 *      serial number will be copied into
 * @param Buffer_length (Input) The number of values to copy into the Buffer
 *      (this should be no larger than the number of Chars allocated in
 *      the Buffer)
 *
 * @return the number of Bytes written into the Buffer
 *}
function SB_optical_bench_get_grating(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;

{*
 * This function returns the total number of stray light coefficient feature
 * instances available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of features that will be returned by a call to
 *      SB_get_stray_light_coeffs_features().
 *}
function SB_get_number_of_stray_light_coeffs_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each stray light coefficient
 * feature instance for this device.  The IDs are only valid when used with
 * the deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) preallocated Buffer to hold returned feature handles
 * @param max_features (Input) size of preallocated Buffer
 *
 * @return the number of stray light coefficient feature IDs that were copied.
 *}
function SB_get_stray_light_coeffs_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;

{*
 * This function reads out stray light coefficients from the device's
 * internal memory if that feature is supported.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a stray light coefficient
 *        feature.  Valid IDs can be found with the
 *        SB_get_stray_light_coeffs_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param Buffer (Output) preallocated Buffer to store stray light coefficients
 * @param max_length (Input) size of preallocated Buffer
 *
 * @return the number of Doubles read from the device into the Buffer
 *}
function SB_stray_light_coeffs_get(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PDouble; max_length: LongInt): LongInt;

{*
 * This function returns the total number of data Buffer feature
 * instances available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of features that will be returned by a call to
 *      SB_get_data_Buffer_features().
 *}
function SB_get_number_of_data_Buffer_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each data Buffer
 * feature instance for this device.  The IDs are only valid when used with
 * the deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) preallocated Buffer to hold returned feature handles
 * @param max_features (Input) size of preallocated Buffer
 *
 * @return the number of data Buffer feature IDs that were copied.
 *}
function SB_get_data_Buffer_features(deviceID: LongInt; errorCode: PLongInt; Buffer: PLongInt; maxLength: DWord): LongInt;

{*
 * @brief Clear the data Buffer
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a data Buffer
 *        feature.  Valid IDs can be found with the
 *        SB_get_data_Buffer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 *}
procedure SB_data_Buffer_clear(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt);

{*
 * @brief Get the number of data elements currently in the Buffer
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a data Buffer
 *        feature.  Valid IDs can be found with the
 *        SB_get_data_Buffer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 * @return A count of how many items are available for retrieval from the Buffer
 *}
function SB_data_Buffer_get_number_of_elements(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;

{*
 * @brief Get the present limit of how many data elements will be retained by the Buffer.
 *        This value can be changed with SB_data_Buffer_set_Buffer_capacity().
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a data Buffer
 *        feature.  Valid IDs can be found with the
 *        SB_get_data_Buffer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 * @return A count of how many items the Buffer will store before data may be lost
 *}
function SB_data_Buffer_get_Buffer_capacity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;

{*
 * @brief Get the maximum possible configurable size for the data Buffer
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a data Buffer
 *        feature.  Valid IDs can be found with the
 *        SB_get_data_Buffer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 * @return The largest value that may be set with SB_data_Buffer_set_Buffer_capacity().
 *}
function SB_data_Buffer_get_Buffer_capacity_maximum(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;

{*
 * @brief Get the minimum possible configurable size for the data Buffer
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a data Buffer
 *        feature.  Valid IDs can be found with the
 *        SB_get_data_Buffer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 * @return The smallest value that may be set with SB_data_Buffer_set_Buffer_capacity().
 *}
function SB_data_Buffer_get_Buffer_capacity_minimum(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;

{*
 * @brief Set the number of data elements that the Buffer should retain
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a data Buffer
 *        feature.  Valid IDs can be found with the
 *        SB_get_data_Buffer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 * @param capacity (Input) Limit on the number of data elements to store.  This is
 *        bounded by what is returned by SB_data_Buffer_get_Buffer_capacity_minimum() and
 *        SB_data_Buffer_get_Buffer_capacity_maximum().
 *}
procedure SB_data_Buffer_set_Buffer_capacity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; capacity: DWord);

{*
 * This function returns the total number of acquisition delay feature
 * instances available in the indicated device.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 *
 * @return the number of features that will be returned by a call to
 *      SB_get_data_Buffer_features().
 *}
function SB_get_number_of_acquisition_delay_features(deviceID: LongInt; errorCode: PLongInt): LongInt;

{*
 * This function returns IDs for accessing each data Buffer
 * feature instance for this device.  The IDs are only valid when used with
 * the deviceID used to obtain them.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *      error codes.
 * @param features (Output) preallocated Buffer to hold returned feature handles
 * @param max_features (Input) size of preallocated Buffer
 *
 * @return the number of data Buffer feature IDs that were copied.
 *}
function SB_get_acquisition_delay_features(deviceID: LongInt; errorCode: PLongInt; Buffer: PLongInt; maxLength: DWord): LongInt;

{*
 * Set the acquisition delay in microseconds.  This may also be referred to as the
 * trigger delay.  In any event, it is the time between some event (such as a request
 * for data, or an external trigger pulse) and when data acquisition begins.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a data Buffer
 *        feature.  Valid IDs can be found with the
 *        SB_get_data_Buffer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 * @param delay_usec (Input) The new delay to use in microseconds
 *}
procedure SB_acquisition_delay_set_delay_microseconds(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; delay_usec: DWord);

{*
 * Get the acquisition delay in microseconds.  This may also be referred to as the
 * trigger delay.  In any event, it is the time between some event (such as a request
 * for data, or an external trigger pulse) and when data acquisition begins.
 *
 * Note that not all devices support reading this value back.  In these cases, the
 * returned value will be the last value sent to SB_acquisition_delay_set_delay_microseconds().
 * If no value has been set and the value cannot be read back, this function will
 * indicate an error.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a data Buffer
 *        feature.  Valid IDs can be found with the
 *        SB_get_data_Buffer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 * @return The acquisition delay in microseconds
 *}
function SB_acquisition_delay_get_delay_microseconds(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;

{*
 * Get the allowed step size for the acquisition delay in microseconds.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a data Buffer
 *        feature.  Valid IDs can be found with the
 *        SB_get_data_Buffer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 * @return The acquisition delay step size in microseconds
 *}
function SB_acquisition_delay_get_delay_increment_microseconds(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;

{*
 * Get the maximum allowed acquisition delay in microseconds.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a data Buffer
 *        feature.  Valid IDs can be found with the
 *        SB_get_data_Buffer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 * @return The maximum acquisition delay in microseconds
 *}
function SB_acquisition_delay_get_delay_maximum_microseconds(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;

{*
 * Get the minimum allowed acquisition delay in microseconds.
 *
 * @param deviceID (Input) The index of a device previously opened with SB_open_device().
 * @param featureID (Input) The ID of a particular instance of a data Buffer
 *        feature.  Valid IDs can be found with the
 *        SB_get_data_Buffer_features() function.
 * @param errorCode (Output) A pointer to an integer that can be used for storing
 *        error codes.
 * @return The minimum acquisition delay in microseconds
 *}
function SB_acquisition_delay_get_delay_minimum_microseconds(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;

var
  SeaBreezeLib: TLibHandle = DynLibs.NilHandle;
  SeaBreezeOk: Boolean = False;

implementation

function MyFunctionAddress(FuncName: String): Pointer;
begin
  if SeaBreezeLib <>  DynLibs.NilHandle then
  begin
    Result := GetProcedureAddress(SeaBreezeLib, 'sbapi_' + FuncName);
    if Result = nil then
    begin
      SeaBreezeOk := False;
      raise Exception.CreateFmt('Function ''%s'' not found.', [FuncName]);
    end;
  end
  else
  begin
    Result := nil;
    SeaBreezeOk := False;
    raise Exception.CreateFmt('Cannot execute function ''%s''. Dynamic library ''%s'' not loaded.', [FuncName, SBLibraryName]);
  end;
end;

function MyProcedureAddress(ProcName: String): Pointer;
begin
  if SeaBreezeLib <>  DynLibs.NilHandle then
  begin
    Result := GetProcedureAddress(SeaBreezeLib, 'sbapi_' + ProcName);
    if Result = nil then
    begin
      SeaBreezeOk := False;
      raise Exception.CreateFmt('Procedure ''%s'' not found.', [ProcName]);
    end;
  end
  else
  begin
    SeaBreezeOk := False;
    raise Exception.CreateFmt('Cannot execute procedure ''%s''. Dynamic library ''%s'' not loaded.', [ProcName, SBLibraryName]);
  end;
end;

procedure SB_initialize;
type
  TLibProcedure = procedure; cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('initialize'));
  // Execute the procedure
  LibProcedure();
end;

procedure SB_shutdown;
type
  TLibProcedure = procedure; cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('shutdown'));
  // Execute the procedure
  LibProcedure();
end;

function SB_add_TCPIPv4_device_location(deviceTypeName: PChar; ipAddress: PChar; port: DWord): LongInt;
type
  TLibFunction = function(deviceTypeName: PChar; ipAddress: PChar; port: DWord): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('add_TCPIPv4_device_location'));
  // Execute the function
  Result := LibFunction(deviceTypeName, ipAddress, port);
end;

function SB_add_RS232_device_location(deviceTypeName: PChar; deviceBusPath: PChar; baud: DWord): LongInt;
type
  TLibFunction = function(deviceTypeName: PChar; deviceBusPath: PChar; baud: DWord): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('add_RS232_device_location'));
  // Execute the function
  Result := LibFunction(deviceTypeName, deviceBusPath, baud);
end;

function SB_probe_devices: LongInt;
type
  TLibFunction = function: LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('probe_devices'));
  // Execute the function
  Result := LibFunction();
end;

function SB_get_number_of_device_ids: LongInt;
type
  TLibFunction = function: LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_device_ids'));
  // Execute the function
  Result := LibFunction();
end;

function SB_get_device_ids(ids: PLongInt; max_ids: DWord): LongInt;
type
  TLibFunction = function(ids: PLongInt; max_ids: DWord): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_device_ids'));
  // Execute the function
  Result := LibFunction(ids, max_ids);
end;

function SB_open_device(id: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(id: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('open_device'));
  // Execute the function
  Result := LibFunction(id, errorCode);
end;

procedure SB_close_device(id: LongInt; errorCode: PLongInt);
type
  TLibProcedure = procedure(id: LongInt; errorCode: PLongInt); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('close_device'));
  // Execute the procedure
  LibProcedure(id, errorCode);
end;

function SB_get_error_string(errorCode: LongInt): PChar;
type
  TLibFunction = function(errorCode: LongInt): PChar; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_error_string'));
  // Execute the function
  Result := LibFunction(errorCode);
end;

function SB_get_device_type(id: LongInt; errorCode: PLongInt; Buffer: PChar; length: DWord): LongInt;
type
  TLibFunction = function(id: LongInt; errorCode: PLongInt; Buffer: PChar; length: DWord): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_device_type'));
  // Execute the function
  Result := LibFunction(id, errorCode, Buffer, length);
end;

function SB_get_device_usb_endpoint_primary_out(id: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(id: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_device_usb_endpoint_primary_out'));
  // Execute the function
  Result := LibFunction(id, errorCode);
end;

function SB_get_device_usb_endpoint_primary_in(id: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(id: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_device_usb_endpoint_primary_in'));
  // Execute the function
  Result := LibFunction(id, errorCode);
end;

function SB_get_device_usb_endpoint_secondary_out(id: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(id: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_device_usb_endpoint_secondary_out'));
  // Execute the function
  Result := LibFunction(id, errorCode);
end;

function SB_get_device_usb_endpoint_secondary_in(id: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(id: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_device_usb_endpoint_secondary_in'));
  // Execute the function
  Result := LibFunction(id, errorCode);
end;

function SB_get_device_usb_endpoint_secondary_in2(id: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(id: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_device_usb_endpoint_secondary_in2'));
  // Execute the function
  Result := LibFunction(id, errorCode);
end;

function SB_get_number_of_raw_usb_bus_access_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_raw_usb_bus_access_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_raw_usb_bus_access_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_raw_usb_bus_access_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

function SB_raw_usb_bus_access_read(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PByte; Buffer_length: LongInt; endpoint: Byte): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PByte; Buffer_length: LongInt; endpoint: Byte): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('raw_usb_bus_access_read'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length, endpoint);
end;

function SB_raw_usb_bus_access_write(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PByte; Buffer_length: LongInt; endpoint: Byte): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PByte; Buffer_length: LongInt; endpoint: Byte): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('raw_usb_bus_access_write'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length, endpoint);
end;

function SB_get_number_of_serial_number_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_serial_number_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_serial_number_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_serial_number_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

function SB_get_serial_number(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_serial_number'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length);
end;

function SB_get_serial_number_maximum_length(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_serial_number_maximum_length'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_get_number_of_spectrometer_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_spectrometer_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_spectrometer_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_spectrometer_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

procedure SB_spectrometer_set_trigger_mode(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; mode: LongInt);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; mode: LongInt); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('spectrometer_set_trigger_mode'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, mode);
end;

procedure SB_spectrometer_set_integration_time_micros(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; integration_time_micros: DWord);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; integration_time_micros: DWord); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('spectrometer_set_integration_time_micros'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, integration_time_micros);
end;

function SB_spectrometer_get_minimum_integration_time_micros(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('spectrometer_get_minimum_integration_time_micros'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_spectrometer_get_maximum_intensity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Double;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Double; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('spectrometer_get_maximum_intensity'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_spectrometer_get_formatted_spectrum_length(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('spectrometer_get_formatted_spectrum_length'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_spectrometer_get_formatted_spectrum(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PDouble; Buffer_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PDouble; Buffer_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('spectrometer_get_formatted_spectrum'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length);
end;

function SB_spectrometer_get_unformatted_spectrum_length(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('spectrometer_get_unformatted_spectrum_length'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_spectrometer_get_unformatted_spectrum(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PByte; Buffer_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PByte; Buffer_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('spectrometer_get_unformatted_spectrum'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length);
end;

function SB_spectrometer_get_wavelengths(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; wavelengths: PDouble; length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; wavelengths: PDouble; length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('spectrometer_get_wavelengths'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, wavelengths, length);
end;

function SB_spectrometer_get_electric_dark_pixel_count(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('spectrometer_get_electric_dark_pixel_count'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_spectrometer_get_electric_dark_pixel_indices(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; indices: PLongInt; length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; indices: PLongInt; length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('spectrometer_get_electric_dark_pixel_indices'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, indices, length);
end;

function SB_get_number_of_pixel_binning_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_pixel_binning_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_pixel_binning_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_pixel_binning_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

procedure SB_binning_set_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; factor: Byte);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; factor: Byte); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('binning_set_pixel_binning_factor'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, factor);
end;

function SB_binning_get_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('binning_get_pixel_binning_factor'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

procedure SB_binning_set_default_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; factor: Byte);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; factor: Byte); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('binning_set_default_pixel_binning_factor'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, factor);
end;

procedure SB_binning_reset_default_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('binning_reset_default_pixel_binning_factor'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode);
end;

function SB_binning_get_default_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('binning_get_default_pixel_binning_factor'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_binning_get_max_pixel_binning_factor(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('binning_get_max_pixel_binning_factor'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_get_number_of_shutter_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_shutter_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_shutter_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_shutter_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

procedure SB_shutter_set_shutter_open(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; opened: Byte);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; opened: Byte); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('shutter_set_shutter_open'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, opened);
end;

function SB_get_number_of_light_source_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_light_source_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_light_source_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_light_source_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

function SB_light_source_get_count(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('light_source_get_count'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_light_source_has_enable(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Byte;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('light_source_has_enable'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, light_source_index);
end;

function SB_light_source_is_enabled(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Byte;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('light_source_is_enabled'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, light_source_index);
end;

procedure SB_light_source_set_enable(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt; enable: Byte);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt; enable: Byte); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('light_source_set_enable'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, light_source_index, enable);
end;

function SB_light_source_has_variable_intensity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Byte;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('light_source_has_variable_intensity'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, light_source_index);
end;

function SB_light_source_get_intensity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Double;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt): Double; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('light_source_get_intensity'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, light_source_index);
end;

procedure SB_light_source_set_intensity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt; intensity: Double);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; light_source_index: LongInt; intensity: Double); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('light_source_set_intensity'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, light_source_index, intensity);
end;

function SB_get_number_of_lamp_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_lamp_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_lamp_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_lamp_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

procedure SB_lamp_set_lamp_enable(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; lamp_enable: Byte);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; lamp_enable: Byte); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('lamp_set_lamp_enable'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, lamp_enable);
end;

function SB_get_number_of_continuous_strobe_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_continuous_strobe_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_continuous_strobe_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_continuous_strobe_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

procedure SB_continuous_strobe_set_continuous_strobe_enable(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; enable: Byte);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; enable: Byte); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('continuous_strobe_set_continuous_strobe_enable'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, enable);
end;

procedure SB_continuous_strobe_set_continuous_strobe_period_micros(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; period_micros: DWord);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; period_micros: DWord); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('continuous_strobe_set_continuous_strobe_period_micros'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, period_micros);
end;

function SB_get_number_of_eeprom_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_eeprom_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_eeprom_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_eeprom_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

function SB_eeprom_read_slot(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; slot_number: LongInt; Buffer:PByte; Buffer_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; slot_number: LongInt; Buffer:PByte; Buffer_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('eeprom_read_slot'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, slot_number, Buffer, Buffer_length);
end;

function SB_get_number_of_irrad_cal_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_irrad_cal_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_irrad_cal_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_irrad_cal_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

function SB_irrad_calibration_read(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PSingle; Buffer_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PSingle; Buffer_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('irrad_calibration_read'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length);
end;

function SB_irrad_calibration_write(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PSingle; Buffer_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer:PSingle; Buffer_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('irrad_calibration_write'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length);
end;

function SB_irrad_calibration_has_collection_area(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('irrad_calibration_has_collection_area'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_irrad_calibration_read_collection_area(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Single;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Single; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('irrad_calibration_read_collection_area'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

procedure SB_irrad_calibration_write_collection_area(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; area: Single);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; area: Single); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('irrad_calibration_write_collection_area'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, area);
end;

function SB_get_number_of_thermo_electric_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_thermo_electric_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_thermo_electric_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_thermo_electric_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

function SB_tec_read_temperature_degrees_C(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Double;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): Double; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('tec_read_temperature_degrees_C'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

procedure SB_tec_set_temperature_setpoint_degrees_C(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; temperature_degrees_celsius: Double);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; temperature_degrees_celsius: Double); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('tec_set_temperature_setpoint_degrees_C'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, temperature_degrees_celsius);
end;

procedure SB_tec_set_enable(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; tec_enable: Byte);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; tec_enable: Byte); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('tec_set_enable'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, tec_enable);
end;

function SB_get_number_of_nonlinearity_coeffs_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_nonlinearity_coeffs_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_nonlinearity_coeffs_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_nonlinearity_coeffs_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

function SB_nonlinearity_coeffs_get(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PDouble; max_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PDouble; max_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('nonlinearity_coeffs_get'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, max_length);
end;

function SB_get_number_of_temperature_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_temperature_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_temperature_features(deviceID: LongInt; errorCode: PLongInt; temperatureFeatures: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; temperatureFeatures: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_temperature_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, temperatureFeatures, max_features);
end;

function SB_temperature_count_get(deviceID: LongInt; temperatureFeatureID: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(deviceID: LongInt; temperatureFeatureID: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('temperature_count_get'));
  // Execute the function
  Result := LibFunction(deviceID, temperatureFeatureID, errorCode);
end;

function SB_temperature_get(deviceID: LongInt; temperatureFeatureID: LongInt; errorCode: PLongInt; index: LongInt): Double;
type
  TLibFunction = function(deviceID: LongInt; temperatureFeatureID: LongInt; errorCode: PLongInt; index: LongInt): Double; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('temperature_get'));
  // Execute the function
  Result := LibFunction(deviceID, temperatureFeatureID, errorCode, index);
end;

function SB_temperature_get_all(deviceID: LongInt; temperatureFeatureID: LongInt; errorCode: PLongInt; Buffer: PDouble; max_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; temperatureFeatureID: LongInt; errorCode: PLongInt; Buffer: PDouble; max_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('temperature_get_all'));
  // Execute the function
  Result := LibFunction(deviceID, temperatureFeatureID, errorCode, Buffer, max_length);
end;

function SB_get_number_of_spectrum_processing_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_spectrum_processing_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_spectrum_processing_features(deviceID: LongInt; errorCode: PLongInt; spectrumProcessingFeatures: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; spectrumProcessingFeatures: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_spectrum_processing_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, spectrumProcessingFeatures, max_features);
end;

function SB_spectrum_processing_scans_to_average_get(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt): Word;
type
  TLibFunction = function(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt): Word; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('spectrum_processing_scans_to_average_get'));
  // Execute the function
  Result := LibFunction(deviceID, spectrumProcessingFeatureID, errorCode);
end;

procedure SB_spectrum_processing_scans_to_average_set(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt; scansToAverage: Word);
type
  TLibProcedure = procedure(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt; scansToAverage: Word); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('spectrum_processing_scans_to_average_set'));
  // Execute the procedure
  LibProcedure(deviceID, spectrumProcessingFeatureID, errorCode, scansToAverage);
end;

function SB_spectrum_processing_boxcar_width_get(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('spectrum_processing_boxcar_width_get'));
  // Execute the function
  Result := LibFunction(deviceID, spectrumProcessingFeatureID, errorCode);
end;

procedure SB_spectrum_processing_boxcar_width_set(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt; boxcarWidth: Byte);
type
  TLibProcedure = procedure(deviceID: LongInt; spectrumProcessingFeatureID: LongInt; errorCode: PLongInt; boxcarWidth: Byte); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('spectrum_processing_boxcar_width_set'));
  // Execute the procedure
  LibProcedure(deviceID, spectrumProcessingFeatureID, errorCode, boxcarWidth);
end;

function SB_get_number_of_revision_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_revision_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_revision_features(deviceID: LongInt; errorCode: PLongInt; revisionFeatures: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; revisionFeatures: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_revision_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, revisionFeatures, max_features);
end;

function SB_revision_hardware_get(deviceID: LongInt; revisionFeatureID: LongInt; errorCode: PLongInt): Byte;
type
  TLibFunction = function(deviceID: LongInt; revisionFeatureID: LongInt; errorCode: PLongInt): Byte; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('revision_hardware_get'));
  // Execute the function
  Result := LibFunction(deviceID, revisionFeatureID, errorCode);
end;

function SB_revision_firmware_get(deviceID: LongInt; revisionFeatureID: LongInt; errorCode: PLongInt): Word;
type
  TLibFunction = function(deviceID: LongInt; revisionFeatureID: LongInt; errorCode: PLongInt): Word; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('revision_firmware_get'));
  // Execute the function
  Result := LibFunction(deviceID, revisionFeatureID, errorCode);
end;

function SB_get_number_of_optical_bench_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_optical_bench_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_optical_bench_features(deviceID: LongInt; errorCode: PLongInt; opticalBenchFeatures: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; opticalBenchFeatures: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_optical_bench_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, opticalBenchFeatures, max_features);
end;

function SB_optical_bench_get_fiber_diameter_microns(deviceID: LongInt; opticalBenchFeatureID: LongInt; errorCode: PLongInt): Word;
type
  TLibFunction = function(deviceID: LongInt; opticalBenchFeatureID: LongInt; errorCode: PLongInt): Word; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('optical_bench_get_fiber_diameter_microns'));
  // Execute the function
  Result := LibFunction(deviceID, opticalBenchFeatureID, errorCode);
end;

function SB_optical_bench_get_slit_width_microns(deviceID: LongInt; opticalBenchFeatureID: LongInt; errorCode: PLongInt): Word;
type
  TLibFunction = function(deviceID: LongInt; opticalBenchFeatureID: LongInt; errorCode: PLongInt): Word; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('optical_bench_get_slit_width_microns'));
  // Execute the function
  Result := LibFunction(deviceID, opticalBenchFeatureID, errorCode);
end;

function SB_optical_bench_get_id(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('optical_bench_get_id'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length);
end;

function SB_optical_bench_get_serial_number(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('optical_bench_get_serial_number'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length);
end;

function SB_optical_bench_get_coating(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('optical_bench_get_coating'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length);
end;

function SB_optical_bench_get_filter(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('optical_bench_get_filter'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length);
end;

function SB_optical_bench_get_grating(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PChar; Buffer_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('optical_bench_get_grating'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, Buffer_length);
end;

function SB_get_number_of_stray_light_coeffs_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_stray_light_coeffs_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_stray_light_coeffs_features(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; features: PLongInt; max_features: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_stray_light_coeffs_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, features, max_features);
end;

function SB_stray_light_coeffs_get(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PDouble; max_length: LongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; Buffer: PDouble; max_length: LongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('stray_light_coeffs_get'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode, Buffer, max_length);
end;

function SB_get_number_of_data_Buffer_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_data_Buffer_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_data_Buffer_features(deviceID: LongInt; errorCode: PLongInt; Buffer: PLongInt; maxLength: DWord): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; Buffer: PLongInt; maxLength: DWord): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_data_Buffer_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, Buffer, maxLength);
end;

procedure SB_data_Buffer_clear(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('data_Buffer_clear'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode);
end;

function SB_data_Buffer_get_number_of_elements(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('data_Buffer_get_number_of_elements'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_data_Buffer_get_Buffer_capacity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('data_Buffer_get_Buffer_capacity'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_data_Buffer_get_Buffer_capacity_maximum(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('data_Buffer_get_Buffer_capacity_maximum'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_data_Buffer_get_Buffer_capacity_minimum(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('data_Buffer_get_Buffer_capacity_minimum'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

procedure SB_data_Buffer_set_Buffer_capacity(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; capacity: DWord);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; capacity: DWord); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('data_Buffer_set_Buffer_capacity'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, capacity);
end;

function SB_get_number_of_acquisition_delay_features(deviceID: LongInt; errorCode: PLongInt): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_number_of_acquisition_delay_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode);
end;

function SB_get_acquisition_delay_features(deviceID: LongInt; errorCode: PLongInt; Buffer: PLongInt; maxLength: DWord): LongInt;
type
  TLibFunction = function(deviceID: LongInt; errorCode: PLongInt; Buffer: PLongInt; maxLength: DWord): LongInt; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('get_acquisition_delay_features'));
  // Execute the function
  Result := LibFunction(deviceID, errorCode, Buffer, maxLength);
end;

procedure SB_acquisition_delay_set_delay_microseconds(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; delay_usec: DWord);
type
  TLibProcedure = procedure(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt; delay_usec: DWord); cdecl;
var
  LibProcedure: TLibProcedure;
begin
  // Read procedure address
  LibProcedure := TLibProcedure(MyProcedureAddress('acquisition_delay_set_delay_microseconds'));
  // Execute the procedure
  LibProcedure(deviceID, featureID, errorCode, delay_usec);
end;

function SB_acquisition_delay_get_delay_microseconds(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('acquisition_delay_get_delay_microseconds'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_acquisition_delay_get_delay_increment_microseconds(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('acquisition_delay_get_delay_increment_microseconds'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_acquisition_delay_get_delay_maximum_microseconds(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('acquisition_delay_get_delay_maximum_microseconds'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

function SB_acquisition_delay_get_delay_minimum_microseconds(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord;
type
  TLibFunction = function(deviceID: LongInt; featureID: LongInt; errorCode: PLongInt): DWord; cdecl;
var
  LibFunction: TLibFunction;
begin
  // Read function address
  LibFunction := TLibFunction(MyFunctionAddress('acquisition_delay_get_delay_minimum_microseconds'));
  // Execute the function
  Result := LibFunction(deviceID, featureID, errorCode);
end;

initialization

{$ifdef darwin}
SeaBreezeLib := LoadLibrary(Application.Location + SBLibraryName);
{$else}
SeaBreezeLib := LoadLibrary(SBLibraryName);
{$endif}
SeaBreezeOk := SeaBreezeLib <> DynLibs.NilHandle;
if not SeaBreezeOk then  //DLL was not loaded successfully
  raise Exception.CreateFmt('Error loading dynamic library ''%s''.', [SBLibraryName]);


finalization

if SeaBreezeLib <>  DynLibs.NilHandle then
  if FreeLibrary(SeaBreezeLib) then
    SeaBreezeLib := DynLibs.NilHandle;  // Unload the lib, if already loaded

end.
