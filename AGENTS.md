# AGENTS.md — PSV_Dataset 项目状态

## 当前目标

本仓库是论文《An integrated dataset of self-report and behavioral measures of positive self-view》（`05_Reports/Sun_2026_DataExp.md`）的数据与复现包。当前阶段的目标是：按作者代码（`04_code_and_reproducibility/analysis/analysis.Rmd`）的实际实现，把 777 条初始记录到 503 人最终样本的排除过程逐人复现，做到**每个被排除个案只有一个主要原因**；同时补齐两处发布文件缺失的被试标识（`ID`），核验并清理已冗余的旧排除表。输入数据（`01_raw/`、`05_Reports/`、`01_raw/README.md`、`data_dictionary.csv` 等）一律只读。

## 已完成

`04_code_and_reproducibility/exclusion_pipeline.qmd` 是唯一的复现入口（R + Quarto，14 节 + 3 张 Mermaid 图），执行后生成 `excluded_subjects_record.csv`（289 行 × 28 列，含 `evidence_basis`）、`exclusion_flow_reconciliation.csv`（13 行 × 15 列）、`flagged_but_retained.csv`（29 行 × 17 列），并渲染出 `exclusion_pipeline.html`——3 张图是 `<pre class="mermaid mermaid-js">` 容器、mermaid 库内嵌于 HTML，浏览器可直接看图。同一份 qmd 还覆盖式重建了 `02_cleaned/IAT_cleaned.csv`（144,840 行 × 11 列，503 人，组块 3/4/6/7，含 `ID`、`block`、`rt`、`RT`）与给 `03_derived/positive_SMT.csv` 补上首列 `ID`（503 行 × 9 列）。两份旧排除表已删除，其 186 行内容归档为 `removed_subjects_legacy_content.csv` 并呈现在 HTML 附录 C。除两个重建文件外，所有只读输入 md5 未变；一致性核查表 11 项全部为 TRUE，并以 `stopifnot(all(...))` 强制校验（不通过即中止）。

## 关键决策

**判据权威在代码里**：年龄 `analysis.Rmd:327-339`、ALT1 `:447-467`、IAT `:476-486`、ALT2 `:543-584`、SRET 再认 `:610-644`、SRET 来源 `:692-729`；论文正文措辞只作说明——按论文反推会得到 ALT1 41、SRET 87 等错误数字。

**论文所述判据的分类（qmd 第 1.5 节）**：论文中真正属于"排除标准"的只有 3 条——C1 年龄（<18 或 >59，prespecified，6 人被移除）、C7 重复提交/未满足数据完整性要求（论文仅举例、未给规则）、C8 注意力核查题（论文仅写"用于评估作答质量"，未给界值，代码里 `trap1/2/3` 也只被丢弃）；其余 5 条（C2 IAT、C3 SMT 几何版、C4 SMT 自我参照版、C5 SRET 的任务层面质量判据，以及 C6 SRET 数据部分缺失）论文未说明是否构成被试层面的排除标准，本数据集只作 note 记录，记录表中一律以"标记（flag）"表述、不作标准解释。

**唯一主要原因（按预设顺序唯一归类）**：`age_ineligible` 5 → `absent_after_day1` 104 → `absent_after_day2_with_flag` 36 → `absent_after_day2_without_flag` 43 → `absent_after_day3_with_flag` 61 → `absent_after_day3_without_flag` 1 → `excluded_by_task_criterion_reapplied` 19 → `excluded_for_other_reasons` 5，流程内合计 274；另有 `task_only_record` 13 与 `unidentifiable_record` 2 属非流程记录，主表共 289 行。环节内若同时未达到多条判据，`primary_reason` 取最明确的一条，其余写入 `secondary_notes`。

