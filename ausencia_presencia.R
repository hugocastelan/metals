# Cargar librerías
library(tidyverse)
library(ggplot2)
library(readxl)
library(RColorBrewer)

# Obtener los nombres de los archivos CSV en el directorio
csv_names <- list.files(path = "/Users/hugo/Documents/Carlos/2_Staphylococcus_aureus", pattern = ".csv", full.names = TRUE)

# Crear un data frame con los nombres de los archivos y un identificador 'id'
csv_names2 <- data.frame(genome = basename(csv_names), id = as.factor(1:length(csv_names)))

# Leer los archivos CSV y combinarlos con el data frame de nombres
data <- csv_names %>%
  lapply(read_csv) %>%
  bind_rows(.id = as.character("id")) %>%
  left_join(csv_names2)

datos <- read.table("/Users/hugo/Documents/Carlos/BACMED.csv", sep = ",", header = TRUE)
newdatos <- na.omit(datos)
colnames(data)[3] <- "id_db"
datos2 <- left_join(data, newdatos, by = "id_db", relationship = "many-to-many")
newdatos <- newdatos %>% distinct(id_db, .keep_all = TRUE)
datos2 <- left_join(data, newdatos, by = "id_db")

# Crear la matriz de presencia y ausencia
presence_absence_matrix <- datos2 %>%
  group_by(genome, gene_name) %>%
  summarise(presence = ifelse(n() > 0, 1, 0)) %>%
  pivot_wider(names_from = gene_name, values_from = presence, values_fill = list(presence = 0)) %>%
  as.data.frame()

# Guardar la matriz de presencia y ausencia en un archivo CSV
write.csv(presence_absence_matrix, "/Users/hugo/Desktop/presence_absence_matrix.csv", row.names = FALSE)

# Imprimir mensaje de éxito
print("Matriz de presencia y ausencia guardada en /Users/hugo/Desktop/presence_absence_matrix.csv")
