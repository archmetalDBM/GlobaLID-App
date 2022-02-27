# Pick plot axes ----------------------------------------------------------

axis_picker <- function(input_axis, input_model) {
  
  switch(input_axis,
         "206Pb/204Pb" = list(input_axis, "<sup>206</sup>Pb/<sup>204</sup>Pb", expression(""^"206"*"Pb/"^"204"*"Pb")), 
         "207Pb/204Pb" = list(input_axis, "<sup>207</sup>Pb/<sup>204</sup>Pb", expression(""^"207"*"Pb/"^"204"*"Pb")),
         "208Pb/204Pb" = list(input_axis, "<sup>208</sup>Pb/<sup>204</sup>Pb", expression(""^"208"*"Pb/"^"204"*"Pb")), 
         "206Pb/207Pb" = list(input_axis, "<sup>206</sup>Pb/<sup>207</sup>Pb", expression(""^"206"*"Pb/"^"207"*"Pb")),
         "208Pb/207Pb" = list(input_axis, "<sup>208</sup>Pb/<sup>207</sup>Pb", expression(""^"208"*"Pb/"^"207"*"Pb")),
         "204Pb/206Pb" = list(input_axis, "<sup>204</sup>Pb/<sup>206</sup>Pb", expression(""^"204"*"Pb/"^"206"*"Pb")), 
         "207Pb/206Pb" = list(input_axis, "<sup>207</sup>Pb/<sup>206</sup>Pb", expression(""^"207"*"Pb/"^"206"*"Pb")), 
         "208Pb/206Pb" = list(input_axis, "<sup>208</sup>Pb/<sup>206</sup>Pb", expression(""^"208"*"Pb/"^"206"*"Pb")), 
         "Model Age" = switch(input_model, 
                              "Stacey & Kramers 1975" = list("Model_Age_SK75", "Model Age<sub>Stacey & Kramers 1975</sub> [Ma]", expression("Model Age"["Stacey & Kramers 1975"]*" [Ma]")), 
                              "Cumming & Richards 1975" = list("Model_Age_CR75", "Model Age<sub>Cumming & Richards 1975</sub> [Ma]", expression("Model Age"["Cumming & Richards 1975"]*" [Ma]")),
                              "Albarede & Juteau 1984" = list("Model_Age_AJ84", "Model Age<sub>Albarède & Juteau 1984</sub> [Ma]", expression("Model Age"["Albarede & Juteau 1984"]*" [Ma]")),
                              "Albarede et al. 2012" = list("Model_Age_ADB12", "Model Age<sub>Albarède et al. 2012</sub> [Ma]", expression("Model Age"["Albarède et al. 2012"]*" [Ma]"))
         ),
         "mu" = switch(input_model, 
                       "Stacey & Kramers 1975" = list("mu_SK75", "\u03BC<sub>Stacey & Kramers 1975</sub>", expression(mu["Stacey & Kramers 1975"])), 
                       "Cumming & Richards 1975" = list("mu_CR75", "\u03BC<sub>Cumming & Richards 1975</sub>", expression(mu["Cumming & Richards 1975"])),
                       "Albarede & Juteau 1984" = list("mu_AJ84", "\u03BC<sub>Albarede & Juteau 1984</sub>", expression(mu["Albarede & Juteau 1984"])),
                       "Albarede et al. 2012" = list("mu_ADB12", "\u03BC<sub>Albarède et al. 2012</sub>", expression(mu["Albarède et al. 2012"]))
         ), 
         "kappa" = switch(input_model, 
                          "Stacey & Kramers 1975" = list("kappa_SK75", "\u03BA<sub>Stacey & Kramers 1975</sub>", expression(kappa["Stacey & Kramers 1975"])), 
                          "Cumming & Richards 1975" = list("kappa_CR75", "\u03BA<sub>Cumming & Richards 1975</sub>", expression(kappa["Cumming & Richards 1975"])),
                          "Albarede & Juteau 1984" = list("kappa_AJ84", "\u03BA<sub>Albarede & Juteau 1984</sub>", expression(kappa["Albarede & Juteau 1984"])),
                          "Albarede et al. 2012" = list("kappa_ADB12", "\u03BA<sub>Albarède et al. 2012</sub>", expression(kappa["Albarède et al. 2012"]))
         )
  )
}

