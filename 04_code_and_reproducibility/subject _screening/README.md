# subject _screening: Standard Cleaning / 标准清洗

This directory documents the **standard participant- and task-level cleaning** applied to the raw data, reducing the 777 Day-1 records to 606 retained participants and then to the 466 complete-and-valid set. It is an alternative bookkeeping to the manuscript's own exclusion path (see sibling `../excluded_record_paper/`).

本目录记录对原始数据施加的**被试层面与任务层面的标准清洗**，将 Day 1 的 777 条记录缩减为 606 名保留参与者，再进一步得到 466 名完整且合格的数据集合。这是与论文自身排除路径并行的另一套记录（见同级 `../excluded_record_paper/`）。

## Cleaning standard / 清洗标准

### Part 1 — Hard (subject-level) criteria / 第一，硬标准（被试层面）

Exclude participants who fail the attention requirement (who should not be invited to subsequent sessions) and voluntary withdrawals (attrition):

排除注意力不符合要求的被试（这些被试不应被邀请再次参加实验）以及自愿退出的（流失）：

| # | Criterion / 判据 | Excluded / 排除 |
|---|---|---|
| 2 | Age out of range / 年龄不合要求 | 6 |
| 3 | Attrition after Day 1: did not attend Session 2 / 第 1 次后失访：未参加第 2 次测试 | 104 |
| 4 | Attrition after Day 2: did not attend Session 3 / 第 2 次后失访：未参加第 3 次测试 | 42 |
| 5 | Attrition after Day 3: did not attend Session 4 / 第 3 次后失访：未参加第 4 次测试 | 1 (retained / 数据保留) |
| 6 | `trap1` answered incorrectly / `trap1` 答错 | 4 |
| 7 | `trap2` ≥ 4 / `trap2` ≥ 4 | 15 |

Hard exclusions total **171** participants, retaining **777 − 171 = 606** (`excluded_subjects_171.csv`). The single Day-3 dropout (row 5) is retained because Session 4 is a retest.

硬标准共排除 **171** 人，保留 **777 − 171 = 606** 人（见 `excluded_subjects_171.csv`）。第 5 项第 3 次后失访的 1 人因第 4 次测验为重测而数据保留。

### Part 2 — Task-level criteria / 第二，任务层面的标准

A failed task invalidates that task's data, but the participant's other-session questionnaire and task data remain valid, and participants who only missed the retest are still used. 

某项任务失败只作废该任务的数据，被试其他场次的问卷及任务数据仍然有效，仅未参加重测的被试数据照常使用。

| # | Session / 场次 | Criterion / 判据 | n | Union / 并集 |
|---|---|---|---|---|
| 8 | Session 2 / 第 2 次 | IAT RT < 300 ms proportion > 10% / IAT 反应时 <300ms 占比 >10% | 4 | 46 |
| 8 | Session 2 / 第 2 次 | SMT any condition accuracy < 60% / SMT 任一条件正确率 <60% | 44 | 46 |
| 9 | Session 3 / 第 3 次 | SRET recognition < 55% / SRET 再认 <55% | 70 | 102 |
| 9 | Session 3 / 第 3 次 | SRET source RT < 200 ms proportion > 30% / SRET 来源 RT <200ms 占比 >30% | 32 | 102 |
| 9 | Session 3 / 第 3 次 | SMT2 any condition < 20% or any domain < 60% / SMT2 任一条件 <20% 或任一领域 <60% | 14 | 102 |

Union across task-level criteria totals **140** participants (`invalidated_task_data_140.csv`). The experiment records that are complete and valid throughout total **466** (`removal_ledger_777_to_466.csv`).

任务层面判据并集共 **140** 人（见 `invalidated_task_data_140.csv`）。整段实验流程数据均完整且合格者共 **466** 人（见 `removal_ledger_777_to_466.csv`）。

## Files / 文件

| File / 文件 | Rows / 行 | Content / 内容 |
|---|---|---|
| `excluded_subjects_171.csv` | 171 | Subject-level (hard-criterion) exclusions; one row per excluded participant / 被试层面（硬标准）排除，每个被排除参与者一行 |
| `invalidated_task_data_140.csv` | 140 | Participants whose task data was invalidated (task-level criteria) but who are retained; includes the 1 missed-retest case / 任务数据被作废但人保留者；含仅缺第 4 次的 1 人 |
| `exclusion_ledger_three_layer.csv` | 325 | record-level (task-only / no valid ID), subject-level exclusion, and task-level data invalidation / 记录级（仅任务数据 / 无有效标识）、被试级排除、任务级数据作废 |
| `removal_ledger_777_to_466.csv` | 325 | Full strict-timeline removal ledger from the initial set to 466, per participant, with attendance, stage, and subsequent-session flags / 从初始集合到 466 的严格时间线逐人排除明细账，含出席、阶段与后续场次标记 |
| `timeline_quality_screen.csv` | 166 | Per-participant, per-event quality-screen log along the session timeline (fail day/session/label, criterion, observed vs. threshold, whether the participant continued) / 沿时间线的逐人逐次质量筛选日志（失败日/场次/标签、判据、观察值与界值、是否继续参加） |

## Reproduction / 复现

The four R scripts rebuild the tables from the released data.The `ID` list of the 606 participants

四份 R 脚本基于已发布数据重建上述表格。清洗后的被试 ID 清单。

| Script / 脚本 | Builds / 生成 |
|---|---|
| `build_excluded186_and_invalidated.R` | `excluded_subjects_171.csv`, `invalidated_task_data_140.csv` |
| `build_exclusion_ledger_three_layer.R` | `exclusion_ledger_three_layer.csv` |
| `build_removal_ledger.R` | `removal_ledger_777_to_466.csv` |
| `build_timeline_quality_screen.R` | `timeline_quality_screen.csv` |
| `retained_606_IDs.csv` | 606 × 1 | The `ID` list of the 606 participants retained after cleaning; used to build `02_cleaned/` / 清洗后保留的 606 名参与者 `ID` 清单；用于构建 `02_cleaned/` |

