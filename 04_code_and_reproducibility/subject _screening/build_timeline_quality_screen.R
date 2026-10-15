## 严格时间线 + 数据质量标准逐人筛选
## 判据实现完全沿用 excluded_record/exclusion_pipeline.qmd（D12：以 analysis.Rmd 为实现权威）
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

## ---- 常量（analysis.Rmd 行号）----
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
PATH_IAT_RAW <- P("01_raw/IAT_raw.csv")
PATH_SMT1    <- P("01_raw/SMT_1_raw.csv")
PATH_SRET    <- P("01_raw/SRET_raw.csv")
PATH_SMT2_ZIP<- P("02_cleaned_author_full/SMT_2_cleaned.zip")
PATH_ZIP_D2  <- P("01_raw/questionnaires_day2_raw.zip")
PATH_ZIP_D3  <- P("01_raw/questionnaires_day3_raw.zip")

## ---- 样本集合 ----
D1  <- ids_of(DAY_FILES["D1"]); D2q <- ids_of(DAY_FILES["D2"])
D3q <- ids_of(DAY_FILES["D3"]); D10q <- ids_of(DAY_FILES["D10"])
IAT_IDS  <- ids_of(PATH_IAT_RAW)
ALT1_IDS <- ids_of(PATH_SMT1)
SRET_ALL <- ids_of(PATH_SRET)
SRET_IDS <- setdiff(SRET_ALL, "NA")

ALT2_ALL <- fread_zip(PATH_ZIP_D3, select = c("ID", "screen_id", "condition", "rt", "correct", "identity"))
ALT2_FORMAL <- ALT2_ALL[screen_id %in% c("ability", "moral")]
ALT2_FORMAL[, `:=`(domain_d = screen_id,
                   person_d  = fifelse(grepl("我$", condition), "self", "friend"),
                   valence_d = fifelse(substr(condition, 1, 1) %in% c("好", "强"), "positive", "negative"))]
ALT2_IDS <- unique(ALT2_FORMAL$ID[!is.na(ALT2_FORMAL$ID)])
FINAL503 <- ids_of_zip(PATH_SMT2_ZIP)
INITIAL_SAMPLE <- sort(unique(c(D1, IAT_IDS, ALT1_IDS, SRET_ALL, ALT2_IDS)))

## ---- 各场次出席 ----
S1 <- D1
S2 <- union(D2q, union(IAT_IDS, ALT1_IDS))
S3 <- union(D3q, union(SRET_IDS, ALT2_IDS))
S4 <- D10q
attend_of <- function(id) {
  s <- c(if (id %in% S1) 1L, if (id %in% S2) 2L, if (id %in% S3) 3L, if (id %in% S4) 4L)
  if (length(s) == 0) "" else paste(s, collapse = ",")
}

## ---- 第一天：年龄 + honeypot ----
day1 <- fread_utf8(DAY_FILES["D1"], select = c("ID", "ParticipantID", "age", "sex"))
day1[, age_num := suppressWarnings(as.numeric(age))]
AGE_BAD <- day1[is.na(age_num) | age_num > AGE_MAX | age_num < AGE_MIN]
AGE_IDS <- AGE_BAD$ID

d1raw <- fread_utf8(P("01_raw/questionnaires_day1_raw.csv"), select = c("ParticipantID", "honeypot", "ID"))
d1raw[, honeypot_num := suppressWarnings(as.numeric(honeypot))]
HONEY_PID <- unique(d1raw[honeypot_num == 1, ParticipantID])
pid2id_d1 <- unique(day1[!is.na(ParticipantID), .(ParticipantID, ID)])
HONEY_IDS <- pid2id_d1[ParticipantID %in% HONEY_PID, ID]
cat("[第一天] 年龄未达标:", length(AGE_IDS), " honeypot=1 的被试:", length(HONEY_IDS), "\n")

D1_FLAG_DT <- rbindlist(list(
  data.table(ID = AGE_BAD$ID, flag_criterion = "AGE_criterion",
             detail = paste0("age=", AGE_BAD$age), observed = as.character(AGE_BAD$age), threshold = "18-59"),
  data.table(ID = HONEY_IDS, flag_criterion = "honeypot", detail = "honeypot=1",
             observed = "1", threshold = "=0")
), fill = TRUE)

