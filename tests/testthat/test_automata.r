context("Automata")

test_that("Test automaton labels and conversion", {
    skip_on_cran()
    th <- threshold_setup()
    G <- th$LightAutomaton(2)
    net <- th$lightautomaton(2)
    G <- th$add_transition(G, 1, 2, 1)
    net <- th$addr_transition(net, 1, 2, 1)
    G <- th$add_transition(G, 2, 2, 2)
    net <- th$addr_transition(net, 2, 2, 2)
    G_to_net <- th$automaton_jl_to_r(G)
    expect_equal(net, G_to_net)
    expect_equal(th$get.labels(net)[1, 2], 1)
    for (i in 1:2) {
        for (j in 1:2) {
                expect_equal(th$get.label(net, i, j), th$get.labels(net)[i,j])
        }
    }
    expect_equal(th$get.label(net, 1, 2), 1)
    expect_equal(th$get.label(net, 2, 2), 2)
    expect_equal(th$get.label(net, 1, 1), NA_integer_)
})
