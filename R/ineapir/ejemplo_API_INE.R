
rm(list=ls())

library(httr)
library(jsonlite)
library(pxR)
library(ineapir)
library(tidyr)
library(dplyr)


  filter <- list("3" = "83") # 83 es para que los datos sean en niveles
  
  # ----------------------------------------------------------------------------  
  # Tabla 23709 (por subclases)
  df <-get_data_table(idTable = 23709, unnest = TRUE, filter = filter,
                      validate = FALSE, tip = "M", metanames = TRUE, 
                      metacodes = TRUE)
  
  # Al usar get_data_table se añade tip = "M", metanames = TRUE, 
  # metacodes = TRUE para que traiga los nombres de las series como
  # figuran en ECOICOP
  
  df$Date <- make_date(year = df$Anyo,month = df$FK_Periodo,day = 1)
  df$ECOICOP <- paste0('CP',df$Subclases.Codigo)
  
  dfNamesECOICOP <- df %>%
    distinct(df$ECOICOP, df$Subclases)
  
  names(dfNamesECOICOP) <- c('Codigo','Nombre')
  
  df <- df[,c('Date','ECOICOP','Valor')]
  
  df0 <- df %>%
    pivot_wider(
      names_from = 'ECOICOP',
      values_from = 'Valor'
    )
  
  df0 <- as.data.frame(df0 %>%
                         arrange(Date))
  
  mIndex <- as.data.frame(df0)
  