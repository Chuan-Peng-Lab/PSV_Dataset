# excluded_record_paper: Exclusion per the Paper / 按论文思路的被试排除记录

This directory documents the participant-exclusion process **following the manuscript's own analysis logic** (`analysis/analysis.Rmd`), from the 777 Day-1 records down to the 503-participant final sample. 

本目录记录**按照论文自身分析逻辑**（`analysis/analysis.Rmd`）进行的被试排除过程，即从 Day 1 的 777 条记录到 503 名最终样本。

## Pipeline / 复现入口

| File / 文件 | Content / 内容 |
|---|---|
| `exclusion_pipeline.qmd` | The single reproduction entry point (R + Quarto): step-by-step reconstruction of the 777 → 503 exclusion process, and the script that writes the three record tables below / 唯一的复现入口（R + Quarto）：逐步复现 777 → 503 的排除流程，并生成下方三张记录表 |
| `exclusion_pipeline.html` | Rendered HTML report from the qmd, including three Mermaid flow diagrams (rendered inline in the browser) / 由该 qmd 渲染出的 HTML 报告，内含三张 Mermaid 流程图（浏览器中直接可见） |

To re-render: run `quarto render exclusion_pipeline.qmd` (see the repository root `AGENTS.md` for the HOME/cache workaround used in this environment).

重新渲染：运行 `quarto render exclusion_pipeline.qmd`（本环境所需的 HOME/缓存处理见仓库根目录 `AGENTS.md`）。

## Record tables / 记录表

| File / 文件 | Rows × Cols / 行 × 列 | Content / 内容 |
|---|---|---|
| `excluded_subjects_record.csv` | 289 × 35 | Per-subject exclusion detail: identity, attendance, exclusion stage, `primary_reason`, criterion, observed vs. threshold values, `evidence_basis`, and `js_*` programmatic-observation columns (recorded only, never an exclusion reason) / 逐人被排除明细：身份、出席、排除环节、唯一主要原因 `primary_reason`、判据、观察值与界值、证据来源 `evidence_basis`，以及 `js_*` 程序性观测列（仅记录，不作为排除理由） |
| `exclusion_flow_reconciliation.csv` | 16 × 15 | Stage-by-stage flow reconciliation (771 → 503). The last 3 rows are stage summaries (final-check split 19/5; total 269) and do not occupy main-table rows / 各环节流程核对表（771 → 503）。末尾 3 行为阶段汇总（最终核查拆分 19/5、合计 269），不占主表行 |
| `flagged_but_retained.csv` | 29 × 17 | Participants who triggered a task-level quality criterion but were nevertheless kept in the released sample / 触发任务层面质量判据但最终仍被保留的参与者 |
| `removed_subjects_log.md` | — | Historical log documenting the earlier 590 → 503 participant deletion check / 记录早期 590 → 503 被试删除核查的历史说明 |

## Flow summary / 流程概要

- Starting point: 777 Day-1 questionnaire records (a union of all session files gives 791 when the 14 non-flow task-only/`"NA"` records are included).
- 终点：**503** 名最终样本。
- The process is decomposed into unique, prespecified-order primary reasons (age ineligible → attrition after each session, with/without an accompanying quality flag → final data-quality check → other reasons), so that **each excluded person has exactly one primary reason**; additional criteria hit are written to `secondary_notes`.
- 终点：**503** 名最终样本。排除按预设顺序唯一归类（年龄不合要求 → 各场次后失访，携带/未携带质量标记 → 最终数据质量核查 → 其他原因），确保**每个被排除个案只有一个主要原因**；其他命中的判据写入 `secondary_notes`。

## Notes / 说明

- The pipeline also rebuilds two released data files: `02_cleaned/IAT_cleaned.csv` and the leading `ID` column of `03_derived/positive_SMT.csv`.
  该流程还会重建两份发布数据文件：`02_cleaned/IAT_cleaned.csv` 与 `03_derived/positive_SMT.csv` 的首列 `ID`。
- This directory reflects the **paper/manuscript** exclusion path (→ 503). For the alternative "standard cleaning" path (777 → 606 → 466), see the sibling folder `../subject _screening/`.
  本目录对应**论文**排除路径（→ 503）。若需另一套“标准清洗”路径（777 → 606 → 466），见同级的 `../subject _screening/`。
