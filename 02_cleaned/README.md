# 02_cleaned：Task / Questionnaire Cleaning / 任务/问卷清洗

公开文件仅保留随机生成的 `public_id`。原始实验ID、平台用户编号、平台追踪字段和直接身份标识已删除。清洗后总被试池为606人。
各任务分别决定有效性；一项任务失败不删除此人的其他有效任务或问卷。
所有文件的ID均为606池的子集；Day1问卷覆盖全池。

The public files only keep the randomly generated `public_id`. The original experiment ID, platform user number, tracking fields, and direct identifiers have all been removed. After cleaning, there are 606 participants in total.
Each task has its own validity check; if someone fails a task, their data from other valid tasks or surveys isn’t deleted.
All file IDs are subsets of the 606-person pool; the Day 1 survey covers the entire pool.

| 文件 | 有效被试数 | 数据行数 |
|file |valid subjects|data rows|
| IAT_cleaned.csv | 602 | 173343 |
| SMT_1_cleaned.zip | 565 | 431382 |
| SMT_2_cleaned.zip | 557 | 421695 |
| SRET_cleaned.csv | 482 | 160720 |
| questionnaires_day1_cleaned.csv | 606 | 606 |
| questionnaires_day2_cleaned.csv | 606 | 606 |
| questionnaires_day3_cleaned.csv | 571 | 571 |
| questionnaires_day10_cleaned.csv | 512 | 512 |


## Behavior Task / 行为任务

- IAT：使用`IAT_raw.csv`，按领域计算RT≤300ms占RT≤10000ms试次比例，任一领域>10%时该任务整人无效。分析区块3、4、6、7，剔除RT>10000ms和缺失RT。保留错误试次用于后续D分数误差惩罚。先从指导记录提取版本信息，再保留A1/A2/B1/B2区块编码；保留原screen_id并提供block同义列。
- SMT1：使用 `SMT_1_raw.csv`，正式阶段按con×conditionType计算准确率（正确且200–1200ms／该条件全部试次），任一条件<60%无效；再保留有效人的200–1200ms正式试次，错误试次保留。565人。
- SMT2：使用 `questionnaires_day3_raw.zip` 中的正式SMT2试次。其中文条件完整，避免旧版独立SMT2压缩表中的乱码。按领域×人物×匹配状态×效价检验条件准确率≥20%，领域准确率≥60%；分母为全部正式试次，分子为正确且200–1200ms。筛人后保留200–1200ms试次，错误试次保留。557人。
- SRET：使用 `SRET_raw.csv`，再认正确率≥55%、来源RT<200ms比例≤30%。482人。
- Day1：selfclarity、PHQ、GAD各606。
- Day2：SES、coreself、SGPS、NPI各606；HSNS/HNS为581。
- Day3：SWLS、LOT、IPC、MorIden、moralSeImag、SDE、IM各571。
- Day10：全部上述量表及domain_rating各512。

- IAT: Use `IAT_raw.csv` and calculate the proportion of trials with RT ≤ 300ms out of those with RT ≤ 10000ms by domain. If any domain exceeds 10%, that participant is considered invalid for this task. Analyze blocks 3, 4, 6, 7, excluding trials with RT > 10000ms or missing RT. Keep error trials for subsequent D-score error penalties. First, extract version info from the instruction records, then keep block codes A1/A2/B1/B2; retain the original screen_id and provide a block synonym column. 
- SMT1: Use `SMT_1_raw.csv`. In the official phase, calculate accuracy by con × conditionType (correct and 200–1200ms / all trials in that condition). If any condition is <60%, the participant is invalid. Keep valid participants’ 200–1200ms official trials, keeping error trials as well. 565 participants. 
- SMT2: Use the official SMT2 trials in `questionnaires_day3_raw.zip`. The Chinese conditions are complete, avoiding garbled data from the old independent SMT2 compressed table. Check accuracy by domain × character × match status × valence, requiring ≥20% per condition and ≥60% per domain (denominator = all official trials, numerator = correct and 200–1200ms). After filtering, keep 200–1200ms trials for valid participants, keeping error trials. 557 participants. 
- SRET: Use `SRET_raw.csv`, with recognition accuracy ≥55% and proportion of source RT <200ms ≤30%. 482 participants. 
- Day1: selfclarity, PHQ, GAD each 606. 
- Day2: SES, coreself, SGPS, NPI each 606; HSNS/HNS 581. 
- Day3: SWLS, LOT, IPC, MorIden, moralSeImag, SDE, IM each 571. 
- Day10: All the above scales and domain_rating 512.


## Backup, Reproduction, and Unupdated Scope / 备份、复现及未更新范围

审计目录：`../04_code_and_reproducibility/subject _screening，包含逐任务质量指标、606人任务有效标记、问卷有效标记、文件人数及逐量表人数。
Audit directory: `../04_code_and_reproducibility/subject_screening`, includes quality metrics per task, 606 valid task marks, valid questionnaire marks, number of people per file, and number of people per scale.

