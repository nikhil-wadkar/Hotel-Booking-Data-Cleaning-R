# ============================================================
# WEEK 3 - STATISTICAL ANALYSIS AND PREDICTIVE MODELING
# Hotel Booking Cancellation Prediction
# ============================================================

# Clear environment
rm(list = ls())

# Load cleaned dataset
df <- read.csv(
  file.choose(),
  stringsAsFactors = FALSE
)

# Check dimensions
dim(df)

# View structure
str(df)

# View first records
head(df)
# Dataset dimensions
cat("Rows:", nrow(df), "\n")
cat("Columns:", ncol(df), "\n")

# Structure
str(df)

# Summary
summary(df)

# Missing values
colSums(is.na(df))
table(df$is_canceled)

prop.table(table(df$is_canceled)) * 100
hist(
  df$lead_time,
  main = "Distribution of Lead Time",
  xlab = "Lead Time",
  breaks = 30
)
hist(
  df$adr,
  main = "Distribution of ADR",
  xlab = "Average Daily Rate",
  breaks = 30
)
tapply(
  df$lead_time,
  df$is_canceled,
  mean,
  na.rm = TRUE
)
t.test(
  lead_time ~ is_canceled,
  data = df
)
wilcox.test(
  lead_time ~ is_canceled,
  data = df
)
deposit_table <- table(
  df$deposit_type,
  df$is_canceled
)

deposit_table_table
chisq.test(deposit_table)
market_segment_table <- table(
  df$market_segment,
  df$is_canceled
)

market_segment_table
chisq.test(market_segment_table)
customer_table <- table(
  df$customer_type,
  df$is_canceled
)

customer_table
chisq.test(customer_table)
chisq.test(
  table(df$hotel, df$is_canceled)
)
chisq.test(
  table(df$meal, df$is_canceled)
)
numeric_data <- df[, c(
  "is_canceled",
  "lead_time",
  "adults",
  "children",
  "babies",
  "stays_in_weekend_nights",
  "stays_in_week_nights",
  "previous_cancellations",
  "previous_bookings_not_canceled",
  "booking_changes",
  "adr",
  "total_of_special_requests"
)]

cor_matrix <- cor(
  numeric_data,
  use = "pairwise.complete.obs"
)

round(cor_matrix, 2)
df$hotel <- as.factor(df$hotel)
df$deposit_type <- as.factor(df$deposit_type)
df$market_segment <- as.factor(df$market_segment)
df$customer_type <- as.factor(df$customer_type)
df$is_canceled <- as.factor(df$is_canceled)
library(caret)

set.seed(123)

train_index <- createDataPartition(
  df$is_canceled,
  p = 0.80,
  list = FALSE
)

train_data <- df[train_index, ]
test_data <- df[-train_index, ]
dim(train_data)
dim(test_data)
prop.table(table(train_data$is_canceled))
prop.table(table(test_data$is_canceled))
model_1 <- glm(
  is_canceled ~
    hotel +
    lead_time +
    stays_in_weekend_nights +
    stays_in_week_nights +
    adults +
    children +
    previous_cancellations +
    previous_bookings_not_canceled +
    booking_changes +
    deposit_type +
    market_segment +
    is_repeated_guest +
    customer_type +
    adr +
    required_car_parking_spaces +
    total_of_special_requests,
  data = train_data,
  family = binomial
)

summary(model_1)
exp(coef(model_1))
install.packages("car")
library(car)

vif(model_1)
library(caret)

control <- trainControl(
  method = "cv",
  number = 10,
  classProbs = TRUE,
  savePredictions = "final"
)
cv_model <- train(
  is_canceled ~
    hotel +
    lead_time +
    stays_in_weekend_nights +
    stays_in_week_nights +
    adults +
    children +
    previous_cancellations +
    previous_bookings_not_canceled +
    booking_changes +
    deposit_type +
    market_segment +
    is_repeated_guest +
    customer_type +
    adr +
    required_car_parking_spaces +
    total_of_special_requests,
  data = train_data,
  method = "glm",
  family = binomial,
  trControl = control
)

cv_model
# Rename cancellation classes
df$is_canceled <- factor(
  df$is_canceled,
  levels = c(0, 1),
  labels = c("No", "Yes")
)

# Check
table(df$is_canceled)
levels(df$is_canceled)
library(caret)

set.seed(123)

train_index <- createDataPartition(
  df$is_canceled,
  p = 0.80,
  list = FALSE
)

