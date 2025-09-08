# qam-psk-ber-awgn-matlab

![License](https://img.shields.io/badge/license-MIT-green.svg)
![MATLAB](https://img.shields.io/badge/MATLAB-R2023b-orange.svg)
![Build](https://img.shields.io/badge/build-passing-brightgreen.svg)
![Platform](https://img.shields.io/badge/platform-Windows--PowerShell-blue.svg)
![Release](https://img.shields.io/github/v/release/AlbertoMarquillas/qam-psk-ber-awgn-matlab)

MATLAB toolkit to simulate **BER vs. Eb/N0** for **QPSK (4-QAM)**, **8-PSK (rectangular)**, and **16-QAM** over **AWGN**. Includes a CLI-style demo and exportable plots.

---

## 📌 Overview

This repository provides Monte-Carlo simulations of digital modulation schemes under AWGN. Each constellation is **power-normalized** so that BER curves are comparable across modulations. A lightweight entrypoint (`run_demo.m`) sweeps Eb/N0 values and exports figures to `build/plots/`.

**Key Features:**

* BER simulation for QPSK, 8-PSK (rectangular), and 16-QAM.
* Power normalization of constellations.
* CLI-style demo script with customizable parameters.
* Plot export to PNG for reports and reproducibility.
* Self-contained: ships with a local stub for `isBERToolSimulationStopped` (no BERTool dependency).

---

## 📂 Repository Structure

```
src/               % MATLAB sources (qam4, psk8, qam16 simulators)
src/utils/         % helpers (demodulator, BERTool stop stub)
test/              % smoke tests (planned)
docs/              % docs & images
build/plots/       % exported figures
```

---

## ⚡ Getting Started (Windows PowerShell)

Run simulations from the repo root using MATLAB batch mode:

```powershell
matlab -batch "run_demo('qam4',  [0:2:12], 100, 1e6, true)"
matlab -batch "run_demo('psk8',  [0:2:12], 100, 1e6, true)"
matlab -batch "run_demo('qam16', [0:2:12], 100, 1e6, true)"
```

**Arguments:**

* `modulation`: `'qam4' | 'psk8' | 'qam16'`
* `ebn0_dB_vector`: vector of Eb/N0 values in dB, e.g. `[0:2:12]`
* `maxNumErrs`: stop criterion by accumulated bit errors (e.g., 100)
* `maxNumBits`: safety cap on simulated bits (e.g., 1e6)
* `doPlot`: `true/false` to plot and export figures

---

## 📊 Example Output

Console output:

```
Running QAM4, Eb/N0(dB) sweep: [0 2 4 6 8 10 12], maxErrs=100, maxBits=1e6
  Eb/N0=0.0 dB -> BER=0.078  (bits=20000)
  Eb/N0=2.0 dB -> BER=0.041  (bits=40000)
  ...
```

Plot saved to:

```
build/plots/ber_qam4.png
```

---

## 🛠️ Usage Notes

* Outputs: BER table in console + plot under `build/plots/`.
* Constellations:

  * QPSK: scaled by `1/sqrt(2)`
  * 16-QAM: scaled by `1/sqrt(10)`
  * 8-PSK: rectangular mapping per assignment spec
* No datasets/models required.

---

## 🚀 Roadmap

* [ ] Smoke tests to ensure BER decreases with Eb/N0.
* [ ] Theoretical BER overlays for comparison.
* [ ] CI pipeline (MATLAB-free lint + optional MATLAB job).
* [ ] Demo plots for report-ready figures.

---

## 💡 What I Learned

Through this project I gained experience in:

* Implementing Monte Carlo simulations for communication systems.
* Designing and normalizing digital modulation constellations (QPSK, 8-PSK, 16-QAM).
* Understanding the impact of **Eb/N0** on BER performance across modulation schemes.
* Structuring MATLAB code into modular functions and reusable utilities.
* Building a CLI-style entrypoint for reproducible experiments.
* Preparing research-grade plots for reports and presentations.
* Applying software engineering best practices: `.gitignore`, licensing, documentation, and version control.

---

## 📜 License

MIT — see `LICENSE`.
