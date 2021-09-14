context("Stability")

test_that("Test spectral radius ", {
    skip_on_cran()
    th <- threshold_setup()
    A <- matrix(c(1, 3, 2, 0), 2, 2)
    expect_equal(th$spectral_radius(A), 3)
})

test_that("Test JSR, CJSR, SCJSR", {
    skip_on_cran()
    th <- threshold_setup()
    A1 <- matrix(c(1, 2, -1, 1), 2, 2)
    A2 <- matrix(c(1, 1, -1, 1), 2, 2)
    A3 <- matrix(c(3, 1, -2, 0), 2, 2)
    A4 <- matrix(c(-2, 1, 0, -1), 2, 2)
    Sigma <- list(A1, A2, A3, A4)
    A1 <- matrix(c(1, 2, -1, 1), 2, 2)
    A2 <- matrix(c(1, 1, -1, 1), 2, 2)
    A3 <- matrix(c(3, 1, -2, 0), 2, 2)
    A4 <- matrix(c(-2, 1, 0, -1), 2, 2)
    E1 <- matrix(c(1, 0, 0, 1), 2, 2)
    D <- matrix(c(0, 0), 1, 2)
    X1 <- list(E1, D)
    E2 <- matrix(c(1, 0, 0, -1), 2, 2)
    X2 <- list(E2, D)
    E3 <- matrix(c(-1, 0, 0, 1), 2, 2)
    X3 <- list(E3, D)
    E4 <- matrix(c(-1, 0, 0, -1), 2, 2)
    X4 <- list(E4, D)
    X <- list(X1, X2, X3, X4)
    G <- th$automaton_constructor(Sigma)
    s <- th$discreteswitchedsystem(Sigma, G, X)
    gamma_sdp <- th$sdpbound_gamma(s)
    gamma_sos <- th$sosbound_gamma(s, 2)
    expect_true(gamma_sdp <= 2.1)
    expect_true(gamma_sdp >= 2)
    expect_true(gamma_sos <= 2.1)
    expect_true(gamma_sos >= 2)
})
