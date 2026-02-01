---
name: r-data-scientist
description: "Expert R programming for data science including tidyverse, statistical modeling, data visualization with ggplot2, and machine learning with R"
---

# R Data Scientist

## Overview

Master R programming for data science including tidyverse ecosystem, statistical analysis, ggplot2 visualization, and machine learning.

## When to Use This Skill

- Use when analyzing data with R
- Use when creating statistical models
- Use when building ggplot2 visualizations
- Use when R-specific analysis needed

## How It Works

### Step 1: Tidyverse Data Manipulation

```r
library(tidyverse)

# Read and explore data
df <- read_csv("data.csv")
glimpse(df)
summary(df)

# Data manipulation with dplyr
result <- df %>%
  filter(year >= 2020, status == "active") %>%
  mutate(
    revenue_per_unit = revenue / quantity,
    quarter = quarter(date)
  ) %>%
  group_by(category, quarter) %>%
  summarise(
    total_revenue = sum(revenue, na.rm = TRUE),
    avg_quantity = mean(quantity, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(total_revenue))

# Pivoting data
wide_df <- df %>%
  pivot_wider(
    names_from = category,
    values_from = revenue,
    values_fill = 0
  )

long_df <- wide_df %>%
  pivot_longer(
    cols = -c(id, date),
    names_to = "category",
    values_to = "revenue"
  )
```

### Step 2: ggplot2 Visualization

```r
library(ggplot2)
library(scales)

# Bar chart
ggplot(df, aes(x = reorder(category, -revenue), y = revenue, fill = category)) +
  geom_col() +
  labs(title = "Revenue by Category", x = "Category", y = "Revenue") +
  scale_y_continuous(labels = dollar_format()) +
  theme_minimal() +
  theme(legend.position = "none")

# Line chart with facets
ggplot(df, aes(x = date, y = value, color = metric)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  facet_wrap(~region, scales = "free_y") +
  labs(title = "Trends by Region") +
  theme_bw()

# Scatter with regression
ggplot(df, aes(x = spend, y = revenue)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(title = "Spend vs Revenue Correlation") +
  theme_classic()

# Save plot
ggsave("analysis.png", width = 10, height = 6, dpi = 300)
```

### Step 3: Statistical Modeling

```r
# Linear regression
model <- lm(revenue ~ spend + quantity + factor(category), data = df)
summary(model)
confint(model)

# Model diagnostics
par(mfrow = c(2, 2))
plot(model)

# Predictions
predictions <- predict(model, newdata = test_df, interval = "confidence")

# Logistic regression
logit_model <- glm(converted ~ age + income + visits, 
                   data = df, 
                   family = binomial)
summary(logit_model)
exp(coef(logit_model))  # Odds ratios

# ANOVA
aov_result <- aov(revenue ~ category * region, data = df)
summary(aov_result)
TukeyHSD(aov_result)

# T-test
t.test(revenue ~ group, data = df, var.equal = FALSE)
```

### Step 4: Machine Learning with tidymodels

```r
library(tidymodels)

# Split data
set.seed(123)
split <- initial_split(df, prop = 0.8, strata = outcome)
train <- training(split)
test <- testing(split)

# Recipe (preprocessing)
recipe <- recipe(outcome ~ ., data = train) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_zv(all_predictors())

# Model specification
rf_spec <- rand_forest(trees = 500, mtry = tune(), min_n = tune()) %>%
  set_engine("ranger") %>%
  set_mode("classification")

# Workflow
workflow <- workflow() %>%
  add_recipe(recipe) %>%
  add_model(rf_spec)

# Cross-validation
cv_folds <- vfold_cv(train, v = 5)
tuned <- tune_grid(workflow, resamples = cv_folds, grid = 20)

# Best model
best <- select_best(tuned, metric = "accuracy")
final <- finalize_workflow(workflow, best) %>% fit(train)

# Evaluate
predictions <- predict(final, test, type = "prob")
```

## Best Practices

### ✅ Do This

- ✅ Use tidyverse for data manipulation
- ✅ Document with R Markdown
- ✅ Use pipes for readable code
- ✅ Set seeds for reproducibility
- ✅ Use projects for organization

### ❌ Avoid This

- ❌ Don't use attach()
- ❌ Don't hardcode file paths
- ❌ Don't ignore missing values
- ❌ Don't skip validation

## Related Skills

- `@senior-data-analyst` - General data analysis
- `@senior-ai-ml-engineer` - Machine learning
