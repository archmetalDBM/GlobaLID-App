
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Release](https://img.shields.io/github/v/release/archmetalDBM/GlobaLID-app.svg)](https://github.com/archmetalDBM/GlobaLID-App)
[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
<!-- badges: end -->

# GlobaLID App <img src="www/logo.svg" align="right" width="120" />

Here you can find the source code of the GlobaLID web app.

# What is GlobaLID?

GlobaLID is a Global Lead Isotope Database and aims to facilitate the
reconstruction of raw material provenances with lead isotopes,
especially in archaeology. The app provides direct access to and
convenient interaction with the [GlobaLID
database](https://doi.org/10.5880/fidgeo.2023.043). You can filter the
database according to your research question, upload own data to compare
it with GlobaLID, and produce and download publication ready plots.
Watch our [video tutorial](https://www.youtube.com/watch?v=qwKStMc-068)
to learn more! Visit [our
webpage](https://archmetaldbm.github.io/Globalid/) to learn more about
the GlobaLID project and to get the latest news.

The current version of the GlobaLID database includes data from these
locations: <img src="man/figures/README-map-1.png" width="100%" />

# How to cite

If you use the GlobaLID app, please cite it as:

- GlobaLID Core Team. (2021). GlobaLID web application V. 1.0, database
  status: 2025-07-28. <https://globalid.dmt-lb.de/>
- Klein, S., Rose, T., Westner, K. J., & Hsu, Y.-K. (2022). From OXALID
  to GlobaLID: Introducing a modern and FAIR lead isotope database with
  an interactive application. Archaeometry 64(4), 935–950.
  <https://doi.org/10.1111/arcm.12762>

<!-- -->

    @misc{GlobaLIDCoreTeam.2022,
     author = {{GlobaLID Core Team}},
     year = {2022},
     title = {{GlobaLID web application V. 1.0, database status: 2025-07-28}},
     url = {https://globalid.dmt-lb.de/}
    }

    @article{Klein.2022,
    author = {Klein, Sabine and Rose, Thomas and Westner, Katrin J. and Hsu, Yiu-Kang},
    title = {From OXALID to GlobaLID: Introducing a modern and FAIR lead isotope database with an interactive application},
    journal = {Archaeometry},
    volume = {64},
    number = {4},
    pages = {935-950},
    doi = {https://doi.org/10.1111/arcm.12762},
    }

# Join the team!

GlobaLID needs your help to grow and to provide high quality datasets!
The core team is permanently reviewing and adding new and old data from
the literature to keep GlobaLID growing. However, we are neither
proficient enough with the geology and geography of all parts of the
world nor do we know all publications with lead isotope data from ores
and minerals. Hence we are happy about any support from our community.
Interested? Write us!

# Team

Please find the up-to-date list of team members on the [TerraLID
webpage](https://terralid.org/team.html), where development of GlobaLID
continues.

# Funding

<table width="100%" cellspacing="0" cellpadding="0" border="0">

<tbody>

<tr>

<td>

<img src="www/dfg_logo.gif">
</td>

<td halign="left">

This work has received funding from the German Research Foundation (DFG)
through the grants KL 1259/17-1 and WI 5923/2-1 (project number:
524790825).
</td>

</tr>

</tbody>

</table>

# Acknowledgements

The initial GlobaLID database was compiled during years of own research
and profited from the generous sharing of published lead isotope
datasets by many colleagues. The creative and collective work of
compiling the database and application was initiated when all members of
the Core Team and E. Salzmann were members of the Archaeometallurgy
group at the Deutsches Bergbau-Museum Bochum (DBM). H. Zietsch (DBM)
compiled the initial literature references.

The Core Team feels deeply grateful for the support of the contributors.
Without their efforts, GlobaLID would grow much slower and less
accurate.

We are indebted to the R Core Team for providing and maintaining
[R](https://cran.r-project.org/), the authors of the fantastic packages
we use, and the R community on
[stackoverflow](https://stackoverflow.com/) and many other webpages. The
app uses the following packages:

- [bs4Dash](https://rinterface.github.io/bs4Dash/)
- [dplyr](https://dplyr.tidyverse.org/)
- [DT](https://rstudio.github.io/DT/)
- [ggplot2](https://ggplot2.tidyverse.org/)
- [kableExtra](https://haozhu233.github.io/kableExtra/)
- [knitr](https://yihui.org/knitr/)
- [ks](https://cran.r-project.org/web/packages/ks/)
- [leaflet](https://rstudio.github.io/leaflet/)
- [leaflet.providers](https://github.com/rstudio/leaflet.providers)
- [lemon](https://github.com/stefanedwards/lemon)
- [plotly](https://plotly-r.com/)
- [RColorBrewer](https://cran.r-project.org/web/packages/RColorBrewer/)
- [rmarkdown](https://rmarkdown.rstudio.com/)
- [rootSolve](https://cran.r-project.org/web/packages/rootSolve)
- [sendmailR](https://cran.r-project.org/web/packages/sendmailR/)
- [shiny](https://shiny.rstudio.com/)
- [shinyvalidate](https://rstudio.github.io/shinyvalidate/)
- [stringr](https://stringr.tidyverse.org/)
- [tidyr](https://tidyr.tidyverse.org/)
- [viridisLite](https://sjmgarnier.github.io/viridisLite/)
- [waiter](https://shiny.john-coene.com/waiter/)
- [zip](https://cran.r-project.org/web/packages/zip)

The implementation of the hCaptcha is a modified version of
[shinyCAPTCHA](https://github.com/carlganz/shinyCAPTCHA).
