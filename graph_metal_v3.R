# Cargar librerías
library(tidyverse)
library(ggplot2)
library(readxl)
library(RColorBrewer)

# Obtener los nombres de los archivos CSV en el directorio
csv_names <- list.files(path = "/Users/hugo/Desktop/Carlos/2_Staphylococcus_aureus", pattern = ".csv", full.names = TRUE)

# Crear un data frame con los nombres de los archivos y un identificador 'id'
csv_names2 <- data.frame(genome = basename(csv_names), id = as.factor(1:length(csv_names)))

# Leer los archivos CSV y combinarlos con el data frame de nombres
data <- csv_names %>%
  lapply(read_csv) %>%
  bind_rows(.id = as.character("id")) %>%
  left_join(csv_names2)

datos <- read.table("/Users/hugo/Desktop/datos.txt", sep = ",", header = TRUE)
newdatos <- na.omit(datos)
colnames(data)[3] <- "id_db"
datos2 <- left_join(data, newdatos, by = "id_db")
datos2 <- na.omit(datos2)

# Crear la matriz de abundancia
abundance_matrix <- datos2 %>%
  group_by(genome, gene.name) %>%
  summarise(n = n()) %>%
  pivot_wider(names_from = gene.name, values_from = n, values_fill = list(n = 0)) %>%
  as.data.frame()

# Guardar la matriz de abundancia en un archivo CSV
write.csv(abundance_matrix, "/Users/hugo/Desktop/abundance_matrix.csv", row.names = FALSE)

# Imprimir mensaje de éxito
print("Matriz de abundancia guardada en /Users/hugo/Desktop/abundance_matrix.csv")

# Normalizar y preparar los datos para el gráfico de calor
datos5 <- datos2 %>%
  group_by(genome, gene.name) %>%
  summarise(n = n()) %>%
  ungroup() %>%
  mutate(n_normalized = (n / sum(n)) * 1000)

# Colores personalizados
colors <- c("gray97", "darkslategray2", "lightblue3", "#a9d6e5", "#012a4a")

# Crear el gráfico de calor
ggplot(datos5 %>% filter(n_normalized > 2), aes(x = gene.name, y = genome, fill = n_normalized)) +
  geom_tile(color = "white", lwd = 1) +
  scale_fill_gradientn(colors = colors, name = "", labels = scales::comma) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 1, hjust = 1, size = 9),
    axis.text.y = element_text(hjust = 1, size = 9),
    axis.title.x = element_text(size = 2),
    axis.title.y = element_text(size = 12, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 13),
    strip.text.x = element_text(size = 10, face = "bold")
  )
