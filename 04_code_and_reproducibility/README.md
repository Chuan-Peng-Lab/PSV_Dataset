# 04_code_and_reproducibility: Code and Reproducibility / 代码与可复现性

This directory contains the experimental programs and the analysis code that support the dataset and the manuscript results; only materials directly related to this dataset are retained.

本目录包含本数据库及论文结果所对应的实验程序与分析代码，仅保留与本数据库直接相关的内容。

## Structure / 目录结构

```
04_code_and_reproducibility/
├── README.md                                          # 文件说明
├── procedure/                                         # 实验程序
├── analysis/                                          # 整合文章内全部分析流程的代码
├── excluded_record_paper/                             # 按论文思路的被试排除记录（777 → 503）
└── subject _screening/                                # 标准清洗记录（777 → 606 ，777 → 466）
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

## excluded_record_paper/ — Exclusion per the Paper / 按论文思路的被试排除

Contains the participant-exclusion records reconstructed by following the manuscript's own analysis logic (`analysis/analysis.Rmd`), from the 777 Day-1 records to the **503**-participant final sample. The single reproduction entry point is `exclusion_pipeline.qmd` (R + Quarto), which also renders `exclusion_pipeline.html`; it writes the per-subject detail `excluded_subjects_record.csv`, the stage-flow `exclusion_flow_reconciliation.csv`, and `flagged_but_retained.csv`. See the folder's `README.md` for details.

包含按照论文自身分析逻辑（`analysis/analysis.Rmd`）重建的被试排除记录，即从 Day 1 的 777 条记录到 **503** 名最终样本。唯一复现入口为 `exclusion_pipeline.qmd`（R + Quarto），同时渲染出 `exclusion_pipeline.html`；并生成逐人明细 `excluded_subjects_record.csv`、流程核对 `exclusion_flow_reconciliation.csv` 及 `flagged_but_retained.csv`。详见该文件夹的 `README.md`。

## subject _screening/ — Standard Cleaning / 标准清洗

Contains the standard participant- and task-level cleaning records, reducing the 777 Day-1 records to **606** retained participants and then to the **466** complete-and-valid set. It holds the hard-criterion exclusions `excluded_subjects_171.csv`, the task-level `invalidated_task_data_140.csv`, the three-layer ledger `exclusion_ledger_three_layer.csv`, the full removal ledger `removal_ledger_777_to_466.csv`, and the timeline log `timeline_quality_screen.csv`, together with the R scripts that rebuild them. See the folder's `README.md` for details.

包含被试层面与任务层面的标准清洗记录，将 Day 1 的 777 条记录缩减为 **606** 名保留参与者，再得到 **466** 名完整且合格的数据集合。内含硬标准排除 `excluded_subjects_171.csv`、任务级 `invalidated_task_data_140.csv`、三层明细账 `exclusion_ledger_three_layer.csv`、完整排除明细账 `removal_ledger_777_to_466.csv` 与时间线日志 `timeline_quality_screen.csv`，以及重建这些表格的 R 脚本。详见该文件夹的 `README.md`。

## Notes / 说明

- Data files (raw, cleaned, and derived indices) are stored separately under `01_raw/`, `02_cleaned/`, and `03_derived/`; this folder contains only code.
  数据文件（原始、清洗后与派生指标）分别存放于 `01_raw/`、`02_cleaned/`、`03_derived/`；本目录仅包含代码。
- The full variable-name mapping is provided in `codebook_variable_mapping.csv` at the dataset root.
  完整变量名对齐清单见数据集根目录 `codebook_variable_mapping.csv`。