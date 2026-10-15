## =====================================================================
## 生成两张详细记录表（不改动任何原有文件）：
##  (1) excluded_subjects_171.csv    —— 被排除被试（第二层 171 人；第一层记录已随 raw 清理移除，不再列入）
##  (2) invalidated_task_data_140.csv —— 任务数据有问题但“人保留”者（第三层 139 + 仅缺第4次 1 = 140）
##  第 3 次后未参加第 4 次者保留，计入 invalidated_task_data_140.csv，不作为第二层排除。
##  排除被试 171；791 - 14 - 171 = 606 人保留；606 - 140 = 466 完整数据。
## 判据实现沿用 excluded_record/exclusion_pipeline.qmd（D12：analysis.Rmd 为权威）
## =====================================================================
suppressPackageStartupMessages({ library(data.table); library(readr) })
## 固定 UTF-8：SRET/ALT2 判据依赖中文字符串，C/POSIX locale 下会少判（70->63, 14->10）
Sys.setlocale("LC_ALL", "en_US.UTF-8")

ROOT <- "/Users/sunxinru/Desktop/PSV_Dataset"
P <- function(...) file.path(ROOT, ...)

fread_utf8 <- function(path, select = NULL, ...)
  data.table::fread(path, select = select, encoding = "UTF-8",
                    showProgress = FALSE, na.strings = c("", "NA"), ...)
fread_zip <- function(zip, select = NULL, enc = "UTF-8")
  data.table::fread(cmd = paste("unzip -p", shQuote(zip)), select = select,
                    encoding = enc, showProgress = FALSE, na.strings = c("", "NA"))
ids_of <- function(path, col = "ID") {
  x <- data.table::fread(path, select = col, encoding = "UTF-8",
                         showProgress = FALSE, na.strings = character(0))[[col]]
  x <- trimws(as.character(x)); unique(x[!is.na(x) & x != ""])
}
ids_of_zip <- function(zip, col = "ID") {
  inner <- utils::unzip(zip, list = TRUE)$Name[1]
  x <- suppressMessages(readr::read_csv(unz(zip, inner), col_select = tidyselect::all_of(col),
                                        show_col_types = FALSE, progress = FALSE))
  v <- trimws(as.character(x[[col]])); unique(v[!is.na(v) & v != ""])
}

## ---- 常量 ----
AGE_MIN <- 18; AGE_MAX <- 59
IAT_LONG <- 10000; IAT_SHORT <- 300; IAT_PROP <- 0.1
ALT1_ACC <- 0.6
ALT2_ACC <- 0.2; ALT2_DOMAIN_ACC <- 0.6
SRET_REC <- 0.55; SRET_SRC_PROP <- 0.3; SRET_SRC_RT <- 200
RT_MIN <- 200; RT_MAX <- 1200
FILLER_RJ <- c("严谨", "认真", "刻板", "白痴", "忠实", "宽宏", "徇私", "可鄙")

DAY_FILES <- c(D1  = P("02_cleaned_author_full/questionnaires_day1_cleaned.csv"),
                D2  = P("02_cleaned_author_full/questionnaires_day2_cleaned.csv"),
                D3  = P("02_cleaned_author_full/questionnaires_day3_cleaned.csv"),
                D10 = P("02_cleaned_author_full/questionnaires_day10_cleaned.csv"))
PATH_IAT_RAW <- P("01_raw/IAT_raw.csv"); PATH_SMT1 <- P("01_raw/SMT_1_raw.csv")
PATH_SRET <- P("01_raw/SRET_raw.csv"); PATH_SMT2_ZIP <- P("02_cleaned_author_full/SMT_2_cleaned.zip")
PATH_ZIP_D2 <- P("01_raw/questionnaires_day2_raw.zip")
PATH_ZIP_D3 <- P("01_raw/questionnaires_day3_raw.zip")

## ---- 样本与出席 ----
D1  <- ids_of(DAY_FILES["D1"]); D2q <- ids_of(DAY_FILES["D2"])
D3q <- ids_of(DAY_FILES["D3"]); D10q <- ids_of(DAY_FILES["D10"])
IAT_IDS  <- ids_of(PATH_IAT_RAW); ALT1_IDS <- ids_of(PATH_SMT1)
SRET_ALL <- ids_of(PATH_SRET); SRET_IDS <- setdiff(SRET_ALL, "NA")
ALT2_ALL <- fread_zip(PATH_ZIP_D3, select = c("ID","screen_id","condition","rt","correct","identity"))
ALT2_FORMAL <- ALT2_ALL[screen_id %in% c("ability","moral")]
ALT2_FORMAL[, `:=`(domain_d = screen_id,
                   person_d  = fifelse(endsWith(condition, "我"), "self", "friend"),
                   valence_d = fifelse(substr(condition, 1, 1) %in% c("好","强"), "positive", "negative"))]
