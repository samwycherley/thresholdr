context("CKSVAR")

test_that("Test CKSVAR functions", {
    skip_on_cran()
    th <- threshold_setup()
    C <- matrix(c(1, 2, -3, 4, 5, 6, -6, 5, 4, -3,
    2, 1, 9, -8, 7, 6, 5, 4), 3, 6)
    Cstar <- matrix(c(1, 0, -1, 1, 0, 1), 3, 2)
    Fstar <- matrix(c(1, -1, 0), 3, 1)
    beta_tilde <- c(0, -1)
    TAR_out <- th$CKSVAR_to_TAR(C, Cstar, beta_tilde, 2)[[1]][[4]]
    expect_equal(TAR_out, matrix(c(1, 2, -3, 1, 0, 0,
    4, 5, 6, 0, 1, 0,
    5, 5, 5, 0, 1, 1,
    -3, 2, 1, 0, 0, 0,
    9, -8, 7, 0, 0, 0,
    1, 0, 1, 0, 0, 0), 6, 6))
    # no test for CKSVAR_to_TAR_st
    comp_out <- th$CKSVAR_to_companion(C, Cstar, beta_tilde, 2)[[1]]
    expect_equal(comp_out, matrix(c(1, 2, -3, 1, 0, 0, 0,
    4, 5, 6, 0, 1, 0, 0,
    -5, 5, 3, 0, 0, 1, 1,
    -3, 2, 1, 0, 0, 0, 0,
    9, -8, 7, 0, 0, 0, 0,
    6, 5, 4, 0, 0, 0, 0,
    1, 0, 1, 0, 0, 0, 0), 7, 7))
    compfd_out <- th$CKSVAR_to_companionFD(C, Fstar, beta_tilde, 2)[[1]]
    expect_equal(compfd_out, matrix(c(1, 2, -3, 1, 0, 0,
    4, 5, 6, 0, 1, 0,
    -5, 4, 5, 0, 0, 1,
    -3, 2, 1, 0, 0, 0,
    9, -8, 7, 0, 0, 0,
    0, 0, 0, 0, 0, 0), 6, 6))
    compfd_outf <- th$CKSVAR_to_companionFD(C, Fstar, beta_tilde, 2, diff=FALSE)[[1]]
    expect_equal(compfd_outf, matrix(c(1, 2, -3, 1, 0, 0, 0,
    4, 5, 6, 0, 1, 0, 0,
    -5, 4, 5, 0, 0, 1, 1,
    -3, 2, 1, 0, 0, 0, 0,
    9, -8, 7, 0, 0, 0, 0,
    6, -5, -4, 0, 0, 0, 0,
    -1, 1, 0, 0, 0, 0, 0), 7, 7))
})