## ---- 第二天：IAT + ALT1 + trap1 ----
iat <- fread_utf8(PATH_IAT_RAW, select = c("ID","ParticipantID","screen_id","task_id","rt","RT","response","correct","word","condition"))
iat_trials <- iat[screen_id %in% c("3","4","6","7")]; iat_trials[, rt := suppressWarnings(as.numeric(rt))]
iat_qc <- iat_trials[, .(rt_les300 = sum(rt <= IAT_SHORT, na.rm = TRUE),
                         row_count = sum(rt <= IAT_LONG, na.rm = TRUE)), by = .(ID, task_id)]
iat_qc[, proportion := rt_les300 / row_count]
IAT_FLAG_DT <- iat_qc[proportion > IAT_PROP,
  .(ID, flag_criterion = "IAT_RT", detail = paste0(task_id, " rt<=", IAT_SHORT, " 占比"),
    observed = as.character(round(proportion, 4)), threshold = ">0.10")]
IAT_FLAG <- unique(IAT_FLAG_DT$ID)

alt1 <- fread_utf8(PATH_SMT1, select = c("ID","screen_id","con","conditionType","rt","correct"))
alt1 <- alt1[screen_id %in% c("formal_ALT1_1","formal_ALT1_2")]; alt1[, rt := suppressWarnings(as.numeric(rt))]
alt1[, cor := fifelse(tolower(correct)=="true",1L, fifelse(tolower(correct)=="false",0L, NA_integer_))]
alt1_qc <- alt1[, .(n=.N, ncor=sum(cor==1 & rt>=RT_MIN & rt<=RT_MAX, na.rm=TRUE)), by=.(ID,con,conditionType)]
alt1_qc[, acc := ncor/n]
alt1_worst <- alt1_qc[, .(acc=min(acc), cond=con[which.min(acc)], n=n[which.min(acc)]), by=ID]
ALT1_FLAG_DT <- alt1_worst[acc < ALT1_ACC,
  .(ID, flag_criterion = "ALT1_accuracy", detail = cond,
    observed = as.character(round(acc,4)), threshold = "<0.60")]
ALT1_FLAG <- unique(ALT1_FLAG_DT$ID)

## trap1：day2 raw 的 survey 试次（有 correct_answer 的行），每人最早一行，correct==FALSE 为未达标
t1raw <- fread_zip(PATH_ZIP_D2, select = c("ID","trial_index","trial_type","trap1","correct_answer","correct"))
t1 <- t1raw[trial_type == "survey-template" & !is.na(correct_answer) & !is.na(ID)]
setorder(t1, ID, trial_index); t1_first <- t1[, .SD[1], by = ID]
TRAP1_FLAG_DT <- t1_first[correct == FALSE,
  .(ID, flag_criterion = "trap1_attention", detail = "day2 hsns 注意核查",
    observed = as.character(trap1), threshold = as.character(correct_answer))]
TRAP1_FLAG <- unique(TRAP1_FLAG_DT$ID)
cat("[第二天] IAT:", length(IAT_FLAG), " ALT1:", length(ALT1_FLAG),
    " trap1(可判", nrow(t1_first), "人):", length(TRAP1_FLAG), "\n")

## ---- 第三天：SRET + ALT2 + trap2 ----
sret <- fread_utf8(PATH_SRET, select = c("ID","screen_id","word","identity","responses","person","rt","correct"))
sret[, rt := suppressWarnings(as.numeric(rt))]
rj1 <- sret[screen_id == "RJ_formal1" & !(word %in% FILLER_RJ)]
rj1[, sdt := fcase(identity=="old" & responses %in% c("familiar","old"), "H",
                   identity=="old" & responses=="new", "M",
                   identity=="new" & responses %in% c("familiar","old"), "FA",
                   identity=="new" & responses=="new", "CR", default=NA_character_)]