ALT2_IDS <- unique(ALT2_FORMAL$ID[!is.na(ALT2_FORMAL$ID)])
FINAL503 <- ids_of_zip(PATH_SMT2_ZIP)
INITIAL_SAMPLE <- sort(unique(c(D1, IAT_IDS, ALT1_IDS, SRET_ALL, ALT2_IDS)))
S1 <- D1; S2 <- union(D2q, union(IAT_IDS, ALT1_IDS))
S3 <- union(D3q, union(SRET_IDS, ALT2_IDS)); S4 <- D10q
ALL4 <- Reduce(intersect, list(S1, S2, S3, S4))

## ---- 逐人指标 ----
day1 <- fread_utf8(DAY_FILES["D1"], select = c("ID","ParticipantID","age","sex"))
day1[, age_num := suppressWarnings(as.numeric(age))]
m_age <- day1[, .(ID, ParticipantID = as.character(ParticipantID), age_num = age_num)]

d1raw <- fread_utf8(P("01_raw/questionnaires_day1_raw.csv"), select = c("ParticipantID","honeypot"))
d1raw[, `:=`(honeypot_num = suppressWarnings(as.numeric(honeypot)), ParticipantID = as.character(ParticipantID))]
m_honey_pid <- d1raw[, .(honeypot_num = max(honeypot_num, na.rm = TRUE)), by = ParticipantID]
day1[, ParticipantID := as.character(ParticipantID)]
pid2id_d1 <- unique(day1[!is.na(ParticipantID), .(ParticipantID, ID)])
m_honey <- merge(pid2id_d1, m_honey_pid, by = "ParticipantID", all.x = TRUE)[, .(ID, honeypot_num)]

iat <- fread_utf8(PATH_IAT_RAW, select = c("ID","ParticipantID","screen_id","task_id","rt","RT","response","correct","word","condition"))
iat_trials <- iat[screen_id %in% c("3","4","6","7")]; iat_trials[, rt := suppressWarnings(as.numeric(rt))]
m_iat <- iat_trials[, .(rt_les300 = sum(rt <= IAT_SHORT, na.rm = TRUE),
                        row_count = sum(rt <= IAT_LONG, na.rm = TRUE)), by = .(ID, task_id)]
m_iat[, proportion := rt_les300 / row_count]
m_iat <- m_iat[, .(iat_prop = max(proportion), iat_task = task_id[which.max(proportion)],
                   iat_n = row_count[which.max(proportion)]), by = ID]

alt1 <- fread_utf8(PATH_SMT1, select = c("ID","screen_id","con","conditionType","rt","correct"))
alt1 <- alt1[screen_id %in% c("formal_ALT1_1","formal_ALT1_2")]; alt1[, rt := suppressWarnings(as.numeric(rt))]
alt1[, cor := fifelse(tolower(correct)=="true",1L, fifelse(tolower(correct)=="false",0L, NA_integer_))]
alt1_qc <- alt1[, .(n=.N, ncor=sum(cor==1 & rt>=RT_MIN & rt<=RT_MAX, na.rm=TRUE)), by=.(ID,con,conditionType)]
alt1_qc[, acc := ncor/n]
m_alt1 <- alt1_qc[, .(alt1_min_acc = min(acc), alt1_cond = con[which.min(acc)], alt1_n = n[which.min(acc)]), by=ID]

t1raw <- fread_zip(PATH_ZIP_D2, select = c("ID","trial_index","trial_type","trap1","correct_answer","correct","trap1_item"))
t1 <- t1raw[trial_type=="survey-template" & !is.na(correct_answer) & !is.na(ID)]
setorder(t1, ID, trial_index)
m_trap1 <- t1[, .SD[1], by = ID][, .(ID, trap1_obs = trap1, trap1_ans = correct_answer,
                                     trap1_pass = correct, trap1_item)]

