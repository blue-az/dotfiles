# Gemini Project Instructions

This file contains workflows and instructions for the Gemini CLI agent.

## Agent Terminology & Definitions
- **BN = Bottlenecks**: In user prompts and documentation, **BN** stands for **Bottlenecks** (tracking system/workflow friction points, issue tracking, and bottleneck resolution). Always interpret "BN" as Bottlenecks.


## Device Workflows

### iPhone Photo Extraction
Detailed procedure for downloading photos from an iPhone on Linux (Fedora) can be found in [devices/iphone/README.md](devices/iphone/README.md).

Quick Summary:
1. Unlock and Trust the iPhone.
2. Run `idevicepair validate`.
3. Detect port with `gphoto2 --auto-detect`.
4. List files with `gphoto2 --port <port> --folder /store_00010001 --list-files --recurse`.
5. Download with `gphoto2 --get-file <index>`.

## Repository Standards
- Dotfiles are managed via GNU Stow.
- Machine-specific notes are in `machines/<hostname>/`.
- Device-specific notes are in `devices/<devicename>/`.
