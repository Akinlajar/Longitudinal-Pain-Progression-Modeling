# Pain Progression in Rheumatoid Arthritis: Linear Mixed-Effects Models

Does baseline disease activity predict how fast pain worsens across repeated clinic visits? A longitudinal analysis in R.

**Stack:** R (lme4, lmerTest, tidyverse, ggplot2, gridExtra)

---

## At a glance

| | |
|---|---|
| Data | 500 patients × 10 visits = 5,000 observations |
| Outcome | Pain on a visual analogue scale (VAS) |
| Final model | Random intercept and random slope for visit (AIC 24,311.9 vs 24,681.3) |
| Key finding | Higher baseline DAS28 means faster pain progression (interaction 0.37, p < 0.001) |

## Why mixed-effects models
Repeated visits from the same patient are correlated, so ordinary regression would understate uncertainty. Mixed-effects models give each patient their own starting level (random intercept) and rate of change (random slope).

## Model building
Five nested models fitted by maximum likelihood (`REML = FALSE`) and compared by AIC:
1. Visit only
2. + baseline DAS28
3. + baseline age
4. + visit × DAS28 interaction
5. + random slope for visit (final)

Diagnostics: residuals vs fitted, Q-Q plot of residuals, scale-location plot, and Q-Q plot of the random effects.

## Results

| Effect | Estimate |
|---|---|
| Pain change per visit | +1.15 points (p < 0.001) |
| Per unit baseline DAS28 | +2.80 points (p < 0.001) |
| Visit × DAS28 interaction | 0.37 (p < 0.001) |
| Random intercept-slope correlation | -0.41 |

**Reading it:** pain worsens over time, and it worsens faster for patients with higher disease activity at baseline. The negative intercept-slope correlation means patients who started with more pain progressed more slowly.

## Visualisations
Spaghetti plot of 100 sampled patients with the average trend, trajectories by DAS28 tertile, a 4-panel diagnostic plot, and model-predicted trajectories by DAS28 level (see the report).

## Files
| File | Contents |
|---|---|
| [`ra_pain_longitudinal_analysis.r`](ra_pain_longitudinal_analysis.r) | Full analysis script |
| [`RA_Pain_Progression_Report.pdf`](RA_Pain_Progression_Report.pdf) | Written report |

The dataset was provided for a University of Manchester module and is not redistributed. Install `lme4`, `lmerTest`, `tidyverse` and `gridExtra`, then run the script top to bottom.

---

## Author
**Judah Akinlaja**, Health Data Scientist · MSc Health Data Science, University of Manchester
[LinkedIn](https://www.linkedin.com/in/judah-akinlaja) · [Portfolio](https://judahakinlajar.co.uk)
