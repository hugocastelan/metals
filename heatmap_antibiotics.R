# Cargar librerías
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(reshape2)

# Ruta de la carpeta con archivos
folder_path <- "Downloads/resultadosantibioticoscarlos_bacteria/"

# Listado de archivos .txt
file_list <- list.files(path = folder_path, pattern = "\\.txt$", full.names = TRUE)

# Función para procesar los datos
process_data <- function(file) {
  data <- read_delim(file, delim = "\t") %>%
    select(Best_Hit_ARO, Best_Identities, Antibiotic)
  
  cepa <- tools::file_path_sans_ext(basename(file))
  
  data <- data %>%
    mutate(Cepa = cepa)
  
  return(data)
}

# Crear un dataframe combinado con todos los archivos
combined_data <- bind_rows(lapply(file_list, process_data))
combined_data <- combined_data[!is.na(combined_data$Antibiotic), ]

# Crear el heatmap
ggplot(combined_data, aes(x = Antibiotic, y = Cepa, fill = Best_Identities)) +
  geom_tile(color = "white", size = 0.1) +
  scale_fill_gradient(low = "gray97", high = "#012a4a", name = "Best_Identities",
                      limits = c(0, 100), breaks = seq(0, 100, by = 10)) +
  labs(title = "Heatmap Antibiotic Resistance",
       x = "Antibiotics",
       y = "Strain Genome") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        axis.title = element_text(size = 12, face = "bold"),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

# Crear la matriz de abundancia
combined_data2 <- combined_data %>% 
  mutate(Presence = ifelse(Best_Identities > 0, 1, 0)) %>%
  select(Cepa, Antibiotic, Presence)

# Renombrar columnas
colnames(combined_data2) <- c("Strain", "Antibiotic", "Presence")

# Crear y ajustar la matriz de abundancia
matriz <- dcast(combined_data2, Strain ~ Antibiotic, value.var = "Presence", fill = 0)
matriz[, -1] <- apply(matriz[, -1], 2, function(x) ifelse(x > 1, 1, x))

# Imprimir la matriz en consola
print(matriz)

# Guardar la matriz en un archivo CSV
write.csv(matriz, "Downloads/resultadosantibioticoscarlos_bacteria/matriz_antibiotics.csv", row.names = FALSE)

# Mensaje de confirmación
print("Matriz de abundancia guardada en 'Downloads/resultadosantibioticoscarlos_bacteria/matriz_antibiotics.csv'")
