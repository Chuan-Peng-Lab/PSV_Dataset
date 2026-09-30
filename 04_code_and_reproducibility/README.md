# 04_code_and_reproducibility: Code and Reproducibility / 代码与可复现性

This directory contains the experimental programs and the analysis code that support the dataset and the manuscript results; only materials directly related to this dataset are retained.

本目录包含本数据库及论文结果所对应的实验程序与分析代码，仅保留与本数据库直接相关的内容。

## Structure / 目录结构

```
04_code_and_reproducibility/
├── README.md                                          # 文件说明
├── procedure/                                         # 实验程序
└── analysis/                                          # 整合文章内全部分析流程的代码
```

## procedure/ — Experimental Programs / 实验程序

Contains the jsPsych experimental programs for the four data-collection sessions (Day 1, Day 2, Day 3, Day 10).

包含四个测试日（Day 1、Day 2、Day 3、Day 10）施测所用的 jsPsych 实验程序。

| Subfolder / 子目录 | Content / 内容 |
|---|---|
| `day1/` | Day 1 screening session: consent, demographics, SCC, PHQ-9, GAD-7 / Day 1 筛查日：知情同意、人口学、SCC、PHQ-9、GAD-7 |
| `day2/` | Day 2: questionnaires (RSES, CSES, NPI-16, HNS, SGPS) + IAT + geometric-shape SMT / Day 2：问卷 + IAT + SMT 几何图形版 |
| `day3/` | Day 3: questionnaires (SWLS, IPC-I, LOT-R, MIS, MSIS, SDE, IM) + SRET + self-referential SMT / Day 3：问卷 + SRET + SMT 自我参照版 |
| `day10/` | Day 10 retest: full questionnaire set, no behavioral tasks / Day 10 重测：问卷全量重测，无行为任务 |

Steps for running the programs locally are described in the README of this subdirectory.

本地运行各程序需注意的事项见该子目录下的说明文件。

## analysis/ — Analysis Code / 分析代码

Contains the integrated analysis pipeline in manuscript order, together with the HTML report generated from it.

包含按论文顺序整合的全部分析流程代码，以及由其生成的 HTML 结果。

| File / 文件 | Content / 内容 |
|---|---|
| `analysis.Rmd` | Main analysis file integrating all analysis code for the manuscript / 主分析文件，整合文章内全部分析流程的代码 |
| `analysis.html` | HTML report generated from `analysis.Rmd` / 由该 Rmd 生成的 HTML |

## Notes / 说明

- Data files (raw, cleaned, and derived indices) are stored separately under `01_raw/`, `02_cleaned/`, and `03_derived/`; this folder contains only code.
  数据文件（原始、清洗后与派生指标）分别存放于 `01_raw/`、`02_cleaned/`、`03_derived/`；本目录仅包含代码。
- The full variable-name mapping is provided in `codebook_variable_mapping.csv` at the dataset root.
  完整变量名对齐清单见数据集根目录 `codebook_variable_mapping.csv`。