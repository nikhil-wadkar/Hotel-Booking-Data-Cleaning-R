# Week 1 – Data Cleaning and Preliminary Analysis with R

## Project Overview

This project is part of my Week 1 internship task focused on Data Cleaning and Preliminary Analysis using R.

The Hotel Booking Demand dataset was analyzed to identify and handle data-quality issues and perform preliminary exploratory analysis.

## Objectives

- Load and inspect the dataset
- Analyze missing values
- Detect and remove duplicate records
- Handle missing values
- Identify invalid values
- Detect potential outliers using the IQR method
- Apply Min-Max normalization
- Encode categorical variables
- Calculate descriptive statistics
- Perform correlation analysis
- Create exploratory visualizations
- Generate initial insights
- Export the cleaned dataset

## Dataset

**Hotel Booking Demand**

The dataset contains hotel reservation information including:

- Hotel type
- Booking cancellation status
- Lead time
- Arrival information
- Number of guests
- Length of stay
- Market segment
- Room type
- Deposit type
- Customer type
- Average Daily Rate (ADR)
- Reservation status

## Tools and Technologies

- R
- RGui
- Base R
- corrplot

## Project Structure

```text
Hotel-Booking-Data-Cleaning-R/
│
├── R/
│   └── Week_1_Data_Cleaning_Preliminary_Analysis.R
│
├── Data/
│   └── processed/
│       └── hotel_bookings_clean.csv
│
├── Outputs/
│   ├── correlation_heatmap.png
│   ├── outlier_boxplots.png
│   └── exploratory_visualizations.png
│
└── Report/
    └── Week_1_Data_Cleaning_Preliminary_Analysis_Report.docx