sret <- fread_utf8(PATH_SRET, select = c("ID","screen_id","word","identity","responses","person","rt","correct"))
sret[, rt := suppressWarnings(as.numeric(rt))]
rj1 <- sret[screen_id=="RJ_formal1" & !(word %in% FILLER_RJ)]
rj1[, sdt := fcase(identity=="old" & responses %in% c("familiar","old"),"H",
                   identity=="old" & responses=="new","M",
                   identity=="new" & responses %in% c("familiar","old"),"FA",
                   identity=="new" & responses=="new","CR", default=NA_character_)]
m_sret_rec <- rj1[, .(H=sum(sdt=="H"),M=sum(sdt=="M"),FA=sum(sdt=="FA"),CR=sum(sdt=="CR")), by=ID][
                  , .(ID, sret_recognition = (H+CR)/(H+CR+M+FA), sret_n = H+M+FA+CR)]
rj2 <- sret[screen_id=="RJ_formal_2" & !(word %in% FILLER_RJ)]
m_sret_src <- rj2[, .(n=.N, less200=sum(rt < SRET_SRC_RT, na.rm=TRUE)), by=ID][
                  , .(ID, sret_src_prop = less200/n, sret_src_n = n)]

alt2 <- copy(ALT2_FORMAL)
alt2[, `:=`(rt=suppressWarnings(as.numeric(rt)), correct=suppressWarnings(as.numeric(correct)))]
alt2[is.na(correct), correct := 0]
alt2[, ok := as.integer(correct==1 & !is.na(rt) & rt>=RT_MIN & rt<=RT_MAX)]
a2c1 <- alt2[, .(n=.N, ncor=sum(ok,na.rm=TRUE)), by=.(ID,domain_d,person_d,identity,valence_d)][, acc:=ncor/n]
a2c2 <- alt2[, .(n=.N, ncor=sum(ok,na.rm=TRUE)), by=.(ID,domain_d)][, acc:=ncor/n]
m_alt2c <- a2c1[, .(alt2_min_cond = min(acc), alt2_cond = paste(domain_d,person_d,identity,valence_d,sep="_")[which.min(acc)]), by=ID]
m_alt2d <- a2c2[, .(alt2_min_domain = min(acc), alt2_domain = domain_d[which.min(acc)]), by=ID]
m_alt2 <- merge(m_alt2c, m_alt2d, by="ID", all=TRUE)

t2raw <- fread_zip(PATH_ZIP_D3, select = c("ID","trial_index","trial_type","trap2","trap2_item"))
t2 <- t2raw[trial_type=="survey-template" & !is.na(trap2_item) & !is.na(ID)]
setorder(t2, ID, trial_index)
m_trap2 <- t2[, .SD[1], by=ID][, .(ID, trap2_obs = trap2, trap2_item)]

M <- data.table(ID = INITIAL_SAMPLE)
for (mm in list(m_age, m_honey, m_iat, m_alt1, m_trap1, m_sret_rec, m_sret_src, m_alt2, m_trap2)) {
  if (!"ID" %in% names(mm)) next
  M <- merge(M, mm, by = "ID", all.x = TRUE)
}
pid_extra <- unique(iat[!is.na(ParticipantID) & !is.na(ID), .(ID, ParticipantID = as.character(ParticipantID))])
pid_extra <- pid_extra[!is.na(ParticipantID)]
M[is.na(ParticipantID), ParticipantID := pid_extra$ParticipantID[match(ID[is.na(ParticipantID)], pid_extra$ID)]]

## ---- 判据标记 ----
M[, f_age := !is.na(age_num) & (age_num < AGE_MIN | age_num > AGE_MAX)]
M[, f_honey := !is.na(honeypot_num) & honeypot_num == 1]
M[, f_iat := !is.na(iat_prop) & iat_prop > IAT_PROP]
M[, f_alt1 := !is.na(alt1_min_acc) & alt1_min_acc < ALT1_ACC]
M[, f_trap1 := !is.na(trap1_pass) & trap1_pass == FALSE]
M[, f_sret_rec := !is.na(sret_recognition) & sret_recognition < SRET_REC]
M[, f_sret_src := !is.na(sret_src_prop) & sret_src_prop > SRET_SRC_PROP]
M[, f_alt2 := (!is.na(alt2_min_cond) & alt2_min_cond < ALT2_ACC) | (!is.na(alt2_min_domain) & alt2_min_domain < ALT2_DOMAIN_ACC)]
M[, f_trap2 := !is.na(trap2_obs) & trap2_obs >= 4]

