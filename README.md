# PMD-FDR-for-Galaxy-P
Monolithic script and example batch file for PMD-FDR. This code was developed in part as preparation for a paper...

## Files
_PMD_FDR_package_for_Galaxy.R_ - combines 4 files across 3 projects, allowing all of the pieces to live in one place

_example_batch_file.cmd_ - a sample batch file that shows how to pass parameters to the R script

_Actual_psm_report.tabular_ - a sample dataset, derived from the Pyrococcus dataset (which was derived from ...)

## Future work
All of the underlying structures have been developed using test-driven development -- I intend to include the test files (and test structures) in the near future. These will also offer clues in how to use the various packages included here; i.e. each test is, in effect, a vignette with a practical demonstration of at least one requirement.

# Input

## Parameters

--psm_report <file_path>
+ full name and path to the PSM report (required input file)

--psm_report_1_percent <file_path>
+ full name and path to the PSM report for 1% FDR (optional input file)

--output_i_fdr <file_path>
+ full name and path to the individual FDR (iFDR) output file (optional output file)

--output_g_fdr <file_path>
+ full name and path to the global FDR (gFDR) output file (optional output file)

--output_densities <file_path>
+ full name and path to the densities output file (optional output file)

--input_file_type <file_path>
+ full name and path to the densities output file (required type from: PMD_FDR_file_type, PSM_Report, MaxQuant_Evidence)

## Input files

Currently PMD-FDR supports three file types: PMD_FDR_file_type, PSM_Report, MaxQuant_Evidence. For unsupported types, it should be relatively straightforward to convert an output file into PMD_FDR_file_type.

### Input PMD_FDR_file_type

__### Editing is currently in process ###__

### Input PSM_Report

### Input MaxQuant_Evidence

# Output


