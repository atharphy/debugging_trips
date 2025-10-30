# Pixel DCS Trip Log Analyzer

This script extracts and summarizes **trip (error) events** from CMS Pixel DCS log files.  
It parses XML-style `ERROR</smi:notify>` blocks and the corresponding FSM state summaries to show which modules tripped, when, and their HV/LV status.

---

## Features
- Supports logs from both `log0` and `log1` directories.
- Handles **BPix** and **FPix** partitions separately.
- Can process a **single run**, the **latest run**, or the **last N runs**.
- Displays for each trip:
  - Module name  
  - Date and time of trip  
  - FSM node type (e.g. `A4603 (BPix_BpO_UP)`)  
  - FSM node counts (`HV_ON`, `LV_ON`, `LV_ON_REDUCED`, `LV_OFF`, `UNDEFINED`)

---

## Directory Structure Expected
```
/nfspixelraid/nfspixelraid/
├── log0/
│   ├── Log_30Oct2025_09-07-44_GMT/
│   │   └── PixelDCS-2025-10-30T09:05:37.225582Z-24680.log
├── log1/
│   ├── BPix/
│   │   └── Log_30Oct2025_10-51-40_GMT/
│   │       └── PixelDCS-2025-10-30T10:51:24.360571Z-144573.log
│   └── FPix/
│       └── ...
```

---

## Usage

```bash
# Check the latest log from log0
./trips.sh -log0 -last

# Check a specific log folder in log0
./trips.sh -log0 Log_30Oct2025_09-07-44_GMT

# Check the latest log from BPix under log1
./trips.sh -log1 -bpix -last

# Check the latest log from FPix under log1
./trips.sh -log1 -fpix -last

# Check the last 10 logs in BPix
./trips.sh -log1 -bpix -last 10

# Check a specific BPix folder
./trips.sh -log1 -bpix Log_30Oct2025_10-51-40_GMT
```

---

## Example Output

```
=== Folder: log1/BPix/Log_30Oct2025_10-51-40_GMT ===
Using log file: /nfspixelraid/nfspixelraid/log1/BPix/Log_30Oct2025_10-51-40_GMT/PixelDCS-2025-10-30T10:51:24.360571Z-144573.log

Module                         Date         Time       Number of FSM nodes of type              HV_ON   LV_ON   LV_ON_REDUCED  LV_OFF   UNDEFINED
-----------------------------------------------------------------------------------------------------------------------------------------------------------
PixelBarrel_BpO_S1_LAY23       30Oct2025    10:51:34   A4603 (BPix_BpO_UP)                     1       0       0              1        6
PixelBarrel_BpO_S2_LAY23       30Oct2025    10:51:35   A4603 (BPix_BpO_UP)                     2       0       0              2        4
PixelBarrel_BpO_S5_LAY23       30Oct2025    10:51:35   A4603 (BPix_BpO_DOWN)                   1       0       0              1        6
```

---
