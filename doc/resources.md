## Resources

The web application is written in [R](https://cran.r-project.org/). The
following functions were specifically developed for GlobaLID. To use
them in your own work, download them by clicking on the function name
and load them into R with `source()`.

<table cellpadding="5">
<thead>
<tr>
<th style="text-align:left;vertical-align: bottom !important;">
Function
</th>
<th style="text-align:left;vertical-align: bottom !important;">
Description
</th>
<th style="text-align:left;vertical-align: bottom !important;">
Required packages
</th>
<th style="text-align:left;vertical-align: bottom !important;">
Date
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;vertical-align: top !important;">
<a href="../scripts/calculate_ratios.R">`LI_ratios_all()`</a>
</td>
<td style="text-align:left;vertical-align: top !important;">
Calculates missing lead isotope ratios from existing ones.
</td>
<td style="text-align:left;vertical-align: top !important;">
dplyr
</td>
<td style="text-align:left;vertical-align: top !important;width: 15%; ">
2021-06-20
</td>
</tr>
<tr>
<td style="text-align:left;vertical-align: top !important;">
<a href="../scripts/calculate_model_ages.R">`LI_model_age()`</a>
</td>
<td style="text-align:left;vertical-align: top !important;">
Calculates parameters for different lead isotope age models. The
function provides convenient access to the different age model function,
that are also part of this script. Currently supported age models:
Stacey & Kramers (1975), Cumming & Richards (1975), Albarède & Juteau
(1984), and Albarède et al. (2012).
</td>
<td style="text-align:left;vertical-align: top !important;">
rootSolve
</td>
<td style="text-align:left;vertical-align: top !important;width: 15%; ">
2021-10-03
</td>
</tr>
<tr>
<td style="text-align:left;vertical-align: top !important;">
<a href="../scripts/geom_kde2d.R">`geom_kde2d()`</a>
</td>
<td style="text-align:left;vertical-align: top !important;">
This geom provides an alternative to the `geom_density_2d()` of the
package ggplot2 for plotting 2D kernel density estimates based on
quantiles.
</td>
<td style="text-align:left;vertical-align: top !important;">
ggplot2, ks
</td>
<td style="text-align:left;vertical-align: top !important;width: 15%; ">
2021-06-04
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="../scripts/hCaptcha_module.R">`hCaptcha module for Shiny`</a>
</td>
<td style="text-align:left;">
A module to include hCaptcha in Shiny apps.
</td>
<td style="text-align:left;">
httr, jsonlite, shiny
</td>
<td style="text-align:left;width: 15%; ">
2021-09-23
</td>
</tr>
</tbody>
</table>

The source code of the GlobaLID web application is available on
<a href="https://github.com/archmetalDBM/GlobaLID-App" target="_blank">GitHub</a>.
