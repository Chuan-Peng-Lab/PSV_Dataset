# Reproduce the historical 606 and strict 466 exclusion lists.
# Age/trap decisions and observed metrics come from the preserved historical ledgers.
suppressPackageStartupMessages(library(data.table))

script <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[1])
script <- gsub("~+~", " ", script, fixed=TRUE)
script <- normalizePath(script)

find_root <- function(path) {
  path <- normalizePath(path, mustWork=TRUE)
  if (!dir.exists(path)) path <- dirname(path)
  repeat {
    if (dir.exists(file.path(path, "02_cleaned")) &&
        dir.exists(file.path(path, "04_code_and_reproducibility"))) return(path)
    parent <- dirname(path)
    if (identical(parent, path)) stop("Cannot locate the project root.")
    path <- parent
  }
}

root <- find_root(dirname(script))
output_dir <- dirname(script)
legacy_dir <- file.path(root, "04_code_and_reproducibility", "subject _screening")
read_csv <- function(path) fread(path, encoding="UTF-8", na.strings=c("", "NA"), showProgress=FALSE)

# Targeted task-level amendment, independent of unavailable historical inputs.
# Run from the project: Rscript "04_code_and_reproducibility/subject _screening/subject_screening.R" --exclude-sret-incomplete
# This is a confirmed individual decision, not a new blanket missing-response rule.
if ("--exclude-sret-incomplete" %in% commandArgs(TRUE)) {
  target <- "phase_017_subj_16"
  clean_file <- file.path(root, "02_cleaned", "SRET_cleaned.csv")
  log_file <- file.path(output_dir, "excluded_task_data.csv")
  backup_dir <- file.path(output_dir, "archive", "sret_exclusion_20261028")
  backup_file <- file.path(backup_dir, "SRET_cleaned.csv")
  x <- read_csv(clean_file)
  if (!target %in% x$ID) {
    stopifnot(uniqueN(x$ID) == 482L, file.exists(log_file), file.exists(backup_file))
    log <- read_csv(log_file)
    stopifnot(nrow(log[ID == target & task == "SRET"]) == 1L)
    cat("Already applied: SRET 482 participants; exclusion record exists.\n")
    quit(save="no", status=0)
  }
  z <- x[ID == target]
  rec <- z[screen_id == "RJ_formal1"]
  stopifnot(uniqueN(x$ID) == 483L, nrow(z) == 355L,
            identical(unique(z$ParticipantID), 74L), nrow(rec) == 160L,
            sum(rec$recognition_scoring_correct) == 109L,
            sum(rec$recognition_response_missing) == 1L)
  protected <- c(list.files(file.path(root,"02_cleaned"), pattern="[.](csv|zip)$",full.names=TRUE),
                 list.files(file.path(root,"03_derived"), pattern="[.]csv$",full.names=TRUE),
                 file.path(output_dir,c("excluded_subjects_606.csv","excluded_subjects_466.csv","valid_data.csv")))
  protected <- setdiff(protected, clean_file)
  hashes <- tools::md5sum(protected)
  dir.create(backup_dir, recursive=TRUE, showWarnings=FALSE)
  if (!file.exists(backup_file)) stopifnot(file.copy(clean_file, backup_file))
  stopifnot(identical(unname(tools::md5sum(clean_file)), unname(tools::md5sum(backup_file))))
  y <- x[ID != target]
  stopifnot(nrow(y) == 160720L, uniqueN(y$ID) == 482L)
  entry <- data.table(ID=target, ParticipantID=74L, task="SRET", exclusion_level="任务级",
    exclusion_reason="再认作答不完整；正确率达标，按用户确认仅剔除该人的SRET数据",
    recognition_trials=160L, recognition_correct=109L, recognition_missing=1L,
    recognition_accuracy=109/160, removed_rows=nrow(z),
    scope="全部SRET阶段；其他任务、问卷及606/466被试级名单不变",
    decision_date="2026-10-28", source_file="02_cleaned/SRET_cleaned.csv",
    backup_file="archive/sret_exclusion_20261028/SRET_cleaned.csv")
  log <- if (file.exists(log_file)) read_csv(log_file) else entry[0]
  log <- rbindlist(list(log[!(ID == target & task == "SRET")],entry),use.names=TRUE,fill=TRUE)
  staged <- tempfile("sret-",tmpdir=backup_dir,fileext=".csv")
  fwrite(y, staged, bom=TRUE, na="")
  check <- read_csv(staged)
  stopifnot(isTRUE(all.equal(as.data.frame(check),as.data.frame(y),tolerance=1e-14)),
            !target %in% check$ID, uniqueN(check$ID)==482L)
  fwrite(log, log_file, bom=TRUE, na="")
  stopifnot(file.rename(staged,clean_file),identical(tools::md5sum(protected),hashes))
  cat("PASS: removed 355 SRET rows; 482 participants / 160720 rows remain. Other data and cohort lists unchanged.\n")
  quit(save="no",status=0)
}