train_data <- df[train_index, ]
test_data <- df[-train_index, ]
prop.table(table(train_data$is_canceled))
prop.table(table(test_data$is_canceled))
control <- trainControl(
  method = "cv",
  number = 10,
  classProbs = TRUE,
  savePredictions = "final"
)
cv_model
pred_prob <- predict(
  cv_model,
  newdata = test_data,
  type = "prob"
)

head(pred_prob)
pred_class <- ifelse(
  pred_prob$Yes >= 0.5,
  "Yes",
  "No"
)

pred_class <- factor(
  pred_class,
  levels = c("No", "Yes")
)

head(pred_class)
conf_matrix <- confusionMatrix(
  pred_class,
  test_data$is_canceled,
  positive = "Yes"
)

conf_matrix
pred_prob <- predict(
  model_1,
  newdata = test_data,
  type = "response"
)
pred_class <- ifelse(
  pred_prob >= 0.5,
  "1",
  "0"
)

pred_class <- factor(
  pred_class,
  levels = levels(test_data$is_canceled)
)
conf_matrix <- confusionMatrix(
  pred_class,
  test_data$is_canceled,
  positive = "1"
)

conf_matrix
install.packages("pROC")
library(pROC)

roc_curve <- roc(
  test_data$is_canceled,
  pred_prob
)

auc_value <- auc(roc_curve)

auc_value
plot(
  roc_curve,
  main = "ROC Curve - Hotel Booking Cancellation Model"
)
conf_matrix
plot(roc_curve)
par(mfrow = c(2, 2))
plot(model_1)
par(mfrow = c(1, 1))
model_2 <- glm(
  is_canceled ~
    lead_time +
    previous_cancellations +
    booking_changes +
    deposit_type +
    market_segment +
    is_repeated_guest +
    adr +
    total_of_special_requests,
  data = train_data,
  family = binomial
)

summary(model_2)
# Predictions from Model 2
model_2_prob <- predict(model_2, newdata = test_data, type = "response")

# Convert probabilities into Yes/No predictions
model_2_pred <- ifelse(model_2_prob >= 0.5, "Yes", "No")

# Convert to factor with the same levels as actual values
model_2_pred <- factor(model_2_pred, levels = c("No", "Yes"))

# Confusion Matrix
conf_matrix_2 <- confusionMatrix(
  model_2_pred,
  test_data$is_canceled,
  positive = "Yes"
)

conf_matrix_2
# Install pROC if needed
# install.packages("pROC")

library(pROC)

# Predicted probabilities from Model 2
roc_model_2 <- roc(
  test_data$is_canceled,
  model_2_prob,
  levels = c("No", "Yes"),
  direction = "<"
)

# Calculate AUC
auc_model_2 <- auc(roc_model_2)

# Display AUC
auc_model_2

# Plot ROC Curve
plot(
  roc_model_2,
  main = "ROC Curve - Hotel Booking Cancellation Model 2"
)

# Add AUC to the plot
legend(
  "bottomright",
  legend = paste("AUC =", round(auc_model_2, 3))
)
# Model 2 diagnostic plots

par(mfrow = c(2, 2))

plot(model_2)

par(mfrow = c(1, 1))
train_data$lead_time_group <- cut(
  train_data$lead_time,
  breaks = c(-Inf, 30, 90, 180, Inf),
  labels = c("0-30 Days", "31-90 Days", "91-180 Days", "181+ Days")
)

# Create contingency table
leadtime_table <- table(
  train_data$lead_time_group,
  train_data$is_canceled
)

leadtime_table
chi_test <- chisq.test(leadtime_table)

chi_test
AIC(model_1, model_2)
cat("Model 1 AIC:", AIC(model_1), "\n")
cat("Model 2 AIC:", AIC(model_2), "\n")
# Model 1 predicted probabilities
model_1_prob <- predict(
  model_1,
  newdata = test_data,
  type = "response"
)

# Convert probabilities to Yes/No predictions
model_1_pred <- ifelse(
  model_1_prob >= 0.5,
  "Yes",
  "No"
)

# Convert to factor
model_1_pred <- factor(
  model_1_pred,
  levels = c("No", "Yes")
)

# Model 1 confusion matrix
conf_matrix_1 <- confusionMatrix(
  model_1_pred,
  test_data$is_canceled,
  positive = "Yes"
)

conf_matrix_1
# Model 1 ROC and AUC
roc_model_1 <- roc(
  test_data$is_canceled,
  model_1_prob,
  levels = c("No", "Yes"),
  direction = "<"
)

auc_model_1 <- auc(roc_model_1)

auc_model_1
plot(
  roc_model_1,
  main = "ROC Curve - Hotel Booking Cancellation Model 1"
)

legend(
  "bottomright",
  legend = paste("AUC =", round(auc_model_1, 3))
)