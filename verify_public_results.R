# PUBLIC REPRODUCIBILITY CHECKS
# Run from the repository root / github_pages_release_publication_v2
# Usage: source("verify_public_results.R")
# Only the small, public aggregate CSVs are required.
# These checks reproduce saved manuscript TABLE summaries, not upstream imputation.

safe_read <- function(path) {
  if (!file.exists(path)) stop("Missing public aggregate file: ", path)
  utils::read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
}
base <- file.path("R results", "Final 2011-2014", "Inference")
mask <- file.path(base, "Repeated masking")
outcome <- file.path(mask, "Outcome simulations")
mice <- file.path(outcome, "Outcome aware MICE")
bmi <- file.path("R results", "Real BMI application")

recon <- safe_read(file.path(mask, "all20_reconstruction_summary.csv"))
inference <- safe_read(file.path(outcome, "full_inference_summary.csv"))
tab1 <- safe_read(file.path(outcome, "Manuscript tables", "Table_1_Reconstruction.csv"))
tab2 <- safe_read(file.path(outcome, "Manuscript tables", "Table_2_Inference.csv"))
stopifnot(nrow(recon)==12L, nrow(inference)==13L,
          nrow(tab1)==12L, nrow(tab2)==13L,
          all(recon$replications==20), all(inference$total_simulations==4000))

result <- list()
log_check <- function(label, n, error=0, tolerance=0) {
  if (!is.finite(error) || error>tolerance+1e-14)
    stop("FAIL: ",label,"; discrepancy=",error," (allowed=",tolerance,")")
  result[[length(result)+1L]] <<- data.frame(
    Verification=label, Configurations=n,
    Maximum_absolute_difference=sprintf("%.8f",error),
    Tolerance=sprintf("%.8f",tolerance), Status="PASS",
    check.names=FALSE)
}
compare <- function(source,target,left,right,multiplier=1,tolerance=.0051,label) {
  pair <- merge(source,target,by.x=c("gap_hours","method"),
                by.y=c("Gap_hours","Method"),sort=FALSE)
  if(nrow(pair)!=nrow(target)) stop("Configuration mismatch: ",label)
  diff <- max(abs(pair[[left]]*multiplier-pair[[right]]))
  log_check(label,nrow(pair),diff,tolerance)
}
compare(recon,tab1,"mean_hourly_RMSE","Hourly_RMSE",label="Table 1: hourly RMSE")
compare(recon,tab1,"mean_exposure_RMSE","Exposure_RMSE",label="Table 1: exposure RMSE")
compare(recon,tab1,"mean_exposure_Bias","Exposure_Bias",label="Table 1: exposure bias")
compare(recon,tab1,"mean_projected_beta","Projected_Beta",tolerance=.000051,
        label="Table 1: projected beta")
for (p in list(
  c("mean_beta","Mean_Beta"),c("bias","Bias"),
  c("empirical_SD","Empirical_SD"),c("mean_model_SE","Mean_Model_SE"),
  c("mean_CI_width","Mean_CI_Width")
)) compare(inference,tab2,p[1],p[2],tolerance=.000051,
           label=paste0("Table 2: ",p[2]))
compare(inference,tab2,"coverage","Coverage_percent",multiplier=100,
        tolerance=.0051,label="Table 2: coverage in percentage points")

selection <- safe_read(file.path(mask,"selection_validation.csv"))
stopifnot(nrow(selection)==2L,all(selection$replications==20L),
          sum(selection$minimum_participants)==3635L,
          all(selection$minimum_participants==selection$maximum_participants),
          all(selection$total_missing_starts==0L))
log_check("Reference cohort selection: archived metadata",2L)

theory <- safe_read(file.path(outcome,"theory_alignment_summary.csv"))
tj <- merge(theory,recon,by=c("gap_hours","method"),sort=FALSE)
stopifnot(nrow(tj)==12L)
log_check("FWL projections: archived cross-summary agreement",12L,
          max(abs(tj$mean_projected_beta.x-tj$mean_projected_beta.y)),1e-10)

null <- safe_read(file.path(base,"fixed_mask_beta0_type1_summary.csv"))
stopifnot(nrow(null)==16L,all(null$simulations==500L),
          all(null$false_positives>=0),all(null$false_positives<=500))
log_check("Fixed-mask null simulation: 500-outcome rejection rates",16L,
          max(abs(null$false_positives/null$simulations-null$Type_I_error)),1e-12)

mice1 <- safe_read(file.path(mice,"participant_mice_200outcome_summary.csv"))
mice2 <- safe_read(file.path(mice,"Table_MICE_200_Outcomes.csv"))
stopifnot(nrow(mice1)==3L,nrow(mice2)==3L,
          setequal(mice1$method,mice2$method),all(mice1$outcomes==200))
mice1 <- mice1[order(mice1$method),];mice2 <- mice2[order(mice2$method),]
numcols <- c("mean_beta","bias","empirical_SD","mean_model_SE","coverage","RMSE_beta")
log_check("Outcome-aware MICE: 200-outcome manuscript table",3L,
          max(abs(as.matrix(mice1[numcols])-as.matrix(mice2[numcols]))),1e-10)

mice4 <- safe_read(file.path(mice,"Table_MICE_Four_Assignments.csv"))
stopifnot(nrow(mice4)==12L,all(mice4$outcomes==50),
          setequal(mice4$assignment,1:4),all(is.finite(mice4$RMSE_beta)))
log_check("MICE sensitivity: four 50-outcome assignments",12L)

bmi_summary <- safe_read(file.path(bmi,"final_five_method_real_bmi_summary.csv"))
stopifnot(nrow(bmi_summary)==15L,all(bmi_summary$masks==20L),
          all(is.finite(bmi_summary$mean_beta_difference)))
log_check("Observed BMI: 15 published method-gap summaries",15L,
          max(abs(bmi_summary$mean_beta_difference -
                    (bmi_summary$mean_imputed_beta-bmi_summary$mean_reference_beta))),1e-10)

report <- do.call(rbind,result)
print(report,row.names=FALSE,right=FALSE)
utils::write.csv(report,"PUBLIC_VERIFICATION_REPORT.csv",row.names=FALSE)
cat("\nPASS: ",nrow(report)," aggregate reproduction checks passed. ",
    "Saved manuscript Tables 1 and 2 agree within their rounding precision.\n",
    "Report: PUBLIC_VERIFICATION_REPORT.csv\n",
    "NOTE: This verifies published aggregate tables; it does not rerun original imputation or simulations.\n",
    sep="")
