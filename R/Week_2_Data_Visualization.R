# ============================================
# WEEK 2 - DATA VISUALIZATION
# ============================================

library(ggplot2)
library(dplyr)
library(scales)

# Load cleaned dataset
df <- read.csv(
  file.choose(),
  stringsAsFactors = FALSE
)

# Initial inspection
dim(df)
names(df)
str(df)
summary(df)
if (!dir.exists("Outputs")) {
  dir.create("Outputs")
}
getwd()
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

df$arrival_date_month <- factor(
  df$arrival_date_month,
  levels = month_order,
  ordered = TRUE
)
booking_status <- df %>%
  count(is_canceled) %>%
  mutate(
    Status = ifelse(
      is_canceled == 1,
      "Canceled",
      "Not Canceled"
    )
  )

p1 <- ggplot(
  booking_status,
  aes(x = Status, y = n)
) +
  geom_col() +
  geom_text(
    aes(label = comma(n)),
    vjust = -0.5
  ) +
  labs(
    title = "Booking Cancellation Status",
    x = "Booking Status",
    y = "Number of Bookings"
  ) +
  theme_minimal()

p1
ggsave(
  "Outputs/booking_status.png",
  p1,
  width = 8,
  height = 5,
  dpi = 300
)
hotel_distribution <- df %>%
  count(hotel)

p2 <- ggplot(
  hotel_distribution,
  aes(x = hotel, y = n)
) +
  geom_col() +
  geom_text(
    aes(label = comma(n)),
    vjust = -0.5
  ) +
  labs(
    title = "Hotel Type Distribution",
    x = "Hotel Type",
    y = "Number of Bookings"
  ) +
  theme_minimal()

p2
ggsave(
  "Outputs/hotel_distribution.png",
  p2,
  width = 8,
  height = 5,
  dpi = 300
)
monthly_bookings <- df %>%
  count(arrival_date_month)

p3 <- ggplot(
  monthly_bookings,
  aes(x = arrival_date_month, y = n, group = 1)
) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_text(
    aes(label = comma(n)),
    vjust = -0.7,
    size = 3
  ) +
  labs(
    title = "Monthly Booking Trend",
    x = "Arrival Month",
    y = "Number of Bookings"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    )
  )

p3
ggsave(
  "Outputs/monthly_booking_trend.png",
  p3,
  width = 10,
  height = 6,
  dpi = 300
)
p4 <- ggplot(
  df,
  aes(x = lead_time)
) +
  geom_histogram(
    bins = 40
  ) +
  labs(
    title = "Distribution of Booking Lead Time",
    x = "Lead Time (Days)",
    y = "Number of Bookings"
  ) +
  theme_minimal()

p4
ggsave(
  "Outputs/lead_time_histogram.png",
  p4,
  width = 8,
  height = 5,
  dpi = 300
)
p5 <- ggplot(
  df,
  aes(x = adr)
) +
  geom_histogram(
    bins = 40
  ) +
  labs(
    title = "Distribution of Average Daily Rate",
    x = "Average Daily Rate (ADR)",
    y = "Number of Bookings"
  ) +
  theme_minimal()

p5
ggsave(
  "Outputs/adr_histogram.png",
  p5,
  width = 8,
  height = 5,
  dpi = 300
)
p6 <- ggplot(
  df,
  aes(
    x = lead_time,
    y = adr
  )
) +
  geom_point(
    alpha = 0.25
  ) +
  geom_smooth(
    method = "lm",
    se = FALSE
  ) +
  labs(
    title = "Relationship Between Lead Time and ADR",
    x = "Lead Time (Days)",
    y = "Average Daily Rate (ADR)"
  ) +
  theme_minimal()

p6
ggsave(
  "Outputs/lead_time_vs_adr.png",
  p6,
  width = 8,
  height = 6,
  dpi = 300
)
p7 <- ggplot(
  df,
  aes(
    x = hotel,
    y = adr
  )
) +
  geom_boxplot() +
  labs(
    title = "Average Daily Rate by Hotel Type",
    x = "Hotel Type",
    y = "Average Daily Rate (ADR)"
  ) +
  theme_minimal()

p7
ggsave(
  "Outputs/adr_by_hotel.png",
  p7,
  width = 8,
  height = 6,
  dpi = 300
)
market_segment <- df %>%
  count(market_segment) %>%
  arrange(desc(n))

p8 <- ggplot(
  market_segment,
  aes(
    x = reorder(market_segment, n),
    y = n
  )
) +
  geom_col() +
  coord_flip() +
  geom_text(
    aes(label = comma(n)),
    hjust = -0.1,
    size = 3
  ) +
  labs(
    title = "Bookings by Market Segment",
    x = "Market Segment",
    y = "Number of Bookings"
  ) +
  theme_minimal()

p8
ggsave(
  "Outputs/market_segment.png",
  p8,
  width = 9,
  height = 6,
  dpi = 300
)
yearly_bookings <- df %>%
  count(arrival_date_year)

p9 <- ggplot(
  yearly_bookings,
  aes(
    x = arrival_date_year,
    y = n,
    group = 1
  )
) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_text(
    aes(label = comma(n)),
    vjust = -0.7
  ) +
  labs(
    title = "Year-wise Booking Trend",
    x = "Arrival Year",
    y = "Number of Bookings"
  ) +
  theme_minimal()

p9
ggsave(
  "Outputs/yearly_booking_trend.png",
  p9,
  width = 8,
  height = 5,
  dpi = 300
)
cancellation_by_hotel <- df %>%
  group_by(hotel) %>%
  summarise(
    cancellation_rate = mean(is_canceled) * 100
  )

p10 <- ggplot(
  cancellation_by_hotel,
  aes(
    x = hotel,
    y = cancellation_rate
  )
) +
  geom_col() +
  geom_text(
    aes(
      label = paste0(
        round(cancellation_rate, 1),
        "%"
      )
    ),
    vjust = -0.5
  ) +
  labs(
    title = "Cancellation Rate by Hotel Type",
    x = "Hotel Type",
    y = "Cancellation Rate (%)"
  ) +
  scale_y_continuous(
    labels = function(x) paste0(x, "%")
  ) +
  theme_minimal()

p10
ggsave(
  "Outputs/cancellation_rate_hotel.png",
  p10,
  width = 8,
  height = 5,
  dpi = 300
)