# The 777-person source table contains the established screening variables and order.
screen <- read_csv(file.path(legacy_dir, "recomputed_screening_all_777.csv"))
ledger <- read_csv(file.path(legacy_dir, "exclusion_ledger_three_layer.csv"))
stopifnot(nrow(screen) == 777L, !anyNA(screen$ID), !anyDuplicated(screen$ID))

age_ids <- ledger[subject_exclusion_stage == "age", ID]
trap1_ids <- ledger[subject_exclusion_stage == "trap1_attention", ID]
trap2_ids <- ledger[subject_exclusion_stage == "trap2_attention", ID]

screen[, `:=`(
  age_failed = ID %in% age_ids,
  trap1_failed = ID %in% trap1_ids,
  trap2_failed = ID %in% trap2_ids,
  day2_task_failed = IAT_status == "fail" | SMT1_status == "fail",
  day3_task_failed = SRET_recognition_status == "fail" |
    SRET_source_RT_status == "fail" | SMT2_status == "fail"
)]

# 606 version: exclude age, first attrition, trap1, second attrition, and trap2.
screen[, reason_606 := fcase(
  age_failed, "age",
  !attended_day2, "dropout_after_day1",
  trap1_failed, "trap1_attention",
  !day2_task_failed & !attended_day3, "dropout_after_day2",
  attended_day3 & trap2_failed, "trap2_attention",
  default="none"
)]

# Strict 466 version: first failure in the day-by-day screening sequence.
screen[, reason_466 := fcase(
  age_failed, "age",
  !attended_day2, "dropout_after_day1",
  day2_task_failed | trap1_failed, "quality_day2",
  !attended_day3, "dropout_after_day2",
  day3_task_failed | trap2_failed, "quality_day3",
  !attended_day4, "dropout_after_day3",
  default="none"
)]

stopifnot(
  all(screen$reason_606 == screen$hard_exclusion_reason),
  all(screen$reason_466 == screen$strict_exclusion_reason),
  sum(screen$reason_606 != "none") == 171L,
  sum(screen$reason_466 != "none") == 311L,
  sum(screen$reason_606 == "none") == 606L,
  sum(screen$reason_466 == "none") == 466L
)

retained_606 <- read_csv(file.path(legacy_dir, "retained_606_IDs.csv"))$ID
retained_466 <- read_csv(file.path(legacy_dir, "recomputed_retained_466.csv"))$ID
stopifnot(
  setequal(screen[reason_606 == "none", ID], retained_606),
  setequal(screen[reason_466 == "none", ID], retained_466)
)

reason_606_zh <- c(
  age="年龄不符合要求",
  dropout_after_day1="第1次后失访：未参加第2次",
  trap1_attention="trap1答错（第2次）",
  dropout_after_day2="第2次后失访：未参加第3次",
  trap2_attention="trap2≥4（第3次）"
)
reason_466_zh <- c(
  age="年龄不符合要求",
  dropout_after_day1="第1次后失访：未参加第2次",
  quality_day2="第2次质量未通过",
  dropout_after_day2="第2次后失访：未参加第3次",
  quality_day3="第3次质量未通过",
  dropout_after_day3="第3次后失访：未参加第4次"
)

# Keep only the person-level exclusion records; non-subject ledger rows are omitted.
detail_606 <- read_csv(file.path(legacy_dir, "excluded_subjects_171.csv"))
detail_606 <- detail_606[ID %in% screen$ID]
stopifnot(nrow(detail_606) == 171L, !anyDuplicated(detail_606$ID))
reason_by_id_606 <- setNames(screen$reason_606, screen$ID)
detail_606 <- detail_606[, .(
  ID,
  ParticipantID,
  `排除原因` = unname(reason_606_zh[reason_by_id_606[ID]]),
  `排除阶段` = subject_exclusion_day,
  `具体判据` = exclusion_criterion_detail,
  `参加场次` = sessions_attended,
  `观测值` = observed_metrics
)]
stopifnot(all(!is.na(detail_606$`排除原因`)))
setorder(detail_606, ID)

detail_466 <- read_csv(file.path(legacy_dir, "removal_ledger_777_to_466.csv"))
detail_466 <- detail_466[ID %in% screen$ID]
stopifnot(nrow(detail_466) == 311L, !anyDuplicated(detail_466$ID))
reason_by_id_466 <- setNames(screen$reason_466, screen$ID)
detail_466 <- detail_466[, .(
  ID,
  ParticipantID,
  `排除原因` = unname(reason_466_zh[reason_by_id_466[ID]]),
  `排除阶段` = removal_stage_zh,
  `触发任务或判据` = criteria_hit_zh,
  `参加场次` = sessions_attended,
  `观测值` = observed_metrics
)]
stopifnot(all(!is.na(detail_466$`排除原因`)))
setorder(detail_466, ID)

fwrite(detail_606, file.path(output_dir, "excluded_subjects_606.csv"), bom=TRUE, na="")
fwrite(detail_466, file.path(output_dir, "excluded_subjects_466.csv"), bom=TRUE, na="")

cat("PASS: 606 version = 171 excluded / 606 retained; strict 466 version = 311 excluded / 466 retained.\n")
