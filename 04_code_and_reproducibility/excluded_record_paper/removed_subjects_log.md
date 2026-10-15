# Sun_2026_DataExp — 590 → 503 被试删除核查日志

> 位置：`1_Data/Sun_2026_DataExp/Sun_2026_DataExp_Raw/04_code_and_reproducibility/`
> 配套文件：`590_to_503_subject_qc.py`（复现脚本）、`removed_subjects_590_to_503.csv`（87 人明细）、`removed_subjects_others.csv`（6 人对照）。

## 1. 数据口径

| 集合 | 定义 | 唯一被试（`ID` = `phase_XXX_subj_YY`） |
|---|---|---|
| RAW | `01_raw/questionnaires_day3_raw.zip → day2_data.csv` 中 ALT2 试次 | **590** |
| CLEAN | `02_cleaned/02_cleaned_data/SMT/ALT2_all.csv`（= 论文 Table 6 分析 N） | **503** |
| REMOVED | RAW − CLEAN | **87** |

- 论文 Appendix 4 写 ALT2「attempted 603 / valid 588 / final 501」，Table 6 写 SMT 各指标 N = 503。
- 本库以 RAW 合并导出（590）为数据基底；它比论文「attempted 603」少 13 人（论文正文自陈原始 jsPsych 导出仅覆盖部分样本）。

## 2. 删除原因总表（87 人）

| `removed_by` | 人数 | 判据 |
|---|---|---|
| `SRET_QC` | 68 | SRET 再认正确率 < 55%（RJ1）和/或 来源判断 RT<200 ms 比例 > 30%（RJ2） |
| `ALT2_accuracy` | 12 | SMT 单条件正确率 < 20% 或 单领域正确率 < 60% |
| `unexplained` | 5 | 通过全部可核查标准（ALT1/IAT/ALT2/SRET/Day10/注意力核查）仍被删 |
| `empty_ID_ghost` | 1 | `ID` 字段空白的幽灵记录（864 行） |
| `missing_SRET` | 1 | 仅 EW 编码，缺 RJ1/RJ2（`phase_017_subj_13`） |
| **合计** | **87** | |

- SRET 两标准的「任一命中」= 70（再认）+ 32（来源 RT）− 9（重合）= **92**，与论文 Appendix 4「SRET flagged 92」吻合。
- 逐条明细（含具体条件/领域与正确率数值）见 `removed_subjects_590_to_503.csv`。

## 3. 关键结论：75 个非 SMT 原因者，本库应保留

87 人拆解：

- **12 人**：SMT（ALT2）自身精度未达标 → 本库视为 SMT 无效数据。
- **75 人**：非 SMT 原因被删——
  - 68 `SRET_QC` + 1 `missing_SRET` = **69 人属 SRET（另一任务）原因**；
  - 1 `empty_ID_ghost`（数据瑕疵）；
  - 5 `unexplained`。

按本数据库「最小预处理、只筛本任务（SMT）」原则：**SMT 数据有效的 69 人（SRET 被剔者）应保留**；`empty_ID_ghost` 因无有效 ID 无法作为被试使用。

## 4. 重复记录与雷同核查

**重复记录**（判据 = 同 `ParticipantID` + 同 `phase`，强判据；单看 PID 不可靠——590 人仅 402 个 PID）：

| 保留（KEPT） | 删除（REMOVED） | PID | phase |
|---|---|---|---|
| phase_015_subj_15 | （空 ID） | 201 | 15 |
| phase_010_subj_19 | phase_010_subj_18 | 576 | 10 |
| phase_016_subj_16 | phase_016_subj_17 | 140 | 16 |
| phase_017_subj_14 | phase_017_subj_13 | 65 | 17 |
| phase_017_subj_97 | phase_017_subj_98 | 398 | 17 |
| phase_018_subj_13 | phase_018_subj_14 | 112 | 18 |

对照被试记录于 `removed_subjects_others.csv`。

**雷同数据核查**：对全部 590 人逐人构造试次级指纹（screen_id/condition/identity/response/responses/rt/correct），按「精确含 rt」「结构去 rt」×「顺序敏感」「顺序无关」四种口径比对 → **0 组完全雷同**。即不存在「两个不同被试数据一模一样」的情况。

## 5. KEPT（503 人）数据质量核查

