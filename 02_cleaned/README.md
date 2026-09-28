# 02_cleaned: Cleaned Data / 清洗后数据

This directory contains cleaned task data and cleaned questionnaire tables used to construct the participant-level indices. Practice trials and invalid trials were removed according to the task-specific preprocessing procedures.

本目录包含用于构建参与者层面指标的清洗任务数据和清洗后问卷表。按照各任务的预处理程序删除了练习试次和无效试次。

## Files / 文件

| File / 文件 | Description / 说明 |
|---|---|
| `IAT_cleaned.csv` | Cleaned trial-level IAT data / 清洗后的 IAT 试次级数据 |
| `SMT_1_cleaned.zip` | Cleaned SMT Version 1 data; geometric-shape SMT (historical label ALT1) / 清洗后的 SMT 版本 1 数据；几何图形 SMT（历史标签 ALT1） |
| `SMT_2_cleaned.zip` | Cleaned SMT Version 2 data; self-reference SMT (historical label ALT2) / 清洗后的 SMT 版本 2 数据；自我参照 SMT（历史标签 ALT2） |
| `SRET_cleaned.csv` | Cleaned trial-level SRET data / 清洗后的 SRET 试次级数据 |
| `questionnaires_day1_cleaned.csv` | Cleaned and merged all questionnaire data collected on Day 1 / 清洗并合并了 Day 1测量的所有问卷数据 |
| `questionnaires_day2_cleaned.csv` | Cleaned and merged all questionnaire data collected on Day 2 / 清洗并合并了 Day 2测量的所有问卷数据 |
| `questionnaires_day3_cleaned.csv` | Cleaned and merged all questionnaire data collected on Day 3 / 清洗并合并了 Day 3测量的所有问卷数据 |
| `questionnaires_day10_cleaned.csv` | Cleaned and merged all questionnaire data collected on Day 10 / 清洗并合并了 Day 10测量的所有问卷数据 |

## SMT naming note / SMT 命名说明

The directory follows the manuscript naming, which uses **SMT**. The files are named `SMT_1_cleaned.zip` (geometric-shape version) and `SMT_2_clean.zip` (self-referential version) to match the file tree; the corresponding historical labels ALT1 and ALT2 are retained only in the raw files and analysis code.

目录命名与论文一致，采用 **SMT**。文件 `SMT_1_clean.zip`（几何图形版）与 `SMT_2_cleaned.zip`（自我参照版）与文件树保持一致；历史标签 ALT1/ALT2 仅保留在原始文件与分析代码中。

The cleaned files are not a substitute for the raw files when users need to implement a new trial-exclusion rule. Use the raw files together with the preprocessing code for such analyses.

如果需要实施新的试次排除规则，清洗后文件不能替代原始文件；此类分析应结合原始文件和预处理代码进行。