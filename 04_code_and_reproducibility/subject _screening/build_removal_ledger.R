## 791 → 466 全流程排除明细账（含身份、出席、排除阶段、原因、后续是否继续参加）
## 判据实现沿用 excluded_record/exclusion_pipeline.qmd（D12：analysis.Rmd 为实现权威）
suppressPackageStartupMessages({ library(data.table); library(readr) })

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

## trap1（day2 raw survey 试次，每人最早一行）
t1raw <- fread_zip(PATH_ZIP_D2, select = c("ID","trial_index","trial_type","trap1","correct_answer","correct","trap1_item"))
t1 <- t1raw[trial_type=="survey-template" & !is.na(correct_answer) & !is.na(ID)]
setorder(t1, ID, trial_index)
m_trap1 <- t1[, .SD[1], by = ID][, .(ID, trap1_obs = trap1, trap1_ans = correct_answer,
                                     trap1_pass = correct, trap1_item)]

## SRET
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

## ALT2
alt2 <- copy(ALT2_FORMAL)
alt2[, `:=`(rt=suppressWarnings(as.numeric(rt)), correct=suppressWarnings(as.numeric(correct)))]
alt2[is.na(correct), correct := 0]
alt2[, ok := as.integer(correct==1 & !is.na(rt) & rt>=RT_MIN & rt<=RT_MAX)]
a2c1 <- alt2[, .(n=.N, ncor=sum(ok,na.rm=TRUE)), by=.(ID,domain_d,person_d,identity,valence_d)][, acc:=ncor/n]
a2c2 <- alt2[, .(n=.N, ncor=sum(ok,na.rm=TRUE)), by=.(ID,domain_d)][, acc:=ncor/n]
m_alt2c <- a2c1[, .(alt2_min_cond = min(acc), alt2_cond = paste(domain_d,person_d,identity,valence_d,sep="_")[which.min(acc)]), by=ID]
m_alt2d <- a2c2[, .(alt2_min_domain = min(acc), alt2_domain = domain_d[which.min(acc)]), by=ID]
m_alt2 <- merge(m_alt2c, m_alt2d, by="ID", all=TRUE)

## trap2（day3 raw survey 试次，每人最早一行）
t2raw <- fread_zip(PATH_ZIP_D3, select = c("ID","trial_index","trial_type","trap2","trap2_item"))
t2 <- t2raw[trial_type=="survey-template" & !is.na(trap2_item) & !is.na(ID)]
setorder(t2, ID, trial_index)
m_trap2 <- t2[, .SD[1], by=ID][, .(ID, trap2_obs = trap2, trap2_item)]

## ---- 汇总逐人指标 ----
M <- data.table(ID = INITIAL_SAMPLE)
for (mm in list(m_age, m_honey, m_iat, m_alt1, m_trap1, m_sret_rec, m_sret_src, m_alt2, m_trap2)) {
  if (!"ID" %in% names(mm)) next
  M <- merge(M, mm, by = "ID", all.x = TRUE)
}
## 补充 ParticipantID（任务文件中的映射，供无 Day1 者使用）
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
M[, day1_fail := f_age | f_honey]
M[, day2_fail := f_iat | f_alt1 | f_trap1]
M[, day3_fail := f_sret_rec | f_sret_src | f_alt2 | f_trap2]

## ---- 严格时间线分层 ----
M[, att1 := ID %in% S1]; M[, att2 := ID %in% S2]; M[, att3 := ID %in% S3]; M[, att4 := ID %in% S4]
M[, sessions := mapply(function(a,b,c,d) paste(c(if(a)1L,if(b)2L,if(c)3L,if(d)4L), collapse=","), att1,att2,att3,att4)]
M[, n_sessions := (att1+att2+att3+att4)]
M[, is_all4 := ID %in% ALL4]

M[, stage := fifelse(ID == "NA", "literal_NA",
             fifelse(!att1, "task_only",
             fifelse(day1_fail, "age",
             fifelse(att2 & day2_fail, "quality_day2",
             fifelse(!att2, "attrition_after_day1",
             fifelse(att3 & day3_fail, "quality_day3",
             fifelse(!att3, "attrition_after_day2",
             fifelse(!att4, "attrition_after_day3", "retained"))))))))]

## ---- 组装明细账 ----
crit_labels <- c(f_age="年龄", f_honey="honeypot", f_iat="IAT反应时", f_alt1="ALT1正确率",
                 f_trap1="trap1注意核查", f_sret_rec="SRET再认", f_sret_src="SRET来源RT",
                 f_alt2="ALT2正确率", f_trap2="trap2恶意条目")
