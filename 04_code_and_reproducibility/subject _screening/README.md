# Subject Screening and Exclusions / 被试筛选与排除

This folder contains participant-level screening records and the R code used to derive the 606-person retained pool and the strict subject sample.

本文件夹保存被试筛选与排除记录，以及用于计算606人保留池和严格被试样本的R代码。

## Files / 文件说明

| File | Description |
|---|---|
| `subject_screening.R` | Screening pipeline for the 606 and strict 449 versions. It also contains the separately invoked SRET-only exclusion amendment for `phase_017_subj_16`. |
| `excluded_subjects.csv` | Person-level exclusion record for the 606 version: 171 excluded participants and their exclusion reason, stage, criterion, attended sessions, and observed metrics. |
| `ID_record.csv` | Cross-folder ID inventory for 777 authoritative participant IDs, including whether each ID appears in `01_raw`, `02_cleaned`, and `03_derived`. |
| `valid_data.csv` | File-level data inventory, including row counts, distinct authoritative/public IDs, and missing authoritative-ID row counts. It is not a participant-level exclusion list. |

## Cohort definitions / 样本定义

- **606 version:** retained after participant-level hard exclusions. The accompanying `excluded_subjects.csv` records 171 excluded participants.
- **Strict 449 version:** applies day-by-day task-quality and attendance requirements; a participant who fails an earlier stage does not proceed to later stages in this strict cohort.
- **Task-level availability:** failure on an individual task does not, by itself, remove that participant's valid data from other tasks or questionnaires. See `../technical_validation/Technical_Validation.html` for current measure-specific sample sizes.

- **606版本：** 根据被试层面的硬性标准筛选；`excluded_subjects.csv`记录171名被排除者。
- **严格449版本：** 按时间顺序应用出勤和任务质量要求，前一阶段未通过者不进入后续阶段的严格样本。
- **任务级可用性：** 单项任务未通过，不自动导致该被试在其他任务或问卷中的有效数据被删除。各测量当前有效人数见 `../technical_validation/Technical_Validation.html`。

## Reproduction / 复现说明

Run from the project root with R and the `data.table` package installed:

```sh
Rscript "04_code_and_reproducibility/subject _screening/subject_screening.R"
```
