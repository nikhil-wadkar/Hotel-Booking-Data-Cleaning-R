# ============================================================
# WEEK 1 – DATA CLEANING AND PRELIMINARY ANALYSIS
# Dataset: Hotel Booking Demand
# Tool: R / RGui
# Author: Nikhil Wadkar
# ============================================================


# ============================================================
# STEP 1 - DATASET SELECTION
# ============================================================

# Dataset:
# Hotel Booking Demand
#
# The dataset contains numerical and categorical variables,
# missing values, duplicate records, invalid values and
# potential outliers.


# ============================================================
# STEP 2 - LOAD DATASET
# ============================================================

# Clear existing objects
rm(list = ls())

# Optional: clear console
cat("\014")

# Load required package for correlation visualization
if (!requireNamespace("corrplot", quietly = TRUE)) {
  install.packages("corrplot")
}

library(corrplot)

# ------------------------------------------------------------
# Load the dataset
# ------------------------------------------------------------

# If your project has this folder structure:
#
# Hotel-Booking-Data-Cleaning-R/
# ├── R/
# ├── Data/
# │   └── raw/
# │       └── hotel_bookings.csv
#
# and you run the script from the project root:

df <- read.csv(
  file.choose(),
  stringsAsFactors = FALSE,
  na.strings = c("", "NA", "NULL")
)
cat("Dataset loaded successfully.\n")


# ============================================================
# STEP 3 - INITIAL DATA INSPECTION
# ============================================================

cat("\n============================================================\n")
cat("STEP 3 - INITIAL DATA INSPECTION\n")
cat("============================================================\n")

# Number of rows and columns
cat("\nDataset Dimensions:\n")
print(dim(df))

# Column names
cat("\nColumn Names:\n")
print(names(df))

# Dataset structure
cat("\nDataset Structure:\n")
str(df)

# Summary statistics
cat("\nSummary Statistics:\n")
print(summary(df))

# First observations
cat("\nFirst 10 Observations:\n")
print(head(df, 10))


# ============================================================
# STEP 4 - MISSING VALUE ANALYSIS
# ============================================================

cat("\n============================================================\n")
cat("STEP 4 - MISSING VALUE ANALYSIS\n")
cat("============================================================\n")

missing_summary <- data.frame(
  Variable = names(df),
  Missing_Count = sapply(
    df,
    function(x) sum(is.na(x))
  ),
  Missing_Percentage = sapply(
    df,
    function(x) mean(is.na(x)) * 100
  )
)

missing_summary <- missing_summary[
  order(-missing_summary$Missing_Count),
]

print(missing_summary)

# Save missing-value summary
write.csv(
  missing_summary,
  "missing_value_summary.csv",
  row.names = FALSE
)


# ============================================================
# STEP 5 - DUPLICATE DETECTION
# ============================================================

cat("\n============================================================\n")
cat("STEP 5 - DUPLICATE DETECTION\n")
cat("============================================================\n")

duplicate_count <- sum(duplicated(df))

duplicate_percentage <-
  (duplicate_count / nrow(df)) * 100

cat(
  "Number of duplicate rows:",
  duplicate_count,
  "\n"
)

cat(
  "Percentage of duplicate rows:",
  round(duplicate_percentage, 2),
  "%\n"
)


# ============================================================
# STEP 6 - REMOVE DUPLICATES
# ============================================================

cat("\n============================================================\n")
cat("STEP 6 - REMOVE DUPLICATES\n")
cat("============================================================\n")

df_clean <- df[!duplicated(df), ]

cat(
  "Rows after duplicate removal:",
  nrow(df_clean),
  "\n"
)

cat(
  "Columns after duplicate removal:",
  ncol(df_clean),
  "\n"
)


# ============================================================
# STEP 7 - HANDLE MISSING VALUES
# ============================================================

cat("\n============================================================\n")
cat("STEP 7 - HANDLE MISSING VALUES\n")
cat("============================================================\n")


# ------------------------------------------------------------
# 7.1 Remove company column
# ------------------------------------------------------------

# company contains a very high percentage of missing values.

if ("company" %in% names(df_clean)) {
  
  df_clean$company <- NULL
  
  cat("company column removed.\n")
  
}


# ------------------------------------------------------------
# 7.2 Replace missing agent values with 0
# ------------------------------------------------------------

