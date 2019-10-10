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
  - Full name and path to the PSM report (required input file)
  - Note that, while this parameter is called "psm_report", we now support two other types of files

--psm_report_1_percent <file_path>
  - Full name and path to the PSM report for 1% FDR (optional input file)

--output_i_fdr <file_path>
  - Full name and path to the individual FDR (iFDR) output file (optional output file)

--output_g_fdr <file_path>
  - Full name and path to the global FDR (gFDR) output file (optional output file)

--output_densities <file_path>
  - Full name and path to the densities output file (optional output file)

--input_file_type <file_path>
  - Full name and path to the densities output file (required type from: PMD_FDR_file_type, PSM_Report, MaxQuant_Evidence)

### Optional Input file: PSM 1% file

At present, this only supports PSM_Report format (see below).  This is simply the PSM_Report from PeptideShaker using a 1% FDR. This file is matched against the Primary Input file, using the spectrum file and title to match records.  If they agree, the record (in the original input) is marked by setting is_one_percent_FDR to TRUE

## Primary Input file

Currently PMD-FDR supports three file types: PMD_FDR_file_type, PSM_Report, MaxQuant_Evidence. For unsupported types, it should be relatively straightforward to convert an output file into PMD_FDR_file_type.

### Input PMD_FDR_file_type

This format is the native format for PMD-FDR; PMD-FDR converts other file types to this one in memory before running the analysis. It is a tab-delimited file where the first row is a list of column names.

The following field names are required (although any others are allowed to exist):

- PMD_FDR_input_score
  - Score must (currently) be 0 to 100, with a substantial number with score of 100.  0 is bad, 100 is good.
- PMD_FDR_pmd
  - Precursor mass discrepancy, in ppm (I’m not sure if the units are a requirement)
- PMD_FDR_spectrum_file
  - Useful when there are more than one input file to the spectrum; guarantees that the normalization of PMD never crosses a file boundary
- PMD_FDR_proteins
  - Required but not very important unless we are talking about the Pyrococcus data (I have hard-coded an understanding of human/pyro/contaminant/decoy)
- PMD_FDR_spectrum_title
  - Useful for ordering the spectra.  I’m not crazy about this design but didn’t think of any alternatives until recently.
- PMD_FDR_sequence
  - Peptide sequence. Its only practical use is so that the algorithm knows the length of the peptide (in amino acids)
- PMD_FDR_decoy
  - Expects 0 for normal, 1 for decoy (presumably reverse-decoy)

### Input PSM_Report

This format is the output of PeptideShaker. We expect it to be a tab-delimited file with the first row being the column labels. The following fields are required for a file to be correctly processed:

- Confidence [%]
  - PeptideShaker Confidence score - represents the probability that the PSM is correct. It can also be thought of as the complement of the local FDR.
  - Becomes PMD_FDR_input_score
- Precursor m/z Error [ppm]
  - Becomes PMD_FDR_pmd
- Spectrum File
  - Becomes PMD_FDR_spectrum_file
- Protein(s)
  - Becomes PMD_FDR_proteins
- Spectrum Title
  - Becomes PMD_FDR_spectrum_title
- Sequence
  - Becomes PMD_FDR_sequence
- Decoy
  - Becomes PMD_FDR_decoy
  
### Input MaxQuant_Evidence

This format is one of the output files from MaxQuant; it is called evidence.txt, found in the result directory. Note that this file has a fundamentally different structure from the expected one: it is a peptide-centric file instead of PSM-centric. However, it appears (from analyzing the Pyrococcus data) that this may be a reasonable compromise.

Note that we do not use file name in this implementation. We are also using Retention Time as a substitute for spectrum index since the actual spectra are scattered through the original data. This is largely irrelevant, however, because we are shutting off our PMD normalization process (MaxQuant does a much better job of normalizing the PMD). We still run our normalization, it just doesn't do very much since the values are already as normalized as they can get.

The following fields are required for correct processing (others can exist):

- PEP
  - We first convert this to a Confidence type score by subtracting from one and multiplying by 100.
  - Further, we force values close to 100 to be 100 (i.e.,  if score is greater than 99.99 it becomes 100)
  - The result of this manipulation is copied to PMD_FDR_input_score
- Mass error [ppm]
  -Copied to PMD_FDR_pmd
- Proteins
  - Copied to PMD_FDR_proteins
- Retention time
  - Copied to PMD_FDR_spectrum_title
  - Note that this is a float but PMD_FDR_spectrum_title is assumed to be text; this difference is invisible to the algorithm and doesn't matter in any case.
- Sequence
  - Copied to PMD_FDR_sequence
- Reverse
  - Convert "" to 0 and "+" to 1
  - The result of this manipulation is copied to PMD_FDR_decoy
  
# Output

This algorithm potentially produces three files as output.  The existance of these files depends on receiving valid file paths as parameters.

## Score ranges
Score ranges are used in all three files. The structure of these fields (and values within a field) is aaa_bbb_cc_dd where

- aaa is the lower bound of the score range
- bbb is the upper bound of the score range
- cc and dd describe the lower bound and upper bound resp:
  - eq - "equal to"
  - ge - "greater than or equal to"
  - gt - "greater than"
  - le - "less than or equal to"
  - lt - "less than"

## i_fdr file

This file contains the individual FDR (iFDR) for each PSM, with supporting evidence

### Field descriptions

- PMD_FDR_spectrum_title     
  - Unique identifier concatenating PMD_FDR_spectrum_file and PMD_FDR_spectrum_index
- value
  - Identical to PMD_FDR_pmd. Implemented this way to allow future alterations that would use input variables other than PMD