| 指标 | 结果 |
|---|---|
| 正式试次（`screen_id` ∈ ability/moral） | 全部 **768**（16 条件 × 48 试次），异常 0 人 |
| 练习试次 | 96–480（变长，正常） |
| 正式正确率 | 范围 0.634–0.975，均值 0.824；无 <0.6、无 >0.99 |
| 跨被试雷同 | 无 |

结论：503 人 SMT 数据规整、无异常、无雷同。

## 6. 入库计划（2026-10 更新）

1. **590 人全部保留**：Clean 中保留 RAW 的全部 590 名被试，不施加论文的 SMT/SRET 剔除。
2. **JSON 记录无效数据**：在 `Sun_2026_DataExp_Exp1.json` 的 `detail` 中说明——共 12 名被试的 SMT 数据未达论文质量标准（单条件 <20% 或 单领域 <60%），但依据本数据库「最小预处理、不过滤」原则仍予保留；使用者可按自身分析目标自行剔除。
3. **SRET 剔除不适用**：论文因 SRET（不同任务）质量剔除的 69 人，与本库 SMT 任务无关，**不纳入本库剔除范围**。
4. **数据瑕疵**：`empty_ID_ghost`（空 ID，864 行）无法对应被试身份，不纳入；如需保留须先补 ID。
5. **主索引口径**：`Sample_Size` = 590（数据口径）；`Note` 记 `Paper_N: 603 attempted / 588 valid / 503 final (Table 6)`。
6. **溯源文件**：本目录脚本与两份 CSV 作为删除判定的证据留存（`raw/` 输入区不进校验、不进 git）。

---

## 7. Task1（SMT_1 / Day 2，Session 2）两来源差异与处置（2026-10 定案）

Task1 有两个来源，**互不包含**，必须先定源再入库：

| 来源 | 规模 | 说明 |
|---|---|---|
| 作者文件 `01_raw/SMT_1_raw.csv` | **681 个 ID** / 604,176 行 | 作者发布的 SMT_1 task 级文件；正式试次 768·人（679 人）、1536·人（2 人） |
| 平台导出 `questionnaires_day2_raw.zip → day1_data.csv` | **644 个 ID** / 572,928 行（ALT1 行） | 脑岛平台整场 jsPsych 导出（问卷+IAT+SMT_1）；编码 GB18030 且含非法字节；正式 768·人（641）、1536·人（3，含 ID 字面为 `NA` 的记录） |

### 7.1 用户决策（2026-10）

1. **作者文件 2 遍、平台仅 1 遍** → 只保留**与平台一致的那一遍**，JSON 中说明。
2. **作者文件与平台均为 2 遍** → **两遍均保留**（该被试可能完成了两次），JSON 中说明。
3. **平台有、作者文件无的记录** → **不入库**（以作者发布的任务级文件为准）。
4. **平台 2 遍、作者文件 1 遍** → **只采用作者文件那 1 遍**，平台多出的那遍不入库。
5. **其他不一致记录** → 记入本文件（本节 7.3）。

### 7.2 逐案处置清单

| 类型 | ID | 作者文件 | 平台导出 | 处置 |
|---|---|---|---|---|
| A 作者 2 遍 / 平台 1 遍 | `phase_003_subj_14`（作者 PID 20231101；平台同 ID 记录 PID 681） | 1872 行：首遍 prac_ALT1_1 144 (0.570) + formal_ALT1_1 384 (**0.594**，未过 60% 门槛) + formal_ALT1_2 384 (0.955)；第二遍 prac 96 (0.722) + formal_ALT1_1 384 (0.893) + formal_ALT1_2 384 (0.898) | 912 行：仅第二遍（formal_ALT1_1 0.893 / RT 607 ms，与作者第二遍**完全一致**） | **保留第二遍（与平台一致）**，丢弃首遍；JSON 说明 |
| B 两边均 2 遍 | `phase_017_subj_20`（PID 85，另与 `phase_017_subj_21`/`phase_018_subj_6` 共用 PID） | 1728 行（2 遍，formal_ALT1_1 0.930 / 0.966） | 1728 行（同 2 遍） | **两遍均保留**；JSON 说明"可能完成两次"；Clean 加 `Run`(1/2) 列区分 |
| C 平台 2 遍 / 作者 1 遍 | `phase_003_subj_2`（PID 60） | 864 行：prac_ALT1_2 48 (0.958) + formal_ALT1_2 384 (0.950) + prac_ALT1_1 48 (0.978) + formal_ALT1_1 384 (0.919) | 1728 行：**与作者那遍 RT 逐段相同**（814/841/837/786 ms）的 run A + 额外 run B（prac_ALT1_1 48 → formal_ALT1_1 0.896 → formal_ALT1_2 0.935，RT 829/714/593/567 ms） | **只采用作者文件的 1 遍**（= 平台 run A）；平台多出的 run B 不入库 |
| D 平台独有伪 ID | `NA`（PID 460、phase 3，1872 行 / 1536 正式） | 无此 ID | 2 遍：run A（prac 96 → formal_ALT1_1 0.935 → formal_ALT1_2 0.956，RT 713/674 ms）+ run B（prac 144 → formal_ALT1_1 **0.568** → formal_ALT1_2 0.940，RT 608/734 ms） | **不入库**（作者文件中不存在该记录；用户 2026-10 决策）；其 run B 的练习结构（144）与平均 RT 608 ms 与作者文件 `phase_003_subj_14` 首遍一致，但 PID 不同（460 vs 20231101），身份无法确证 |

