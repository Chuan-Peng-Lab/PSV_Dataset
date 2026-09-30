# PSV_Dataset: Integrated Self-Report and Behavioral Measures of Positive Self-View

## Dataset overview / 数据集概述

This dataset contains item-level questionnaire data and trial-level data from three behavioral tasks collected across multiple sessions. The behavioral tasks are the Implicit Association Test (IAT), the Self-Matching Task (SMT), and the Self-Referent Encoding Task (SRET). The term **SMT** is used in the manuscript and dataset description; the archived analysis code and file prefixes use **ALT** for this task. Accordingly, `SMT_1` and `SMT_2` below are the two versions of the SMT — the geometric-shape version administered on Day 2 and the self-referential version administered on Day 3 — not a fourth task.

本数据集包含多次测量中收集的问卷条目级数据和三个行为任务的试次级数据。三个行为任务为内隐联想测验（IAT）、自我匹配任务（SMT）和自我参照编码任务（SRET）。论文和数据集说明统一使用 **SMT**；历史分析代码和文件名前缀使用 **ALT** 表示该任务。因此，下面的 `SMT_1` 和 `SMT_2` 是 SMT 的两个版本——Day 2 施测的几何图形版与 Day 3 施测的自我参照版——不代表第四个任务。

The dataset contains trial-level raw data for all task attempters and complete-case cleaned data with 503 participants. Of the 777 records collected at the Day 1 screening session, six were removed by the age criterion (777 → 771); 244 participants did not complete all four sessions (103 did not return for Day 2, 79 did not return for Day 3, and 62 did not complete the Day 10 retest), leaving 527 complete-case participants; of these, 24 were excluded in the final screening (20 failed behavioral quality-control criteria, one had partially missing SRET data, and three were excluded for other reasons), yielding the final sample of 503. Behavioral criteria were applied wave-by-wave during data collection as re-invitation gates (46 flagged on Day 2 and 103 on Day 3 among all session attendees, overlaps merged within session). The participant-flow diagram is reported in the manuscript (Figure A1, Appendix 3), and task-level valid sample sizes are summarized in Appendix 4 (Table A3) of the manuscript.

本数据集的任务级原始数据覆盖全部实际参加者，完整个案清洗数据保留 503 名参与者。Day 1（筛查日）共收集 777 份记录，年龄标准剔除 6 人（777 → 771）；244 人未完成全部四次测试（103 人未返回 Day 2、79 人未返回 Day 3、62 人未完成 Day 10 重测），完整个案 527 人；其中 24 人在最终筛查中被剔除（20 人触及行为质量控制标准、1 人 SRET 数据部分缺失、3 人因其他原因），最终样本 503 人。行为标准在数据收集期间逐批次执行，作为复邀门槛（Day 2 全部到场者中标记 46 人、Day 3 标记 103 人，当日内重合已合并）。被试流程图见论文图A1（附录3），任务级有效样本量见论文附录4（表A3）。

## Session naming / 测试日命名

The questionnaire files are labeled Day 1, Day 2, Day 3, and Day 10, corresponding to the four test sessions described in the manuscript:

问卷文件按 Day 1、Day 2、Day 3、Day 10 命名，对应论文中描述的四个测试日：

| File label / 文件标签 | Manuscript session / 论文测试日 | Core content / 核心内容 |
|---|---|---|
| `day1` | Day 1 | Informed consent, demographics, Self-Concept Clarity Scale (SCC), PHQ-9, GAD-7 / 知情同意、人口学问卷、自我概念清晰度量表（SCC）、PHQ-9、GAD-7 |
| `day2` | Day 2 | Questionnaires (RSES, CSES, NPI-16, HNS, SGPS) + IAT + geometric-shape version of the SMT (SMT_1) / 问卷（RSES、CSES、NPI-16、HNS、SGPS）+ IAT + SMT 几何图形版（SMT_1） |
| `day3` | Day 3 | Questionnaires (SWLS, IPC-I, LOT-R, MIS, MSIS, SDE, IM) + SRET + self-referential version of the SMT with moral/competence labels (SMT_2) / 问卷（SWLS、IPC-I、LOT-R、MIS、MSIS、SDE、IM）+ SRET + SMT 自我参照版（道德/能力标签，SMT_2） |
| `day10` | Day 10 | Full questionnaire retest (all scales; no behavioral tasks) / 问卷全量重测（全部量表，无行为任务） |

Day 10 was the retest session, scheduled 7–9 days after the baseline sessions, and involved questionnaire retesting only. The eight SMT indices released in this dataset were derived from the self-referential version administered on Day 3 (SMT_2).

Day 10 为重测日，安排在基线施测后 7–9 天，仅重测问卷。本数据集发布的 8 个 SMT 指标来自 Day 3 施测的自我参照版（SMT_2）。

## Directory structure / 文件结构