# Pick palette ------------------------------------------------------------

palette_picker <- function(input_palette, input_style) {
  
  if (!input_style %in% c("2D Scatter")) { # discrete scales
    
    if (input_palette %in% c("viridis", "magma", "inferno", "plasma", "cividis")) {
      palette <- list(scale_color_viridis_d(option = input_palette), scale_fill_viridis_d(option = input_palette))
    }
    
    if (input_palette %in% c("Blues", "BuGn", "BuPu", "GnBu", "Greens", "Greys", "Oranges", "OrRd", "PuBu", "PuBuGn", "PuRd", "Purples", "RdPu", "Reds", "YlGn", "YlGnBu", "YlOrBr", "YlOrRd")) {
      palette <- list(scale_color_brewer(palette = input_palette, type = "seq"), scale_fill_brewer(palette = input_palette, type = "seq"))
    }
    
    if (input_palette %in% c("BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn", "Spectral")) {
      palette <- list(scale_color_brewer(palette = input_palette, type = "div"), scale_fill_brewer(palette = input_palette, type = "div"))
    }
    
    if (input_palette %in% c("Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2", "Set3")) {
      palette <- list(scale_color_brewer(palette = input_palette, type = "qual"), scale_fill_brewer(palette = input_palette, type = "qual"))
    }
    
  } else { # continuous scales
    
    if (input_palette %in% c("viridis", "magma", "inferno", "plasma", "cividis")) {
      palette <- list(scale_color_viridis_c(option = input_palette), scale_fill_viridis_c(option = input_palette))
    }
    
    if (input_palette %in% c("Blues", "BuGn", "BuPu", "GnBu", "Greens", "Greys", "Oranges", "OrRd", "PuBu", "PuBuGn", "PuRd", "Purples", "RdPu", "Reds", "YlGn", "YlGnBu", "YlOrBr", "YlOrRd")) {
      palette <- list(scale_color_distiller(palette = input_palette, type = "seq"), scale_color_distiller(palette = input_palette, type = "seq"))
    }
    
    if (input_palette %in% c("BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn", "Spectral")) {
      palette <- list(scale_color_distiller(palette = input_palette, type = "div"), scale_color_distiller(palette = input_palette, type = "div"))
    }
    
    if (input_palette %in% c("Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2", "Set3")) {
      palette <- list(scale_color_distiller(palette = input_palette, type = "qual"), scale_color_distiller(palette = input_palette, type = "qual"))
    }
  }
  
  palette
}

# Plot ShinyModule --------------------------------------------------------------

plotExploreUI <- function(id, title_plot, start_y) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      tabBox(
        id = "setting",
        title = title_plot,
        width = 6,
        side = "right",
        maximizable = TRUE, 
        tabPanel(
          title = "Settings", 
          fluidRow(
            column(
              width = 4, 
              h5("Variables"),
              selectizeInput(ns("x"), "X-axis", choices = c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb", "206Pb/207Pb", "208Pb/207Pb", "204Pb/206Pb", "207Pb/206Pb", "208Pb/206Pb", "Model Age", "mu", "kappa"), 
                             selected = "206Pb/204Pb"), 
              selectizeInput(ns("y"), "Y-axis", choices = c("none", "206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb", "206Pb/207Pb", "208Pb/207Pb", "204Pb/206Pb", "207Pb/206Pb", "208Pb/206Pb", "Model Age", "mu", "kappa"),
                             selected = start_y),
              selectizeInput(ns("z"), "Z-axis or fill", choices = c("none", "206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb", "206Pb/207Pb", "208Pb/207Pb", "204Pb/206Pb", "207Pb/206Pb", "208Pb/206Pb", "Model Age", "mu", "kappa"),
                             selected = "none"),
              selectizeInput(ns("model"), "Age model", choices = c("Stacey & Kramers 1975", "Cumming & Richards 1975", "Albarede & Juteau 1984", "Albarede et al. 2012"),
                             options = list(placeholder = 'Please select the age model.'), selected = "Stacey & Kramers 1975"),
            ), 
            column(
              width = 4, 
              h5("Style"), 
              selectInput(ns("style"), "Plot style", choices = c("Point", "Density 2D", "Point + Density 2D"), selected = "Point"),
              uiOutput(ns("add1")), 
              uiOutput(ns("add2")), 
              uiOutput(ns("add3"))
            ),
            column(
              width = 4, 
              h5("Design"),
              sliderInput(ns("alpha"), label = "Transparency", value = 0.5, min = 0, max = 1),
              sliderInput(ns("size_reference"), label = "Point size or linewidth", value = 1, min = 0, max = 10, step = .1), 
              sliderInput(ns("size_upload"), label = "Size of uploaded data", value = 2, min = 0, max = 10, step = .1)
            )
          )
        ), 
        tabPanel(
          title = "Data Viewer", 
          DT::dataTableOutput(ns("plot_data"))
        )
      ), 
      tabBox(
        id = "Plots",
        title = paste0("View ", tolower(title_plot)),
        width = 6,
        side = "right",
        maximizable = TRUE, 
        tabPanel(
          title = "Interactive",
          plotlyOutput(ns("plot_interactive"))
        ), 
        tabPanel(
          title = "Print preview",
          plotOutput(ns("plot_print"))
        )
      )
    )
  )
}

