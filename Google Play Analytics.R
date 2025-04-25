apps = read.csv("C://Users//nahoa//Downloads//googleplaystore.csv")

#summary of dataset
head(apps)
colnames(apps)
summary(apps)
str(apps)
install.packages("Amelia")
library(Amelia)
missmap(apps)

#Handling missing data
install.packages("tidyverse")
library(tidyverse)
apps <- distinct(apps)
apps_w_rating <- drop_na(apps)
str(apps_w_rating)

#cleaning Reviews and Installs
apps_w_rating <- apps_w_rating %>%
  mutate(
    Reviews = as.numeric(Reviews),
    Installs = ifelse(Installs == "0+", "1", Installs),
    Installs = str_remove_all(Installs, "[+,]"),
    Installs = as.numeric(Installs)
  )

#cleaning Price
apps_w_rating <- apps_w_rating %>%
  filter(Price != "Everyone") %>%
  mutate(
    Price = str_remove(Price, "\\$"),
    Price = as.numeric(Price)
  )
#cleaning Size

apps_w_rating <- apps_w_rating %>%
  mutate(
    Size = case_when(
      str_detect(Size, "M") ~ as.numeric(str_replace(Size, "M", "")),
      str_detect(Size, "k") ~ as.numeric(str_replace(Size, "k", "")) / 1024,
      TRUE ~ NA_real_
    )
  )

# Replaced Size$Varies_with_device 
overall_mean_size <- mean(apps_w_rating$Size, na.rm = TRUE)

apps_w_rating <- apps_w_rating %>%
  group_by(Genres) %>%
  mutate(Size = ifelse(is.na(Size), mean(Size, na.rm = TRUE), Size)) %>%
  ungroup() %>%
  mutate(Size = ifelse(is.na(Size), overall_mean_size, Size))

#Distribution
  #Distribution of price
ggplot(apps_w_rating, aes(x = log10(Price + 1))) +
  geom_histogram(bins = 30, fill = "gold", color = "black") +
  labs(
    title = "Histogram of Log-Transformed App Prices",
    x = "Log10(Price + 1)",
    y = "Count"
  ) +
  theme_minimal()

  #Distribution of review
ggplot(apps_w_rating, aes(x = log10(Reviews + 1))) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  labs(
    title = "Histogram of Log-Transformed App Reviews",
    x = "Log10(Number of Reviews + 1)",
    y = "Count"
  ) +
  theme_minimal()