- PMD_FDR_decoy              
  - Input variable - 1 for decoy, 0 for other
- median_of_group_index      
  - median PMD for good-training records with the same group_index as the current record
- value_norm                 
  - normalized value (value minus median_of_group_index)
- used_to_find_middle        
  - logical variable reflecting the following statement: was this record used to identify the median_of_group_index? (These records MUST be excluded in any summary statistics.)
- PMD_FDR_input_score        
  - The score used to separate data
- PMD_FDR_pmd                
  - Precursor Mass Discrepancy
- PMD_FDR_peptide_length     
  - Peptide length of identified peptide
- PMD_FDR_spectrum_file      
  - Name of file containing spectrum
- PMD_FDR_spectrum_index     
  - Spectrum number within file
- PMD_FDR_proteins           
  - Protein name
- group_input_score          
  - Grouping by score
- group_pmd                  
  - Grouping by PMD (approx 20 groups)
- group_peptide_length       
  - Grouping by peptide length
- group_training_class       
  - Grouping by Training class, (see notes)
- group_proteins             
  - Grouping by Protein groups (see notes)
- group_spectrum_file        
  - Same as PMD_FDR_spectrum_file
- group_spectrum_index       
  - Contiguous groups of spectra (see notes)
- group_proteins             
  - Grouping by species (however, see notes)
- group_decoy_input_score    
  - decoy version of group_input_score
- group_decoy_pmd            
  - decoy version of group_pmd
- group_decoy_peptide_length 
  - decoy version of group_peptide_length
- group_decoy_spectrum_file  
  - decoy version of group_spectrum_file
- group_decoy_spectrum_index 
  - decoy version of group_spectrum_index
- group_decoy_proteins       
  - decoy version of group_proteins
- is_in_1percent             
  - PSM in 1% FDR file (if it exists)
- value_of_interest          
  - Defunct column (used during processing)
- group_of_interest          
  - Defunct column (used during processing)
- interpolated_groupwise_FDR 
  - estimated gFDR, interpolated from gFDR derived from group_decoy_input_score
- t                          
  - density of t at PMD of record
- f                          
  - density of f at PMD of record
- alpha                      
  - same as interpolated_groupwise_FDR
- i_fdr                      
  - iFDR (alpha*f / (alpha*f + (1-alpha)*t))

### Notes about i_FDR file:
There are several categories of variables in this file, as indicated by the prefix

- PMD_FDR_    - an input variable (exception: PMD_FDR_spectrum_title)
- group_      - a grouping of the dataset into a small number of subsets groups are formed by first trying to place all records into deciles (usually) of the variable but keeping like with like. For example, in our datasets a score of exactly 100 might contain 20% of the dataset - all of these would be in their own group ()
- group_decoy - a grouping of the dataset that puts all decoys into one subset. Each group_decoy_ has a matching group_ column on which it was based.

#### Notes about group_training_class:

This field separates the data into the following groups:

- bad_long      
  - Currently: PSMs identifying decoy peptides  containing at least 11 amino acids
- bad_short    
  - Currently: PSMs identifying decoy peptides  containing less than 11 amino acids
- good_testing  
  - Currently: half the PSMs identifying a non-decoy with at least 11 amino acids
- good_training
  - Currently: half the PSMs identifying a non-decoy with at least 11 amino acids
- other_long   
  - PSMs that are neither good nor bad that identify peptides with at least 11 amino acids
- other_short  
  - PSMs that are neither good nor bad that identify peptides with less than 11 amino acids

#### Notes about group_spectrum_index:

Unlike most group_ variables, this group contains approximately 
100 groups, although it can contain less if the data require it
Each group contains contiguous records and at least 100 "good-training"
records. Also, a group can never cross a file boundary.

#### Notes about group_proteins:
This grouping only exists with specialized inputs to analyze pyrococcus
and should usually be ignored since it will default to "human": 
- human       
  - Default
- pyrococcus  
  - PMD_FDR_proteins contains "pfu_"
- contaminant 
  - PMD_FDR_proteins contains "cRAP"


## alpha file 

File contains the groupwise FDR (gFDR) for each score range

- group_of_interest 
  - name of score group
- alpha             
  - gFDR
  
### Notes about alpha

Note that this number should be a number between 0 and 1
However, it is generated after excluding 
the training data and based on the resulting (random)
peak height of each distribution. 
This means that the gFDR can be greater than 1 in practice
Rather than hide this fact by setting a hard limit,
I decided to let the dirty laundry remain visible - 
If the worst score has a number much greater than 1
then there the density function of False Hits 
should be suspected.
(This is how I discovered the Decoy Mode.)
It is also possible for this number to be less than 0;
this reflects a dataset that appears to be more perfect
than perfection.  This can occur on high scoring data.
During early development this sometimes occured on the
_second-best_ scoring group.  This was how I discovered
the cause of the Decoy Mode (peptide length) - the secondary
scores had a greater abundance of shorter peptides, making
them more likely to have a peptide with the  
correct chemical composition.
In other words, values outside the range of 0 and 1 are possible
and reflect potential issues in the dataset or underlying assumptions
but are not, in and of themselves, indications of errors.

# densities file

File contains a normalized version of the density function applied to up to 13 subsets of the data. All but "x" refers to the subsetting variable. As such, each column, except x, should sum to 1.

- x             
  - center of a range of normalized PMD interval
- t             
  - (estimated) relative abundance of True Hits
- f             
  - (estimated) relative abundance of False Hits
- decoy         
  - relative abundance of decoys (superset of f)
- aaa_bbb_cc_dd 
  - relative abundance of score range; see above for definition of score