**只记录可核实事实，不作归因**：`analysis.Rmd:447-507`、`:543-799` 把每次测试的未达标者写成 `Eligible = "no"` 并导出 `select_dayX.xlsx`（注释"导入脑岛"）；论文第 47 行与 README 提到未达标者不再被邀请参加后续测试。但**发布数据中没有任何记录该决定的变量**（唯一疑似变量 `status` 在 144 万行中全为空；作者侧名册 `subj_dayX.xlsx`/`select_dayX.xlsx`/`invalid_dayX.xlsx` 不在本数据集内），而按发布数据复算：第 2 次测试未达标 46 人中有 9 人仍参加第 3 次、第 3 次测试未达标 102 人中有 40 人仍完成第 4 次。因此本数据集**不使用任何归因性措辞**：阶段名只用可观察定义（`absent_after_dayN_with_flag` = 未参加且携带标记 / `absent_after_dayN_without_flag` = 未参加且无标记），主表这些行的 `note` 只陈述"触发判据"与"未参加下一次测试"两项事实；附录 A 第 19 条记录该缺口。同一批判据下处置不一致（527 个完整个案中 47 人触发判据：19 人在最终核查中被个案层面排除、28 人未被排除），故主表用 `evidence_basis` 列标明每个原因的**证据来源**（`paper_documented` / `author_recorded` / `recomputed_flag_only` / `not_applicable`），并在被排除的 19 人处标注替代定义：若以同一判据统一处理，样本量将为 522。另注：这些判据是**任务表现界值**（正确率/反应时），不是注意力核查题——`trap1/2/3` 从未参与 `Eligible` 判定；观察性线索（非结论）：未达标却仍参加的 9 人全部来自最后四个招募轮次 phase_016–019。

**"未达标 ≠ 排除"**：质量筛选只在当事人**未参加下一场次**时才解释该段失访。实测有 9 人在第 2 次测试未达标后仍参加第 3 次、40 人在第 3 次测试未达标后仍完成第 4 次（其中 21 人留在 503），另有 1 人年龄未达标仍进入最终样本——这些只记入 `secondary_notes` 或"未达标但保留"表，不作排除原因。

**术语采用心理学/社会科学数据预处理的惯用说法**（qmd 第 1.3 节为唯一术语表，分"既有对照"与"本轮新增对照"两张表）：初始样本（原"宇宙"）、质量筛选（原"门控"）、未达标（原"触标"）、失访（原"流失"）、无标识记录（原"幽灵记录"）、排除环节、最终数据质量核查；本轮新增：决策记录（原"决策台账"）、流程核对表（原"对账表"）、结构概览（原"画像"）、匹配键（原"指纹"）、补录（原"回填"）、变量（原"字段"）、组块（原"区块"）、判定界值（原"阈值"，指质量判据的 cutoff）、按预设顺序唯一归类（原"first-match"）、个案层面排除（原"整人排除"）、重复提交（原"双跑"）、招募轮次（原"批次"）、一致性校验（原"断言"）、重复运行结果不变（原"幂等"）。`rt` 与 `RT` 保持原列名不改；质量筛选用 `rt`，分析运算用 `RT`；`IAT_raw.csv` 不做任何处理。已发布 CSV 的列名与列内取值不在本轮改动范围（见 qmd 第 1.3 节末注）。

## 核心文件

复现入口与产物在 `04_code_and_reproducibility/`（`exclusion_pipeline.qmd` 与其 HTML、三张记录表、存档副本 `removed_subjects_legacy_content.csv`）；判据实现证据在 `04_code_and_reproducibility/analysis/analysis.Rmd`；被重建的数据文件是 `02_cleaned/IAT_cleaned.csv` 与 `03_derived/positive_SMT.csv`；历史说明保留在 `04_code_and_reproducibility/removed_subjects_log.md`。`04_code_and_reproducibility/590_to_503_subject_qc.py` 不属于本流程。

## 验证结果（已实测）

质量筛选复算与论文附录 4 逐项吻合：IAT 4、ALT1 44、第 2 次测试质量筛选未达标 46；SRET 再认 70 + 来源 RT 32（并集 92）、ALT2 14、第 3 次测试质量筛选未达标 102（论文 103，因 ALT2 平台导出只覆盖 589/603）。失访构成：第 1 次测试后 104（论文 103，差 1 即年龄未达标者）、第 2 次测试后 43（另有 36 人携带标记且未参加）、第 3 次测试后 1（另有 61 人携带标记且未参加）。最终数据质量核查排除 24 = **19 人触发任务质量判据** + 5 人数据缺失/不可考（其中 15 人复算一致，与作者 `SRET_QC` 和最终数据质量核查的交集逐人一致）；527 完整个案中触发任务质量判据者共 47 人（19 被排、28 保留）。每段减少的两条可观察路径：第 2 次测试后 79 = 36（携带标记且未参加）+ 43（无标记且未参加）；第 3 次测试后 62 = 61 + 1。未达标但保留 29 人 = 任务质量判据 28 人（**与论文自陈的 28 完全一致**，含 ALT2）+ 年龄未达标 1 人；重施全部标准后个案层面 N = 474（仅按任务质量判据为 475）。`positive_SMT.csv` 的 ID 以 4 个 d′ 指标为匹配键补录，503/503 精确一一对应。

