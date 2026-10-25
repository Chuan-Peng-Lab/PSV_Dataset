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
