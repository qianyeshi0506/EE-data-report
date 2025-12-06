<!-- ====================================================================== -->
<!--                    🌍 ULEZ NO₂ Impact Analysis — Group 6              -->
<!-- ====================================================================== -->

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=30&color=3DB2FF&center=true&vCenter=true&width=650&lines=London+ULEZ+Impact+Assessment;Satellite+Data+%7C+GEE+%7C+Stata+Analysis;Environmental+Economics+Project+Group+6" alt="Animated Banner">
</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/github/explore/main/topics/earth-engine/earth-engine.png">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/github/explore/main/topics/stata/stata.png">
    <img alt="Tech Logo" src="https://raw.githubusercontent.com/github/explore/main/topics/stata/stata.png" width="110">
  </picture>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Google%20Earth%20Engine-Data%20Processing-34A853?style=for-the-badge">
  <img src="https://img.shields.io/badge/Stata-Panel%20Regression-007ACC?style=for-the-badge">
  <img src="https://img.shields.io/badge/Sentinel--5P-Satellite%20NO%E2%82%82-FF5733?style=for-the-badge">
</p>

---

# 📘 Project Overview

This repository contains the full workflow, code, and outputs for an empirical analysis evaluating the effect of **London’s ULEZ expansion** on **NO₂ pollution**, using:

- 🛰️ **Sentinel-5P satellite NO₂ data**
- 🌦️ **ERA5-Land meteorological variables**
- 📊 **Stata panel econometrics (DID, Event Study, Placebo)**
- 🗺️ **Google Earth Engine (GEE) preprocessing**

The project was developed for **7QQMM906 – Environmental Economics** at **King’s College London**.

---

# 📚 Table of Contents

<table>
  <tr>
    <td>📘 <a href="#-project-overview">Project Overview</a></td>
    <td>🛰️ <a href="#-data-sources">Data Sources</a></td>
  </tr>
  <tr>
    <td>📁 <a href="#-repository-structure">Repository Structure</a></td>
    <td>🧠 <a href="#-methodology">Methodology</a></td>
  </tr>
  <tr>
    <td>📉 <a href="#-results-summary">Results Summary</a></td>
    <td>🔁 <a href="#-reproducibility">Reproducibility</a></td>
  </tr>
  <tr>
    <td>👥 <a href="#-contributors">Contributors</a></td>
    <td>📊 <a href="#-github-stats">GitHub Stats</a></td>
  </tr>
  <tr>
</table>



---

# 🛰️ Data Sources

<details>
<summary><b> 📌Click to expand</b></summary>

### **1. Sentinel-5P OFFL NO₂**
- Variable used: *tropospheric_NO2_column_number_density*  
- Daily NO₂ averaged over ULEZ and control zones

### **2. ERA5-Land (ECMWF)**
Meteorological variables used as controls:
- Temperature  
- Wind speed & direction  
- Surface pressure  
- Dew point / RH  
- Total precipitation  
- Cloud fraction  

### **3. Geospatial Boundaries**
- 2021 ULEZ  
- 2023 ULEZ expansion  
- Outer London (control area)  

</details>


---



# 📁 Repository Structure

<details>
<summary><b>📌 Click to expand</b></summary>

<pre>
📁 Group_6
 ┣ 📂 Code
 ┃ ┣ 📄 Master_file.do            — Main master script (runs all sub-scripts)
 ┃ ┣ 📄 Import.do                 — Data import script
 ┃ ┣ 📄 Clean.do                  — Data cleaning script
 ┃ ┣ 📄 Test.do                   — Data correction / transformation
 ┃ ┣ 📄 Merge.do                  — Dataset merging script
 ┃ ┣ 📄 Generate.do               — Variable generation
 ┃ ┣ 📄 Visualize.do              — Figure generation
 ┃ ┗ 📄 Regress.do                — Regression analysis
 │
 ┣ 📂 Data
 ┃ ┣ 📁 raw                       — Raw datasets (e.g., GEE data, ERA5)
 ┃ ┗ 📁 processed                 — Cleaned & analysis-ready datasets
 │
 ┣ 📂 Output
 ┃ ┣ 📁 Figures                   — Figures (named consistently with report: Fig1, Fig2…)
 ┃ ┣ 📁 Tables                    — Tables (named consistently with report: Table1…)
 ┃ ┗ 📄 final_report.pdf          — Final project report
 │
 ┗ 📘 README.md                   — This documentation file
</pre>

</details>

---
# 🧠 Methodology Summary

<details>
<summary><b>📌 Click to expand</b></summary>

### ✔ Data Preprocessing
- Merging NO₂ + meteorological variables  
- Creating treatment, post, and DID interaction terms  
- Winsorizing 1–99th percentile  
- Holiday dummy, time fixed effects  
- Log-transform of NO₂  

### ✔ Econometric Framework
- **Difference-in-Differences (DID)**  
- **Event Study (pre-trend & dynamic effects)**  
- **Permutation-based placebo test**  
- **Heterogeneity across station types**  

### ✔ Software
- Google Earth Engine (JavaScript)
- Stata 17 (reghdfe, coefplot, dpplot)

</details>

---

# 📉 Results Summary

<details>
<summary><b>📌 Click to expand</b></summary>

### ✅ **NO₂ decreased significantly in treated areas after ULEZ expansion**  
→ Estimated reduction **≈ 9–10%**

### ✅ Pre-policy trends stable  
Supports DID identification validity.

### ✅ Robustness passed  
- Placebo (random assignment)  
- Heterogeneity across monitoring station categories  

### ✅ Policy implications  
- ULEZ is effective at reducing NO₂  
- Results align with environmental externality & Pigouvian frameworks  

</details>

---
# 👥 Contributors
<table align="center">
  <tr>
    <!-- Author 1 -->
    <td align="center">
      <img src="https://github.com/qianyeshi0506.png" width="120" style="border-radius:50%">
      <br><b>Qianye Shi</b><br>GEE & Data Pipeline
    </td>
    <!-- Author 2 -->
    <td align="center">
      <img src="https://github.com/victoriapodovsovnik.png" width="120" style="border-radius:50%">
      <br><b>Victoria Podovsovnik</b><br>Stata Modeling & Regression
    </td>

  </tr>
</table>

</details>

---

# 📈 GitHub Stats

<p align="center">
  <img src="https://github-readme-stats-one-bice.vercel.app/api?username=qianyeshi0506&show_icons=true&theme=vue" height="165">
  <img src="https://github-readme-stats-one-bice.vercel.app/api?username=victoriapodovsovnik&show_icons=true&theme=vue" height="165">
</p>

































