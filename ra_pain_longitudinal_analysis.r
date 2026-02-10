# set up aand data preparation
 

# project aim to get association between DAS28_baseline and pain measured 
# across times VAS
pd_dat <- read_rds("PD_dat.RData")





#Data inspection
range(pd_dat$VAS)
head(pd_dat$DAS28_Baseline, 30)
tail(pd_dat)
summary(pd_dat)
str(pd_dat)
dim(pd_dat)
length(unique(pd_dat$ID))
colSums(is.na(pd_dat))
table(table(pd_dat$ID))


# Exploratory Data Analysis

# create a baseline data:

baseline_data <- pd_dat %>% 
  filter(Visit_number == 1) %>% 
  select(ID, Age_Baseline, DAS28_Baseline, VAS)

baseline_data

# summary statistic for baseline
summary(baseline_data)
sd(baseline_data$Age_Baseline)
sd(baseline_data$DAS28_Baseline)
sd(baseline_data$VAS)

# summarize VAS by visit

vas_by_visit <- pd_dat %>% group_by(Visit_number)

summary(vas_by_visit)
sd(vas_by_visit$VAS)
sd(vas_by_visit$Age_Baseline)
sd(vas_by_visit$DAS28_Baseline)

# Visual Exploration

# sample 100 patients for clarity

sample_id <- sample(unique(pd_dat$ID), 100)

sample_plot_1 <- ggplot(pd_dat %>% filter(ID %in% sample_id),
                      aes(x=Visit_number, y=VAS, group = ID)) +
  geom_line(alpha=0.2, color="blue") + 
  geom_smooth(aes(group=1), method="loess", color="red", size=1.5, se=TRUE) +
  labs(title = "Sample individual pain trajectory for 100 patients over time",
       x="number of visits",
       y = "VAS Pain level")

sample_plot_1


# create pain assesments into groups

pd_dat <- pd_dat %>% mutate(DAS28_groups = cut(DAS28_Baseline, 
                                               breaks =quantile(DAS28_Baseline,
                                                                probs = c(0, 1/3, 2/3, 1)),
                                               labels = c("low_DAS28", "medium_DAS28", "High_DAS28"),
                                               include.lowest = TRUE))


tail(pd_dat[, c(5,6)], 30)
unique(pd_dat$DAS28_groups)

sample_plot_2 <- ggplot(pd_dat, aes(x=Visit_number, y= VAS,
                             color = DAS28_groups, group = DAS28_groups)) +
  geom_smooth(method = "loess", se = TRUE, size = 1.2) +
  scale_color_manual(values = c("green", "blue", "red"))+
  labs(title = "pain progression by baseline disease activity",
       x = "number of visits",
       y = "VAS pain level",
       color = "DAS28 groups")+
  theme(legend.position = "bottom")


sample_plot_2


# statisticsl modeling

# Model 1: Baseline (intercept + time only, random intercept)
model_1 <- lmer(VAS ~ Visit_number + (1|ID), data= pd_dat, REML = FALSE)

# Model 2: Add DAS28 main effect
model_2 <- lmer(VAS ~ Visit_number + DAS28_Baseline + (1|ID), data = pd_dat, REML = FALSE)

# Model 3: Add Age as covariate
model_3 <- lmer(VAS ~ Visit_number + DAS28_Baseline + Age_Baseline +
                  (1|ID), data = pd_dat, REML = FALSE)

# Model 4: Add DAS28 x Visit interaction
model_4 <- lmer(VAS ~ Visit_number * DAS28_Baseline + Age_Baseline +
                  (1|ID), data =pd_dat, REML = FALSE)

# Model 5: Add slope for Visit
model_5 <- lmer(VAS ~ Visit_number * DAS28_Baseline + Age_Baseline +
                  (Visit_number|ID), data = pd_dat, REML = FALSE)

summary(model_4)
summary(model_5)

# compare all models
install.packages("lmerTest")
library(lmerTest)

install.packages("gridExtra")
library(gridExtra)

anova(model_1, model_2, model_3, model_4, model_5)

# test significance of moel_interaction
anova(model_3, model_4)

# test need for random slope
anova(model_4, model_5)

# refill final model with REML = True for diagnostics

final_model <- lmer(VAS ~ Visit_number * DAS28_Baseline + Age_Baseline +
                      (1|ID), data = pd_dat, REML = TRUE)


pd_dat$fitted <- fitted(final_model)
pd_dat$residuals <- residuals(final_model)

head(pd_dat, 10)

# create plots

par(mfrow = c(2,2))

# residual vs fitted

plot(fitted(final_model), residuals(final_model),
     xlab = "Fitted values", ylab = "Residuals", 
     main = "Residuals vs fitted")
abline(h=0, col = "red", lty = 2)

# plot of residuals
qqnorm(residuals(final_model), main = "Q-Q plot of Residuals")
qqline(residuals(final_model), col = "red")

# scale-location 
plot(fitted(final_model), sqrt(abs(residuals(final_model))),
     xlab = "fitted values", ylab = "Residual sqrt",
     main = "scale_location plot")

# Q-Q plot of random effects

random_effects <- ranef(final_model)$ID[,1]
qqnorm(random_effects, main = "Q-Q plot of random effects")
qqline(random_effects, col = "red")

# Calculate DAS28 percentiles
das28_percentiles <- quantile(PD_dat$DAS28_Baseline, probs = c(0.1, 0.5, 0.9))
mean_age <- mean(PD_dat$Age_Baseline)

# Create prediction data
pred_data <- expand.grid(
  Visit_number = 1:10,
  DAS28_Baseline = das28_percentiles,
  Age_Baseline = mean_age
)

# Get predictions from Model 5
pred_data$predicted_VAS <- predict(final_model, 
                                   newdata = pred_data, 
                                   re.form = NA)

# Create readable labels
pred_data$DAS28_group <- factor(
  pred_data$DAS28_Baseline,
  levels = das28_percentiles,
  labels = c(
    paste0("Low DAS28 (10th %ile = ", round(das28_percentiles[1], 2), ")"),
    paste0("Median DAS28 (50th %ile = ", round(das28_percentiles[2], 2), ")"),
    paste0("High DAS28 (90th %ile = ", round(das28_percentiles[3], 2), ")")
  )
)

# Create the plot
library(ggplot2)

p_predicted <- ggplot(pred_data, 
                      aes(x = Visit_number, 
                          y = predicted_VAS, 
                          color = DAS28_group, 
                          group = DAS28_group)) +
  geom_line(size = 1.5) +
  geom_point(size = 3) +
  scale_color_manual(values = c("green", "blue", "red"),
                     name = "Baseline Disease Activity") +
  scale_x_continuous(breaks = 1:10) +
  labs(
    title = "Figure 4: Predicted Pain Trajectories by Baseline DAS28",
    subtitle = "Based on Model 5 predictions, adjusted for mean age",
    x = "Visit Number",
    y = "Predicted VAS Pain Score"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text( size = 13),
    plot.subtitle = element_text(size = 10),
    axis.title = element_text(size = 11)
  )

print(p_predicted)

# Calculate total changes for each group
pred_summary <- pred_data %>%
  group_by(DAS28_group) %>%
  summarise(
    Start_VAS = predicted_VAS[Visit_number == 1],
    End_VAS = predicted_VAS[Visit_number == 10],
    Total_Change = End_VAS - Start_VAS
  )
print(pred_summary)




