M[, att1 := ID %in% S1]; M[, att2 := ID %in% S2]; M[, att3 := ID %in% S3]; M[, att4 := ID %in% S4]
M[, sessions := mapply(function(a,b,c,d) paste(c(if(a)1L,if(b)2L,if(c)3L,if(d)4L), collapse=","), att1,att2,att3,att4)]
M[, n_sessions := (att1+att2+att3+att4)]
M[, is_all4 := ID %in% ALL4]

## ---- 第二层（被试级）----
M[, day2_task_fail := f_iat | f_alt1]
M[, day3_task_fail := f_sret_rec | f_sret_src | f_alt2]
M[, subject_stage := fcase(
  ID == "NA",                                "literal_NA",
  !att1,                                     "task_only",
  f_age,                                     "age",
  !att2,                                     "dropout_after_day1",
  f_trap1,                                   "trap1_attention",
  !day2_task_fail & !att3,                   "dropout_after_day2",
  att3 & f_trap2,                            "trap2_attention",
  att3 & !day3_task_fail & !att4,            "missing_day4_retained",
  default = "none")]
## 特殊归类：仅缺最后一场（第4次）且前三场任务数据完整者，不作为"被试级排除"，准予保留（进 140 表）
M[, subject_removed := subject_stage %in% c("age","dropout_after_day1","trap1_attention",
                                            "dropout_after_day2","trap2_attention")]
M[, is_record_level := subject_stage %in% c("literal_NA","task_only")]

## ---- 第三层（任务级数据作废）----
M[, t_iat      := att2 & f_iat]
M[, t_alt1     := att2 & f_alt1]
M[, t_sret_rec := att3 & f_sret_rec]
M[, t_sret_src := att3 & f_sret_src]
M[, t_alt2     := att3 & f_alt2]
M[, task_data_invalidated_n := t_iat + t_alt1 + t_sret_rec + t_sret_src + t_alt2]
M[, task_data_invalidated := mapply(function(a,b,c,d,e)
  paste(c(if(a)"IAT",if(b)"ALT1",if(c)"SRET再认",if(d)"SRET来源RT",if(e)"ALT2"), collapse="; "),
  t_iat, t_alt1, t_sret_rec, t_sret_src, t_alt2)]

## 逐任务失败细节（哪个任务、哪个指标、观察值、阈值、试次数）
fail_detail <- function(r) {
  x <- character(0)
  if (isTRUE(r$t_iat)) x <- c(x, sprintf("第2次测试·IAT：RT<300ms 占比 %.4f（最差块 %s，n=%d）> 阈值0.10",
                                         r$iat_prop, r$iat_task, r$iat_n))
  if (isTRUE(r$t_alt1)) x <- c(x, sprintf("第2次测试·ALT1：条件 %s 正确率 %.4f（n=%d）< 阈值0.60",
                                          r$alt1_cond, r$alt1_min_acc, r$alt1_n))
  if (isTRUE(r$t_sret_rec)) x <- c(x, sprintf("第3次测试·SRET再认：正确率 %.4f（n=%d）< 阈值0.55",
                                              r$sret_recognition, r$sret_n))
  if (isTRUE(r$t_sret_src)) x <- c(x, sprintf("第3次测试·SRET来源RT：<200ms 占比 %.4f（n=%d）> 阈值0.30",
                                              r$sret_src_prop, r$sret_src_n))
  if (isTRUE(r$t_alt2)) {
    d1 <- !is.na(r$alt2_min_cond) & r$alt2_min_cond < ALT2_ACC
    d2 <- !is.na(r$alt2_min_domain) & r$alt2_min_domain < ALT2_DOMAIN_ACC
    tag <- if (d1 && d2) "条件与领域均未达标" else if (d1) "条件未达标" else "领域未达标"
    x <- c(x, sprintf("第3次测试·ALT2：%s（条件 %s=%.4f <0.20；领域 %s=%.4f <0.60）",
                      tag, r$alt2_cond, r$alt2_min_cond, r$alt2_domain, r$alt2_min_domain))
  }
  paste(x, collapse="；")
}
M[, failure_detail := mapply(function(i) fail_detail(M[i]), .I)]

