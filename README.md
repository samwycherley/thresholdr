# thresholdr

[![R-CMD-check](https://github.com/samwycherley/thresholdr/workflows/R-CMD-check/badge.svg)](https://github.com/samwycherley/thresholdr/actions)  

thresholdr is an R package providing a convenient wrapper for [ThresholdStability.jl](https://github.com/samwycherley/ThresholdStability.jl), a Julia package providing tools to determine the stability of threshold vector autoregressive models.

## Installation
The package can be installed directly from GitHub using
```r
devtools::install_github("samwycherley/thresholdr")
```
This package relies on [JuliaCall](https://cran.r-project.org/web/packages/JuliaCall/index.html), an R interface to Julia. You might initially need to take some additional steps to set this interface up - instructions can be found [here](https://github.com/Non-Contradiction/JuliaCall#troubleshooting-and-ways-to-get-help).

## Usage
To initialize the package, use
```r
library(thresholdr)
th <- threshold_setup()
```
This will install Julia and ThresholdStability.jl if they are not installed already.

The first time the package is initialized might take a while as ThresholdStability.jl needs to precompile. If it appears stuck indefinitely at the message `"Loading setup script for JuliaCall..."`, however, this may be a sign that JuliaCall has not been set up properly, in which case you may need to take the additional steps mentioned above.

### Functions
Much like other R wrappers for Julia packages, such as [diffeqr](https://github.com/SciML/diffeqr), thresholdr mostly provides a direct wrapper over the Julia functions, and the namespace is set-up so that the names of the R wrapper functions coincide with that of the functions in ThresholdStability.jl.

Some important exceptions:
- functions are prefaced with `th$`.
- those functions that end in `!` in Julia, such as `add_transition!` (standard syntax in Julia for functions that modify an object in-place.) In thresholdr, these are renamed without the `!`, so `add_transition!` becomes `add_transition`. 
- those functions featuring Greek letters in ThresholdStability.jl: `sdp_γ` and `sos_γ`. ThresholdStability.jl includes aliases `sdp_gamma` and `sos_gamma` for these functions, which can be called from thresholdr.
- `CKSVAR_to_TAR` is split into two functions: `CKSVAR_to_TAR` which returns the set of matrices `Σ` and `CKSVAR_to_TAR_st_space` which returns the set of state space constraint matrices `X`.
- `discreteswitchedsystem` now requires all three arguments (set of matrices `Σ`, automaton `G`, state space constraint set `X`.)

Functions can return either an R object or a Julia object, and this can be specified by including `need_return="R"` or `need_return="Julia"` as an argument in thresholdr functions. Some Julia objects, such as automata or hybrid systems, cannot be converted to R objects automatically.

To convert a CKSVAR model and calculate the JSR, CJSR or SCJSR, we might run something like the following:
```r
C =...  # some appropriately sized matrix(c(...), nc, nr)
Cstar = ...  # "
beta_tilde = ... # some c(...)
nlags = 2  # some integer

Sigma <- th$CKSVAR_to_TAR(C, Cstar, beta_tilde, nlags)  # returns an R object
G <- th$automaton_constructor(Sigma)
X <- th$CKSVAR_to_TAR(C, Cstar, beta_tilde, nlags)  # returns a Julia object as default
s <- th$discreteswitchedsystem(Sigma, G, X)

# Now we are in a position to find SCJSR etc.
th$jsr(s)  # upper bound on JSR
th$cjsr(s)  # upper bound on CJSR
th$sosbound_gamma(s, 2)  # upper bound on SCJSR through SOS method, with d=2
```

We can also construct the vectors needed for `Sigma` and `X` in R through lists.
```r
Sigma1 <- matrix(c(...), nr, nc)  # some square matrix
Sigma2 <- ...  # another
Sigma3 <- ...
Sigma4 <- ...
Sigma <- list(Sigma1, Sigma2, Sigma3, Sigma4)  # this is compatible with dicreteswitchedsystem or automaton_constructor
G <- th$automaton_constructor(Sigma)  # will work 
# (NOTE only use `automaton_constructor` if the `Sigma$i`s are in the appropriate order (see ThresholdStability docs)!)
# Otherwise, construct the automaton manually (below)

X1 <- list(matrix(c(...), nr, nc), matrix(c(...), nr, nc))  # [E1, D1], the first pair of state space constraint matrices
X2 <- ...  # another
X3 <- ...
X4 <- ...
X <- list(X1, X2, X3, X4)
s <- th$discreteswitchedsystem(Sigma, G, X)
```

### Automata conversion
While [HybridSystems.jl](https://github.com/blegat/HybridSystems.jl) automata from Julia are not automatically translated to an R equivalent, thresholdr provides functions that can translate automata from HybridSystems into a representation in R using the [network](https://cran.r-project.org/web/packages/network/) package, and R equivalents of the functions used to build automata in Julia.

In the R representation, transitions are tracked by an adjacency matrix and labels are tracked similarly via a network attribute.

```r
G <- th$GraphAutomaton(4)  # create a Julia GraphAutomaton `G` with 4 nodes
net <- th$graphautomaton(4)  # create an R representation of an automaton, `net`, with 4 nodes. 

G <- th$add_transition(G, 1, 2, 1)  # add transition 1 -> 2 with label 1 to the GraphAutomaton
net <- th$addr_transition(G, 1, 2, 1)  # same but for the R automaton
th$get.labels(net)  # retrieve labels for the R automaton

net <- th$automaton_jl_to_r(G)  # convert Julia automaton G to R automaton `net`
G <- th$automaton_r_to_jl(net)  # convert R automaton to Julia
```
