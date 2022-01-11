
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![Release](https://img.shields.io/github/v/release/archmetalDBM/GlobaLID-database.svg)](https://github.com/archmetalDBM/GlobaLID-App)
<!-- badges: end -->

# GlobaLID App <img src="www/logo.svg" align="right" width="120" />

Here you can find the source code of the GlobaLID web app.

# What is GlobaLID?

GlobaLID is a Global Lead Isotope Database and aims to facilitate the
reconstruction of raw material provenances with lead isotopes,
especially in archaeology. The app provides direct access to and
convenient interaction with the [GlobaLID
database](https://doi.org/10.5880/fidgeo.2021.031). You can filter the
database according to your research question, upload own data to compare
it with GlobaLID, and produce and download publication ready plots.

The current version of the GlobaLID database includes data from these
locations: <img src="man/figures/README-map-1.png" width="100%" />

# How to cite

If you use the GlobaLID app, please cite it as:  
GlobaLID Core Team. (2021). GlobaLID web application V. 1.0, database
status: 2021-11-15. <https://globalid.dmt-lb.de/>

    @misc{GlobaLIDCoreTeam.2021,
     author = {{GlobaLID Core Team}},
     year = {2021},
     title = {{GlobaLID web application V. 1.0, database status: 2021-11-15}},
     url = {https://globalid.dmt-lb.de/}
    }

# Become a contributor!

GlobaLID needs your help to grow and to provide high quality datasets!
The core team is permanently reviewing and adding new and old data from
the literature to keep GlobaLID growing. However, we are neither
proficient enough with the geology and geography of all parts of the
world nor do we know all publications with lead isotope data from ores
and minerals. Hence we are happy about any support from our community.
Interested? Write us!

# GlobaLID core team

-   Coordinator: [Sabine
    Klein](https://www.bergbaumuseum.de/en/museum/mitarbeitende/kontakt-detailseite/prof-dr-sabine-klein)
    [![](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png)](https://orcid.org/0000-0002-3939-4428)
    (Forschungsbereich Archäometallurgie, Leibniz-Forschungsmuseum für
    Georessourcen/Deutsches Bergbau-Museum Bochum, Bochum, Germany;
    Institut für Archäologische Wissenschaften, Ruhr-Universität Bochum,
    Bochum, Germany; FIERCE, Frankfurt Isotope & Element Research
    Centre, Goethe Universität, Frankfurt am Main, Germany)
-   Programming: [Thomas Rose](https://copper-smelting.com/)
    [![](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png)](https://orcid.org/0000-0002-8186-3566)
    (Department of Archaeology, Ben-Gurion University of the Negev,
    Be’er Sheva, Israel; Department of Antiquity, Sapienza University of
    Rome, Rome, Italy; Forschungsbereich Archäometallurgie,
    Leibniz-Forschungsmuseum für Georessourcen/Deutsches Bergbau-Museum
    Bochum, Bochum, Germany)
-   Database: [Katrin J.
    Westner](http://lgltpe.ens-lyon.fr/annuaire/westner-katrin)
    [![](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png)](https://orcid.org/0000-0001-5529-1165)
    (Ecole Normale Supérieure de Lyon, CNRS, Université de Lyon, Lyon,
    France)
-   East Asia: [Yiu-Kang
    Hsu](https://www.bergbaumuseum.de/en/museum/mitarbeitende/kontakt-detailseite/yiu-kang-hsu)
    [![](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png)](https://orcid.org/0000-0002-2439-4863)
    (Forschungsbereich Archäometallurgie, Leibniz-Forschungsmuseum für
    Georessourcen/Deutsches Bergbau-Museum Bochum, Bochum, Germany)

# Contributors

-   [Nima
    Nezafati](https://www.bergbaumuseum.de/en/museum/mitarbeitende/kontakt-detailseite/dr-nima-nezafati)
    [![](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png)](https://orcid.org/0000-0002-5806-343X)
    (Forschungsbereich Archäometallurgie, Leibniz-Forschungsmuseum für
    Georessourcen/Deutsches Bergbau-Museum Bochum, Bochum, Germany)
-   Markos Vaxevanopoulos
    [![](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png)](https://orcid.org/0000-0003-3027-5622)
    (École Normale Supérieure de Lyon, Laboratoire de Géologie de Lyon:
    Terre, Planète, Environnement, Lyon, France)

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

-   [bs4Dash](https://rinterface.github.io/bs4Dash/)
-   [dplyr](https://dplyr.tidyverse.org/)
-   [DT](https://rstudio.github.io/DT/)
-   [ggplot2](https://ggplot2.tidyverse.org/)
-   [kableExtra](https://haozhu233.github.io/kableExtra/)
-   [knitr](https://yihui.org/knitr/)
-   [ks](https://cran.r-project.org/web/packages/ks/)
-   [leaflet](https://rstudio.github.io/leaflet/)
-   [leaflet.providers](https://github.com/rstudio/leaflet.providers)
-   [lemon](https://github.com/stefanedwards/lemon)
-   [plotly](https://plotly-r.com/)
-   [RColorBrewer](https://cran.r-project.org/web/packages/RColorBrewer/)
-   [rmarkdown](https://rmarkdown.rstudio.com/)
-   [rootSolve](https://cran.r-project.org/web/packages/rootSolve)
-   [sendmailR](https://cran.r-project.org/web/packages/sendmailR/)
-   [shiny](https://shiny.rstudio.com/)
-   [shinyvalidate](https://rstudio.github.io/shinyvalidate/)
-   [stringr](https://stringr.tidyverse.org/)
-   [tidyr](https://tidyr.tidyverse.org/)
-   [viridisLite](https://sjmgarnier.github.io/viridisLite/)
-   [waiter](https://shiny.john-coene.com/waiter/)
-   [zip](https://cran.r-project.org/web/packages/zip)

The implementation of the hCaptcha is a modified version of
[shinyCAPTCHA](https://github.com/carlganz/shinyCAPTCHA).
