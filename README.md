# 🩺 Rheumatoid Arthritis Pain Progression Analysis

> **Does baseline disease activity predict pain progression over time in Rheumatoid Arthritis patients?**

A longitudinal data analysis using **Linear Mixed-Effects Models** to investigate the association between baseline disease activity (DAS28) and pain trajectory across repeated clinic visits.

![R](https://img.shields.io/badge/R-4.0+-blue?logo=r)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## 📌 Table of Contents

- [Overview](#overview)
- [Research Question](#research-question)
- [Dataset](#dataset)
- [Methodology](#methodology)
- [Key Results](#key-results)
- [Model Selection](#model-selection)
- [Visualizations](#visualizations)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Skills Demonstrated](#skills-demonstrated)
- [Clinical Implications](#clinical-implications)
- [References](#references)
- [Author](#author)

---

## 🎯 Overview

Rheumatoid Arthritis (RA) is a chronic inflammatory condition that causes joint pain and damage. Understanding how baseline disease severity influences pain progression is crucial for early intervention and treatment planning.

This project analyzes longitudinal data from **500 patients** across **10 clinic visits** to determine whether patients with higher baseline disease activity (measured by DAS28) experience:
1. Higher initial pain levels
2. Faster pain progression over time

**Why Mixed-Effects Models?**

Standard regression assumes independence between observations. But when the same patient is measured repeatedly, their observations are correlated. Mixed-effects models account for this by including:
- **Fixed effects:** Population-level trends (time, disease activity, age)
- **Random effects:** Patient-specific deviations (individual intercepts and slopes)

---

## ❓ Research Question

**Primary Question:** Is there an association between baseline disease activity (DAS28_Baseline) and pain progression over time in patients with Rheumatoid Arthritis?

**Hypotheses:**
- H1: Higher baseline DAS28 is associated with higher pain levels
- H2: Higher baseline DAS28 is associated with faster pain increase over time (interaction effect)

---

## 📊 Dataset

| Attribute | Value |
|-----------|-------|
| **Patients** | 500 unique individuals |
| **Observations** | 5,000 (10 visits per patient) |
| **Follow-up** | 10 clinic visits |
| **Missing Data** | None |

### Variables

| Variable | Type | Description | Range |
|----------|------|-------------|-------|
| `ID` | Categorical | Patient identifier | 1–500 |
| `Visit_number` | Continuous | Clinic visit number (time) | 1–10 |
| `VAS` | Continuous | Visual Analog Scale pain score (outcome) | 19.3–100.0 |
| `DAS28_Baseline` | Continuous | Disease Activity Score at baseline | 1.35–8.62 |
| `Age_Baseline` | Continuous | Patient age at baseline | 32–94 years |

### Summary Statistics

| Variable | Mean | SD | Min | Max |
|----------|------|-----|-----|-----|
| VAS (all visits) | 47.4 | 11.1 | 19.3 | 100.0 |
| VAS (baseline only) | 35.3 | 6.7 | 19.3 | 61.5 |
| DAS28_Baseline | 4.10 | 1.19 | 1.35 | 8.62 |
| Age_Baseline | 60.6 | 10.2 | 32.3 | 93.7 |

---

## 🔬 Methodology

### Phase 1: Exploratory Data Analysis

**Objective:** Understand pain patterns and visualize trends by disease activity level.

**Steps:**
1. Examined data structure and verified no missing values
2. Plotted individual pain trajectories for 100 sampled patients
3. Categorized DAS28 into tertiles (Low, Medium, High)
4. Visualized pain progression by DAS28 group

**Key Finding:** Clear visual separation between groups—higher DAS28 patients start higher and increase faster.

### Phase 2: Model Building

**Approach:** Fit a series of increasingly complex mixed-effects models and compare fit using AIC/BIC.

```r
# Model 1: Random intercept only
model_1 <- lmer(VAS ~ Visit_number + (1|ID), data = pd_dat, REML = FALSE)

# Model 2: Add DAS28 main effect
model_2 <- lmer(VAS ~ Visit_number + DAS28_Baseline + (1|ID), data = pd_dat, REML = FALSE)

# Model 3: Add Age covariate
model_3 <- lmer(VAS ~ Visit_number + DAS28_Baseline + Age_Baseline + (1|ID), data = pd_dat, REML = FALSE)

# Model 4: Add DAS28 × Visit interaction
model_4 <- lmer(VAS ~ Visit_number * DAS28_Baseline + Age_Baseline + (1|ID), data = pd_dat, REML = FALSE)

# Model 5: Add random slope for Visit (FINAL MODEL)
model_5 <- lmer(VAS ~ Visit_number * DAS28_Baseline + Age_Baseline + (Visit_number|ID), data = pd_dat, REML = FALSE)
```

### Phase 3: Model Selection

Models compared using AIC and BIC:

| Model | Description | AIC | BIC |
|-------|-------------|-----|-----|
| Model 1 | Time + random intercept | — | — |
| Model 2 | + DAS28 main effect | — | — |
| Model 3 | + Age | — | — |
| Model 4 | + DAS28 × Time interaction | 24,681.3 | — |
| **Model 5** | **+ Random slope for time** | **24,311.9** | **—** |

**Selected:** Model 5 (substantially lower AIC, better accounts for individual variation in pain trajectories)

### Phase 4: Model Diagnostics

All assumptions verified:
- ✅ Residuals vs Fitted: Random scatter around zero (linearity, homoscedasticity)
- ✅ Q-Q Plot of Residuals: Points follow theoretical line (normality)
- ✅ Scale-Location Plot: Constant spread (homoscedasticity)
- ✅ Q-Q Plot of Random Effects: Normally distributed random intercepts

---

## 📈 Key Results

### Fixed Effects (Final Model)

| Predictor | Estimate | SE | 95% CI | t-value | p-value |
|-----------|----------|-----|--------|---------|---------|
| Intercept | 0.05 | 1.248 | [-2.39, 2.50] | 0.04 | 0.967 |
| **Visit_number** | **1.15** | 0.068 | [1.02, 1.28] | 16.98 | **<0.001** |
| **DAS28_Baseline** | **2.80** | 0.163 | [2.48, 3.12] | 17.13 | **<0.001** |
| **Age_Baseline** | **0.35** | 0.017 | [0.32, 0.38] | 21.12 | **<0.001** |
| **Visit × DAS28** | **0.37** | 0.016 | [0.34, 0.40] | 23.25 | **<0.001** |

### Interpretation

1. **Visit_number (β = 1.15, p < 0.001)**
   - Pain increases by 1.15 points per visit on average
   - Confirms pain progression over time

2. **DAS28_Baseline (β = 2.80, p < 0.001)**
   - Each 1-unit increase in baseline DAS28 → 2.80 higher VAS pain score
   - Higher disease activity = higher pain levels

3. **Age_Baseline (β = 0.35, p < 0.001)**
   - Each additional year of age → 0.35 higher pain score
   - Older patients report more pain

4. **Visit × DAS28 Interaction (β = 0.37, p < 0.001)**
   - Pain increases **faster** in high-DAS28 patients
   - Critical finding: Disease activity affects both level AND trajectory

### Random Effects

| Component | Variance | SD | Interpretation |
|-----------|----------|-----|----------------|
| Intercept | 16.6 | 4.1 | Patients differ in baseline pain |
| Slope (Visit) | 0.12 | 0.35 | Patients differ in pain trajectory |
| Correlation | -0.41 | — | Higher initial pain → slower increase |

### Pain Progression by DAS28 Group

| DAS28 Group | Start VAS | End VAS | Total Change |
|-------------|-----------|---------|--------------|
| Low | 31.0 | 50.3 | +19.3 |
| Medium | 34.9 | 58.4 | +23.5 |
| **High** | **40.0** | **68.9** | **+28.8** |

High-DAS28 patients experience **50% more pain increase** than low-DAS28 patients over the same period.

---

## 📊 Visualizations

### 1. Individual Pain Trajectories
*Spaghetti plot showing 100 patients' pain over 10 visits with average trend line*

### 2. Pain Progression by DAS28 Group
*Grouped trajectory plot showing clear separation between Low, Medium, and High DAS28*

### 3. Model Diagnostics
*4-panel diagnostic plot: Residuals vs Fitted, Q-Q plots, Scale-Location*

### 4. Predicted Pain Trajectories
*Model-based predictions showing diverging trajectories by DAS28 level*

---

## 📁 Project Structure

```
rheumatoid-arthritis-pain-analysis/
│
├── 📂 data/
│   └── ra_pain_data.csv              # Longitudinal patient data
│
├── 📂 scripts/
│   ├── 01_data_exploration.R         # EDA and summary statistics
│   ├── 02_visualization.R            # Pain trajectory plots
│   ├── 03_model_building.R           # Mixed-effects model fitting
│   ├── 04_model_selection.R          # AIC/BIC comparison
│   └── 05_diagnostics.R              # Residual analysis
│
├── 📂 outputs/
│   ├── 📂 figures/
│   │   ├── pain_trajectories.png
│   │   ├── das28_groups_plot.png
│   │   ├── diagnostics.png
│   │   └── predicted_trajectories.png
│   │
│   └── 📂 tables/
│       ├── summary_statistics.csv
│       ├── model_comparison.csv
│       └── fixed_effects.csv
│
├── 📂 report/
│   └── RA_Pain_Analysis_Report.pdf
│
├── README.md
└── LICENSE
```

---

## ⚙️ Installation

### Prerequisites

- R version 4.0+
- RStudio (recommended)

### Install Required Packages

```r
# Mixed-effects modeling
install.packages("lme4")
install.packages("lmerTest")

# Data manipulation & visualization
install.packages("tidyverse")
install.packages("ggplot2")

# Model diagnostics
install.packages("performance")
install.packages("see")

# Tables
install.packages("sjPlot")
install.packages("broom.mixed")
```

---

## 🚀 Usage

### Clone the Repository

```bash
git clone https://github.com/Akinlajar/rheumatoid-arthritis-pain-analysis.git
cd rheumatoid-arthritis-pain-analysis
```

### Run the Analysis

```r
source("scripts/01_data_exploration.R")
source("scripts/02_visualization.R")
source("scripts/03_model_building.R")
source("scripts/04_model_selection.R")
source("scripts/05_diagnostics.R")
```

---

## 🛠️ Skills Demonstrated

### Statistical Methods
- ✅ Linear Mixed-Effects Models (LMM)
- ✅ Random intercepts and slopes
- ✅ Interaction effects
- ✅ Model selection (AIC/BIC)
- ✅ Longitudinal data analysis
- ✅ Model diagnostics (residual analysis, Q-Q plots)

### Technical Skills
- ✅ R programming (lme4, tidyverse)
- ✅ Data visualization (ggplot2)
- ✅ Statistical modeling
- ✅ Scientific reporting

### Domain Knowledge
- ✅ Rheumatoid Arthritis disease metrics (DAS28)
- ✅ Pain assessment (VAS scores)
- ✅ Longitudinal study design
- ✅ Clinical research interpretation

---

## 🏥 Clinical Implications

1. **Early Identification:** Patients with high baseline DAS28 should be flagged for intensive monitoring, as they experience faster pain progression.

2. **Treatment Planning:** Aggressive early intervention may be warranted for high-DAS28 patients to slow pain trajectory.

3. **Prognosis Communication:** Clinicians can use baseline DAS28 to set realistic expectations about pain progression with patients.

4. **Resource Allocation:** Healthcare systems can prioritize resources for high-risk patients identified at baseline.

---

## 📚 References

### Methodology
- Bates D, et al. Fitting Linear Mixed-Effects Models Using lme4. *Journal of Statistical Software*. 2015;67(1):1-48.
- Singer JD, Willett JB. *Applied Longitudinal Data Analysis*. Oxford University Press; 2003.

### Clinical Background
- Prevoo ML, et al. Modified disease activity scores that include twenty-eight-joint counts. *Arthritis & Rheumatism*. 1995;38(1):44-48.
- Anderson DL. Development and validation of criteria for classification of rheumatoid arthritis. *Arthritis & Rheumatism*. 2010.

---

## 👤 Author

**Judah Akinlajar**

MSc Health Data Science | University of Manchester

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://www.linkedin.com/in/judah-akinlaja-a10385194)
[![Email](https://img.shields.io/badge/Email-Contact-red?logo=gmail)](mailto:judahakinlajar@gmail.com)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <b>Key Takeaway:</b> Baseline disease activity doesn't just predict current pain—it predicts how fast pain will get worse over time.
</p>

<p align="center">
  <i>If you found this project useful, please consider giving it a ⭐</i>
</p>
