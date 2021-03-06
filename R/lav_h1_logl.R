# compute logl for the unrestricted (h1) model -- per group
lav_h1_logl <- function(lavdata        = NULL,
                        lavsamplestats = NULL,
                        lavoptions     = NULL) {

    # number of groups
    ngroups <- lavdata@ngroups

    logl.group <- rep(as.numeric(NA), ngroups)

    # should compute logl, or return NA?
    logl.ok <- FALSE
    if(lavoptions$estimator %in% c("ML", "MML")) {
        # check if everything is numeric, OR if we have exogenous
        # factor with 2 levels only
        if(all(lavdata@ov$type == "numeric")) {
            logl.ok <- TRUE
        } else {
            not.idx <- which(lavdata@ov$type != "numeric")
            for(i in not.idx) {
                if(lavdata@ov$type[i] == "factor" &&
                   lavdata@ov$exo[i] == 1L &&
                   lavdata@ov$nlev[i] == 2L) {
                    logl.ok <- TRUE
                } else {
                    logl.ok <- FALSE
                    break
                }
            }
        }
    }

    if(logl.ok) {    
        for(g in seq_len(ngroups) ) {
            if(lavdata@nlevels > 1L) {
                # not ready yet:
                # - we need to fit the saturated model first
                logl.group[g] <- as.numeric(NA)

            } else if(lavsamplestats@missing.flag) {
                logl.group[g] <-
                    lav_mvnorm_missing_loglik_samplestats(
                        Yp    = lavsamplestats@missing[[g]],
                        Mu    = lavsamplestats@missing.h1[[g]]$mu,
                        Sigma = lavsamplestats@missing.h1[[g]]$sigma)
            } else { # single-level, complete data
                # all we need is: logdet of covariance matrix, nobs and nvar
                if(lavoptions$conditional.x) {
                    logl.group[g] <-
                        lav_mvnorm_h1_loglik_samplestats(
                            sample.cov.logdet =
                                lavsamplestats@res.cov.log.det[[g]],
                            sample.nvar       = 
                                NCOL(lavsamplestats@res.cov[[g]]),
                            sample.nobs       = lavsamplestats@nobs[[g]])
                } else {
                    logl.group[g] <-
                        lav_mvnorm_h1_loglik_samplestats(
                            sample.cov.logdet = lavsamplestats@cov.log.det[[g]],
                            sample.nvar       = NCOL(lavsamplestats@cov[[g]]),
                            sample.nobs       = lavsamplestats@nobs[[g]])
                }
            } # complete
        } # g
    } # logl.ok is TRUE

    out <- list(loglik       = sum(logl.group),
                loglik.group = logl.group)

    out
}
