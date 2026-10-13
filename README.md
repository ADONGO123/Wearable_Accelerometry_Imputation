# Reconstruction Accuracy Does Not Imply Inferential Validity

Reproducibility website using NHANES 2011-2014 hourly accelerometry.
The website is a pre-rendered HTML document, not an R computation service.

## Scope and limitations

The public repository holds a pre-rendered `index.html`, source `index.Rmd`,
and approved aggregate CSVs with MD5 checksums.
The original numbered R scripts, raw NHANES XPT files, and RDS simulation
checkpoints are kept in the original analysis archive pending code review
and preparation of an executable clean-session pipeline.
The public clone alone cannot currently knit `index.Rmd` from source.
It supports independent inspection of aggregate values, not a full rerun.

## Official input data documentation

- NHANES 2011-2012 PAXHR_G: https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2011/DataFiles/PAXHR_G.htm
- NHANES 2013-2014 PAXHR_H: https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2013/DataFiles/PAXHR_H.htm

## Publishing with GitHub Pages

1. Create a GitHub repository and upload the contents of THIS release folder
   to its root (not the original private research directory).
2. In repository Settings -> Pages, select Deploy from a branch,
   branch `main`, folder `/(root)`, then Save.
3. Confirm the live page loads. Check all tables and figures.
4. Keep raw XPT, RDS, .Rhistory, .Rproj.user, and private notes out of git.

## Reproduction status

Original project: 81 numbered scripts. The archived-report site checks
20 primary regression checkpoints, 350 participant-MICE outcome checkpoints,
and 40 BMI checkpoints. Its first-level results tests compare saved
summaries with manuscript tables. Fully independent computational
reproduction remains a separate, not-yet-verified step.
