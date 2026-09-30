# 01_raw: Raw Data / 原始数据

This directory contains data exported from the experimental platform before trial-level cleaning. It includes three behavioral tasks and questionnaire exports from four collection days.

本目录包含实验平台导出的、尚未进行试次级清洗的数据，包括三个行为任务和四个测试日（Day 1、Day 2、Day 3、Day 10）的问卷数据。

## Files / 文件

| File / 文件 | Description / 说明 |
|---|---|
| `IAT_raw.csv` | Trial-level data for the Implicit Association Test (IAT), merged across all collection waves (n = 681 participants) / IAT 试次级数据，全部批次合并（681 名被试） |
| `SMT_1_raw.csv` | Trial-level data for the geometric-shape version of the SMT (Day 2 session; historical label ALT1), all waves (n = 681) / SMT 几何图形版（Day 2；历史标签 ALT1）试次级数据，全部批次（681 人） |
| `SMT_2_raw.csv` | Trial-level data for the self-referential version of the SMT (Day 3 session; historical label ALT2), all waves (n = 603) / SMT 自我参照版（Day 3；历史标签 ALT2）试次级数据，全部批次（603 人） |
| `SRET_raw.csv` | Trial-level data for the Self-Referent Encoding Task (SRET), all waves (n = 603) / SRET 试次级数据，全部批次（603 人） |
| `questionnaires_day1_raw.csv` | Day 1 questionnaire export (platform label `day0`): consent, demographics, SCC, PHQ-9, GAD-7 / Day 1（平台标签 `day0`）：知情同意、人口学、SCC、PHQ-9、GAD-7 |
| `questionnaires_day2_raw.zip` | Compressed Day 2 export (platform label `day1`): questionnaires (RSES, CSES, NPI-16, HNS, SGPS) + IAT + SMT geometric version (ALT1) / Day 2（平台标签 `day1`）：问卷 + IAT + SMT 几何版（ALT1） |
| `questionnaires_day3_raw.zip` | Compressed Day 3 export (platform label `day2`): questionnaires (SWLS, IPC-I, LOT-R, MIS, MSIS, SDE, IM) + SRET + SMT self-referential version (ALT2) / Day 3（平台标签 `day2`）：问卷 + SRET + SMT 自我参照版（ALT2） |
| `questionnaires_day10_raw.csv` | Day 10 retest export (platform label `day3`): full questionnaire set, no behavioral tasks / Day 10 重测（平台标签 `day3`）：问卷全量重测，无行为任务 |


## Task terminology / 任务术语

The manuscript uses **SMT** (Self-Matching Task). The raw SMT files are named `SMT_1_raw.csv` and `SMT_2_raw.csv` for the geometric-shape (historical label ALT1) and self-referential (historical label ALT2) versions, because the archived analysis code calls this task ALT. They should therefore be interpreted as the raw SMT files.

论文使用 **SMT**（Self-Matching Task，自我匹配任务）。由于历史分析代码将该任务称为 ALT，原始 SMT 文件按版本命名为 `SMT_1_raw.csv`（几何图形版，历史标签 ALT1）与 `SMT_2_raw.csv`（自我参照版，历史标签 ALT2），它们应理解为 SMT 原始数据文件。

Raw files may contain practice trials, instruction records, timeout records, and other platform-generated fields. Trial-level preprocessing is described in the analysis code and the manuscript.

原始文件可能包含练习试次、指导语记录、超时记录及平台自动生成的其他字段。试次级预处理过程见分析代码和论文。