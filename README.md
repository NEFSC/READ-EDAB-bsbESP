This R project contains the code used to create data, figures, and tables for the 2025 Black Sea Bass Snapshot Ecosystem and Socioeconomic Profile document. Figures and tables were compiled with the _targets.R script using the {targets} R package. This script calculates most indicators from their source data. Methods are further documented in `readme_2025.txt`. This R project is intended to allow a user to recreate the 2025 Black Sea Bass Snapshot Ecosystem and Socioeconomic Profile data and analyses; however, due to local differences in R packages, file paths, and R versions, it is likely that a user will need to complete (hopefully minimal) troubleshooting in order to successfully execute the entire codebase. We hope that the documentation here, in the `_targets.R` file, in the `scripts` folder, and in the `docs` folder will help users complete any needed troubleshooting.

Folders and files in this repository:
- `.github` folder: Contains GitHub actions
- `_targets` folder: Automatically created and updated by the {targets} package
- `data` folder: Contains indicator time series data
- `data-raw` folder: Contains raw or intermediate data files
- `docs` folder: Contains Quarto document and associated helper files to generate the snapshot pdf report
- `images` folder: Contains images of indicator time series
- `renv` folder: Automatically created and updated by the {renv} package
- `scripts` folder: Contains scripts used to create indicators, plot indicators, and other functions needed to create the snapshot pdf report



#### Legal disclaimer

*This repository is a scientific product and is not official
communication of the National Oceanic and Atmospheric Administration, or
the United States Department of Commerce. All NOAA GitHub project code
is provided on an ‘as is’ basis and the user assumes responsibility for
its use. Any claims against the Department of Commerce or Department of
Commerce bureaus stemming from the use of this GitHub project will be
governed by all applicable Federal law. Any reference to specific
commercial products, processes, or services by service mark, trademark,
manufacturer, or otherwise, does not constitute or imply their
endorsement, recommendation or favoring by the Department of Commerce.
The Department of Commerce seal and logo, or the seal and logo of a DOC
bureau, shall not be used in any manner to imply endorsement of any
commercial product or activity by DOC or the United States Government.*