## ---- 观察值明细 ----
obs_of <- function(i) {
  r <- M[i]; x <- character(0)
  if (!is.na(r$age_num)) x <- c(x, sprintf("age=%s", r$age_num))
  if (!is.na(r$honeypot_num)) x <- c(x, sprintf("honeypot=%s", r$honeypot_num))
  if (!is.na(r$iat_prop)) x <- c(x, sprintf("IAT_prop=%.4f(%s,n=%d)", r$iat_prop, r$iat_task, r$iat_n))
  if (!is.na(r$alt1_min_acc)) x <- c(x, sprintf("ALT1_min_acc=%.4f(%s,n=%d)", r$alt1_min_acc, r$alt1_cond, r$alt1_n))
  if (!is.na(r$trap1_obs)) x <- c(x, sprintf("trap1=%s(ans=%s)", r$trap1_obs, r$trap1_ans))
  if (!is.na(r$sret_recognition)) x <- c(x, sprintf("SRET_rec=%.4f(n=%d)", r$sret_recognition, r$sret_n))
  if (!is.na(r$sret_src_prop)) x <- c(x, sprintf("SRET_src_lt200=%.4f(n=%d)", r$sret_src_prop, r$sret_src_n))
  if (!is.na(r$alt2_min_cond)) x <- c(x, sprintf("ALT2_min_cond=%.4f(%s)", r$alt2_min_cond, r$alt2_cond))
  if (!is.na(r$alt2_min_domain)) x <- c(x, sprintf("ALT2_min_domain=%.4f(%s)", r$alt2_min_domain, r$alt2_domain))
  if (!is.na(r$trap2_obs)) x <- c(x, sprintf("trap2=%s(%s)", r$trap2_obs, r$trap2_item))
  paste(x, collapse="; ")
}
M[, observed_metrics := mapply(obs_of, .I)]

## ---- 公共列 ----
M[, has_valid_ID := fifelse(ID=="NA","N","Y")]
M[, id_status := fifelse(ID=="NA","字符串 \"NA\"（无有效标识）", "有效被试标识")]
M[, in_released_503 := fifelse(ID %in% FINAL503, "Y", "N")]
M[, continued_after_subject_exclusion := mapply(function(s, a2, a3, a4) {
  if (s == "age")             return(ifelse(a2 | a3 | a4, "Y", "N"))
  if (s == "trap1_attention") return(ifelse(a3 | a4, "Y", "N"))
  if (s == "trap2_attention") return(ifelse(a4, "Y", "N"))
  "NA"
}, subject_stage, att2, att3, att4)]
M[, subsequent_sessions_attended := mapply(function(s, a1, a2, a3, a4) {
  att <- c(a1,a2,a3,a4)
  base <- c(age=1L, dropout_after_day1=1L, trap1_attention=2L,
            dropout_after_day2=2L, trap2_attention=3L, dropout_after_day3=3L,
            literal_NA=0L, task_only=0L)[s]
  if (is.na(base)) return("")
  idx <- 1:4; paste(idx[idx > base & att[idx]], collapse=",")
}, subject_stage, att1, att2, att3, att4)]

subj_zh <- c(literal_NA="无有效标识记录", task_only="仅任务数据（无 Day1 问卷）",
             age="年龄不合要求（<18 或 >59）", dropout_after_day1="第1次后失访（未参加第2次）",
             trap1_attention="注意核查未通过 trap1（Day2）",
             dropout_after_day2="第2次后失访（未参加第3次）",
             trap2_attention="注意核查未通过 trap2（Day3）",
             missing_day4_retained="第3次后未参加第4次（前三场数据完整，保留）", none="（未被被试级排除）")
subj_day <- c(literal_NA="—", task_only="—", age="Day1", dropout_after_day1="Day1",
              trap1_attention="Day2", dropout_after_day2="Day2", trap2_attention="Day3",
              missing_day4_retained="Day3", none="—")
M[, subject_exclusion_reason := subj_zh[subject_stage]]
M[, subject_exclusion_day := subj_day[subject_stage]]

criterion_detail <- function(i) {
  r <- M[i]
  switch(r$subject_stage,
    age              = sprintf("年龄=%s（%d–%d 之外）", r$age_num, AGE_MIN, AGE_MAX),
    trap1_attention  = sprintf("trap1=%s（答案应为 %s，答错）", r$trap1_obs, r$trap1_ans),
    trap2_attention  = sprintf("trap2=%s（“%s”，≥4 视为未通过）", r$trap2_obs, r$trap2_item),
    dropout_after_day1 = "未参加第2次测试（自愿退出）",
    dropout_after_day2 = "未参加第3次测试（自愿退出）",
    dropout_after_day3 = "未参加第4次测试（自愿退出）",
    literal_NA = "无被试标识（字符串 \"NA\"）",
    task_only  = "无 Day1 问卷记录，仅行为任务数据",
    "—")
}
M[, exclusion_criterion_detail := mapply(criterion_detail, .I)]

