REM ###############################################################################
REM # example_batch_file.cmd                                                      #
REM #                                                                             #
REM # Project 021 - PMD-FDR for Galaxy-P                                          #
REM #                                                                             #
REM # Description: Example of calling the PMD-FDR code, with parameters           #
REM #                                                                             #
REM ###############################################################################

set   proj_dir=D:\Professional\Programming\R\Project 021 - PMD-FDR for Galaxy-P\
set r_proj_dir=D:/Professional/Programming/R/Project 021 - PMD-FDR for Galaxy-P/
set r_data_dir=%r_proj_dir%
set r_output_dir=%r_proj_dir%
set prog=C:\Program Files\R\R-3.5.1\bin\x64\Rscript.exe

set script_name=PMD_FDR_package_for_Galaxy.R

set script_full_name=%proj_dir%%script_name%

REM  # --psm_report            full name and path to the PSM report
REM  # --psm_report_1_percent  full name and path to the PSM report for 1% FDR
REM  # --output_i_fdr          full name and path to the i-FDR output file 
REM  # --output_g_fdr          full name and path to the g-FDR output file 
REM  # --output_densities      full name and path to the densities output file 
REM  # --input_file_type       type of input file (currently supports "PSM_Report" and "PMD_FDR_input_file") 

set param_psm_report=--psm_report "%r_data_dir%input.tabular"
set param_psm_report_1_percent=--psm_report_1_percent "%r_data_dir%input_1_percent.tabular"
set param_psm_output_densities=--output_densities "%r_output_dir%output_densities.tabular"
set param_psm_output_g_fdr=--output_g_fdr "%r_output_dir%output_g_fdr.tabular"
set param_psm_output_i_fdr=--output_i_fdr "%r_output_dir%output_i_fdr.tabular"
set param_psm_input_file_type=--input_file_type "PSM_Report"

set params=%param_psm_report% %param_psm_report_1_percent% %param_psm_output_densities% %param_psm_output_g_fdr% %param_psm_output_i_fdr% %param_psm_input_file_type

cd "%proj_dir%"
"%prog%" "%script_name%" %params%
pause  