if ("agent" %in% names(df_clean)) {
  
  df_clean$agent[is.na(df_clean$agent)] <- 0
  
  cat("Missing agent values replaced with 0.\n")
  
}


# ------------------------------------------------------------
# 7.3 Replace missing country values with PRT
# ------------------------------------------------------------

if ("country" %in% names(df_clean)) {
  
  df_clean$country[is.na(df_clean$country)] <- "PRT"
  
  cat("Missing country values replaced with PRT.\n")
  
}


# ------------------------------------------------------------
# 7.4 Replace missing children values with median
# ------------------------------------------------------------

if ("children" %in% names(df_clean)) {
  
  children_median <- median(
    df_clean$children,
    na.rm = TRUE
  )
  
  df_clean$children[
    is.na(df_clean$children)
  ] <- children_median
  
  cat(
    "Missing children values replaced with median:",
    children_median,
    "\n"
  )
  
}


# ------------------------------------------------------------
# Verify missing values after treatment
# ------------------------------------------------------------

missing_after <- data.frame(
  Variable = names(df_clean),
  Missing_Count = sapply(
    df_clean,
    function(x) sum(is.na(x))
  )
)

missing_after <- missing_after[
  missing_after$Missing_Count > 0,
]

cat("\nRemaining missing values:\n")

if (nrow(missing_after) == 0) {
  
  cat("No missing values remain.\n")
  
} else {
  
  print(missing_after)
  
}


# ============================================================
# STEP 8 - INVALID VALUE DETECTION
# ============================================================

cat("\n============================================================\n")
cat("STEP 8 - INVALID VALUE DETECTION\n")
cat("============================================================\n")


# Adults less than 1
invalid_adults <- sum(
  df_clean$adults < 1,
  na.rm = TRUE
)

# Negative ADR
invalid_adr <- sum(
  df_clean$adr < 0,
  na.rm = TRUE
)

# Negative children
invalid_children <- sum(
  df_clean$children < 0,
  na.rm = TRUE
)

# Negative babies
invalid_babies <- sum(
  df_clean$babies < 0,
  na.rm = TRUE
)

# Negative lead time
invalid_lead_time <- sum(
  df_clean$lead_time < 0,
  na.rm = TRUE
)

# Zero total guests
zero_guest_records <- sum(
  (df_clean$adults +
     df_clean$children +
     df_clean$babies) == 0,
  na.rm = TRUE
)


cat(
  "Adults less than 1:",
  invalid_adults,
  "\n"
)

cat(
  "ADR less than 0:",
  invalid_adr,
  "\n"
)

cat(
  "Children less than 0:",
  invalid_children,
  "\n"
)

cat(
  "Babies less than 0:",
  invalid_babies,
  "\n"
)

cat(
  "Lead time less than 0:",
  invalid_lead_time,
  "\n"
)

cat(
  "Zero-guest records:",
  zero_guest_records,
  "\n"
)


# ============================================================
# STEP 9 - FIX INVALID VALUES
# ============================================================

cat("\n============================================================\n")
cat("STEP 9 - FIX INVALID VALUES\n")
cat("============================================================\n")


# ------------------------------------------------------------
# Remove records with zero total guests
# ------------------------------------------------------------

before_invalid_removal <- nrow(df_clean)

df_clean <- df_clean[
  !(
    df_clean$adults +
    df_clean$children +
    df_clean$babies == 0
  ),
]

# ------------------------------------------------------------
# Remove records with negative ADR
# ------------------------------------------------------------

df_clean <- df_clean[
  df_clean$adr >= 0,
]

after_invalid_removal <- nrow(df_clean)

cat(
  "Rows before invalid-value treatment:",
  before_invalid_removal,
  "\n"
)

cat(
  "Rows after invalid-value treatment:",
  after_invalid_removal,
  "\n"
)

cat(
  "Records removed during invalid-value treatment:",
  before_invalid_removal -
    after_invalid_removal,
  "\n"
)


# ============================================================
# STEP 10 - OUTLIER DETECTION USING IQR
# ============================================================

cat("\n============================================================\n")
cat("STEP 10 - OUTLIER DETECTION USING IQR\n")
cat("============================================================\n")