M[, concordance := fcase(
  is_record_level, "n/a（记录级，不适用被试逻辑）",
  subject_removed & in_released_503 == "N", "一致：第二层命中，作者亦移除",
  subject_removed & in_released_503 == "Y", "不一致：第二层命中，作者却保留",
  !subject_removed & task_data_invalidated_n > 0 & in_released_503 == "N",
    "不一致：第三层数据问题，作者却移除了被试（三层逻辑下应保留人、仅作废数据）",
  !subject_removed & task_data_invalidated_n > 0 & in_released_503 == "Y",
    "一致：第三层命中，仅作废数据、人保留",
  subject_stage == "missing_day4_retained",
    "按保留处理（仅缺第4次、前三场任务数据完整）；作者最终样本未包含",
  default = "")]

## =====================================================================
## 表1：被排除被试（第二层 171 人）
## =====================================================================
excl <- M[subject_removed == TRUE]
excl[, exclusion_id := .I]
setorder(excl, subject_stage, ID)
T1 <- excl[, .(
  exclusion_id, ID, ParticipantID,
  record_type = fifelse(is_record_level, subject_stage, "questionnaire_subject"),
  has_valid_ID, id_status,
  layer1_non_subject = fifelse(is_record_level, subject_stage, "—"),
  attended_day1=ifelse(att1,"Y","N"), attended_day2=ifelse(att2,"Y","N"),
  attended_day3=ifelse(att3,"Y","N"), attended_day4=ifelse(att4,"Y","N"),
  sessions_attended=sessions, n_sessions_attended=n_sessions, is_all4_completer=ifelse(is_all4,"Y","N"),
  exclusion_level = "第二层（被试级）",
  exclusion_object = fifelse(is_record_level, "记录", "被试"),
  subject_exclusion_stage=subject_stage, subject_exclusion_day, subject_exclusion_reason,
  exclusion_criterion_detail,
  also_task_data_invalidated = task_data_invalidated, task_data_invalidated_n, task_data_detail = failure_detail,
  observed_metrics, in_released_503,
  continued_after_subject_exclusion, subsequent_sessions_attended,
  concordance,
  retention_basis = fifelse(in_released_503=="Y", "第二层命中但作者仍纳入 503，与三层逻辑不一致", "不适用（已移除）"),
  retention_reason = fifelse(in_released_503=="Y", "作者最终核查未以第二层判据整人排除；疑为个别处理不一致", ""),
  evidence_basis = fifelse(is_record_level, "n/a", "recomputed_from_released_data")
)]
T1[record_type=="literal_NA", ID := '"NA"']

