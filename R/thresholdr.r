#' Set up thresholdr
#'
#' This function initializes Julia and ThresholdStability.jl,
#' installing them if necessary and creating wrappers for the
#' functions in ThresholdStability.jl.
#'
#' @param pkg_check logical, check that ThresholdStability.jl is
#' installed, and install if necessary.
#' @param ... arguments passed down to JuliaCall::julia_setup
#'
#' @examples
#' \dontrun{
#' thresholdr::threshold_setup()
#' }
#'
#' @export

threshold_setup <- function(pkg_check=TRUE,...) {
  julia <- JuliaCall::julia_setup(installJulia = TRUE, ...)
  if (pkg_check) julia$install_package_if_needed("ThresholdStability")
  julia$library("ThresholdStability")
  functions <- julia$eval("isavailable(s::AbstractString)=isascii(s) &&
  !occursin(\"!\", s); filter(isavailable,
  string.(propertynames(ThresholdStability)))")
  th <- JuliaCall::julia_pkg_import("ThresholdStability", functions)
  th2 <- JuliaCall::julia_pkg_import("ThresholdStability", functions)

  th2$add_state <- function(G) {
    julia$call("add_state!", G)
  }

  th2$rem_state <- function(G, st) {
    julia$call("rem_state!", G, as.integer(st))
  }

  th2$add_transition <- function(G, i, j, label) {
    julia$call("add_transition!", G, as.integer(i),
    as.integer(j), as.integer(label))
    G
  }

  th2$CKSVAR_to_TAR <- function(C, Cstar, beta_tilde, nlags,...) {
    out <- th$CKSVAR_to_TAR(C, Cstar, beta_tilde, as.integer(nlags),...)
    out[1]
  }

  th2$CKSVAR_to_TAR_stspace <- function(C, Cstar, beta_tilde, nlags,...) {
    out <- th$CKSVAR_to_TAR(C, Cstar, beta_tilde, as.integer(nlags),...)
    out[2]
}

  th2$CKSVAR_to_companion <- function(C, Cstar, beta_tilde, nlags,...) {
    th$CKSVAR_to_companion(C, Cstar, beta_tilde, as.integer(nlags),...)
  }

  th2$CKSVAR_to_companionFD <- function(F, Fstar, beta_tilde, nlags,...) {
    th$CKSVAR_to_companionFD(F, Fstar, beta_tilde, as.integer(nlags),...)
  }

  th2$GraphAutomaton <- function(nstates) {
    th$GraphAutomaton(as.integer(nstates))
  }

  th2$graphautomaton <- function(nstates) {
    net <- network.initialize(nstates, loops = TRUE)
    net %n% "label" <- matrix(rep(NA, nstates^2), nstates, nstates)
    net
  }

  th2$addr_transition <- function(net, i, j, label) {
    net <<- add.edge(net, i, j)
    L <- get.network.attribute(net, "label")
    L[i, j] <- label
    net %n% "label" <- L
    net
  }

  th2$automaton_r_to_jl <- function(net) {
    G <- th2$GraphAutomaton(get.network.attribute(net, "n"))
    L <- get.network.attribute(net, "label")
    for (i in 1:get.network.attribute(net, "n")) {
      for (j in 1:get.network.attribute(net, "n")) {
        if (is.adjacent(net, i, j)) th2$add_transition(G, i, j, L[i, j])
      }
    }
    G
  }

  th2$get.labels <- function(net) get.network.attribute(net, "label")
  th2$get.label <- function(net, i, j) th2$get.labels(net)[i, j]

  th2$automaton_jl_to_r <- function(G) {
    n <- th$nstates(G)
    net <- th2$graphautomaton(n)
    if (th$isgraphautomaton(G)) {
      for (i in 1:n) {
        for (j in 1:n) {
          if (th$has_transition(G, i, j)) {
            label <- th$event(G, i, j)
            net <- th2$addr_transition(net, i, j, label)
          }
        }
      }
    } else {
      net[,] <- 1
    }
    net
  }

  th2$automaton_constructor <- function(A, need_return="Julia") {
    julia$assign("B", A)
    B <- julia$eval("Vector{Array{Float64, 2}}(B)")
    if (need_return == "R") {
      G <- th$automaton_constructor(B)
      net <- th2$automaton_jl_to_r(G)
      net
    } else {
      G <- th$automaton_constructor(B)
      G
    }
  }

  th2$discreteswitchedsystem <- function(A, G, X) {
    julia$assign("A", A)
    julia$eval("A = Vector{Array{Float64, 2}}(A)")
    julia$assign("G", G)
    julia$assign("X", X)
    julia$eval("X = Vector{Array{Array{Float64, 2}}}(X)")
    s <- julia$eval("discreteswitchedsystem(A, G, X)")
    s
  }

  th2$sosbound_gamma <- function(s, d) th$sosbound_gamma(s, as.integer(d))
  th2
}