### 7.3 其他不一致记录

1. **覆盖差异（作者独有 38 个 ID）**：`phase_002_subj_2/4–15`（13 人）、`phase_003_subj_3`、`phase_003_subj_10`、`phase_009_subj_1–23`（23 人）——这 38 人在平台这份导出中**完全缺失**（各 768 正式试次），Task1 只能取作者文件；平台导出对 phase_002 / phase_009 两批无覆盖。
2. **平台独有 1 个 ID**：字面 `NA`（见 7.2 D）。
3. **`correct` 列在部分 run 上不一致**：如 `phase_003_subj_2` 的 formal_ALT1_2，作者文件 0.950 vs 平台 0.935（RT 逐段相同，仅正确率口径/取值不同）；`phase_003_subj_14` 第二遍两边则完全一致。差异原因待查（疑为作者侧重算 `correct` 时的 RT 过滤口径）。
4. **PID 与 ID 的关系不稳定**：同一 PID 可对应多个 ID（如 PID 85 → `phase_017_subj_20`/`phase_017_subj_21`/`phase_018_subj_6`）；平台 `NA` 记录的 run B 与作者 `phase_003_subj_14` 首遍内容对应但 PID 不同。故**不得以 PID 作为跨来源对齐键**。
5. **来源选择结论**：Task1 主源 = **作者文件 `SMT_1_raw.csv`**（覆盖 681 人 > 平台 644 人；平台仅作时间戳与双跑鉴定佐证）。

### 7.4 执行结果（2026-10-01，**并集口径；已被 §8 交集口径取代**）

> 注：本节记录的是当次按「两任务并集」执行的结果（682 被试 / 1,128,096 行）。用户随后改为**交集口径**（§8），库内数据与主索引已按 589 被试 / 1,040,880 行收口；本节数字仅作历史留档。

上述决策已由 `1_Data/Sun_2026_DataExp/Sun_2026_DataExp_clean.R` 落实并收口：

- **Clean**：1,128,096 行 / **682 被试**（Task1 603,216 行 + Task2 524,880 行），按被试边界分 4 片（`_Clean_part1–4.csv`，各 ~43 MB）。
- **raw**：同样 1,128,096 行 / 682 被试，分 4 片（`_raw_part1–4.csv`，各 ~47.8 MB，库内首个 raw 分片）。
- **双跑落地**：`phase_003_subj_14` 保留 912 行（仅重跑遍）；`phase_017_subj_20` 保留 1728 行并标 `Run=1/2`；`phase_003_subj_2` 保留作者文件 768 行；平台 `NA` 记录未入库。
- **幽灵**：`phase_015_subj_ghost01` 864 行入库（ID 即标识）。
- **主索引**：`Sample_Size=682`、`Valid_Subj=503`、`Drop_Subj=179`、`Status=1`、`License=CC BY 4.0`、`PubType=Journal`、`Journal=Data Express`、`Repo_Link=SciDB`、`City=NA`。
- **校验**：`validate_json_metadata.R` EXIT=0；`validate_clean_csv.R` 0 ERROR（`known` 中 Sun 的 E3 豁免已移除）。

