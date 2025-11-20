# Wine Multivariate Analysis: MDS, PCA and Correspondence Analysis

This repository contains a multivariate statistical analysis of a wine dataset
with **178 samples** and **5 wine classes**, carried out for the course  
*Statistical Methods for Business Strategies* (University of Calabria).

The objectives are:

1. Provide a graphical representation of the **similarities and dissimilarities
   between wine classes** using chemical composition variables.
2. Investigate whether specific **sommelier characteristics** (gender and age)
   are associated with the consumption of particular wine categories.

The analysis is implemented in **R** and documented through a written report.

---

## 📊 Dataset

The dataset includes **19 variables**:

- **Class label**: wine class (1–5)  
- **13 chemical composition variables** (columns 2–14):  
  `Alcohol`, `Malic.acid`, `Ash`, `Alcalinity.of.ash`, `Magnesium`,
  `Total.phenols`, `Flavanoids`, `Nonflavanoid.phenols`, `Proanthocyanins`,
  `Color.intensity`, `Hue`, `OD280.OD315.of.diluted.wines`, `Proline`
- **5 sommelier-related variables** (columns 15–19):  
  gender (`F`, `M`) and age groups (`Eta18_25`, `Eta25_40`, `Eta_sup40`)

> **Data availability**  
> The file `data/WINE.txt` is used for educational purposes.  
> Depending on the course rules, it may not be redistributed publicly.  
> If the dataset cannot be shared here, please contact the authors or use a
> compatible wine dataset with the same structure.

---

## 🔬 Methods

The project applies several multivariate techniques:

1. **Exploratory Data Analysis**
   - Descriptive statistics and histograms for the 13 chemical variables  
   - Boxplots and correlation matrix to explore heterogeneity, outliers and
     latent structure

2. **Metric Multidimensional Scaling (MDS)**
   - MDS applied to the **centroids of the 5 wine classes**
   - Euclidean distances computed on standardized centroids
   - 2D solution providing a clear perceptual map of the wine classes

3. **Principal Component Analysis (PCA)**
   - PCA on standardized centroids
   - Loadings and biplot used to interpret the main axes in terms of
     chemical variables
   - Comparison between PCA and MDS maps

4. **Correspondence Analysis (CA)**
   - Contingency table between **wine classes** and **sommelier profiles**
     (gender × age)
   - Joint representation of classes and profiles to highlight preferential
     associations

Further theoretical details (distances, eigenvalues, GoF, chi-square distance, etc.)
are presented in the report.

---

## 🗂 Project structure

```text
.
├─ R/
│   └─ wines_mds_pca_ca.R        # Main R script: EDA, MDS, PCA, CA
├─ data/
│   └─ WINE.txt                  # Wine dataset (if distributable)
├─ docs/
│   └─ report/
│       └─ Relazione_MDS_AC.pdf  # Full report (Italian)
├─ .gitignore
├─ LICENSE
└─ README.md