# ------------------------------------------------------------
# Function to calculate IQR outliers
# ------------------------------------------------------------

detect_outliers <- function(x) {
  
  Q1 <- quantile(
    x,
    0.25,
    na.rm = TRUE
  )
  
  Q3 <- quantile(
    x,
    0.75,
    na.rm = TRUE
  )
  
  IQR_value <- Q3 - Q1
  
  lower_bound <- Q1 - 1.5 * IQR_value
  
  upper_bound <- Q3 + 1.5 * IQR_value
  
  outliers <- x[
    x < lower_bound |
      x > upper_bound
  ]
  
  return(length(outliers))
}


# ------------------------------------------------------------
# Variables for outlier detection
# ------------------------------------------------------------

outlier_variables <- c(
  "lead_time",
  "stays_in_weekend_nights",
  "stays_in_week_nights",
  "adults",
  "children",
  "babies",
  "previous_cancellations",
  "previous_bookings_not_canceled",
  "booking_changes",
  "days_in_waiting_list",
  "adr",
  "required_car_parking_spaces",
  "total_of_special_requests"
)


# ------------------------------------------------------------
# Calculate outlier counts
# ------------------------------------------------------------

outlier_counts <- data.frame(
  Variable = outlier_variables,
  Outlier_Count = sapply(
    df_clean[outlier_variables],
    detect_outliers
  )
)

outlier_counts$Outlier_Percentage <-
  round(
    (
      outlier_counts$Outlier_Count /
        nrow(df_clean)
    ) * 100,
    2
  )

print(outlier_counts)

# Save outlier summary
write.csv(
  outlier_counts,
  "outlier_summary.csv",
  row.names = FALSE
)


# ============================================================
# STEP 11 - OUTLIER VISUALIZATION
# ============================================================

cat("\n============================================================\n")
cat("STEP 11 - OUTLIER VISUALIZATION\n")
cat("============================================================\n")


# ------------------------------------------------------------
# Create 2 x 3 boxplot layout
# ------------------------------------------------------------

par(mfrow = c(2, 3))


# 1. Lead Time
boxplot(
  df_clean$lead_time,
  main = "Lead Time",
  ylab = "Days"
)


# 2. Average Daily Rate
boxplot(
  df_clean$adr,
  main = "Average Daily Rate",
  ylab = "ADR"
)


# 3. Week Night Stays
boxplot(
  df_clean$stays_in_week_nights,
  main = "Week Night Stays",
  ylab = "Number of Nights"
)


# 4. Weekend Night Stays
boxplot(
  df_clean$stays_in_weekend_nights,
  main = "Weekend Night Stays",
  ylab = "Number of Nights"
)


# 5. Booking Changes
boxplot(
  df_clean$booking_changes,
  main = "Booking Changes",
  ylab = "Number of Changes"
)


# 6. Special Requests
boxplot(
  df_clean$total_of_special_requests,
  main = "Special Requests",
  ylab = "Number of Requests"
)


# Reset plotting layout
par(mfrow = c(1, 1))


# ============================================================
# STEP 12 - DATA NORMALIZATION
# ============================================================

cat("\n============================================================\n")
cat("STEP 12 - DATA NORMALIZATION\n")
cat("============================================================\n")


# ------------------------------------------------------------
# Min-Max normalization function
# ------------------------------------------------------------

min_max_normalize <- function(x) {
  
  return(
    (x - min(x, na.rm = TRUE)) /
      (
        max(x, na.rm = TRUE) -
          min(x, na.rm = TRUE)
      )
  )
}


# ------------------------------------------------------------
# Normalize selected numerical variables
# ------------------------------------------------------------

df_clean$lead_time_normalized <-
  min_max_normalize(df_clean$lead_time)

df_clean$adr_normalized <-
  min_max_normalize(df_clean$adr)

df_clean$week_nights_normalized <-
  min_max_normalize(
    df_clean$stays_in_week_nights
  )

df_clean$weekend_nights_normalized <-
  min_max_normalize(
    df_clean$stays_in_weekend_nights
  )

df_clean$booking_changes_normalized <-
  min_max_normalize(
    df_clean$booking_changes
  )


# ------------------------------------------------------------
# Check normalized variables
# ------------------------------------------------------------

