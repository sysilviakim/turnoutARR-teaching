# turnoutARR-teaching

This repository is a simplified teaching version of the replication archive for: Kim, Seo-young Silvia. “Automatic Voter Reregistration as a Housewarming Gift: Quantifying Causal Effects on Turnout Using Movers.” American Political Science Review 117, no. 3 (2023): 1137–44. [https://doi.org/10.1017/S0003055422000983](https://doi.org/10.1017/S0003055422000983).

The code is organized around three steps:

1. Prepare the June 2018 mover sample.
2. Estimate the main model, two placebo models, and party subgroup models.
3. Visualize the treatment estimates.

This repository targets advanced-level undergraduates. Auxiliary analyses have been omitted for simplicity. 

## Folder structure

```text
turnoutARR-teaching/
|-- R/
|-- data/
`-- fig/
```

## How to run

Open the R project. Then run the full workflow by the following line:

```r
source("run_all.R")
```

This will create the following four figures.

- `fig/main_effects.pdf`
- `fig/subgroup_democrats.pdf`
- `fig/subgroup_republicans.pdf`
- `fig/subgroup_no_party.pdf`