## 已知问题（仅记录，未改动任何原文）

重建前 `IAT_cleaned.csv` 无 `ID`、丢失组块号、只含特质词试次且 `rt` 实为校正值，无法据此复算 D 分数；重建前 `positive_SMT.csv` 无 `ID`、行序与合并表不同，其 4 个 `SMT_rt_*` 与 `analysis.Rmd:1079` 的 `friend-self` 符号相反（相关 −0.91~−0.94）；`01_raw/README.md` 提到的 `SMT_2_raw.csv` 不存在；论文记 SRET attempted 602，实际是 602 名被试加 1 条字符串 `"NA"`；最终核查构成论文写 20+3+1、本数据集复算 19+4+1；空 ID 记录实测 3577 行（ALT2 正式试次 768、反馈界面（feedback screen）864，旧日志只记 864）；年龄上界 59 无文献或预注册依据且只在第 1 次测试判定一次；注意力核查项 `trap1/2/3` 从未参与 `Eligible` 判定（`analysis.Rmd` 中仅被 `select(-c(...))` 丢弃）；论文 Table A3 的 final sample 列是任务级有效数据量，与"未达标"属不同概念。以上均写入 qmd 附录 A。

## 失败与放弃的方案

按论文正文反推判据（ALT1 的 RT 过滤位置、SRET 分母、填充词处理）得到 ALT1 41、SRET 87，改用 `analysis.Rmd` 的判定定义后全部对齐，反推方案已放弃。ALT2 曾用 `data.table::fread` 读 zip，其 `select=` 在 zip 连接上未生效且无任何提示，改为 `readr` + `unz()`；平台导出的 ALT2 正式试次不带 `domain`/`valence`/`person`，改由词标签还原（好/强为积极、坏/弱为消极、我为自我），对应关系经 cleaned 文件按 `rt` 与 `identity` 核对。`positive_SMT.csv` 的 ID 补录最初用 8 指标最近邻/Hungarian，且一次失败运行在一致性校验之前就写入文件、覆盖了原文件（已从 git 恢复，原 md5 `6bdb81feb27994cce77b27855492232c`），现改为先校验后写入、以 d′ 四项精确匹配，且重复运行结果不变。Mermaid 图最初用 `cat()` 动态生成，Quarto 未注册 mermaid 依赖（HTML 里 0 处 JS 引用）而渲染失败；现改为**源文件级** ```` ```{mermaid} ```` 块、图内数字写实值 + 紧随的 R 块一致性校验，且块内选项必须用 `%%|`（`#|` 会报 "chunk options should start with '%%| '"）。

## 环境与操作注意事项

R 4.5.2 与 Quarto 1.10.18；qmd 依赖 data.table、readr、glue、knitr。仓库所在卷不支持硬链接式原子写入（即写入中断可能留下不完整文件），文本文件需用普通写入。Quarto 渲染 HTML 会写用户级 Sass 缓存 `~/Library/Caches/quarto`（deno KV），该路径在 workspace-write 沙箱下不可写（报 `unable to open database file`），且与源文件位置无关；当前做法是把 HOME 指向仓库内临时目录再渲染：在 `04_code_and_reproducibility/` 下执行 `env HOME=<repo>/_cache/quarto_home DENO_DIR=<repo>/_cache/quarto_home/deno quarto render exclusion_pipeline.qmd -P delete_legacy:false`，渲染后删除 `_cache/`。`--to gfm` 不需要该缓存，但 GFM 不支持代码块属性，不能用来检验 Mermaid 渲染（应检查 HTML 中 `<pre class="mermaid mermaid-js">` 的数量与内嵌库标记）。旧表已删除，重新运行不会再改动它们；`delete_legacy` 参数保留但已无实际作用。

## 下一步

按需重新渲染以刷新产物；若原始数据或判据有更新，清空 `_cache/` 后重新运行。`removed_subjects_legacy_content.csv` 是旧表的归档证据（附录 C 与最终核查的判据文字都读它），请勿删除。若准备发布，建议先确认与论文的差异（第 1 次测试后失访 103/104、第 3 次测试质量筛选 103/102、最终核查构成 20+3+1/19+4+1、以及"同一批判据下 19 人被排除、28 人未被排除"的处置不一致）是否需在稿件中同步修订，并考虑把 `04_code_and_reproducibility/README.md` 补上对新 qmd 与三张记录表的索引（本轮按约定未改动既有说明文档）。
