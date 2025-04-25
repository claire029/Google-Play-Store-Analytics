# 📱 Google Play Store Analytics
**Final Project – ISM 4420 Business Analytics**  
*Florida International University | Spring 2025*  
By Anh Hoang & Christopher Tsiomakidis

---

## 📌 Project Overview
This project aims to assist a marketing team in creating a data-driven promotional strategy for mobile applications listed on the Google Play Store. Using unsupervised machine learning—specifically **k-means clustering**—we classified apps into three strategic groups based on installs, reviews, ratings, price, and size. Each group was then mapped to a tailored marketing plan.

---

## 🎯 Business Objectives
- Identify actionable patterns in app performance
- Segment apps by user engagement and monetization traits
- Propose promotional strategies based on behavioral and commercial insights

---

## 🧼 Data Preprocessing
- **Source**: `googleplaystore.csv` (10,841 entries, 13 columns)
- **Cleaning steps**:
  - Removed duplicates
  - Converted size/price/install units to numeric
  - Replaced “Varies with device” with genre-wise average
  - Removed apps with no reviews and missing ratings
  - Final dataset: **8,892 rows** and 5 key numeric columns

```r
# Final clustering variables
select(Rating, Reviews, Installs, Price, Size)
```

---

## 🧪 Analytical Approach

### 🔹 Clustering: K-Means
- Selected variables: `Rating`, `Reviews`, `Installs`, `Price`, `Size`
- Used **log-transformation** on skewed variables
- Optimal clusters: **K = 3** (chosen using Elbow Method)
- Visualization via **PCA** to interpret clusters

---

## 📊 Cluster Insights & Strategy

| Cluster        | Traits                                                                 | Strategy Overview                                          | Budget  |
|----------------|------------------------------------------------------------------------|------------------------------------------------------------|---------|
| **Cluster 1**  | Solid performers with moderate-high installs & good ratings            | Scale through Google Ads, YouTube pre-rolls                | $3,000  |
| **Cluster 2**  | Niche or new apps, freemium/paid, small size, highest average price    | Build credibility via influencers, PR, micro-targeting     | $2,500  |
| **Cluster 3**  | Viral market leaders (TikTok, Google, etc.), all free, massive reach   | Focus on retention via in-app events and major media ads   | $10,000 |

---

## 📈 Key Findings

- **Reviews correlate strongly** with installs (r = 0.63)
- **App categories** like FAMILY, GAME, TOOLS are oversaturated
- **PCA results**:
  - PC1: driven by Reviews & Installs → indicates *popularity*
  - PC2: reflects *user satisfaction* & *complexity* (Rating + Size)

---

## 💡 Promotional Plan Summary

| Cluster         | Primary Channel                      | KPI Focus                          | Messaging Style                         |
|-----------------|---------------------------------------|-------------------------------------|------------------------------------------|
| Solid Performers| Google/YouTube Ads                   | Installs, CPI, Retention            | “Join 1M+ users!”                         |
| Niche/Newcomers | Influencer marketing, PR             | Conversion, Reviews, Trial rate     | “Try before you buy”                     |
| Market Leaders  | National TV, In-app, Feature rollout | DAU, Ad revenue, Brand loyalty      | “New feature just dropped!”              |

---

## 📚 References
- ISM 4420 Lecture Notes – Dr. Hemang Subramanian
- Google Play Store Dataset 

---

## 👩‍💻 Authors
Anh Hoang, 
Christopher Tsiomakidis  
[LinkedIn](https://www.linkedin.com/in/anhhoang29/) | [Portfolio](https://github.com/claire029)