plotExploreServer <- function(id, data_reference, data_custom, group_ref, input_palette) {
  
  moduleServer(
    id,
    function(input, output, session) {
      
      ns <- session$ns
      
      w <- Waiter$new(id = c(ns("plot_print"), ns("plot_interactive")))
      
      plotModule_iv <- InputValidator$new()
      plotModule_iv$add_rule("x", sv_in_set(c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb", "206Pb/207Pb", "208Pb/207Pb", "204Pb/206Pb", "207Pb/206Pb", "208Pb/206Pb", "Model Age", "mu", "kappa"))) 
      plotModule_iv$add_rule("y", sv_in_set(c("none", "206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb", "206Pb/207Pb", "208Pb/207Pb", "204Pb/206Pb", "207Pb/206Pb", "208Pb/206Pb", "Model Age", "mu", "kappa")))
      plotModule_iv$add_rule("z", sv_in_set(c("none", "206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb", "206Pb/207Pb", "208Pb/207Pb", "204Pb/206Pb", "207Pb/206Pb", "208Pb/206Pb", "Model Age", "mu", "kappa")))
      plotModule_iv$add_rule("model", sv_in_set(c("Stacey & Kramers 1975", "Cumming & Richards 1975", "Albarede & Juteau 1984", "Albarede et al. 2012")))
      plotModule_iv$add_rule("style", sv_in_set(c("2D Scatter", "3D Scatter", "Point", "Density 2D", "Point + Density 2D", "Density", "Density filled", "Histogram", "Frequency polygon", "Frequency polygon filled", "Boxplot")))
      plotModule_iv$add_rule("alpha", sv_numeric())
      plotModule_iv$add_rule("alpha", sv_between(0, 1))
      plotModule_iv$add_rule("size_reference", sv_numeric())
      plotModule_iv$add_rule("size_reference", sv_between(0, 10))
      plotModule_iv$add_rule("size_upload", sv_numeric())
      plotModule_iv$add_rule("size_upload", sv_between(0, 10))
      plotModule_iv$add_rule("add_position", sv_optional())
      plotModule_iv$add_rule("add_quantiles", sv_optional())
      plotModule_iv$add_rule("add_minprob", sv_optional())
      plotModule_iv$add_rule("add_bins", sv_optional())
      plotModule_iv$add_rule("add_fill",  sv_optional())
      plotModule_iv$add_rule("add_quantiles", sv_optional())
      plotModule_iv$add_rule("add_minprob", sv_optional())
      plotModule_iv$add_rule("add_bins", sv_optional())
      plotModule_iv$add_rule("add_position", sv_in_set(c("identity" , "stack", "fill")))
      plotModule_iv$add_rule("add_quantiles", sv_integer()) 
      plotModule_iv$add_rule("add_minprob", sv_numeric())
      plotModule_iv$add_rule("add_bins", sv_integer())
      plotModule_iv$add_rule("add_fill",  ~ if(!is.logical(.)) "Do not hack the app.")
      plotModule_iv$add_rule("add_quantiles", sv_between(1, 10)) 
      plotModule_iv$add_rule("add_minprob", sv_between(0, 1))
      plotModule_iv$add_rule("add_bins", sv_between(1, 100))
      
      plotModule_iv$enable()
      
      x <- reactive({ axis_picker(input$x, input$model) })
      y <- reactive({ if (input$y == "none") {NULL} else {axis_picker(input$y, input$model)} })
      z <- reactive({ if (input$z == "none" | input$y == "none") {NULL} else {axis_picker(input$z, input$model)} })  
      
      palette <- reactive({ palette_picker(input_palette(), input$style) })
      
      observe({
        
        plot_styles <- c("Density", "Density filled", "Histogram", "Frequency polygon", "Frequency polygon filled", "Boxplot") # , "Violin" - Bug with plotly
        if (!is.null(y()) && is.null(z())) {plot_styles <- c("Point", "Density 2D", "Point + Density 2D")} 
        if (!is.null(y()) && !is.null(z())) {plot_styles <- c("2D Scatter", "3D Scatter")}
        
        updateSelectInput(session, "style", choices = plot_styles, selected = plot_styles[1])
       
        output$add1 <- renderUI({
          req(input$style)
          
          switch(input$style, 
                 "Density" = selectInput(ns("add_position"), "Arrangement of groups", choices = c("Separate" = "identity" , "Stacked" = "stack", "Stacked & normalised" = "fill")), 
                 "Density filled" = selectInput(ns("add_position"), "Arrangement of groups", choices = c("Separate" = "identity" , "Stacked" = "stack", "Stacked & normalised" = "fill")), 
                 "Histogram" = selectInput(ns("add_position"), "Arrangement of groups", choices = c("Separate" = "identity" , "Stacked" = "stack", "Stacked & normalised" = "fill")), 
                 "Frequency polygon" = selectInput(ns("add_position"), "Arrangement of groups", choices = c("Separate" = "identity" , "Stacked" = "stack", "Stacked & normalised" = "fill")), 
                 "Frequency polygon filled" = selectInput(ns("add_position"), "Arrangement of groups", choices = c("Separate" = "identity" , "Stacked" = "stack", "Stacked & normalised" = "fill")), 
                 #"Violin" = selectInput(ns("add_scale"), "Display method", choices = c("Uniform area" = "area", "Area scaled to counts" =	"count", "Uniform maximum width" =	"width")), 
                 "Density 2D" = sliderInput(ns("add_quantiles"), label = "Number of quantiles", min = 1, max = 10, step = 1, value = 4), 
                 "Point + Density 2D" = sliderInput(ns("add_quantiles"), label = "Number of quantiles", min = 1, max = 10, step = 1, value = 4),
                 NULL
          )
        })
        
        output$add2 <- renderUI({
          req(input$style)
          
          switch(input$style, 
                 #"Density" = selectInput(ns("add_afterstat"), "Method", choices = c("Density" = "density", "Density * count" = "count",	"Normalised density" = "scaled")), 
                 #"Density filled" = selectInput(ns("add_afterstat"), "Method", choices = c("Density" = "density", "Density * count" = "count",	"Normalised density" = "scaled")), 
                 #"Histogram" = selectInput(ns("add_afterstat"), "Method", choices = c("Count" = "count", "Density" = "density ", "Normalised count" = "ncount", "Normalised density" = "ndensity")), 
                 #"Frequency polygon" = selectInput(ns("add_afterstat"), "Method", choices = c("Count" = "count", "Density" = "density ", "Normalised count" = "ncount", "Normalised density" = "ndensity")), 
                 #"Frequency polygon filled" = selectInput(ns("add_afterstat"), "Method", choices = c("Count" = "count", "Density" = "density ", "Normalised count" = "ncount", "Normalised density" = "ndensity")), 
                 "Density 2D" = sliderInput(ns("add_minprob"), label = "Smallest displayed quantile", min = 0, max = 1, step = 0.01, value = 0.02), 
                 "Point + Density 2D" = sliderInput(ns("add_minprob"), label = "Smallest displayed quantile", min = 0, max = 1, step = 0.01, value = 0.02),
                 NULL
          )
          
        })
        
        output$add3 <- renderUI({
          req(input$style)
          
          switch(input$style, 
                 "Histogram" = sliderInput(ns("add_bins"), "Number of bins", value = 30, min = 1, max = 100, step = 1), 
                 "Frequency polygon" = sliderInput(ns("add_bins"), "Number of bins", value = 30, min = 1, max = 100, step = 1), 
                 "Frequency polygon filled" = sliderInput(ns("add_bins"), "Number of bins", value = 30, min = 1, max = 100, step = 1), 
                 "Density 2D" = checkboxInput(ns("add_fill"), label = "Filled polygons"), 
                 NULL
          )
          
        })
      })
      
      plot <- reactive({
        w$show()
        
        req(plotModule_iv$is_valid(), data_reference())
        
        plot_build <- ggplot(data_reference()) + 
          palette() + 
          theme_bw() + 
          guides(alpha = "none", size = "none")
        
        if (is.null(y()) && is.null(z())) {
          
          # label_y <- {
          #   req(input$add_afterstat)
          #   switch (input$add_afterstat,
          #                    "density" = "Density", 
          #                    "count" = if (input$style == "Density") {"n * density"} else {"Count"},
          #                    "ndensity"	= "normalised density", 
          #                    "ncount" = "normalised count"
          #   )
          #   }
          
          switch(input$style, 
                 "Density" = {
                   req(input$add_position) #input$add_afterstat, 
                   
                   plot_build <- plot_build +
                     stat_density(geom = "line", aes(x = .data[[x()[[1]]]], colour = .data[[group_ref()]], text = .data[[group_ref()]]),
                                  position = input$add_position, alpha = input$alpha, size = input$size_reference) + # aes(y = after_stat(!!input$add_afterstat)), 
                     labs(x = x()[[2]], y = "Density") #label_y)
                   
                   if (!is.null(data_custom())) {
                     plot_build <- plot_build + 
                       geom_density(data = data_custom(), aes(x = .data[[x()[[1]]]], linetype = group, text = group), size = input$size_upload, colour = "black") + 
                       scale_linetype(name = if ("This study" %in% data_custom()$group) {NULL} else {"This study"})
                   }
                 }, 
                 "Density filled" = {
                   req(input$add_position) #input$add_afterstat, 
                   
                   plot_build <- plot_build +
                     geom_density(aes(x = .data[[x()[[1]]]], colour = .data[[group_ref()]], text = .data[[group_ref()]], fill = .data[[group_ref()]]),
                                  position = input$add_position, alpha = input$alpha, size = input$size_reference) + # aes(y = after_stat(!!input$add_afterstat)), 
                     labs(x = x()[[2]], y = "Density") #label_y)
                   
                   if (!is.null(data_custom())) {
                     plot_build <- plot_build + 
                       geom_density(data = data_custom(), aes(x = .data[[x()[[1]]]], linetype = group, text = group), size = input$size_upload, colour = "black") + 
                       scale_linetype(name = if ("This study" %in% data_custom()$group) {NULL} else {"This study"})
                   }
                 }, 
                 "Histogram" = {
                   req(input$add_bins, input$add_position)# input$add_afterstat, 
                   
                   plot_build <- plot_build +  
                     geom_histogram(aes(x = .data[[x()[[1]]]], colour = .data[[group_ref()]], text = .data[[group_ref()]], fill = .data[[group_ref()]]), 
                                    position = input$add_position, bins = input$add_bins, alpha = input$alpha, size = input$size_reference) +  # aes(y = after_stat(!!input$add_afterstat)), 
                     labs(x = x()[[2]], y = "Count") #label_y)
                   
                   if (!is.null(data_custom())) {
                     plot_build <- plot_build + 
                       geom_histogram(data = data_custom(), aes(x = .data[[x()[[1]]]], linetype = group, text = group), size = input$size_upload, alpha = .25, colour = "black") + 
                       scale_linetype(name = if ("This study" %in% data_custom()$group) {NULL} else {"This study"})
                   }
                 }, 
                 "Frequency polygon" = {
                   req(input$add_bins, input$add_position) # input$add_afterstat, 
                   
                   plot_build <- plot_build + 
                     geom_freqpoly(aes(x = .data[[x()[[1]]]], colour = .data[[group_ref()]], text = .data[[group_ref()]]), 
                                   position = input$add_position, bins = input$add_bins, alpha = input$alpha, size = input$size_reference) + # aes(y = after_stat(!!input$add_afterstat)), 
                     labs(x = x()[[2]], y = "Count") #label_y)
                   
                   if (!is.null(data_custom())) {
                     plot_build <- plot_build + 
                       geom_freqpoly(data = data_custom(), aes(x = .data[[x()[[1]]]], linetype = group, text = group), size = input$size_upload, colour = "black") + 
                       scale_linetype(name = if ("This study" %in% data_custom()$group) {NULL} else {"This study"})
                   }
                 }, 
                 "Frequency polygon filled" = {
                   req(input$add_bins, input$add_position) # input$add_afterstat, 
                   
                   plot_build <- plot_build + 
                     geom_area(stat = "bin", aes(x = .data[[x()[[1]]]], colour = .data[[group_ref()]], text = .data[[group_ref()]], fill = .data[[group_ref()]]), 
                                   position = input$add_position, bins = input$add_bins, alpha = input$alpha, size = input$size_reference) + # aes(y = after_stat(!!input$add_afterstat)), 
                     labs(x = x()[[2]], y = "Count") #label_y)
                   
                   if (!is.null(data_custom())) {
                     plot_build <- plot_build + 
                       geom_freqpoly(data = data_custom(), aes(x = .data[[x()[[1]]]], linetype = group, text = group), size = input$size_upload, colour = "black") + 
                       scale_linetype(name = if ("This study" %in% data_custom()$group) {NULL} else {"This study"})
                   }
                 }, 
                 # "Violin" = {
                 #   req(input$add_scale)
                 #   
                 #   plot_build <- plot_build +
                 #     geom_violin(aes(y = .data[[x()[[1]]]], x = .data[[group_ref()]], text = .data[[group_ref()]]), draw_quantiles = input$add_quantiles, scale = input$add_scale, colour = "black", alpha = input$alpha, size = input$size_reference) + 
                 #     labs(y = x()[[2]], x = group_ref()) + 
                 #     theme(axis.text.x = element_text(angle = 45, hjust = 1))
                 #   
                 #   if (!is.null(data_custom())) {
                 #     plot_build <- plot_build + 
                 #       geom_violin(data = data_custom(), aes(y = .data[[x()[[1]]]], x = group, text = group), fill = "grey50", size = input$size_upload, draw_quantiles = input$add_quantiles, scale = input$add_scale, colour = "black", size = input$size_upload) + 
                 #       scale_linetype(name = if ("This study" %in% data_custom()$group) {NULL} else {"This study"})
                 #   }
                 # }, 
                 "Boxplot" = {
                   plot_build <- plot_build +
                     geom_boxplot(aes(y = .data[[x()[[1]]]], x = .data[[group_ref()]], text = .data[[group_ref()]]), colour = "black", alpha = input$alpha, size = input$size_reference) +
                     labs(y = x()[[2]], x = group_ref()) + 
                     theme(axis.text.x = element_text(angle = 45, hjust = 1))
                   
                   if (!is.null(data_custom())) {
                     plot_build <- plot_build + 
                       geom_boxplot(data = data_custom(), aes(y = .data[[x()[[1]]]], x = group, text = group), 
                                    fill = "grey50", size = input$size_upload, colour = "black") + 
                       scale_linetype(name = if ("This study" %in% data_custom()$group) {NULL} else {"This study"})
                   }
                 }
          )
        }
        
        if (!is.null(y()) && is.null(z())) {
          
          switch(input$style, 
                 "Point" = {
                   plot_build <- plot_build +
                     geom_point(aes(x = .data[[x()[[1]]]], y = .data[[y()[[1]]]], colour = .data[[group_ref()]], fill = .data[[group_ref()]], text = .data$tooltip), 
                                size = input$size_reference, alpha = input$alpha) + 
                     labs(x = x()[[2]], y = y()[[2]])
                 },
                 "Density 2D" = {
                   req(input$add_minprob, input$add_quantiles)
                   
                   plot_build <- plot_build +
                     geom_kde2d(aes(x = .data[[x()[[1]]]], y = .data[[y()[[1]]]], group = .data[[group_ref()]], colour = .data[[group_ref()]], 
                                    fill = if (input$add_fill) {.data[[group_ref()]]} else {NA}, text = .data$tooltip), 
                                size = input$size_reference, alpha = input$alpha, quantiles = input$add_quantiles, min_prob = input$add_minprob, 
                                show.legend = if (input$add_fill) {c(colour = FALSE, fill = TRUE)} else {NA}) + 
                     labs(x = x()[[2]], y = y()[[2]])
                   
                   if (input$add_fill) { plot_build <- plot_build + guides(fill = guide_legend(title = group_ref())) }
                 },
                 "Point + Density 2D" = {
                   req(input$add_minprob, input$add_quantiles)
                   
                   plot_build <- plot_build +
                     geom_point(aes(x = .data[[x()[[1]]]], y = .data[[y()[[1]]]], colour = .data[[group_ref()]], fill = .data[[group_ref()]], text = .data$tooltip), 
                                size = input$size_reference) +
                     geom_kde2d(aes(x = .data[[x()[[1]]]], y = .data[[y()[[1]]]], group = .data[[group_ref()]], colour = .data[[group_ref()]], fill = .data[[group_ref()]], text = .data$tooltip), 
                                size = input$size_reference/2, alpha = input$alpha, quantiles = input$add_quantiles, min_prob = input$add_minprob) +
                     labs(x = x()[[2]], y = y()[[2]])
                 }
          )
          
          if (!is.null(data_custom())) {
            
            plot_build <- plot_build + 
              geom_point(data = data_custom(), aes(x = .data[[x()[[1]]]], y = .data[[y()[[1]]]], colour = .data[[group_ref()]], fill = .data[[group_ref()]], text = .data$tooltip, shape = group), 
                         size = input$size_upload, colour = "black", fill = "black") + 
              scale_shape(name = if ("This study" %in% data_custom()$group) {NULL} else {"This study"})
          }
        }
        
        if (!is.null(y()) && !is.null(z())) {
          
          switch(input$style, 
                 "2D Scatter" = {
                   plot_build <- plot_build + 
                     geom_point(aes(x = .data[[x()[[1]]]], y = .data[[y()[[1]]]], color = .data[[z()[[1]]]], text = .data$tooltip), 
                                size = input$size_reference, alpha = input$alpha) +
                     labs(x = x()[[2]], y = y()[[2]], color = z()[[2]])
                   
                   if (!is.null(data_custom())) {
                     plot_build <- plot_build + 
                       labs(x = x()[[2]], y = y()[[2]]) +
                       geom_point(data = data_custom(), aes(x = .data[[x()[[1]]]], y = .data[[y()[[1]]]], color = .data[[z()[[1]]]], text = .data$tooltip, shape = group), 
                                  size = input$size_upload, colour = "black", fill = "black") + 
                       scale_shape(name = if ("This study" %in% data_custom()$group) {NULL} else {"This study"})
                   }
                   
                 }, 
                 "3D Scatter" = {
                   
                   if (input_palette() %in% c("viridis", "magma", "inferno", "plasma", "cividis")) {
                     palette_plotly <- viridis(option = input_palette(), n = length(unique(data_reference()[[group_ref()]])))
                   } else {
                     palette_plotly <- brewer.pal(length(unique(data_reference()[[group_ref()]])), name = input_palette())
                   }
                   
                   plot_build <- plot_ly(type="scatter3d", mode = "markers", hovertemplate = "%{text}<extra></extra>", colors = palette_plotly) %>%
                     add_markers(data = data_reference(), x = ~.data[[x()[[1]]]], y = ~.data[[y()[[1]]]], z = ~.data[[z()[[1]]]], text = ~.data$tooltip, color= ~.data[[group_ref()]], alpha = input$alpha, size = I(input$size_reference*50)) %>%
                     layout(scene = list(xaxis = list(title = x()[[2]]),
                                         yaxis = list(title = y()[[2]]),
                                         zaxis = list(title = z()[[2]])
                     )
                     )
                   
                   if (!is.null(data_custom())) {
                     plot_build <- plot_build %>%
                       add_markers(data = data_custom(), x = ~.data[[x()[[1]]]], y = ~.data[[y()[[1]]]], z = ~.data[[z()[[1]]]], text = ~.data$tooltip, alpha = 1, color= I("black"), size = I(input$size_custom), symbol = ~group)
                   }
                 }
          )
        }
        
        plot_build
      })  
      
      output$plot_interactive <- renderPlotly({
        req(plot())
        
        if (input$style != "Density 2D") {
          
          plot_plotly <- ggplotly(p = plot(), tooltip = "text", dynamicTicks = TRUE, source = ns("Plot")) %>%
            config(displaylogo = FALSE)
          
          if (input$style == "Histogram") {
            
            plot_plotly <- config(plot_plotly, modeBarButtonsToRemove = list("select2d","lasso2d"))
            
          }
          
        } else {
          
          plot_plotly <- plot_ly(x = 1, y = 1, type = 'scatter', mode = 'text', 
                                 text = 'This plot type is not available as interactive plot. <br> Please see the "Print" tap instead.', 
                                 textposition = 'middle center', textfont = list(color = '#000000', size = 16)) %>%
            layout(xaxis = list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE, showgrid = FALSE), 
                   yaxis = list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE, showgrid = FALSE))

        }
        
        if (!input$style %in% c("Boxplot", "Violin")) {
        
          if (str_detect(x()[[1]], "Model")) {plot_plotly <- plot_plotly %>% layout(xaxis = list(autorange = "reversed"))}
          if (!is.null(y()) && str_detect(y()[[1]], "Model")) {plot_plotly <- plot_plotly %>% layout(yaxis = list(autorange = "reversed"))}
          if (!is.null(z()) && str_detect(z()[[1]], "Model")) {plot_plotly <- plot_plotly %>% layout(zaxis = list(autorange = "reversed"))}
        
        } else {
          
          if (str_detect(x()[[1]], "Model")) {plot_plotly <- plot_plotly %>% layout(yaxis = list(autorange = "reversed"))}
        
        }
        
        for (i in 1:length(plot_plotly$x$data)){
          if (!is.null(plot_plotly$x$data[[i]]$name)){
            plot_plotly$x$data[[i]]$name <- gsub("\\(","",str_split(plot_plotly$x$data[[i]]$name,",")[[1]][1])
          }
        }
        
        plot_plotly

      })
      
      output$plot_data <- DT::renderDataTable({
        
        plot_coords <- event_data("plotly_brushed", source = ns("Plot"))
        
        if (is.null(plot_coords)) return(NULL)
        
        data_view <- data_reference() %>% 
          filter(between(!!as.symbol(x()[[1]]), plot_coords[["x"]][1], plot_coords[["x"]][2])) %>%
          filter(between(!!as.symbol(y()[[1]]), plot_coords[["y"]][1], plot_coords[["y"]][2]))
        
        DT::datatable(data_view %>% select(-contains("20"), -Reference, -doi, -Note, -Latitude, -Longitude, -year, -contains("_"), -tooltip), 
                      rownames = FALSE, options = list(scrollX = TRUE))
        
      })
      
      plot_export <- reactive({
        req(plot())
        
        plot_export <- plot()
        
        if ("ggplot" %in% class(plot_export)) {
          
          if (!is.null(y())) {plot_export <- plot_export + labs(y = y()[[3]])}
          if (input$style == "2D Scatter") {plot_export <- plot_export + labs(color = z()[[3]])}
          
          if (!input$style %in% c("Boxplot", "Violin")) {
            
            if (str_detect(x()[[1]], "Model")) {plot_export <- plot_export + scale_x_reverse()}
            if (!is.null(y()) && str_detect(y()[[1]], "Model")) {plot_export <- plot_export + scale_y_reverse()}
            if (plot_export[["labels"]][["x"]] == x()[[2]]) {plot_export <- plot_export + labs(x = x()[[3]])}
          
          } else {
            
            if (str_detect(x()[[1]], "Model")) {plot_export <- plot_export + scale_y_reverse()}
            if (plot_export[["labels"]][["y"]] == x()[[2]]) {plot_export <- plot_export + labs(y = x()[[3]])}
          }
          
        } else {
          
          plot_export <- ggplot(mapping = aes(x = c(1, 0), y = c(0, 1), colour = c("A", "B"))) + 
            geom_point(alpha = 0) + 
            annotate(geom = "text", x = 0.5, y = 0.5, label = str_wrap("3D Scatterplots cannot be downloaded. Please use the snapshot tool in the interactive plot instead.", width = 40), size = 5) + 
            theme_void() + 
            theme(legend.position = "none", 
                  legend.text=element_text(color = "white")
            )
          }
        
        plot_export
      })
      
      output$plot_print <- renderPlot({ plot_export() })
      
      return(plot_export)
    }
  )
}
