# Shiny module for hCaptcha
# modified from the package shinyCAPTCHA by Carl Ganz (https://github.com/carlganz/shinyCAPTCHA)

#' Client-side module component
#' @export
#' @param id unique id for module
#' @param sitekey sitekey code for hCAPTCHA
#' @param ... values passed onto input
#' @import htmltools
#' @importFrom shiny NS
hcaptchaUI <- function(id, sitekey = Sys.getenv("hcaptcha_sitekey"), ...) {
  ns <- NS(id)
  
  tagList(tags$div(
    shiny::tags$script(
      src = "https://js.hcaptcha.com/1/api.js",
      async = NA,
      defer = NA
    ),
    tags$script(
      paste0("shinyCaptcha = function(response) {
          Shiny.onInputChange('", ns("hcaptcha_response"),"', response);
      }"
      )),
    tags$form(
      class = "shinyCAPTCHA-form",
      action = "?",
      method = "POST",
      tags$div(class = "h-captcha", `data-sitekey` = sitekey, `data-callback` = I("shinyCaptcha"))
    )
  ))
}

#' Server-side module component
#' @export
#' @param input input
#' @param output output
#' @param session session
#' @param secret secret for hCAPTCHA
#' @import httr 
#' @importFrom jsonlite fromJSON
#' @importFrom shiny reactive
hcaptcha <- function(id, secret = Sys.getenv("recaptcha_secret")) {
  
  moduleServer(
    id,
    function(input, output, session) {
      
      ns <- session$ns
      
      status <- reactive({
        
        if (isTruthy(input$hcaptcha_response)) {
          url <- "https://hcaptcha.com/siteverify"
          
          resp <- httr::POST(url, body = list(
            secret = secret,
            response = input$hcaptcha_response
          ))
          
          jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
        } else {
          list(success = FALSE)
        }
      })
      
      return(status)
      
    }
  )
}