## =====================================================================
## 三层排除 / 作废明细账（不改动原 removal_ledger_791_to_466.csv）
##   第一层  记录级（仅任务数据 / 无有效标识）—— 移除“记录”
##   第二层  被试级排除标准            —— 移除“人”：年龄、注意核查(trap1/trap2)、失访
##   第三层  任务级数据标准            —— 作废“该任务的数据”，不排除被试
##  保留规则（与 build_excluded186_and_invalidated139.R 一致）：
##   第 3 次后未参加第 4 次者保留（missing_day4_retained），计入第三层/保留，不作为第二层排除。
##   第二层 171；第三层 139 + 仅缺第4次 1 = 140；791 - 14 - 171 = 606 保留；606 - 140 = 466。
## 输出: exclusion_ledger_three_layer.csv （每个有排除/作废事件的人一行）
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

## ---- 常量（与判据实现一致）----
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

## 第一层记录级（14 条）：13 个仅任务数据被试 + 1 条字面 "NA"。
## 这 14 条已从 01_raw 移除，此处静态登记，保证明细账仍可复现。
LAYER1_RECORDS <- c(paste0("phase_002_subj_", c(2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)), "NA")

## ---- 样本集合与出席 ----
D1  <- ids_of(DAY_FILES["D1"]); D2q <- ids_of(DAY_FILES["D2"])
D3q <- ids_of(DAY_FILES["D3"]); D10q <- ids_of(DAY_FILES["D10"])
IAT_IDS  <- ids_of(PATH_IAT_RAW); ALT1_IDS <- ids_of(PATH_SMT1)
SRET_ALL <- ids_of(PATH_SRET); SRET_IDS <- setdiff(SRET_ALL, "NA")
ALT2_ALL <- fread_zip(PATH_ZIP_D3, select = c("ID","screen_id","condition","rt","correct","identity"))
ALT2_FORMAL <- ALT2_ALL[screen_id %in% c("ability","moral")]
ALT2_FORMAL[, `:=`(domain_d = screen_id,
                   person_d  = fifelse(grepl("我$", condition), "self", "friend"),
                   valence_d = fifelse(substr(condition, 1, 1) %in% c("好","强"), "positive", "negative"))]
ALT2_IDS <- unique(ALT2_FORMAL$ID[!is.na(ALT2_FORMAL$ID)])
FINAL503 <- ids_of_zip(PATH_SMT2_ZIP)
INITIAL_SAMPLE <- sort(unique(c(D1, IAT_IDS, ALT1_IDS, SRET_ALL, ALT2_IDS, LAYER1_RECORDS)))
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

## ---- 出席 ----
M[, att1 := ID %in% S1]; M[, att2 := ID %in% S2]; M[, att3 := ID %in% S3]; M[, att4 := ID %in% S4]
M[, sessions := mapply(function(a,b,c,d) paste(c(if(a)1L,if(b)2L,if(c)3L,if(d)4L), collapse=","), att1,att2,att3,att4)]
M[, n_sessions := (att1+att2+att3+att4)]
M[, is_all4 := ID %in% ALL4]

## =====================================================================
## 第二层：被试级移除事件（按时间线取最早）
##   age(day1) > 失访(day1后) > trap1(day2) > 失访(day2后，仅限通过当日判据者)
##            > trap2(day3) > 仅缺第4次(day3后，前三场数据完整，保留)
##   任务级未达标(第三层)不移除被试；第3次后未参加第4次者保留，故不计入第二层
## =====================================================================
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
M[, subject_removed := subject_stage %in% c("age","dropout_after_day1","trap1_attention",
                                            "dropout_after_day2","trap2_attention")]
M[, is_record_level := subject_stage %in% c("literal_NA","task_only")]

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

## =====================================================================
## 第三层：任务级数据作废事件（各自独立，不排除人）
##   仅对“该场次已参加”的任务判定
## =====================================================================
M[, t_iat      := att2 & f_iat]
M[, t_alt1     := att2 & f_alt1]
M[, t_sret_rec := att3 & f_sret_rec]
M[, t_sret_src := att3 & f_sret_src]
M[, t_alt2     := att3 & f_alt2]
M[, task_data_invalidated_n := t_iat + t_alt1 + t_sret_rec + t_sret_src + t_alt2]
M[, task_data_invalidated := mapply(function(a,b,c,d,e)
  paste(c(if(a)"IAT",if(b)"ALT1",if(c)"SRET再认",if(d)"SRET来源RT",if(e)"ALT2"), collapse="; "),
  t_iat, t_alt1, t_sret_rec, t_sret_src, t_alt2)]