---

### 附：12 名 SMT 无效被试明细

| ID | 未达标标准 | 具体条件/领域 | 正确率 |
|---|---|---|---|
| phase_005_subj_6 | standard1 条件<20% | 弱我(匹配) · 坏我(匹配) | 0.167 · 0.188 |
| phase_018_subj_99 | standard1 条件<20% | 弱我(匹配) | 0.188 |
| phase_019_subj_50 | standard1 条件<20% | 坏他/她(匹配) | 0.188 |
| phase_005_subj_8 | standard2 领域<60% | 能力 | 0.594 |
| phase_006_subj_21 | standard2 领域<60% | 道德 | 0.576 |
| phase_006_subj_9 | standard2 领域<60% | 道德 | 0.596 |
| phase_014_subj_24 | standard2 领域<60% | 能力 | 0.552 |
| phase_016_subj_62 | standard2 领域<60% | 能力 | 0.581 |
| phase_017_subj_15 | standard2 领域<60% | 能力 · 道德 | 0.516 · 0.581 |
| phase_017_subj_155 | standard2 领域<60% | 能力 | 0.508 |
| phase_017_subj_18 | standard2 领域<60% | 道德 | 0.570 |
| phase_018_subj_29 | standard2 领域<60% | 能力 · 道德 | 0.406 · 0.526 |

### 附：5 名原因不明被试

`phase_005_subj_17`、`phase_008_subj_4`、`phase_008_subj_6`、`phase_008_subj_7`、`phase_015_subj_46`
—— 均通过全部可核查标准、完成全部 session、ParticipantID 唯一；删除原因在匿名化数据中不可考（最可能为论文「3 excluded for other reasons」中依赖姓名/联系方式的重复提交或数据完整性判定）。

---

## 8. 交集口径（2026-10-01 用户决策；**本数据特例，不作为通用规则**）

### 8.1 决策

- 库内数据**只保留 Task1（SMT_1 / Day 2 / Session 2）与 Task2（SMT_2 / Day 3 / Session 3）的交集**——即两个会话都完成的被试。
- 该口径**仅适用于本数据集**，不写入 SKILL。
- 同时决定：**空 ID 幽灵记录不再保留**（统一按交集原则），**`Run` 列取消**（唯一双跑者被交集排除，该列将恒为 1）。

### 8.2 口径与数字

| 集合 | 人数 | 行数 | 处置 |
|---|---|---|---|
| **交集（保留）** | **589** | **1,040,880**（Session 2: 516,864；Session 3: 524,016） | 库内 Clean / raw |
| 仅 Session 2（无 Day 3 数据） | 92 | 86,352 | 排除（`removed_by = no_Task2_session`） |
| 仅 Session 3（空 ID 重复提交） | 1（`phase_015_subj_ghost01`） | 864 | 排除（`removed_by = no_Task1_session`） |

主索引随之：`Sample_Size = 589`、`Valid_Subj = 503`、`Drop_Subj = 86`、Male/Female = 294/295（**交集口径下性别全覆盖**，先前缺 `Sex` 的 92 人已排除）。

### 8.3 与此前 §7 处置的关系

- **`phase_003_subj_14`**（§7.2 类型 A：只保留与平台一致的重跑遍）与 **`phase_017_subj_20`**（§7.2 类型 B：两遍均保留 + `Run` 列）**均无 Session 3 数据 → 按交集整体排除**；两人的双跑证据仍留在 §7.2 与本表中备查，但不再影响库内数据（`Run` 列因此取消）。
- **`phase_003_subj_2`**（§7.2 类型 C）在交集内 → 仍按"只采用作者文件那 1 遍"入库，不变。
- **作者剔除的 86 人**（590 − 503 − 幽灵）全在交集内 → 仍按最小预处理原则保留，不变；12 名 Task2 精度未达标者同样保留。

### 8.4 证据文件更新

- `removed_subjects_590_to_503.csv` 追加 **93 行**：92 × `no_Task2_session`（附各自 Session 2 试次数）+ 1 × `no_Task1_session`（幽灵，试次数 864，重复标记 duplicate）。原有 87 行（作者阶段）逐字节未改。
- 本文件 §8 与 exp JSON `detail`、`3_Reports/Sun_2026_DataExp_Ingestion_Plan.md` §8 三处口径一致。
