Longitudinal Analysis of Pain Progression in Rheumatoid Arthritis

Project Overview
This study investigates the association between baseline disease activity (DAS28) and join pain progression (VAS) in 500 patients followed over 10 clinical visits. The goal was to determine if initial disease severity predicts both starting pain levels and the rate of pain increase over time.

Technical Highlights
* Advanced Modeling: Developed Linear Mixed-Effects Models (LMM) to account for repeated measurements and individual patient variability (random intercepts and slopes).
* Interaction Effects: Statistically validated a Visit_number x DAS28_Baseline interaction, proving that higher initial disease activity leads to a faster rate of pain increase.
* Predictive Visualization: Created predicted pain trajectory plots to demonstrate the diverging health outcomes for patients with varying baseline severity.
* Model Diagnostics: Conducted thorough assumption checking using Residual vs. Fitted, Q-Q plots of residuals, and Q-Q plots of random effects to ensure model reliability.

Clinical Impact
* Findings: Patients with high baseline DAS28 experienced a 28.8-point increase in pain compared to a 19.3-point increase for low-severity patients.
* Intervention Insight: The results highlight the critical importance of early identification and aggressive management of high DAS28 at baseline to prevent rapid pain escalation.

Tools & Technologies
* R Programming: (lme4, lmerTest, ggplot2, tidyverse).
* Statistical Concepts: Mixed-Effects Modeling, Interaction Terms, AIC/BIC Model Selection, Heteroscedasticity Analysis