M[, task_data_detail := mapply(function(i, a,b,c,d,e) {
  r <- M[i]; x <- character(0)
  if (a) x <- c(x, sprintf("IAT:%.4f>%.2f", r$iat_prop, IAT_PROP))
  if (b) x <- c(x, sprintf("ALT1:%.4f<%.2f", r$alt1_min_acc, ALT1_ACC))
  if (c) x <- c(x, sprintf("SRET再认:%.4f<%.2f", r$sret_recognition, SRET_REC))
  if (d) x <- c(x, sprintf("SRET来源RT:%.4f>%.2f", r$sret_src_prop, SRET_SRC_PROP))
  if (e) x <- c(x, sprintf("ALT2:cond %.4f / domain %.4f", r$alt2_min_cond, r$alt2_min_domain))
  paste(x, collapse="; ")
}, .I, t_iat, t_alt1, t_sret_rec, t_sret_src, t_alt2)]

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

## ---- 保留状态 / 续参 / 依据 ----
M[, in_released_503 := fifelse(ID %in% FINAL503, "Y", "N")]
M[, person_retained_in_sample := fifelse(is_record_level, "N",
                                  fifelse(subject_removed, "N", "Y"))]
M[, continued_after_subject_exclusion := mapply(function(s, a2, a3, a4) {
  if (s == "age")             return(ifelse(a2 | a3 | a4, "Y", "N"))
  if (s == "trap1_attention") return(ifelse(a3 | a4, "Y", "N"))
  if (s == "trap2_attention") return(ifelse(a4, "Y", "N"))
  "NA"
}, subject_stage, att2, att3, att4)]
M[, subsequent_sessions_attended := mapply(function(s, a1, a2, a3, a4) {
  att <- c(a1,a2,a3,a4)
  base <- c(age=1L, dropout_after_day1=1L, trap1_attention=2L,
            dropout_after_day2=2L, trap2_attention=3L, missing_day4_retained=3L,
            literal_NA=0L, task_only=0L)[s]
  if (is.na(base)) return("")
  idx <- 1:4; paste(idx[idx > base & att[idx]], collapse=",")
}, subject_stage, att1, att2, att3, att4)]

## exclusion_level / object（严格按照排除对象分层）
M[, exclusion_level := fcase(
  is_record_level, "第一层",
  subject_removed & task_data_invalidated_n > 0, "第二层+第三层",
  subject_removed, "第二层",
  subject_stage == "missing_day4_retained", "保留（仅缺第4次）",
  task_data_invalidated_n > 0, "第三层",
  default = "—")]
M[, exclusion_object := fcase(
  is_record_level, "记录",
  subject_removed & task_data_invalidated_n > 0, "被试+任务数据",
  subject_removed, "被试",
  subject_stage == "missing_day4_retained", "被试（仅缺第4次）",
  task_data_invalidated_n > 0, "任务数据",
  default = "—")]

## 三层逻辑 vs 作者实际处置是否一致
M[, concordance := fcase(
  is_record_level, "n/a（记录级，不适用被试逻辑）",
  subject_removed & in_released_503 == "N", "一致：第二层命中，作者亦移除",
  subject_removed & in_released_503 == "Y", "不一致：第二层命中，作者却保留",
  !subject_removed & task_data_invalidated_n > 0 & in_released_503 == "N",
    "不一致：第三层数据问题，作者却移除了被试（三层逻辑下应保留人、仅作废数据）",
  !subject_removed & task_data_invalidated_n > 0 & in_released_503 == "Y",
    "一致：第三层命中，仅作废数据、人保留",
  subject_stage == "missing_day4_retained",
    "按保留处理（仅缺第4次、前三场数据完整）；作者最终样本未包含",
  default = "")]

## 保留依据/原因（针对“仍在发布版 503”者）
M[, retention_basis := fcase(
  in_released_503 == "N" & subject_removed, "不适用（已移除）",
  subject_stage == "missing_day4_retained",
    "按保留处理：仅缺第4次、前三场任务数据完整，不作为排除",
  !subject_removed & task_data_invalidated_n > 0, "任务级数据标准仅作废该任务数据，不动被试",
  default = "触发被试级/记录级判据但发布版 503 仍保留")]
M[, retention_reason := fcase(
  in_released_503 == "N" & subject_removed, "",
  subject_stage == "missing_day4_retained",
    "第3次后未参加第4次，但无需作废任何任务数据；准予保留",
  !subject_removed & task_data_invalidated_n > 0,
    "第三层命中：作者未据此删除被试，仅应作废对应任务数据；人保留",
  default = "第二层命中（年龄/注意核查）但作者仍纳入 503，与三层逻辑不一致")]

