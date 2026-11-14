# 03_derived：02清洗数据的派生指标

公开文件仅保留随机生成的 `public_id`，不包含原始实验ID或平台身份标识。

## CSV内容

| 文件 | 内容 |
|---|---|
| positive_IAT.csv | 602人，2指标 |
| positive_SMT.csv | 557人，8指标，来自SMT2而非SMT1 |
| positive_SRET.csv | 482人，16指标 |
| questionnaire_indices_day1.csv | 606人，Day1量表总分及既有分类，含ID共6列 |
| questionnaire_indices_day2.csv | 606人，Day2量表总分，含ID共6列 |
| questionnaire_indices_day3.csv | 571人，Day3量表总分，含ID共8列 |
| questionnaire_indices_day10.csv | 512人，重测量表总分、既有分类及领域评分，含ID共24列 |
| questionnaire_indices_all_sessions.csv | 606人，合并Day1/2/3/10问卷总分及相关字段，含ID共41列 |
| all_derived_indices.csv | 606人，public_id + 160个首次测量问卷条目 + 26个行为指标，共187列 |


## 问卷条目及样本

| 场次 | 量表及条目数 | 每项有效人数 |
|---|---|---:|
| Day1 | selfclarity 12、PHQ 9、GAD 7，共28项 | 606 |
| Day2 | SES 10、coreself 10、SGPS 9、NPI 15，共44项 | 606 |
| Day2 | HSNS/HNS 10项 | 581 |
| Day3 | SWB 5、LOT 6、IPC 8、MorIden 10、moralSeImag 9、SDE 20、IM 20，共78项 | 571 |

首次测量共15份量表、160项。继承02已清洗分数，不重复反向计分。总分要求整份量表条目完整，IPC条目和加24。NPI实际15项，不补造第16项。Day10另含5项domain_rating，放在重测补充总分文件中。


## 行为指标定义

- IAT：错误试次RT替换为该public_id×领域×区块的正确试次RT均值+600ms。分别计算A1/B1及A2/B2原始RT合并后的样本SD，分子使用替换后的区块平均RT差(B−A)，最后平均两个D值。
- SMT2 RT：匹配试次mean RT(self)−mean RT(friend)，包括02保留的正确与错误试次。SMT2 d′：d′(self)−d′(friend)，同领域同效价的全部不匹配试次作为双方共享噪声。
- SRET yes：P(yes|self)−P(yes|friend)，每个人物条件的分母为有效yes/no作答数，未作答不计为no。SRET RT：mean RT(self)−mean RT(friend)，使用各条件可用RT。
- REC：d′(self)−d′(friend)，新词噪声共享，familiar/old都作为再认反应。
- SOURCE：self正确/错误为H/M，friend正确/错误为CR/FA，计算单一来源辨别d′，不再做self−friend。正值表示来源辨别优于机会水平，不表示自我来源记忆优势。

d′采用Rmd的loglinear校正：qnorm((H+0.5)/(H+M+1)) − qnorm((FA+0.5)/(FA+CR+1))。条件组存在但某一类计数为0时，仍按Rmd进行0.5校正；完全没有可计分试次的条件不伪造数据，指标留NA。

2026-11-12依据文稿及用户确认更新，当前重算代码在analysis.Rmd第10节。保持原始指标单位，未实施Z标准化；160项问卷保留，135项清单尚待确认。样本筛选不变。SRET有6人的SOURCE_morality_Negative保持缺失，482人中476人16项均完整。文稿中的旧描述性统计、相关分析及图表尚未用本次新指标更新。
