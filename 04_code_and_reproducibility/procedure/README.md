# Procedure: Experimental Scripts / 实验程序

This directory contains the jsPsych experimental programs for the four data-collection sessions (Day 1, Day 2, Day 3, Day 10). Only materials directly related to this dataset are retained.

本目录包含四个测试日（Day 1、Day 2、Day 3、Day 10）施测所用的 jsPsych 实验程序，仅保留与本数据库直接相关的内容。

## Structure / 目录结构

### day1/ — Day 1 session / Day 1 筛查日
知情同意 + 人口学 + SCC + PHQ + GAD（三个问卷）：`github.js`、`index.html`、`initJspsy0.js`、`img/ses.png`、`self-report/`（jquery、plugin-survey-multi-choice、plugin-survey-template copy）、`surveys/`（demographics、gad7、phq9、plugin-survey-likert、plugin-survey、selfclarity）

### day2/ — Day 2 session / Day 2 施测
问卷（RSES、CSES、NPI-16、HNS、SGPS）+ IAT + SMT 几何图形版：`github.js`、`SMT_1.js`、`IAT.js`、`index.html`、`initJspsy.js`、`img/`（12 张形状图）、`self-report/`（shuffle-seed.js / shuffle-seed.min.js）、`surveys/`（selfesteem、coreself、NPI、hsns、SGPS）

### day3/ — Day 3 session / Day 3 施测
问卷（SWLS、IPC-I、LOT-R、MIS、MSIS、SDE、IM）+ SRET + SMT 自我参照版：`github.js`、`SMT_2.js`、`index.html`、`initJspsy2.js`、`img/`（12 张形状图）、`self-report/`（shuffle-seed、shuffle-seed.min、SRET_eval）、`surveys/`（bogus_items、IM、IPC、LOT、moralidentity、moralSelfimage、plugin-survey、sde、SWB）

### day10/ — Day 10 retest / Day 10 重测
全量问卷重测，无行为任务：`index.html`、`initJspsy2.js`、`self-report/`（plugin-survey-template、jquery、plugin-survey-multi-choice）、`surveys/`（domain_rating、IM、IPC、LOT、moralidentity、moralSelfimage、plugin-survey、sde、SWB、gad7、phq9、plugin-survey-likert、selfclarity、selfesteem、coreself、NPI、hsns、SGPS）

## Notes / 说明

- Data files for the behavioral tasks and questionnaires are stored separately under `01_raw/`, `02_cleaned/`, and `03_derived/`; this folder only contains the experimental scripts.

  数据文件（行为任务与问卷）分别存放于 `01_raw/`、`02_cleaned/`、`03_derived/`，本目录仅包含实验程序脚本。

- 本地运行需注释掉哪些内容：本地运行时请按需注释与正式部署相关的加载项（如 extension_naodao、jspsych 云端依赖等），避免影响程序中的引用。

  Local running note: when running locally, comment out the deployment-related entries as needed, to avoid breaking references within the programs.