crit_codes  <- c(f_age="AGE_criterion", f_honey="honeypot", f_iat="IAT_RT", f_alt1="ALT1_accuracy",
                 f_trap1="trap1_attention", f_sret_rec="SRET_recognition", f_sret_src="SRET_source_RT",
                 f_alt2="ALT2_accuracy", f_trap2="trap2_bogus")
flag_vals <- c("f_age","f_honey","f_iat","f_alt1","f_trap1","f_sret_rec","f_sret_src","f_alt2","f_trap2")

stage_zh <- c(literal_NA="无有效标识记录", task_only="仅任务数据（无 Day1 问卷）",
              age="Day1 年龄纳入标准", quality_day2="Day2 质量筛选未达标",
              quality_day3="Day3 质量筛选未达标", attrition_after_day1="Day1 后未参加 Day2（失访）",
              attrition_after_day2="Day2 后未参加 Day3（失访）", attrition_after_day3="Day3 后未参加 Day4（失访）",
              retained="保留（进入 466）")
stage_day <- c(literal_NA="—", task_only="—", age="Day1", quality_day2="Day2", quality_day3="Day3",
               attrition_after_day1="Day1", attrition_after_day2="Day2", attrition_after_day3="Day3", retained="Day4")
stage_order <- c(literal_NA=0L, task_only=1L, age=2L, attrition_after_day1=3L, quality_day2=4L,
                 attrition_after_day2=5L, quality_day3=6L, attrition_after_day3=7L, retained=8L)

stage_flags <- list(
  literal_NA = character(0),
  task_only  = flag_vals,
  age        = c("f_age","f_honey"),
  quality_day2 = c("f_iat","f_alt1","f_trap1"),
  quality_day3 = c("f_sret_rec","f_sret_src","f_alt2","f_trap2"),
  attrition_after_day1 = character(0), attrition_after_day2 = character(0),
  attrition_after_day3 = character(0))
M[, criteria_hit := mapply(function(i, s) {
  fs <- stage_flags[[s]]
  hit <- fs[vapply(fs, function(f) isTRUE(M[[f]][i]), logical(1))]
  if (length(hit) == 0) "" else paste(crit_codes[hit], collapse="; ")
}, .I, stage)]
M[, criteria_hit_zh := mapply(function(i, s) {
  fs <- stage_flags[[s]]
  hit <- fs[vapply(fs, function(f) isTRUE(M[[f]][i]), logical(1))]
  if (length(hit) == 0) "" else paste(crit_labels[hit], collapse="; ")
}, .I, stage)]
## 触发判据的性质（任务质量 / 注意核查 / 年龄）
M[, trigger_type := mapply(function(i, s) {
  fs <- stage_flags[[s]]
  hit <- fs[vapply(fs, function(f) isTRUE(M[[f]][i]), logical(1))]
  ty <- character(0)
  if (any(hit %in% c("f_iat","f_alt1","f_alt2","f_sret_rec","f_sret_src"))) ty <- c(ty, "任务质量")
  if (any(hit %in% c("f_trap1","f_trap2","f_honey"))) ty <- c(ty, "注意核查")
  if (any(hit == "f_age")) ty <- c(ty, "年龄")
  if (length(ty) == 0) "" else paste(ty, collapse="+")
}, .I, stage)]

## 观察值明细
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

## 下一步是否继续参加
next_of <- function(s, att2, att3, att4) {
  if (s == "age") return(ifelse(att2, "Y", "N"))
  if (s == "quality_day2") return(ifelse(att3 | att4, "Y", "N"))
  if (s == "quality_day3") return(ifelse(att4, "Y", "N"))
  "NA"
}
M[, next_attended := mapply(next_of, stage, att2, att3, att4)]
M[, subsequent := mapply(function(s, a1, a2, a3, a4) {
  att <- c(a1, a2, a3, a4)
  base <- c(age=1L, quality_day2=2L, quality_day3=3L,
            attrition_after_day1=1L, attrition_after_day2=2L, attrition_after_day3=3L,
            task_only=0L)[s]
  if (is.na(base)) return("")
  idx <- 1:4; paste(idx[idx > base & att[idx]], collapse=",")
}, stage, att1, att2, att3, att4)]
M[, continued := fifelse(is.na(match(stage, c("age","quality_day2","quality_day3"))), "NA",
                  fifelse(subsequent != "", "Y", "N"))]

