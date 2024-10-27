### PROBANDO THRESHOLDS
# Librarias 
library(dplyr)
library(ggplot2)
library(reshape2)
library(dplyr)
library(igraph)

# Leer los archivos CSV
metals_matrix <- read.csv("/Users/hugo/Desktop/presence_absence_matrix.csv")
antibiotics_matrix <- read.csv("/Users/hugo/Downloads/matriz_antibiotics_2_Staphylococcus_aureus.csv")

# Filter para incluir names of same strains 
common_strains <- intersect(metals_matrix$Strain, antibiotics_matrix$Strain)

# Filtrar las matrices para mantener solo cepas comunes
metals_matrix_filtered <- metals_matrix %>% filter(Strain %in% common_strains)
antibiotics_matrix_filtered <- antibiotics_matrix %>% filter(Strain %in% common_strains)

# Convertir a matrices numéricas y eliminar la columna Strain
X <- metals_matrix_filtered[, -which(names(metals_matrix_filtered) == "Strain")] %>% as.matrix()
Y <- antibiotics_matrix_filtered[, -which(names(antibiotics_matrix_filtered) == "Strain")] %>% as.matrix()

# Calcular la matriz de correlación de Pearson
correlation_matrix <- cor(cbind(X, Y), method = "pearson", use = "pairwise.complete.obs")

# get metales and antibiotics 
metals_names <- colnames(X)
antibiotics_names <- colnames(Y)

# Filtrar la matriz de correlación para incluir solo antibióticos y metales
filtered_correlation_matrix <- correlation_matrix[metals_names, antibiotics_names]

# umbral de correlación
correlation_threshold <- 0.01

# Filtrar las correlaciones que cumplen el umbral
filtered_correlation_matrix[abs(filtered_correlation_matrix) < correlation_threshold] <- NA

filtered_correlation_matrix <- filtered_correlation_matrix[metals_names, antibiotics_names]


# umbral de correlación
#correlation_threshold <- 0.3  

# Filtrar las correlaciones que cumplen el umbral
#filtered_correlation_matrix[abs(filtered_correlation_matrix) < correlation_threshold] <- NA

# Generar un gráfico de calor (heatmap) para visualizar la correlación filtrada
#heatmap_data <- melt(filtered_correlation_matrix, na.rm = TRUE)
heatmap_data <- melt(filtered_correlation_matrix)
heatmap_data <- na.omit(heatmap_data)


# Convertir Var1 y Var2 a caracteres para evitar problemas con factores
heatmap_data$Var1 <- as.character(heatmap_data$Var1)
heatmap_data$Var2 <- as.character(heatmap_data$Var2)

                               
# Generar el gráfico
ggplot(heatmap_data, aes(Var1, Var2, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white",
                       midpoint = 0, limit = c(-1, 1),
                       name = "Pearson Correlation") +
  labs(x = "Metals",
       y = "Antibiotics") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))