normalized_variables <- c(
  "lead_time_normalized",
  "adr_normalized",
  "week_nights_normalized",
  "weekend_nights_normalized",
  "booking_changes_normalized"
)

cat("\nSummary of normalized variables:\n")

print(
  summary(
    df_clean[normalized_variables]
  )
)


# ============================================================
# STEP 13 - CATEGORICAL ENCODING
# ============================================================

cat("\n============================================================\n")
cat("STEP 13 - CATEGORICAL ENCODING\n")
cat("============================================================\n")


# ------------------------------------------------------------
# Convert selected categorical variables to factors
# ------------------------------------------------------------

categorical_variables <- c(
  "hotel",
  "arrival_date_month",
  "meal",
  "country",
  "market_segment",
  "distribution_channel",
  "reserved_room_type",
  "assigned_room_type",
  "deposit_type",
  "customer_type",
  "reservation_status"
)


for (variable in categorical_variables) {
  
  if (variable %in% names(df_clean)) {
    
    df_clean[[variable]] <-
      as.factor(df_clean[[variable]])
    
  }
  
}


cat("\nCategorical variables converted to factors.\n")


# ------------------------------------------------------------
# Display structure after encoding
# ------------------------------------------------------------

str(
  df_clean[categorical_variables]
)


# ============================================================
# STEP 14 - DESCRIPTIVE STATISTICS
# ============================================================

cat("\n============================================================\n")
cat("STEP 14 - DESCRIPTIVE STATISTICS\n")
cat("============================================================\n")


descriptive_variables <- c(
  "lead_time",
  "adults",
  "children",
  "babies",
  "stays_in_weekend_nights",
  "stays_in_week_nights",
  "adr",
  "booking_changes",
  "total_of_special_requests"
)


# ------------------------------------------------------------
# Summary statistics
# ------------------------------------------------------------

descriptive_statistics <- data.frame(
  Variable = descriptive_variables,
  
  Minimum = sapply(
    df_clean[descriptive_variables],
    min,
    na.rm = TRUE
  ),
  
  Q1 = sapply(
    df_clean[descriptive_variables],
    quantile,
    probs = 0.25,
    na.rm = TRUE
  ),
  
  Median = sapply(
    df_clean[descriptive_variables],
    median,
    na.rm = TRUE
  ),
  
  Mean = sapply(
    df_clean[descriptive_variables],
    mean,
    na.rm = TRUE
  ),
  
  Q3 = sapply(
    df_clean[descriptive_variables],
    quantile,
    probs = 0.75,
    na.rm = TRUE
  ),
  
  Maximum = sapply(
    df_clean[descriptive_variables],
    max,
    na.rm = TRUE
  ),
  
  Standard_Deviation = sapply(
    df_clean[descriptive_variables],
    sd,
    na.rm = TRUE
  )
)


print(descriptive_statistics)


# Save descriptive statistics
write.csv(
  descriptive_statistics,
  "descriptive_statistics.csv",
  row.names = FALSE
)


# ============================================================
# STEP 15 - CORRELATION ANALYSIS
# ============================================================

cat("\n============================================================\n")
cat("STEP 15 - CORRELATION ANALYSIS\n")
cat("============================================================\n")


# ------------------------------------------------------------
# Select numerical variables
# ------------------------------------------------------------

numeric_variables <- c(
  "lead_time",
  "adults",
  "children",
  "babies",
  "stays_in_weekend_nights",
  "stays_in_week_nights",
  "adr",
  "total_of_special_requests",
  "previous_cancellations",
  "previous_bookings_not_canceled",
  "booking_changes",
  "required_car_parking_spaces",
  "days_in_waiting_list",
  "is_canceled"
)


numeric_data <- df_clean[
  numeric_variables
]


# ------------------------------------------------------------
# Calculate correlation matrix
# ------------------------------------------------------------

cor_matrix <- cor(
  numeric_data,
  use = "pairwise.complete.obs"
)


cat("\nCorrelation Matrix:\n")

print(
  round(cor_matrix, 2)
)


# ------------------------------------------------------------
# Save correlation matrix
# ------------------------------------------------------------

write.csv(
  cor_matrix,
  "correlation_matrix.csv",
  row.names = TRUE
)


# ------------------------------------------------------------
# Correlation heatmap
# ------------------------------------------------------------