rec <- rj1[, .(H=sum(sdt=="H"), M=sum(sdt=="M"), FA=sum(sdt=="FA"), CR=sum(sdt=="CR")), by=ID]
rec[, recognition := (H+CR)/(H+CR+M+FA)]
SRET_REC_FLAG_DT <- rec[recognition < SRET_REC,
  .(ID, flag_criterion="SRET_recognition", detail="整体再认",
    observed=as.character(round(recognition,4)), threshold="<0.55")]
SRET_REC_FLAG <- unique(SRET_REC_FLAG_DT$ID)
rj2 <- sret[screen_id == "RJ_formal_2" & !(word %in% FILLER_RJ)]
src <- rj2[, .(n=.N, less200=sum(rt < SRET_SRC_RT, na.rm=TRUE)), by=ID]; src[, less_200 := less200/n]
SRET_SRC_FLAG_DT <- src[less_200 > SRET_SRC_PROP,
  .(ID, flag_criterion="SRET_source_RT", detail=paste0("来源判断 rt<",SRET_SRC_RT,"ms 占比"),
    observed=as.character(round(less_200,4)), threshold=">0.30")]
SRET_SRC_FLAG <- unique(SRET_SRC_FLAG_DT$ID)

alt2 <- copy(ALT2_FORMAL)
alt2[, `:=`(rt=suppressWarnings(as.numeric(rt)), correct=suppressWarnings(as.numeric(correct)))]
alt2[is.na(correct), correct := 0]
alt2[, ok := as.integer(correct==1 & !is.na(rt) & rt>=RT_MIN & rt<=RT_MAX)]
alt2_c1 <- alt2[, .(n=.N, ncor=sum(ok, na.rm=TRUE)), by=.(ID,domain_d,person_d,identity,valence_d)][, acc:=ncor/n]
ALT2_FLAG1 <- unique(alt2_c1[, .(bad=any(acc<ALT2_ACC)), by=ID][bad==TRUE, ID])
alt2_c2 <- alt2[, .(n=.N, ncor=sum(ok, na.rm=TRUE)), by=.(ID,domain_d)][, acc:=ncor/n]
ALT2_FLAG2 <- unique(alt2_c2[, .(bad=any(acc<ALT2_DOMAIN_ACC)), by=ID][bad==TRUE, ID])
alt2_w1 <- alt2_c1[acc<ALT2_ACC, .(acc=min(acc), cond=paste(domain_d,person_d,identity,valence_d,sep="_")[which.min(acc)]), by=ID]
alt2_w2 <- alt2_c2[acc<ALT2_DOMAIN_ACC, .(acc2=min(acc), cond2=domain_d[which.min(acc)]), by=ID]
ALT2_FLAG_DT <- rbindlist(list(
  alt2_w1[, .(ID, flag_criterion="ALT2_condition_accuracy", detail=cond, observed=as.character(round(acc,4)), threshold="<0.20")],
  alt2_w2[!(ID %in% alt2_w1$ID), .(ID, flag_criterion="ALT2_domain_accuracy", detail=cond2, observed=as.character(round(acc2,4)), threshold="<0.60")]
), fill=TRUE)
ALT2_FLAG <- union(ALT2_FLAG1, ALT2_FLAG2)

## trap2：day3 raw survey 试次（有 trap2_item 的行），每人最早一行，取值 >=4 为未达标（sde.js：选1-3正确）
t2raw <- fread_zip(PATH_ZIP_D3, select = c("ID","trial_index","trial_type","trap2","trap2_item"))
t2 <- t2raw[trial_type == "survey-template" & !is.na(trap2_item) & !is.na(ID)]
setorder(t2, ID, trial_index); t2_first <- t2[, .SD[1], by = ID]
TRAP2_FLAG_DT <- t2_first[trap2 >= 4,
  .(ID, flag_criterion="trap2_bogus", detail=trap2_item, observed=as.character(trap2), threshold="1-3")]
TRAP2_FLAG <- unique(TRAP2_FLAG_DT$ID)
cat("[第三天] SRET_rec:", length(SRET_REC_FLAG), " SRET_src:", length(SRET_SRC_FLAG),
    " ALT2:", length(ALT2_FLAG), " trap2(可判", nrow(t2_first), "人):", length(TRAP2_FLAG), "\n")

