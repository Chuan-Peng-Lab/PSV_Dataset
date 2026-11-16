# Project .Rprofile -----------------------------------------------------------
# RStudio sets RSTUDIO_PANDOC itself, so Knit works out of the box. When R is
# started from a plain terminal (Rscript), rmarkdown::render() cannot find
# pandoc and stops with "pandoc version 1.12.3 or higher is required".
#
# This block fills that gap by pointing RSTUDIO_PANDOC at a pandoc that is
# already on this machine. It never overrides an existing RSTUDIO_PANDOC, and
# silently does nothing when no candidate is found (e.g. on another machine),
# so it is safe to commit and share.
if (!nzchar(Sys.getenv("RSTUDIO_PANDOC"))) {
  rstudio_tools <- "/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools"
  candidates <- c(
    file.path(rstudio_tools, R.version$arch, "pandoc"),  # "aarch64" or "x86_64"
    file.path(rstudio_tools, "aarch64", "pandoc"),
    file.path(rstudio_tools, "x86_64", "pandoc"),
    "/opt/homebrew/bin/pandoc",                          # Homebrew, Apple Silicon
    "/usr/local/bin/pandoc"                              # Homebrew Intel / official .pkg
  )
  found <- candidates[file.exists(candidates)]
  # RSTUDIO_PANDOC is the directory that *contains* the pandoc executable.
  if (length(found)) Sys.setenv(RSTUDIO_PANDOC = dirname(found[[1L]]))
}