corrplot(
  cor_matrix,
  method = "color",
  type = "upper",
  tl.cex = 0.7,
  tl.col = "black",
  addCoef.col = "black"
)


# ============================================================
# STEP 16 - EXPLORATORY DATA VISUALIZATION
# ============================================================

cat("\n============================================================\n")
cat("STEP 16 - EXPLORATORY DATA VISUALIZATION\n")
cat("============================================================\n")


# ------------------------------------------------------------
# Create 2 x 3 visualization layout
# ------------------------------------------------------------

par(mfrow = c(2, 3))


# ------------------------------------------------------------
# 1. Cancellation Status
# ------------------------------------------------------------

barplot(
  table(df_clean$is_canceled),
  main = "Booking Cancellation Status",
  xlab = "Status",
  ylab = "Number of Bookings",
  names.arg = c(
    "Not Canceled",
    "Canceled"
  )
)


# ------------------------------------------------------------
# 2. Hotel Type Distribution
# ------------------------------------------------------------

barplot(
  table(df_clean$hotel),
  main = "Hotel Type Distribution",
  xlab = "Hotel Type",
  ylab = "Number of Bookings"
)


# ------------------------------------------------------------
# 3. Arrival Month Distribution
# ------------------------------------------------------------

month_order <- c(
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
)


month_counts <- table(
  factor(
    df_clean$arrival_date_month,
    levels = month_order
  )
)


barplot(
  month_counts,
  main = "Bookings by Arrival Month",
  xlab = "Arrival Month",
  ylab = "Bookings",
  las = 2
)


# ------------------------------------------------------------
# 4. Lead Time Distribution
# ------------------------------------------------------------

hist(
  df_clean$lead_time,
  main = "Lead Time Distribution",
  xlab = "Lead Time (Days)",
  ylab = "Frequency",
  breaks = 30
)


# ------------------------------------------------------------
# 5. Average Daily Rate Distribution
# ------------------------------------------------------------

hist(
  df_clean$adr,
  main = "ADR Distribution",
  xlab = "Average Daily Rate",
  ylab = "Frequency",
  breaks = 30
)


# ------------------------------------------------------------
# 6. Market Segment Distribution
# ------------------------------------------------------------

barplot(
  sort(
    table(df_clean$market_segment),
    decreasing = TRUE
  ),
  main = "Market Segment Distribution",
  xlab = "Market Segment",
  ylab = "Bookings",
  las = 2
)


# Reset plotting layout
par(mfrow = c(1, 1))


# ============================================================
# STEP 17 - INITIAL INSIGHTS
# ============================================================

cat("\n============================================================\n")
cat("STEP 17 - INITIAL INSIGHTS\n")
cat("============================================================\n")


# ------------------------------------------------------------
# Total bookings
# ------------------------------------------------------------

total_bookings <- nrow(df_clean)


# ------------------------------------------------------------
# Cancellation rate
# ------------------------------------------------------------

cancellation_rate <-
  mean(
    df_clean$is_canceled,
    na.rm = TRUE
  ) * 100


# ------------------------------------------------------------
# Average lead time
# ------------------------------------------------------------

average_lead_time <-
  mean(
    df_clean$lead_time,
    na.rm = TRUE
  )


# ------------------------------------------------------------
# Average ADR
# ------------------------------------------------------------

average_adr <-
  mean(
    df_clean$adr,
    na.rm = TRUE
  )


# ------------------------------------------------------------
# Average length of stay
# ------------------------------------------------------------

average_week_nights <-
  mean(
    df_clean$stays_in_week_nights,
    na.rm = TRUE
  )

average_weekend_nights <-
  mean(
    df_clean$stays_in_weekend_nights,
    na.rm = TRUE
  )

average_total_stay <-
  average_week_nights +
  average_weekend_nights


# ------------------------------------------------------------
# Average special requests
# ------------------------------------------------------------

average_requests <-
  mean(
    df_clean$total_of_special_requests,
    na.rm = TRUE
  )


# ------------------------------------------------------------
# Most common hotel type
# ------------------------------------------------------------

hotel_counts <- table(
  df_clean$hotel
)

most_common_hotel <-
  names(
    hotel_counts[
      which.max(hotel_counts)
    ]
  )


