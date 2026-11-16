# 03_derived：Ddrived Indicator / 派生指标

Public documents only keep a randomly generated `public_id` and don’t include the original experiment ID or platform identity.
公开文件仅保留随机生成的 `public_id`，不包含原始实验ID或平台身份标识。

## Content of CSV / CSV内容

| 文件 | 内容 |
| file | Content |
| positive_IAT.csv | 602人，2指标 / 602 people, 2 indicators |
| positive_SMT.csv | 557人，8指标 / 557 people, 8 indicators |
| positive_SRET.csv | 482人，16指标 / 482 people, 16 indicators |
| questionnaire_indices_day1.csv | 606人，Day1量表总分及既有分类 / 606 people, Day 1 total scale scores and existing categories |
| questionnaire_indices_day2.csv | 606人，Day2量表总分 / 606 people, Day 2 total scale scores |
| questionnaire_indices_day3.csv | 571人，Day3量表总分 / 571 people, Day 3 total scale scores  |
| questionnaire_indices_day10.csv | 512人，重测量表总分、既有分类及领域评分 / 512 people, retest total scale scores, existing categories, and domain scores |
| questionnaire_indices_all_sessions.csv | 606人，合并Day1/2/3/10问卷总分及相关字段 / 606 people, combined Day 1/2/3/10 questionnaire total scores and related fields |
| all_derived_indices.csv | 606人，public_id + 首次测量问卷条目 + 行为指标 / 606 people, public_id + first-time questionnaire items + behavioral indicators |


## 问卷条目及样本

| 场次 | 量表及条目数 | 每项有效人数 |
|---|---|---:|
| Day1 | selfclarity 12、PHQ 9、GAD 7 | 606 |
| Day2 | SES 10、coreself 10、SGPS 9、NPI 15 | 606 |
| Day2 | HSNS/HNS | 581 |
| Day3 | SWB 5、LOT 6、IPC 8、MorIden 10、moralSeImag 9、SDE 20、IM 20 | 571 |

计算依据02已清洗分数，不重复反向计分。总分要求整份量表条目完整。Day10另含5项domain_rating，放在重测补充总分文件中。

The calculation is based on Version 02 cleaned scores, without double reverse scoring. The total score requires all items on the full scale to be complete. Day 10 also includes 5 domain_rating items, which are placed in the retest supplemental total score file.


## 行为指标定义

- IAT：错误试次RT替换为该public_id×领域×区块的正确试次RT均值+600ms。分别计算A1/B1及A2/B2原始RT合并后的样本SD，分子使用替换后的区块平均RT差(B−A)，最后平均两个D值。
- SMT2 RT：匹配试次mean RT(self)−mean RT(friend)，包括02保留的正确与错误试次。SMT2 d′：d′(self)−d′(friend)，同领域同效价的全部不匹配试次作为双方共享噪声。
- SRET yes：P(yes|self)−P(yes|friend)，每个人物条件的分母为有效yes/no作答数，未作答不计为no。SRET RT：mean RT(self)−mean RT(friend)，使用各条件可用RT。
- REC：d′(self)−d′(friend)，新词噪声共享，familiar/old都作为再认反应。
- SOURCE：self正确/错误为H/M，friend正确/错误为CR/FA，计算单一来源辨别d′，不再做self−friend。正值表示来源辨别优于机会水平，不表示自我来源记忆优势。
- d′采用Rmd的loglinear校正：qnorm((H+0.5)/(H+M+1)) − qnorm((FA+0.5)/(FA+CR+1))。条件组存在但某一类计数为0时，仍按Rmd进行0.5校正；完全没有可计分试次的指标为NA。

- IAT: Error trial RTs are replaced with the mean RT of correct trials for that public_id × domain × block + 600 ms. Then, calculate the sample SDs for the combined original RTs of A1/B1 and A2/B2, the numerator uses the replaced block mean RT difference (B−A), and finally, average the two D values.  
- SMT2 RT: Mean RT difference for matching trials (self) − mean RT (friend), including correctly and incorrectly retained 02 trials. SMT2 d′: d′(self) − d′(friend), all unmatched trials in the same domain and valence are considered shared noise.  
- SRET yes: P(yes|self) − P(yes|friend); for each character condition, the denominator is the number of valid yes/no responses, unanswered trials are not counted as no. SRET RT: mean RT(self) − mean RT(friend), using available RTs for each condition.  
- REC: d′(self) − d′(friend), new word noise is shared, both familiar/old are treated as recognition responses.  
- SOURCE: self correct/error as H/M, friend correct/error as CR/FA, calculate single-source discrimination d′, no longer doing self−friend. Positive values indicate source discrimination above chance, not self-source memory superiority.
- d′ uses Rmd’s loglinear correction: qnorm((H+0.5)/(H+M+1)) − qnorm((FA+0.5)/(FA+CR+1)). If a condition group exists but a category has 0 count, still apply 0.5 correction per Rmd; indicators without any scorable trials are NA.

