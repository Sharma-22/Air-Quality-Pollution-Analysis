# AirWatch: Interactive Air Quality & Pollution Analytics Dashboard

AirWatch is an interactive web-based analytical application built with **R**, **Shiny**, and **shinydashboard**. It enables multi-pollutant environmental telemetry tracking, temporal trend analysis, meteorological correlations, and localized city-wise comparisons across 24 Indian cities spanning North, West, South, and Himalayan regional clusters.

---

## 🌟 Key Features

- **Cascading Filters**: Dynamically filters locations hierarchically: `State` → `District` → `City` → `Date Range` using reactive observers.
- **Real-Time KPI Value Boxes**: Dynamic tracking of Pan-India / regional Average AQI, PM2.5, PM10, and active city count.
- **Pollution Trends & Weather**:
  - LOESS smoothed time-series curves for individual pollutants (AQI, PM2.5, PM10, NO2, SO2, CO).
  - Temperature vs. Humidity scatter plots with color-coded AQI severity gradients.
- **City Benchmarking**: Horizontal bar ranking and automated summary tables highlighting the Top 5 most polluted locations.
- **Interactive Data Explorer**:
  - Full dataset exploration via `DT::datatable` with client-side sorting, pagination, and multi-column search.
  - One-click dynamic CSV export (`AirWatch_<Date>.csv`) honoring active filter states.

---

## 📂 Project Structure

```text
AirWatch/
│
├── project_r.R                      # Main R Shiny application (UI & Server)
├── requirements.txt                 # Python / environment dependency list
├── install_packages.R              # R script to install all required libraries
├── README.md                       # Project documentation and setup guide
└── AirWatch_R_Shiny_Report.docx    # Mini project report document
```

---

## 🛠️ Prerequisites

Ensure you have the following installed on your system:
- **R** (version 4.2.0 or higher): [Download R](https://cran.r-project.org/)
- **RStudio Desktop** (recommended): [Download RStudio](https://posit.co/download/rstudio-desktop/)

---

## 📦 Required R Packages

| Package | Purpose |
| :--- | :--- |
| `shiny` | Reactive web application framework |
| `shinydashboard` | Dashboard UI layouts, value boxes, and sidebars |
| `ggplot2` | Data visualization and grammar of graphics |
| `dplyr` | Data wrangling, filtering, and summarization pipelines |
| `tidyr` | Tidy data reshaping and manipulations |
| `plotly` | Interactive web-based plotting with tooltips and zoom |
| `DT` | Interactive JavaScript DataTables wrapper |
| `lubridate` | Date-time handling and temporal manipulations |

---

## 🚀 Installation & Setup

### 1. Clone or Extract Project
Place `project_r.R` and all related files into a dedicated project folder.

### 2. Install Dependencies
Open R or RStudio Console and run:

```R
install.packages(c(
  "shiny",
  "shinydashboard",
  "ggplot2",
  "dplyr",
  "tidyr",
  "plotly",
  "DT",
  "lubridate"
))
```

Alternatively, run the automated setup script:
```R
source("install_packages.R")
```

### 3. Run the Application
In RStudio:
1. Open `project_r.R`.
2. Click the **Run App** button in the top right corner of the script editor.

Or from the R Console:
```R
library(shiny)
shiny::runApp("project_r.R")
```

---

## 🖥️ System Requirements

- **Operating System**: Windows 10/11, macOS, or Linux
- **Processor**: Intel Core i3 / AMD Ryzen 3 or higher
- **RAM**: Minimum 4 GB (8 GB recommended)
- **Disk Space**: ~500 MB free space

---

## 👥 Author

- **Name**: Komal
- **UID**: 26MCD10036
- **Branch**: Master of Computer Applications (MCA) – Data Science
- **Institute**: University Institute of Computing (UIC), Chandigarh University
