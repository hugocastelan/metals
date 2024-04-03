# Instalar y cargar el paquete readxl
# Luego, puedes usar la función read_excel
library(tidyverse)
library(ggplot2)
library(readxl)

# Obtener los nombres de los archivos CSV en el directorio
csv_names <- list.files(path = "/Users/hugo/Desktop/Carlos", pattern = "\\.csv$", full.names = TRUE)

# Crear un data frame con los nombres de los archivos y un identificador 'id'
csv_names2 <- data.frame(genome = basename(csv_names), id = as.factor(1:length(csv_names)))

# Leer los archivos CSV y combinarlos con el data frame de nombres
data <- csv_names %>%
  lapply(read_csv) %>%
  bind_rows(.id = as.character("id")) %>%
  left_join(csv_names2)

datos<-read.table("/Users/hugo/Desktop/Data_Table.csv", sep="," , header = 1)

datos2<-left_join(data, datos, "id_db")

datos2<-datos2 %>% group_by(genome, gene_name.x, Metal)%>% summarise(n = n())

colors <- c("#a9d6e5", "#012a4a") 

datos4<-datos2 %>% group_by(genome, Metal)%>% summarise(n = n())
ggplot(datos4, aes(x = Metal, y =genome , fill = n)) +
  geom_tile(color = "white", lwd = 1) +
  scale_fill_gradientn(colors = colors, name = "", labels = scales::comma) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 1, hjust = 1, size = 9),
    axis.text.y = element_text(hjust = 1, size = 9),
    axis.title.x = element_text(size = 12, face = "bold"),
    axis.title.y = element_text(size = 12, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 13),
    strip.text.x = element_text(size = 10, face = "bold")
  )