#Distribution of rating
ggplot(apps_w_rating, aes(x = Rating)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  labs(
    title = "Histogram of App Rating",
    x = "Rating",
    y = "Count"
  ) +
  theme_minimal()

#Distribution of install
ggplot(apps_w_rating, aes(x = log10(Installs + 1))) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  labs(
    title = "Histogram of Log-Transformed App Installations",
    x = "Log10(Number of Installs + 1)",
    y = "Count"
  ) +
  theme_minimal()

#Distribution of size
ggplot(apps_w_rating, aes(x = Size)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  labs(
    title = "Histogram of Size",
    x = "Size",
    y = "Count"
  ) +
  theme_minimal()

na_size_rows <- subset(apps_w_rating, is.na(Size))
str(na_size_rows)

  #Count apps in each Category
apps %>%
  count(Category) %>%
  arrange(desc(n)) %>%
  ggplot(aes(x = reorder(Category, n), y = n)) +
  geom_col(fill = "lightgreen", color = "black") +
  coord_flip() +
  labs(title = "Total Number of Apps by Category",
       x = "Category",
       y = "Number of Apps") +
  theme_minimal()

#summary
summary(apps_w_rating$Rating)
summary(apps_w_rating$Reviews)
summary(apps_w_rating$Size)
summary(apps_w_rating$Installs)
summary(apps_w_rating$Price)
#Standrad deviation
sd(apps_w_rating$Size)
sd(apps_w_rating$Installs)
sd(apps_w_rating$Price)
sd(apps_w_rating$Reviews)
sd(apps_w_rating$Rating)

#Correlation
regression_data <- apps_w_rating %>%
  select(Rating, Reviews, Installs, Price, Size) %>%
  drop_na()

  #Heat map
install.packages("ggcorrplot")
library(ggcorrplot)
cor_matrix <- cor(regression_data, use = "complete.obs")
ggcorrplot(cor_matrix, 
           method = "circle", 
           type = "full", 
           lab = TRUE, 
           lab_size = 3,
           colors = c("steelblue", "white", "darkred"),
           title = "Correlation Matrix Heatmap",
           ggtheme = theme_minimal())


  #Linear Regression Model
model <- lm(Installs ~ Reviews + Rating + Price + Size, data = regression_data)
summary(model)
#cluster data using K-means and Elbow Method to find K
cluster_data <- apps_w_rating %>%
  select(Rating, Reviews, Installs, Price, Size) %>%
  drop_na() %>%
  mutate(across(everything(), as.numeric))

str(cluster_data)
summary(cluster_data)

cluster_data_scaled <- scale(cluster_data)
head(cluster_data_scaled)

wss <- vector()
for (k in 1:10) {
  kmeans_result <- kmeans(cluster_data_scaled, centers = k, nstart = 10)
  wss[k] <- kmeans_result$tot.withinss
}

wss <- numeric(10)

for (k in 1:10) {
  set.seed(123)  # for reproducibility
  kmeans_result <- kmeans(cluster_data_scaled, centers = k, nstart = 10)
  wss[k] <- kmeans_result$tot.withinss
}

plot(1:10, wss, type = "b",
     pch = 19, frame = FALSE,
     xlab = "Number of Clusters (k)",
     ylab = "Total Within-Cluster Sum of Squares (WSS)",
     main = "Elbow Method for Optimal k")

set.seed(123)
kmeans_result <- kmeans(cluster_data_scaled, centers = 3, nstart = 25)
cluster_data$Cluster <- as.factor(kmeans_result$cluster)
head(cluster_data)

cluster_summary <- cluster_data %>%
  group_by(Cluster) %>%
  summarise(
    Avg_Rating = mean(Rating, na.rm = TRUE),
    Avg_Reviews = mean(Reviews, na.rm = TRUE),
    Avg_Installs = mean(Installs, na.rm = TRUE),
    Avg_Price = mean(Price, na.rm = TRUE),
    Avg_Size = mean(Size, na.rm = TRUE),
    Count = n()
  )
print(cluster_summary)


# Run PCA on scaled data
pca_result <- prcomp(cluster_data_scaled)

# Create a dataframe with first 2 PCs and cluster labels
pca_df <- as.data.frame(pca_result$x[, 1:2])
pca_df$Cluster <- cluster_data$Cluster

# Plot PCA-based cluster visualization
ggplot(pca_df, aes(x = PC1, y = PC2, color = Cluster)) +
  geom_point(alpha = 0.7, size = 2.5) +
  labs(title = "K-Means Clusters Visualized with PCA",
       x = "Principal Component 1",
       y = "Principal Component 2") +
  theme_minimal()

pca_result$rotation
#Description
library(ggplot2)

ggplot(cluster_data, aes(x = Cluster, y = Installs, fill = Cluster)) +
  geom_boxplot() +
  scale_y_log10() +  
  labs(title = "Boxplot of Installs by Cluster",
       x = "Cluster",
       y = "Number of Installs (log scale)") +
  theme_minimal()

#Subset cluster data
clustered_apps <- bind_cols(apps_w_rating %>% drop_na(), cluster_data["Cluster"])

subset_cluster_3 <- clustered_apps %>%
  filter(Cluster == "3")

head(subset_cluster_3)

subset_cluster_2 <- clustered_apps %>%
  filter(Cluster == "2")

subset_cluster_1 <- clustered_apps %>%
  filter(Cluster == "1")