```text
PSV_Dataset/
├── README.md                                              # 数据集总说明
├── data_dictionary.csv                                    # 变量名
├── codebook_variable_mapping.csv                          # 发布变量名与稿件指标名对齐清单
│
├── 01_raw/                                                # 原始数据
│   ├── IAT_raw.csv
│   ├── SMT_1_raw.csv
│   ├── SMT_2_raw.csv
│   ├── SRET_raw.csv
│   ├── questionnaires_day1_raw.csv                        # Day 1
│   ├── questionnaires_day2_raw.zip                        # Day 2
│   ├── questionnaires_day3_raw.zip                        # Day 3
│   ├── questionnaires_day10_raw.csv                       # Day 10 重测
│   └── README.md
│
├── 02_cleaned/                                            # 清理后数据
│   ├── IAT_cleaned.csv
│   ├── SMT_1_cleaned.zip
│   ├── SMT_2_cleaned.zip
│   ├── SRET_cleaned.csv
│   ├── questionnaires_day1_cleaned.csv
│   ├── questionnaires_day2_cleaned.csv
│   ├── questionnaires_day3_cleaned.csv
│   ├── questionnaires_day10_cleaned.csv
│   └── README.md
│
├── 03_derived/                                            # 派生指标
│   ├── positive_IAT.csv
│   ├── positive_SMT.csv
│   ├── positive_SRET.csv
│   ├── positive_self_view_indices.csv                     # 合并 503 名参与者的行为任务指标
│   └── README.md
│
└── 04_code_and_reproducibility/                           # 代码与可复现性
    ├── README.md                                          # 文件说明
    ├── procedure/                                         # 实验程序（day1/day2/day3/day10）
    └── analysis/                                          # 整合文章内全部分析流程的代码
        ├── analysis.Rmd                                   # 主分析文件
        ├── analysis.html                                  # 由该 Rmd 生成的 HTML
        └── README.md                                      # 分析代码说明
```

## File naming and task terminology / 文件命名与任务术语

| Manuscript term / 论文术语 | Archived code/file term / 历史代码或文件术语 | Meaning / 含义 |
|---|---|---|
| IAT | IAT | Implicit Association Test / 内隐联想测验 |
| SMT | ALT, ALT1, ALT2 | Self-Matching Task; the released data files use SMT_1 (geometric-shape version) and SMT_2 (self-reference/moral version); the archived code uses ALT1 and ALT2 / 自我匹配任务；发布数据文件使用 SMT_1（几何图形版）与 SMT_2（自我参照与道德版），历史代码使用 ALT1 与 ALT2 |
| SRET | SRET | Self-Referent Encoding Task / 自我参照编码任务 |

The archived filenames are preserved in `04_code_and_reproducibility/` so that the code matches its original source; the released data files use the SMT_1/SMT_2 naming. The manuscript-facing task name is SMT throughout.

历史存档文件名保留于 `04_code_and_reproducibility/`，以确保代码与其原始文件一致；发布的数据文件使用 SMT_1/SMT_2 命名。在论文面向读者的任务名称中统一使用 SMT。

## Variable naming and abbreviations / 变量命名与缩写

| Abbreviation / 缩写 | Meaning / 含义 |
|---|---|
| `ability` | Competence domain / 能力领域（论文中记作 competence） |
| `moral` | Morality domain / 道德领域（论文中记作 morality） |
| `EW` | SRET encoding phase, i.e., the formal word-evaluation screen (`EW_formal` in the code): participants judged whether each trait word described themselves or their friend / SRET 编码阶段（代码中的 `EW_formal` 词评价屏）：判断特质词描述自己还是朋友 |
| `RJ1` | First recognition judgment in the SRET (`RJ_formal1`): new / familiar / old / SRET 第一次再认判断（`RJ_formal1`）：新／熟悉／旧 |
| `RJ2` | Second judgment in the SRET (`RJ_formal_2`): source memory, attributing the word to self or friend / SRET 第二次判断（`RJ_formal_2`）：来源记忆，将词归因于自己或朋友 |
| `yes` | Endorsement (count of "yes" responses) during SRET encoding / SRET 编码阶段的认可（"yes" 反应计数） |
| `REC` | Recognition-phase sensitivity (d′) indices / 再认阶段敏感性（d′）指标 |
| `SOURCE` | Source-memory sensitivity (d′) indices / 来源记忆敏感性（d′）指标 |
| `rt` / `RT` | Reaction time / 反应时 |
| `d` | Signal-detection sensitivity d′ / 信号检测敏感性 d′ |
| `D` | IAT D-score (improved algorithm) / IAT D 分数（改进算法） |
| `_al` (suffix) | Total score of a scale / 量表总分 |

The complete mapping between the released variable names and the manuscript-facing indicator names (Tables 3 and 6 of the manuscript) is provided in `codebook_variable_mapping.csv`. Note that valence is capitalized in some released files (`Positive`/`Negative`) but lowercase in the manuscript (`positive`/`negative`).

发布变量名与论文指标名（论文表3与表6）之间的完整对应关系见 `codebook_variable_mapping.csv`。注意：部分发布文件中效价标签为首字母大写（`Positive`/`Negative`），论文中为小写（`positive`/`negative`）。

## Data levels / 数据层级

- `01_raw`（01_raw_data）：实验平台导出的原始数据，包括行为任务试次记录和问卷导出文件。
- `02_cleaned`（02_cleaned_data）：按照论文所述规则删除无效试次和练习试次后的清洗任务数据及问卷表。
- `03_derived`（03_derived_indices）：参与者层面的任务指标、问卷表、合并数据以及相关/重测结果。

- `01_raw`: raw exports from the experimental platform, including trial-level behavioral records and questionnaire exports.
- `02_cleaned`: cleaned trial-level task data and cleaned questionnaire tables after removal of invalid trials and practice trials as described in the manuscript.
- `03_derived`: participant-level task indices, questionnaire tables, merged datasets, and correlation/retest outputs.

