# Analysis

当前派生指标实现统一位于analysis.Rmd：02清洗数据、606池、160个问卷条目和26个行为指标、九个CSV正式输出及独立核验。

`Technical_Validation.qmd` 使用 `analysis.Rmd` 自动生成的无身份标识统计CSV，动态呈现描述统计、信度、Cohen's d及独立核验结果。每次运行主分析后重新渲染 qmd，即可更新报告表格。打开 qmd 可使用编辑器自带的 Render 按钮；macOS 也可双击 `render_technical_validation.command` 输出并打开 HTML。


项目根目录命令：
- Rscript 04_code_and_reproducibility/analysis/run_analysis_current.R --install
- Rscript 04_code_and_reproducibility/analysis/run_analysis_current.R --mode=validate


两版被试排除名单和合并筛查脚本位于同级subject _screening。

