# Execute only the current manuscript figure block in analysis.Rmd.
args <- commandArgs(FALSE)
script <- sub("^--file=", "", args[grepl("^--file=", args)])
analysis_dir <- dirname(normalizePath(script))
rmd <- readLines(file.path(analysis_dir, "analysis.Rmd"), warn=FALSE)
start <- grep("^```\\{r manuscript_figures_current", rmd)
stopifnot(length(start)==1L)
end <- which(seq_along(rmd)>start & rmd=="```")[1]
env <- new.env(parent=globalenv())
env$root <- normalizePath(file.path(analysis_dir, "..", ".."))
eval(parse(text=rmd[(start+1):(end-1)]), envir=env)
