# 02_cleaned：606人池内按任务／问卷独立清洗

更新：2026-10-22。总被试池为04中 `retained_606_IDs.csv` 的606个ID。
各任务分别决定有效性；一项任务失败不删除此人的其他有效任务或问卷。
所有文件的ID均为606池的子集；Day1问卷覆盖全池。

| 文件 | 有效被试数 | 数据行数 |
|---|---:|---:|
| IAT_cleaned.csv | 602 | 173343 |
| SMT_1_cleaned.zip | 565 | 431382 |
| SMT_2_cleaned.zip | 557 | 421695 |
| SRET_cleaned.csv | 483 | 161075 |
| questionnaires_day1_cleaned.csv | 606 | 606 |
| questionnaires_day2_cleaned.csv | 606 | 606 |
| questionnaires_day3_cleaned.csv | 571 | 571 |
| questionnaires_day10_cleaned.csv | 512 | 512 |

ZIP内分别为同名CSV。CSV为UTF-8 BOM编码。延续Day10重测命名，未改为Day4。

## 行为任务

全部行为任务从 `01_raw_old` 重算，不使用当前 `01_raw`。

- IAT：使用旧版 `IAT_raw.csv`，按领域计算RT≤300ms占RT≤10000ms试次比例，任一领域>10%时该任务整人无效。分析区块3、4、6、7，剔除RT>10000ms和缺失RT。保留错误试次用于后续D分数误差惩罚。先从指导记录提取版本信息，再保留A1/A2/B1/B2区块编码；保留原screen_id并提供block同义列。
- SMT1：旧版 `SMT_1_raw.csv`，正式阶段按con×conditionType计算准确率（正确且200–1200ms／该条件全部试次），任一条件<60%无效；再保留有效人的200–1200ms正式试次，错误试次保留。565人。
- SMT2：使用旧版 `questionnaires_day3_raw.zip` 中的正式SMT2试次。其中文条件完整，避免旧版独立SMT2压缩表中的乱码。按领域×人物×匹配状态×效价检验条件准确率≥20%，领域准确率≥60%；分母为全部正式试次，分子为正确且200–1200ms。筛人后保留200–1200ms试次，错误试次保留。557人。
- SRET：旧版 `SRET_raw.csv`，再认正确率≥55%、来源RT<200ms比例≤30%。采用用户指定483人口径：缺失再认反应按未答对处理，保留完整分母。`phase_017_subj_16` 为109/160正确，1条反应缺失；仍保留，并以 `recognition_response_missing` 和 `recognition_scoring_correct` 标记，不伪造反应。保留EW_formal、RJ_formal1、RJ_formal_2；删除EW首尾干扰词及再认/来源练习词。两名特殊被试及缺失person的修补按04分析思路用ID+word键对应，不按行号填充。源RT不强加SMT的200–1200ms窗口。

各任务判据在删除试次之前计算；不要在输出的RT筛选后试次上重算相同排除比例并期望相同分母。原始判据分母和逐人记录保存在04的审计目录。

## 问卷

按用户要求延续原02问卷清洗版本及04的条目选择/完整量表计分思路，不重新反向计分或按全场完整案例删人。**问卷不是从旧raw独立重建**：旧版基线没有统一ID，旧版第二场混合导出也缺少部分ID；因此使用本次替换前备份中的原问卷清洗表。精确来源和MD5见审计目录。

- Day1：selfclarity、PHQ、GAD各606。
- Day2：SES、coreself、SGPS、NPI各606；HSNS/HNS为581。
- Day3：SWB、LOT、IPC、MorIden、moralSeImag、SDE、IM各571。
- Day10：全部上述量表及domain_rating各512。

每份量表增加 `valid_量表名` 布尔列。任一条目缺失则该量表无效：25名Day2 HSNS不完整者的10项HSNS条目整体置为空，保留其其他有效问卷及被试行。原部分作答仍在备份中，可恢复。`questionnaire_source`注明来自原问卷清洗版本。这里的有效性指条目完整，不新增未经授权的反应时、极端分或一致性筛除。

NPI保持原04代码的NPI1–NPI15共15列，不能因量表名称写作NPI-16而补造第16项。

## 备份、复现及未更新范围

替换前02的全部13个文件已备份到：
`../04_code_and_reproducibility/subject _screening1/archive/audit/cleaning_606_audit/backup_02_cleaned_20261022_153757/`。
02目录已移除4个重复 `_pertask` 文件，原文件可从该备份恢复。02现在只保留8个规范命名的数据文件和本说明。

审计目录：`../04_code_and_reproducibility/subject _screening1/archive/audit/cleaning_606_audit/`，包含逐任务质量指标、606人任务有效标记、问卷有效标记、文件人数及逐量表人数、来源MD5和安装记录。

项目根目录运行：
`Rscript "04_code_and_reproducibility/subject _screening1/archive/code/rebuild_cleaned_old_raw.R"` 仅生成暂存结果并核验；添加 `--install` 才备份并替换02。
`Rscript "04_code_and_reproducibility/subject _screening1/archive/code/validate_cleaned_old_raw.R"` 核验已安装02。

01_raw、01_raw_old、原606/466名单和171排除表未修改。03_derived已由04的analysis/analysis.Rmd第9节重算，并按要求保留9个CSV；根目录valid_data.csv未同步重算。当前有效ID核对表见04的subject _screening1/archive。旧版既有ID分配沿用授权口径，本次没有宣称完成所有历史身份冲突的独立解决。
