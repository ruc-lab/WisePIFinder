# WisePIFinder+

This repository contains multiple implementations and experiments for flow measurement and detection, including software sketches and a Tofino P4 pipeline.

## Repository Layout

- `Persistent/`
  - WisePIFinder implementation (C++) for persistent flow detection.
  - Typical usage: run `make` and then `./WisePIFinder`

- `Persistent-Frequent/`
  - WisePIFinder implementation (C++) for persistent and frequent flow detection.
  - Typical usage: run `make` and then `./WisePIFinder` in this directory.

- `Persistent-Infrequent/`
  - WisePIFinder implementation (C++) for persistent and infrequent flow detection.
  - Typical usage: run `make` and then `./WisePIFinder` in this directory.

- `tofino/`
  - Tofino switch implementation.
  - `data_plane/`: P4 data plane programs and configuration.
  - `control_plane/`: control plane scripts and runtime tools.

## Notes

- Build and runtime parameters are defined in each subproject's source and Makefile.
- Add datasets or experiment scripts under the relevant subdirectory as needed.