## =====================================================================
## 表2：任务数据有问题但人保留（纯第三层 139）+ 仅缺第4次保留 1 → 140
## =====================================================================
inv <- M[!is_record_level & !subject_removed & (task_data_invalidated_n > 0 | subject_stage == "missing_day4_retained")]
inv[, record_id := .I]
setorder(inv, subject_stage, ID)
T2 <- inv[, .(
  record_id, ID, ParticipantID, record_type = "questionnaire_subject",
  has_valid_ID, id_status,
  attended_day1=ifelse(att1,"Y","N"), attended_day2=ifelse(att2,"Y","N"),
  attended_day3=ifelse(att3,"Y","N"), attended_day4=ifelse(att4,"Y","N"),
  sessions_attended=sessions, n_sessions_attended=n_sessions, is_all4_completer=ifelse(is_all4,"Y","N"),
  exclusion_level = fifelse(subject_stage=="missing_day4_retained", "保留（仅缺第4次，不入排除）", "第三层（任务级数据标准）"),
  exclusion_object = fifelse(subject_stage=="missing_day4_retained", "被试（仅缺第4次）", "任务数据"),
  person_retained_in_sample = fifelse(subject_stage=="missing_day4_retained",
                                      "Y（仅缺第4次，前三场任务数据完整）",
                                      "Y（仅作废对应任务数据）"),
  in_released_503,
  task_data_invalidated, task_data_invalidated_n,
  ## 逐任务：是否评估 / 是否作废 / 观察值 / 阈值 / 试次数
  day2_IAT_assessed = ifelse(att2,"Y","N"), day2_IAT_invalid = ifelse(t_iat,"Y","N"),
    IAT_rt_lt300_prop = iat_prop, IAT_threshold = 0.10, IAT_worst_task = iat_task, IAT_n = iat_n,
  day2_ALT1_assessed = ifelse(att2,"Y","N"), day2_ALT1_invalid = ifelse(t_alt1,"Y","N"),
    ALT1_min_acc = alt1_min_acc, ALT1_threshold = 0.60, ALT1_worst_condition = alt1_cond, ALT1_n = alt1_n,
  day3_SRETrec_assessed = ifelse(att3,"Y","N"), day3_SRETrec_invalid = ifelse(t_sret_rec,"Y","N"),
    SRET_rec_acc = sret_recognition, SRET_rec_threshold = 0.55, SRET_rec_n = sret_n,
  day3_SRETsrc_assessed = ifelse(att3,"Y","N"), day3_SRETsrc_invalid = ifelse(t_sret_src,"Y","N"),
    SRET_src_lt200_prop = sret_src_prop, SRET_src_threshold = 0.30, SRET_src_n = sret_src_n,
  day3_ALT2_assessed = ifelse(att3,"Y","N"), day3_ALT2_invalid = ifelse(t_alt2,"Y","N"),
    ALT2_min_cond_acc = alt2_min_cond, ALT2_cond_threshold = 0.20, ALT2_worst_condition = alt2_cond,
    ALT2_min_domain_acc = alt2_min_domain, ALT2_domain_threshold = 0.60, ALT2_worst_domain = alt2_domain,
  ## 明细
  failure_detail = fifelse(subject_stage=="missing_day4_retained",
                           "无任务数据作废（0 项）；仅缺最后一场（第4次）", failure_detail),
  observed_metrics,
  retention_basis = fifelse(subject_stage=="missing_day4_retained",
                            "按保留处理：仅缺第4次、前三场任务数据完整，不作为排除",
                            "任务级数据标准仅作废该任务数据，不排除被试"),
  retention_reason = fifelse(subject_stage=="missing_day4_retained",
                             "第3次后未参加第4次，但无需作废任何任务数据；准予保留",
                             "第三层命中：应保留人、作废对应任务数据"),
  concordance,
  note = fifelse(subject_stage=="missing_day4_retained",
                 "仅第4次未参加（最后一场缺失）；前三场任务数据完整、无作废，按保留处理",
                 "该任务数据不可用，其余任务数据（含未作废者）仍可分析"),
  evidence_basis = fifelse(subject_stage=="missing_day4_retained",
                           "recomputed_from_released_data（特殊归类：仅缺第4次）",
                           "recomputed_from_released_data")
)]
T2[is.na(ALT2_min_cond_acc), `:=`(ALT2_min_cond_acc="", ALT2_worst_condition="")]
T2[is.na(ALT2_min_domain_acc), `:=`(ALT2_min_domain_acc="", ALT2_worst_domain="")]

out1 <- P("04_code_and_reproducibility/excluded_subjects_171.csv")
out2 <- P("04_code_and_reproducibility/invalidated_task_data_140.csv")
fwrite(T1, out1, bom = TRUE)
fwrite(T2, out2, bom = TRUE)

cat("=== 表1 被排除被试（第二层）===\n")
cat("行数:", nrow(T1), " 列数:", ncol(T1), "\n")
print(T1[, .N, by=.(subject_exclusion_stage, subject_exclusion_reason)][order(-N)])
cat("输出:", out1, "\n\n")

cat("=== 表2 任务数据有问题但人保留 ===\n")
cat("行数:", nrow(T2), " 列数:", ncol(T2), "\n")
print(T2[, .N, by=task_data_invalidated][order(-N)])
cat("各判据命中人数: IAT", sum(T2$day2_IAT_invalid=="Y"), "| ALT1", sum(T2$day2_ALT1_invalid=="Y"),
    "| SRET再认", sum(T2$day3_SRETrec_invalid=="Y"), "| SRET来源RT", sum(T2$day3_SRETsrc_invalid=="Y"),
    "| ALT2", sum(T2$day3_ALT2_invalid=="Y"), "\n")
cat("其中仍在作者503:", nrow(T2[in_released_503=="Y"]), "；作者移除:", nrow(T2[in_released_503=="N"]), "\n")
cat("输出:", out2, "\n")