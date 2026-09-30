# 03_derived: Derived Indices / 衍生指标

This directory contains participant-level behavioral indices for the three behavioral tasks under positive conditions, derived from the cleaned data.

本目录包含三个行为任务在积极条件下的参与者层面行为指标，基于清洗后数据计算得到。

## Files / 文件

| File / 文件 | Description / 说明 |
|---|---|
| `positive_IAT.csv` | Two participant-level IAT D-score variables: `ability_IAT` and `moral_IAT` / 两个参与者层面的 IAT D 分数变量：`ability_IAT` 和 `moral_IAT` |
| `positive_SMT.csv` | Eight SMT indices: four sensitivity-based indices and four reaction-time-based indices across competence/morality and positive valence / 8 个 SMT 指标：能力/道德领域积极条件下的 4 个敏感性指标和 4 个反应时指标 |
| `positive_SRET.csv` | Sixteen SRET encoding, recognition, source-memory, and reaction-time indices / 16 个 SRET 编码、再认、来源记忆和反应时指标 |
| `positive_self_view_indices.csv` | Merged participant-level behavioral indices for the 503 participants with complete data / 合并的 503 名完整数据参与者的行为任务指标 |


## IAT D-score calculation / IAT D 分数计算

The IAT analysis retains Blocks 3, 4, 6, and 7. Trials with reaction times greater than 10,000 ms are removed, and a participant is excluded when more than 10% of the remaining trials have reaction times of 300 ms or less. Incorrect-trial reaction times are replaced with the corresponding block mean plus 600 ms.

IAT 分析保留第 3、4、6 和 7 区块。删除反应时大于 10,000 ms 的试次；如果剩余试次中反应时不超过 300 ms 的比例大于 10%，则排除该参与者。错误试次的反应时替换为相应区块均值加 600 ms。

For each participant and domain, let A1 and A2 denote the compatible blocks and B1 and B2 the incompatible blocks. The two standardized contrasts are:

对于每名参与者和每个领域，令 A1、A2 表示相容区块，B1、B2 表示不相容区块。两个标准化差异为：

```text
diff_B1A1 = mean_rt_B1 - mean_rt_A1
diff_B2A2 = mean_rt_B2 - mean_rt_A2
D = [(diff_B1A1 / SD_B1A1) + (diff_B2A2 / SD_B2A2)] / 2
```

The inclusive standard deviations combine the two blocks in each contrast, including the between-block mean difference:

综合标准差使用每一组对比中的两个区块，并纳入区块均值差异：

```text
SD_B1A1 = sqrt(((n_A1-1)s_A1^2 + (n_B1-1)s_B1^2
                + (n_A1+n_B1)(mean_A1-mean_B1)^2/4)
               /(n_A1+n_B1-1))
```

`SD_B2A2` is computed analogously using A2 and B2.

`SD_B2A2` 使用 A2 和 B2 按同样公式计算。

### Worked example / 计算示例

The following is a numerical example showing the calculation for one domain. It is an illustration of the algorithm rather than a claim about a particular participant.

以下为一个领域的数值计算示例，用于展示算法，不代表某一具体参与者的实际结果。

| Quantity / 项目 | A1 | B1 | A2 | B2 |
|---|---|---:|---:|---:|
| Mean RT (ms) / 平均反应时（ms） | 600 | 800 | 620 | 850 |
| SD (ms) / 标准差（ms） | 100 | 120 | 110 | 130 |
| Number of trials / 试次数 | 40 | 40 | 40 | 40 |

```text
diff_B1A1 = 800 - 600 = 200 ms
diff_B2A2 = 850 - 620 = 230 ms

SD_B1A1 = 148.903 ms
SD_B2A2 = 166.460 ms

D = [(200 / 148.903) + (230 / 166.460)] / 2
  = (1.343 + 1.382) / 2
  = 1.362
```

Thus, the illustrative IAT D score is 1.362. In the supplied derived file, the two retained domain-specific variables are `ability_IAT` and `moral_IAT` in `positive_IAT.csv`.

因此，该示例的 IAT D 分数为 1.362。在所提供的衍生文件中，保留的两个领域特异性变量是 `positive_IAT.csv` 中的 `ability_IAT` 和 `moral_IAT`。

## SMT indices / SMT 指标

The manuscript calls this task the Self-Matching Task (SMT). The analysis code uses the historical name ALT. The eight released indices were derived from the self-referential version administered on Day 3 (ALT2); the geometric-shape version administered on Day 2 (ALT1) was used for quality control and its indices are not part of the 26 manuscript indices. `positive_SMT.csv` contains the eight retained SMT variables: `SMT_d_ability_negative`, `SMT_d_ability_positive`, `SMT_d_moral_negative`, `SMT_d_moral_positive`, `SMT_rt_ability_negative`, `SMT_rt_ability_positive`, `SMT_rt_moral_negative`, and `SMT_rt_moral_positive`.

论文将该任务称为自我匹配任务（SMT），分析代码使用历史名称 ALT。发布的 8 个指标来自 Day 3 施测的自我参照版（ALT2）；Day 2 施测的几何图形版（ALT1）数据用于质量控制，其指标不包含在论文的 26 个指标中。`positive_SMT.csv` 包含 8 个保留的 SMT 变量：`SMT_d_ability_negative`、`SMT_d_ability_positive`、`SMT_d_moral_negative`、`SMT_d_moral_positive`、`SMT_rt_ability_negative`、`SMT_rt_ability_positive`、`SMT_rt_moral_negative` 和 `SMT_rt_moral_positive`。

## SRET indices / SRET 指标

`positive_SRET.csv` contains 16 retained SRET variables covering encoding endorsement, encoding reaction time, recognition, and source memory across competence/morality and positive/negative valence conditions.

### Variable naming / 变量命名

The released variable names use the historical code labels, which map onto the manuscript names as follows (`ability` = competence, `moral` = morality; full definitions in `codebook_variable_mapping.csv` at the dataset root): `ability_IAT`/`moral_IAT` → `IAT_competence`/`IAT_morality`; `SMT_d_*`/`SMT_rt_*` → `SMT_d_*`/`SMT_RT_*`; `SRET_yes_*` → `SRET_encoding_endorsement_*` (encoding phase, EW = formal word-evaluation screen); `SRET_rt_*` → `SRET_encoding_RT_*`; `REC_*` → `SRET_RJ1_*` (first recognition judgment, new/familiar/old); `SOURCE_*` → `SRET_RJ2_*` (source-memory judgment, self vs. friend).

发布变量名使用历史代码标签，与论文命名的对应关系如下（`ability` = 能力域，`moral` = 道德域；完整定义见数据集根目录 `codebook_variable_mapping.csv`）：`ability_IAT`/`moral_IAT` → `IAT_competence`/`IAT_morality`；`SMT_d_*`/`SMT_rt_*` → `SMT_d_*`/`SMT_RT_*`；`SRET_yes_*` → `SRET_encoding_endorsement_*`（编码阶段，EW = 正式词评价屏）；`SRET_rt_*` → `SRET_encoding_RT_*`；`REC_*` → `SRET_RJ1_*`（第一次再认判断：新/熟悉/旧）；`SOURCE_*` → `SRET_RJ2_*`（来源记忆判断：自己 vs. 朋友）。

`positive_SRET.csv` 包含 16 个 SRET 指标，覆盖能力/道德领域和正/负效价条件下的编码认可、编码反应时、再认和来源记忆指标。