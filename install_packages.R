# One-Click Package Installer for AirWatch Dashboard
packages <- c(
  "shiny",
  "shinydashboard",
  "ggplot2",
  "dplyr",
  "tidyr",
  "plotly",
  "DT",
  "lubridate"
)

installed <- rownames(installed.packages())
for (pkg in packages) {
  if (!pkg %in% installed) {
    message(paste("Installing package:", pkg))
    install.packages(pkg, dependencies = TRUE)
  } else {
    message(paste("Package already installed:", pkg))
  }
}

message("All packages are ready! You can now run the app using shiny::runApp('project_r.R')")