primary_reason <- c(
  literal_NA = "无被试标识（字符串 \"NA\"），无法归属任何被试",
  task_only  = "无 Day1 问卷记录，仅有行为任务数据（不在多日流程内）",
  age        = "年龄 <18 或 >59（Day1 纳入标准）",
  quality_day2 = "Day2 行为任务质量判据未达标",
  quality_day3 = "Day3 行为任务质量判据未达标",
  attrition_after_day1 = "参加 Day1 后未参加 Day2",
  attrition_after_day2 = "参加 Day2 后未参加 Day3",
  attrition_after_day3 = "参加 Day3 后未参加 Day4")
M[, primary_reason := primary_reason[stage]]
M[, removal_stage_zh := stage_zh[stage]]
M[, removal_day := stage_day[stage]]
M[, stage_order := stage_order[stage]]
M[, record_type := fifelse(stage=="literal_NA","literal_NA", fifelse(stage=="task_only","task_only","questionnaire_subject"))]
M[, has_valid_ID := fifelse(ID=="NA","N","Y")]
M[, id_status := fifelse(ID=="NA","字符串 \"NA\"（无有效标识）", "有效被试标识")]
M[, in_released_503 := fifelse(ID %in% FINAL503, "Y", "N")]
M[, evidence_basis := fifelse(stage %in% c("literal_NA","task_only"), "n/a", "recomputed_from_released_data")]

## 保留依据与保留原因（仅对“触发判据但仍在发布版 503”的行有意义）
ret_basis <- function(tt) {
  if (!nzchar(tt)) return("不适用（未保留）")
  parts <- character(0)
  if (grepl("任务质量", tt)) parts <- c(parts, "论文未列为被试层面排除标准（C2–C5 仅作 note）")
  if (grepl("注意核查", tt)) parts <- c(parts, "作者代码从未将注意核查用作排除门槛")
  if (grepl("年龄", tt))     parts <- c(parts, "无依据（与 C1 年龄排除标准冲突）")
  paste(parts, collapse="；")
}
ret_reason <- function(tt) {
  if (!nzchar(tt)) return("")
  parts <- character(0)
  if (grepl("任务质量", tt)) parts <- c(parts, "作者最终核查未按该判据排除；已存档于 flagged_but_retained.csv（28 人，与论文自陈 28 一致）")
  if (grepl("注意核查", tt)) parts <- c(parts, "trap 仅被记录、未参与 Eligible 判定，保留与代码实现一致")
  if (grepl("年龄", tt))     parts <- c(parts, "年龄超标仍被纳入最终样本，无规则支持，疑为个别处理不一致")
  paste(parts, collapse="；")
}
M[, retention_basis := fifelse(in_released_503 == "Y",
                               vapply(trigger_type, ret_basis, character(1)), "不适用（未保留）")]
M[, retention_reason := fifelse(in_released_503 == "Y",
                                vapply(trigger_type, ret_reason, character(1)), "")]

ledger <- M[stage != "retained", .(
  stage_order, ID, record_type, has_valid_ID, id_status, ParticipantID,
  attended_day1=ifelse(att1,"Y","N"), attended_day2=ifelse(att2,"Y","N"),
  attended_day3=ifelse(att3,"Y","N"), attended_day4=ifelse(att4,"Y","N"),
  sessions_attended=sessions, n_sessions_attended=n_sessions, is_all4_completer=ifelse(is_all4,"Y","N"),
  removal_stage=stage, removal_stage_zh, removal_day, primary_reason,
  criteria_hit, criteria_hit_zh, trigger_type, observed_metrics,
  next_session_after_removal_attended=next_attended,
  subsequent_sessions_attended=subsequent, continued_after_removal=continued,
  in_released_503,
  retention_basis, retention_reason,
  note = fifelse(in_released_503=="Y" & stage %in% c("age","quality_day2","quality_day3"),
                 "触发判据但发布版最终样本 503 仍保留",
          fifelse(stage=="task_only" & nzchar(criteria_hit),
                 "无问卷记录，且命中了行为任务质量判据",
          fifelse(stage=="task_only", "无问卷记录，仅任务数据且未命中判据", ""))),
  evidence_basis
)]
ledger[removal_stage=="literal_NA", ID := '"NA"']
setorder(ledger, stage_order, ID)

out_path <- P("04_code_and_reproducibility/removal_ledger_791_to_466.csv")
fwrite(ledger, out_path, bom = TRUE)

cat("=== 791 → 466 排除明细账 ===\n")
cat("总行数:", nrow(ledger), "（791 - 466 = 325）\n")
print(ledger[, .N, by = .(stage_order, removal_stage, removal_stage_zh)][order(stage_order)])
cat("\n各阶段『不合格后仍继续参加』人数:\n")
print(ledger[continued_after_removal=="Y", .N, by=removal_stage][order(-N)])
cat("\n输出:", out_path, "\n")
EOF_MARKER <- NULL
