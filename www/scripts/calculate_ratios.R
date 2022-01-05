#' Convert lead isotope ratios
#'
#' @author Thomas Rose, \email{thomas.rose@daad-alumni.de}
#'
#' The function takes any of the lead isotope ratios listed in \emph{Details}
#' and calculates the other listed isotope ratios, if possible.
#'
#' The function recognises the columns with the respective supported lead
#' isotope ratios based on the order of the atomic masses per ratio and
#' renames them in the pattern "20xPb/20yPb" with x and y being the last
#' digits of the respective isotopes. The function only checks whether columns
#' are empty and not if values within a column are missing. Consequently, the
#' input columns must be uniform in the presence/absence of ratios.
#'
#' Supported lead isotope ratios: \itemize{\item 206Pb/204Pb \item 207Pb/204Pb
#' \item 208Pb/204Pb \item 206Pb/206Pb \item 207Pb/206Pb \item 208Pb/206Pb
#' \item 208Pb/207Pb}
#'
#' @param data A tibble.
#'
#' @return A tibble.
#' @export

LI_ratios_all <- function (data)
{
  #if (!"dplyr" %in% utils::installed.packages()) {install.packages("dplyr")}
  
  colnames(data) <- sub(".*6.+4.*", "206Pb/204Pb", colnames(data)) 
  colnames(data) <- sub(".*7.+4.*", "207Pb/204Pb", colnames(data)) 
  colnames(data) <- sub(".*8.+4.*", "208Pb/204Pb", colnames(data)) 
  colnames(data) <- sub(".*4.+6.*", "204Pb/206Pb", colnames(data))
  colnames(data) <- sub(".*7.+6.*", "207Pb/206Pb", colnames(data)) 
  colnames(data) <- sub(".*8.+6.*", "208Pb/206Pb", colnames(data))
  colnames(data) <- sub(".*6.+7.*", "206Pb/207Pb", colnames(data))
  colnames(data) <- sub(".*8.+7.*", "208Pb/207Pb", colnames(data))
  
  ratios_data <- grep(".*20.*20.*", names(data), value = TRUE)
  
  ratios_ref <-  c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb", "206Pb/207Pb", "208Pb/207Pb", "204Pb/206Pb", "207Pb/206Pb", "208Pb/206Pb")
  ratios_missing <- setdiff(ratios_ref, ratios_data)
  
  data[,ratios_missing] <- NA_real_
  
  for (i in 1:3) {
    
    data <- data %>%
      dplyr::mutate(`206Pb/204Pb` = dplyr::case_when(
        is.na(.data$`206Pb/204Pb`) & !is.na(.data$`204Pb/206Pb`) ~ 1 / .data$`204Pb/206Pb`,
        is.na(.data$`206Pb/204Pb`) & !is.na(.data$`207Pb/204Pb`) & !is.na(.data$`207Pb/206Pb`) ~ .data$`207Pb/204Pb` / .data$`207Pb/206Pb`,
        is.na(.data$`206Pb/204Pb`) & !is.na(.data$`208Pb/204Pb`) & !is.na(.data$`208Pb/206Pb`) ~ .data$`208Pb/204Pb` / .data$`208Pb/206Pb`,
        !is.na(.data$`206Pb/204Pb`) ~ .data$`206Pb/204Pb`)) %>%
      dplyr::mutate(`207Pb/204Pb` = dplyr::case_when(
        is.na(.data$`207Pb/204Pb`) & !is.na(.data$`208Pb/204Pb`) & !is.na(.data$`208Pb/207Pb`) ~ .data$`208Pb/204Pb` / .data$`208Pb/207Pb`,
        is.na(.data$`207Pb/204Pb`) & !is.na(.data$`206Pb/204Pb`) & !is.na(.data$`207Pb/206Pb`) ~ .data$`206Pb/204Pb` * .data$`207Pb/206Pb`,
        !is.na(.data$`207Pb/204Pb`) ~ .data$`207Pb/204Pb`)) %>%
      dplyr::mutate(`208Pb/204Pb` = dplyr::case_when(
        is.na(.data$`208Pb/204Pb`) & !is.na(.data$`208Pb/207Pb`) & !is.na(.data$`207Pb/204Pb`) ~ .data$`208Pb/207Pb` * .data$`207Pb/204Pb`,
        is.na(.data$`208Pb/204Pb`) & !is.na(.data$`206Pb/204Pb`) & !is.na(.data$`208Pb/206Pb`) ~ .data$`206Pb/204Pb` * .data$`208Pb/206Pb`,
        !is.na(.data$`208Pb/204Pb`) ~ .data$`208Pb/204Pb`)) %>%
      dplyr::mutate(`208Pb/207Pb` = dplyr::case_when(
        is.na(.data$`208Pb/207Pb`) & !is.na(.data$`208Pb/204Pb`) & !is.na(.data$`207Pb/204Pb`) ~ .data$`208Pb/204Pb` / .data$`207Pb/204Pb`,
        is.na(.data$`208Pb/207Pb`) & !is.na(.data$`208Pb/206Pb`) & !is.na(.data$`207Pb/206Pb`) ~ .data$`208Pb/206Pb` / .data$`207Pb/206Pb`,
        !is.na(.data$`208Pb/207Pb`) ~ .data$`208Pb/207Pb`)) %>%
      dplyr::mutate(`207Pb/206Pb` = dplyr::case_when(
        is.na(.data$`207Pb/206Pb`) & !is.na(.data$`207Pb/204Pb`) & !is.na(.data$`206Pb/204Pb`) ~ .data$`207Pb/204Pb` / .data$`206Pb/204Pb`,
        is.na(.data$`207Pb/206Pb`) & !is.na(.data$`208Pb/206Pb`) & !is.na(.data$`208Pb/207Pb`) ~ .data$`208Pb/206Pb` / .data$`208Pb/207Pb`,
        !is.na(.data$`207Pb/206Pb`) ~ .data$`207Pb/206Pb`)) %>%
      dplyr::mutate(`208Pb/206Pb` = dplyr::case_when(
        is.na(.data$`208Pb/206Pb`) & !is.na(.data$`208Pb/204Pb`) & !is.na(.data$`206Pb/204Pb`) ~ .data$`208Pb/204Pb` / .data$`206Pb/204Pb`,
        is.na(.data$`208Pb/206Pb`) & !is.na(.data$`208Pb/207Pb`) & !is.na(.data$`207Pb/206Pb`) ~ .data$`208Pb/207Pb` / .data$`207Pb/206Pb`,
        !is.na(.data$`208Pb/206Pb`) ~ .data$`208Pb/206Pb`)) %>%
      dplyr::mutate(`204Pb/206Pb` = dplyr::if_else(is.na(.data$`204Pb/206Pb`) & !is.na(.data$`206Pb/204Pb`), 1 / .data$`206Pb/204Pb`, .data$`204Pb/206Pb`)) %>%
      dplyr::mutate(`206Pb/207Pb` = dplyr::if_else(is.na(.data$`206Pb/207Pb`) & !is.na(.data$`207Pb/206Pb`), 1 / .data$`207Pb/206Pb`, .data$`206Pb/207Pb`))
    
  }
  
  data[ratios_ref] <- round(data[ratios_ref], 6)
  
  data
}