## ---- 严格时间线归类 ----
D2_FLAG_DT <- rbindlist(list(IAT_FLAG_DT, ALT1_FLAG_DT, TRAP1_FLAG_DT), fill=TRUE)
D3_FLAG_DT <- rbindlist(list(SRET_REC_FLAG_DT, SRET_SRC_FLAG_DT, ALT2_FLAG_DT, TRAP2_FLAG_DT), fill=TRUE)
D2_FLAG <- unique(D2_FLAG_DT$ID); D3_FLAG <- unique(D3_FLAG_DT$ID)

universe <- setdiff(INITIAL_SAMPLE, "NA")
res <- rbindlist(lapply(universe, function(id) {
  ff <- NA_integer_
  if (id %in% D1 && id %in% AGE_IDS) ff <- 1L
  else if (id %in% S2 && id %in% D2_FLAG) ff <- 2L
  else if (id %in% S3 && id %in% D3_FLAG) ff <- 3L
  if (is.na(ff)) return(NULL)
  dt <- if (ff == 1L) D1_FLAG_DT[ID == id] else if (ff == 2L) D2_FLAG_DT[ID == id] else D3_FLAG_DT[ID == id]
  dts <- unique(dt, by = c("flag_criterion","detail"))
  att <- attend_of(id)
  att_sessions <- if (att == "") integer(0) else as.integer(strsplit(att, ",")[[1]])
  subs <- setdiff(att_sessions, 1:ff)
  data.table(
    ID = id,
    fail_day = c("Day1","Day2","Day3")[ff],
    fail_session = ff,
    fail_label = c("第一天（Day1 问卷/筛查）","第二天（Day2 IAT+SMT几何+hsns）","第三天（Day3 SMT自我参照+SRET+sde）")[ff],
    in_day1_questionnaire = ifelse(id %in% D1, "Y", "N"),
    criteria = paste(dts$flag_criterion, collapse = "; "),
    criteria_detail = paste(ifelse(is.na(dts$detail), "", dts$detail), collapse = " | "),
    observed_vs_threshold = paste(sprintf("%s vs %s", dts$observed, dts$threshold), collapse = " | "),
    attended_sessions = att,
    continued_after_fail = ifelse(length(subs) > 0, "Y", "N"),
    subsequent_sessions = if (length(subs) == 0) "" else paste(subs, collapse = ",")
  )
}), fill = TRUE)
setorder(res, fail_session, ID)
stopifnot(!any(duplicated(res$ID)), nrow(res) == uniqueN(res$ID))

out_path <- P("04_code_and_reproducibility/timeline_quality_screen.csv")
fwrite(res, out_path, bom = TRUE)

cat("\n==== 严格时间线筛选汇总 ====\n")
cat("初始样本 791；其中记录为不合格:", nrow(res), "人\n")
print(res[, .N, by = .(fail_session, fail_label)][order(fail_session)])
cat("\n各天按判据拆分（当天该判据命中的唯一被试数，含重叠）:\n")
print(rbindlist(list(
  D1_FLAG_DT[, .(session=1L, n=uniqueN(ID)), by=.(criterion=flag_criterion)],
  D2_FLAG_DT[, .(session=2L, n=uniqueN(ID)), by=.(criterion=flag_criterion)],
  D3_FLAG_DT[, .(session=3L, n=uniqueN(ID)), by=.(criterion=flag_criterion)]
))[order(session,criterion)])
cat("\n各天并集(未去重前): 第一天", length(AGE_IDS), " 第二天", length(D2_FLAG),
    " 第三天", length(D3_FLAG), "\n")
cat("其中不在 Day1 问卷者（任务文件独有）被列入:", nrow(res[!ID %in% D1]), "\n")
cat("各天失败的被试是否在最终 503:", length(intersect(res$ID, FINAL503)), "\n")
cat("\n失败后又继续参加的人次:", nrow(res[continued_after_fail=="Y"]), "\n")
cat("输出:", out_path, "\n")
