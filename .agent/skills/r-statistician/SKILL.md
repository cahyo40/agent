---
name: r-statistician
description: "Expert statistical analysis with R including hypothesis testing, regression analysis, time series, Bayesian statistics, and research methodology"
---

# R Statistician

## Overview

Advanced statistical analysis with R including hypothesis testing, multivariate analysis, time series, Bayesian methods, and research statistics.

## When to Use This Skill

- Use when performing statistical analysis
- Use when conducting hypothesis tests
- Use when time series analysis needed
- Use when Bayesian inference required

## How It Works

### Step 1: Hypothesis Testing

```r
# One-sample t-test
t.test(df$value, mu = 100, alternative = "two.sided")

# Two-sample t-test
t.test(value ~ group, data = df, var.equal = FALSE)

# Paired t-test  
t.test(df$before, df$after, paired = TRUE)

# Chi-square test
table <- table(df$category, df$outcome)
chisq.test(table)

# Fisher's exact test (small samples)
fisher.test(table)

# Mann-Whitney U test (non-parametric)
wilcox.test(value ~ group, data = df)

# Kruskal-Wallis test
kruskal.test(value ~ group, data = df)

# Effect size (Cohen's d)
library(effsize)
cohen.d(df$value ~ df$group)
```

### Step 2: Regression Analysis

```r
# Multiple regression
model <- lm(y ~ x1 + x2 + x3 + x1:x2, data = df)
summary(model)

# Stepwise selection
library(MASS)
full_model <- lm(y ~ ., data = df)
step_model <- stepAIC(full_model, direction = "both")

# Multicollinearity check
library(car)
vif(model)

# Heteroscedasticity test
library(lmtest)
bptest(model)

# Robust standard errors
library(sandwich)
coeftest(model, vcov = vcovHC(model, type = "HC3"))

# Mixed effects model
library(lme4)
mixed_model <- lmer(y ~ x1 + x2 + (1 | group), data = df)
summary(mixed_model)
```

### Step 3: Time Series Analysis

```r
library(forecast)
library(tseries)

# Create time series
ts_data <- ts(df$value, start = c(2020, 1), frequency = 12)

# Decomposition
decomp <- decompose(ts_data)
plot(decomp)

# Stationarity test
adf.test(ts_data)

# ARIMA modeling
auto_arima <- auto.arima(ts_data)
summary(auto_arima)

# Forecast
forecast_result <- forecast(auto_arima, h = 12)
plot(forecast_result)

# Exponential smoothing
ets_model <- ets(ts_data)
forecast(ets_model, h = 12)
```

### Step 4: Bayesian Statistics

```r
library(brms)
library(rstanarm)

# Bayesian linear regression
bayes_model <- stan_glm(
  y ~ x1 + x2,
  data = df,
  family = gaussian(),
  prior = normal(0, 5),
  prior_intercept = normal(0, 10),
  chains = 4, iter = 2000
)

summary(bayes_model)
posterior_interval(bayes_model, prob = 0.95)

# Posterior predictive check
pp_check(bayes_model)

# Model comparison
loo(bayes_model)
```

## Best Practices

### ✅ Do This

- ✅ Check assumptions before tests
- ✅ Report effect sizes
- ✅ Use appropriate tests
- ✅ Document methodology
- ✅ Consider power analysis

### ❌ Avoid This

- ❌ Don't p-hack
- ❌ Don't ignore assumptions
- ❌ Don't over-interpret results
- ❌ Don't forget sample size

## Related Skills

- `@r-data-scientist` - R data science
- `@senior-data-analyst` - Data analysis