M[, note := fcase(
  task_data_invalidated_n > 0 & subject_removed, "先命中第三层(数据)，后被第二层移除(人)",
  task_data_invalidated_n > 0 & !subject_removed, "仅第三层：数据作废、人保留",
  subject_stage == "missing_day4_retained", "仅第4次未参加（最后一场缺失）；前三场任务数据完整、无作废，按保留处理",
  subject_removed, "",
  default = "")]

## ---- 生成明细（只保留有事件的：第一/第二/第三层任一，或仅缺第4次保留）----
keep <- M[is_record_level | subject_removed | task_data_invalidated_n > 0 | subject_stage == "missing_day4_retained"]
keep[, exclusion_id := .I]
setorder(keep, exclusion_level, subject_exclusion_day, ID)

ledger <- keep[, .(
  exclusion_id, ID, ParticipantID, record_type = fifelse(is_record_level, subject_stage, "questionnaire_subject"),
  has_valid_ID = fifelse(ID=="NA","N","Y"),
  id_status = fifelse(ID=="NA","字符串 \"NA\"（无有效标识）", "有效被试标识"),
  layer1_non_subject = fifelse(is_record_level, subject_stage, "—"),
  attended_day1=ifelse(att1,"Y","N"), attended_day2=ifelse(att2,"Y","N"),
  attended_day3=ifelse(att3,"Y","N"), attended_day4=ifelse(att4,"Y","N"),
  sessions_attended=sessions, n_sessions_attended=n_sessions, is_all4_completer=ifelse(is_all4,"Y","N"),
  exclusion_level, exclusion_object,
  subject_removed = fifelse(is_record_level, "NA", fifelse(subject_removed,"Y","N")),
  subject_exclusion_stage = subject_stage,
  subject_exclusion_day,
  subject_exclusion_reason,
  attention_trap_flagged = fifelse(f_trap1 | f_trap2, "Y", "N"),
  task_data_invalidated, task_data_invalidated_n, task_data_detail,
  person_retained_in_sample,
  observed_metrics, in_released_503,
  continued_after_subject_exclusion, subsequent_sessions_attended,
  retention_basis, retention_reason, concordance, note,
  evidence_basis = fifelse(is_record_level, "n/a", "recomputed_from_released_data")
)]
ledger[record_type=="literal_NA", ID := '"NA"']

out_path <- P("04_code_and_reproducibility/exclusion_ledger_three_layer.csv")
fwrite(ledger, out_path, bom = TRUE)

cat("=== 三层排除/作废明细账 ===\n")
cat("总行数:", nrow(ledger), "（列数:", ncol(ledger), "）\n\n")
cat("按层级:\n"); print(ledger[, .N, by=exclusion_level][order(exclusion_level)])
cat("\n按被试级阶段:\n"); print(ledger[subject_exclusion_stage!="none", .N, by=.(subject_exclusion_stage, subject_exclusion_reason)][order(-N)])
cat("\n按排除对象:\n"); print(ledger[, .N, by=exclusion_object][order(-N)])
cat("\n第三层作废的任务分布（含多任务者重复计数）:\n")
print(ledger[task_data_invalidated_n>0 & !(subject_exclusion_stage %in% c("literal_NA","task_only")),
             .N, by=task_data_invalidated][order(-N)])
n1 <- ledger[exclusion_level=="第一层", .N]
n2 <- ledger[exclusion_level %in% c("第二层","第二层+第三层"), .N]
n3 <- ledger[exclusion_level=="第三层", .N]                 # 保留、仅任务数据作废
n4 <- ledger[exclusion_level=="保留（仅缺第4次）", .N]        # 保留、仅缺第4次
cat("\n=== 三层逻辑下最终样本 ===\n")
cat(sprintf("791 − 一层(记录) %d − 二层(被试) %d = %d 人保留\n", n1, n2, 791-n1-n2))
cat(sprintf("其中 %d 人有 ≥1 项任务数据作废，另有 %d 人仅缺第4次 → 任务数据不完整共 %d 人\n", n3, n4, n3+n4))
cat(sprintf("完整数据 = %d − %d = %d\n", 791-n1-n2, n3+n4, 791-n1-n2-n3-n4))
cat("作者实际最终样本 = 503；两者之差来自第三层被作者整人移除者。\n")
cat("\n一致性核查（三层逻辑 vs 作者处置）：\n")
print(ledger[, .N, by=concordance][order(-N)])
cat("\n输出:", out_path, "\n")
