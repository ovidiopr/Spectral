# Spectral

**Spectral** is a **Lazarus** application designed for real-time optical spectroscopy. This software interfaces with **Ocean Optics** spectrometers using the **SeaBreeze API**, providing a robust framework for spectral data acquisition, processing, and visualization.

## Key Features

* **Multi-Device Support:** Manage multiple spectrometers simultaneously via a streamlined tabbed interface.
* **Data Archiving:** Save any active measurement to disk in standard formats (XML/TXT) for easy integration with LabVIEW, MATLAB, or Python.
* **Hardware Synchronization:** Automatically resets spectrometers to a known state (**Normal Trigger Mode**) upon connection to ensure software/hardware alignment.
* **Advanced Real-time Processing:**
    * **Spectra Averaging:** Perform high-speed scan averaging to maximize Signal-to-Noise Ratio (SNR).
    * **Boxcar Smoothing:** Integrated spatial smoothing for effective noise reduction.
    * **Electric Dark Correction:** Real-time dark current subtraction utilizing hardware-specific dark pixels.
* **Threaded Acquisition:** Dedicated background threads handle USB communication, ensuring the UI remains responsive even during high-frequency data fetching.

---

## Installation

### Windows
* **Installer (.exe):** Download and run the [`Install-Spectral-v1.1.0-win64-x86_64.exe`](https://github.com/ovidiopr/Spectral/releases/download/v1.1.0/Install-Spectral-v1.1.0-win64-x86_64.exe).
* **Drivers:** Ensure you have the SeaBreeze USB drivers (WinUSB or Ocean Optics vendor drivers) installed. The installer provides an option to bundle these.

### Linux (Debian / Ubuntu / Linux Mint)
* **Standard Desktop:** Download the [`spectral_1.1.0_amd64.deb`](https://github.com/ovidiopr/Spectral/releases/download/v1.1.0/spectral_1.1.0_amd64.deb) package and install via:
    ```bash
    sudo dpkg -i spectral_1.1.0_amd64.deb
    ```
* **Raspberry Pi:** Download the dedicated ARM-based [`spectral_1.1.0_arm64.deb`](https://github.com/ovidiopr/Spectral/releases/download/v1.1.0/spectral_1.1.0_arm64.deb) package for Raspberry Pi OS (formerly Raspbian) and install via:
    ```bash
    sudo dpkg -i spectral_1.1.0_arm64.deb
    ```
* **USB Permissions:** To access spectrometers without root, install the included `udev` rules or add your user to the `plugdev` group.

### macOS
* **Disk Image (.dmg):** Open the [`spectral_1.1.0_aarch64.dmg`](https://github.com/ovidiopr/Spectral/releases/download/v1.1.0/spectral_1.1.0_aarch64.dmg) and drag the application to your **Applications** folder.
* **Architecture:** Fully compatible with both Intel and Apple Silicon (M1/M2/M3) systems.

---

## Usage

1.  **Device Discovery:** On startup, the application automatically probes the USB bus for SeaBreeze-compatible devices.
2.  **Configure Measurements:** Navigate to the Configuration panel to define:
    * **Integration Time:** Exposure duration in microseconds.
    * **Processing:** Toggle between hardware and software-level averaging and smoothing.
    * **Electric Dark:** Enable real-time baseline correction.
3.  **Acquisition:** Click **Start** to begin the live feed.
4.  **Save Data:** Use the "Configure Save..." button to configure the batch saving of the processed spectra (you can save several acquisitions simultaneously).

---

## Technical Architecture

The core logic is contained within the `SBDevices.pas` unit, which provides a high-level Object Pascal wrapper for the **SeaBreeze C API**.

* **Language:** Object Pascal (Lazarus/Free Pascal)
* **Backend:** SeaBreeze (v3.0+)
* **Threading Model:** `TSBAcquireThread` manages a non-blocking internal loop for `SB_spectrometer_get_formatted_spectrum`.



---

### Implementation Note: Trigger States

The SeaBreeze API utilizes **write-only trigger registers**. Because the hardware cannot be queried for its current trigger state, the application defaults to **Normal Mode (0)** on startup. This ensures that the software-side state and the hardware-side state are perfectly synchronized from the first scan.

---

### License

This program is free software: you can redistribute it and/or modify it under the terms of the **GNU General Public License** as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

For the full text of the license, see the [LICENSE](LICENSE) file included in this repository or visit <https://www.gnu.org/licenses/gpl-3.0.html>.

## Credits and Licensing
* **Spectral:** Licensed under GPLv3.
* **SeaBreeze Library:** Copyright (c) Ocean Insight. Distributed under the MIT License.