
<!-- README.md is generated from README.Rmd. Please edit that file -->

# footBayes <img src="man/figures/logo.png" width = 200 align="right" />

[![CRAN Version](https://www.r-pkg.org/badges/version/footBayes)](https://cran.r-project.org/package=footBayes)
[![R-CMD-check.yaml](https://github.com/RoMaD-96/footBayes/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/RoMaD-96/footBayes/actions/workflows/R-CMD-check.yaml)
[![Downloads](https://cranlogs.r-pkg.org/badges/footBayes?color=brightgreen)](https://CRAN.R-project.org/package=footBayes)

The goal of `footBayes` is to propose a complete workflow to:

- fit the most well-known football models: double Poisson, bivariate
  Poisson, Skellam, student-t, according to both maximum likelihood and
  Bayesian methods (+ Hamiltonian Monte Carlo engine);

- visualize the teams’ abilities, the model checks, the rank-league
  reconstruction;

- predict out-of-sample matches.

## Installation

Using `footBayes` package requires installing the R package
[`cmdstanr`](https://mc-stan.org/cmdstanr/) (not available on CRAN) and
the command-line interface to Stan:
[`CmdStan`](https://mc-stan.org/users/interfaces/cmdstan.html). You may
follow the instructions in [Getting started with
CmdStanR](https://mc-stan.org/cmdstanr/articles/cmdstanr.html) to
install both.

You can install the released version of `footBayes` from CRAN with:

``` r
install.packages("footBayes", type = "source")
```

Please note that it is important to set `type = "source"`. Otherwise,
the ‘CmdStan’ models in the package may not be compiled during
installation.

Alternatively to CRAN, you can install the development version from
GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("leoegidi/footBayes")
```

## Example

In what follows, a quick example to fit a Bayesian double Poisson model
for the Italian Serie A (seasons 2000-2001, 2001-2002, 2002-2003),
visualize the estimated teams’ abilities, and predict the last four
match days for the season 2002-2003:

``` r
library(footBayes)
require(dplyr)

# dataset for Italian serie A
data("italy")
italy <- as_tibble(italy)
italy_2000_2002 <- italy %>%
  dplyr::select(Season, home, visitor, hgoal, vgoal) %>%
  filter(Season == "2000" | Season == "2001" | Season == "2002")

fit1 <- stan_foot(
  data = italy_2000_2002,
  model = "double_pois",
  predict = 36
) # double poisson fit (predict last 4 match-days)
foot_abilities(fit1, italy_2000_2002) # teams abilities
pp_foot(italy_2000_2002, fit1) # pp checks
foot_rank(italy_2000_2002, fit1) # rank league reconstruction
foot_prob(fit1, italy_2000_2002) # out-of-sample posterior pred. probabilities
```

For more and more technical details and references, see the vignette!