# ------------------------------------------------------------
# Most common market segment
# ------------------------------------------------------------

market_counts <- table(
  df_clean$market_segment
)

most_common_market <-
  names(
    market_counts[
      which.max(market_counts)
    ]
  )


# ------------------------------------------------------------
# Most common customer type
# ------------------------------------------------------------

customer_counts <- table(
  df_clean$customer_type
)

most_common_customer <-
  names(
    customer_counts[
      which.max(customer_counts)
    ]
  )


# ------------------------------------------------------------
# Most common arrival month
# ------------------------------------------------------------

arrival_month_counts <- table(
  df_clean$arrival_date_month
)

most_common_month <-
  names(
    arrival_month_counts[
      which.max(arrival_month_counts)
    ]
  )


# ------------------------------------------------------------
# Print results
# ------------------------------------------------------------

cat(
  "Total Bookings:",
  total_bookings,
  "\n"
)

cat(
  "Cancellation Rate:",
  round(cancellation_rate, 2),
  "%\n"
)

cat(
  "Average Lead Time:",
  round(average_lead_time, 2),
  "days\n"
)

cat(
  "Average ADR:",
  round(average_adr, 2),
  "\n"
)

cat(
  "Average Length of Stay:",
  round(average_total_stay, 2),
  "nights\n"
)

cat(
  "Average Special Requests:",
  round(average_requests, 2),
  "\n"
)

cat(
  "Most Common Hotel Type:",
  most_common_hotel,
  "\n"
)

cat(
  "Most Common Market Segment:",
  most_common_market,
  "\n"
)

cat(
  "Most Common Customer Type:",
  most_common_customer,
  "\n"
)

cat(
  "Most Common Arrival Month:",
  most_common_month,
  "\n"
)


# ------------------------------------------------------------
# Create Initial Insights Summary Table
# ------------------------------------------------------------

initial_insights <- data.frame(
  
  Metric = c(
    "Total Bookings",
    "Cancellation Rate (%)",
    "Average Lead Time (Days)",
    "Average ADR",
    "Average Length of Stay (Nights)",
    "Average Special Requests"
  ),
  
  Value = c(
    total_bookings,
    round(cancellation_rate, 2),
    round(average_lead_time, 2),
    round(average_adr, 2),
    round(average_total_stay, 2),
    round(average_requests, 2)
  )
)


cat("\nInitial Insights Summary:\n")

print(initial_insights)


# Save initial insights
write.csv(
  initial_insights,
  "initial_insights.csv",
  row.names = FALSE
)


# ============================================================
# STEP 18 - EXPORT CLEAN DATASET
# ============================================================

cat("\n============================================================\n")
cat("STEP 18 - EXPORT CLEAN DATASET\n")
cat("============================================================\n")


# ------------------------------------------------------------
# Create output directory if it does not exist
# ------------------------------------------------------------

if (!dir.exists("Data/processed")) {
  
  dir.create(
    "Data/processed",
    recursive = TRUE
  )
  
}


# ------------------------------------------------------------
# Export final cleaned dataset
# ------------------------------------------------------------

write.csv(
  df_clean,
  "Data/processed/hotel_bookings_clean.csv",
  row.names = FALSE
)


# ------------------------------------------------------------
# Final dataset information
# ------------------------------------------------------------

cat(
  "Final cleaned dataset exported successfully.\n"
)

cat(
  "Final Rows:",
  nrow(df_clean),
  "\n"
)

cat(
  "Final Columns:",
  ncol(df_clean),
  "\n"
)

cat(
  "Output File: Data/processed/hotel_bookings_clean.csv\n"
)


# ============================================================
# FINAL PROJECT SUMMARY
# ============================================================

cat("\n============================================================\n")
cat("WEEK 1 ANALYSIS COMPLETED\n")
cat("============================================================\n")

cat(
  "\nFinal Dataset Dimensions:",
  nrow(df_clean),
  "rows x",
  ncol(df_clean),
  "columns\n"
)

cat(
  "\nAll major Week 1 data-cleaning and preliminary-analysis\n"
)

cat(
  "steps have been completed successfully.\n"
)

cat(
  "\nClean dataset:\n"
)

cat(
  "Data/processed/hotel_bookings_clean.csv\n"
)

cat("\n============================================================\n")