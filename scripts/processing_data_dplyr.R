## Se concentrando em processar o conjunto de dados históricos de demanda de compartilhamento de bicicletas de Seul.
## Esse é o conjunto de dados principal para criar um modelo preditivo posteriormente.

# Verifique se você precisa instalar a biblioteca `tidyverse`
# require("tidyverse")
library(tidyverse)

bike_sharing_df <- read_csv("raw_seoul_bike_sharing.csv")

# Primeiro, dê uma olhada rápida no conjunto de dados:
summary(bike_sharing_df)
dim(bike_sharing_df)

## Detectar e manipular valores ausentes

# Eliminar linhas com a coluna `RENTED_BIKE_COUNT` == NA
bike_sharing_df <- drop_na(bike_sharing_df, RENTED_BIKE_COUNT)

# Imprima a dimensão do conjunto de dados novamente depois que essas linhas forem eliminadas
dim(bike_sharing_df)

# Dando uma olhada nos valores ausentes na coluna TEMPERATURA.
bike_sharing_df %>%
  filter(is.na(TEMPERATURE))

## Impute os valores faltantes para a coluna TEMPERATURA usando seu valor médio.

# Calcule a temperatura média do verão
summer_avg_temp <- bike_sharing_df %>%
  filter(SEASONS == "Summer") %>%
  select(TEMPERATURE) %>%
  summarise(mean(TEMPERATURE, na.rm = TRUE)) %>%
  unlist() %>%
  unname()

# Imputar valores faltantes para coluna TEMPERATURA com temperatura média de verão
bike_sharing_df$TEMPERATURE <- replace_na(bike_sharing_df$TEMPERATURE, summer_avg_temp)

# Imprima o resumo do conjunto de dados novamente para garantir que não haja valores ausentes em todas as colunas
bike_sharing_df %>%
  filter(is.na(TEMPERATURE))


## Criar variáveis indicadoras (fictícias) para variáveis categóricas

# Converter coluna HOUR de numérica em caractere primeiro:
bike_sharing_df <- bike_sharing_df %>%
  mutate(HOUR = as.character(HOUR))

# Converta as colunas ESTAÇÕES, FERIADOS e HORA em colunas de indicadores.
col <- c("SEASONS", "HOLIDAY", "HOUR")

for (column in col) {
  bike_sharing_df <- bike_sharing_df %>%
    mutate(dummy = 1) %>%
    spread(key = column, value = dummy, fill = 0)
}

# Imprima o resumo do conjunto de dados novamente para garantir que as colunas do indicador sejam criadas corretamente
summary(bike_sharing_df)

# Salve o conjunto de dados como `seoul_bike_sharing_converted.csv`
#write_csv(dataframe, "seoul_bike_sharing_converted.csv")
write_csv(bike_sharing_df, "seoul_bike_sharing_converted.csv")


## Normalizar dados

# A função 'rescale()' de scales package ajuda na normalização min-max
install.packages("scales")
library(scales)

# Use a função `mutate()` para aplicar normalização min-max em colunas
# `RENTED_BIKE_COUNT`, `TEMPERATURE`, `HUMIDITY`, `WIND_SPEED`, `VISIBILITY`, `DEW_POINT_TEMPERATURE`, `SOLAR_RADIATION`, `RAINFALL`, `SNOWFALL`

bike_sharing_df <- bike_sharing_df %>%
  mutate(RENTED_BIKE_COUNT = rescale(RENTED_BIKE_COUNT, to = 0:1),
         TEMPERATURE = rescale(TEMPERATURE, to = 0:1),
         HUMIDITY = rescale(HUMIDITY, to = 0:1),
         WIND_SPEED = rescale(WIND_SPEED, to = 0:1),
         VISIBILITY = rescale(VISIBILITY, to = 0:1),
         DEW_POINT_TEMPERATURE = rescale(DEW_POINT_TEMPERATURE, to = 0:1),
         SOLAR_RADIATION = rescale(SOLAR_RADIATION, to = 0:1),
         RAINFALL = rescale(RAINFALL, to = 0:1),
         SNOWFALL = rescale(SNOWFALL, to = 0:1))


# Imprima o resumo do conjunto de dados novamente para garantir que as colunas numéricas estejam entre 0 e 1
summary(bike_sharing_df)

# Salve o conjunto de dados como `seoul_bike_sharing_converted_normalized.csv`
#write_csv(dataframe, "seoul_bike_sharing_converted_normalized.csv")
write_csv(bike_sharing_df, "seoul_bike_sharing_converted_normalized.csv")

## Padronizar os nomes de coluna novamente para os novos conjuntos de dados
# Como você adicionou muitas novas variáveis de indicador, você precisa padronizar seus nomes de coluna novamente usando o seguinte código:

# Dataset list
dataset_list <- c('seoul_bike_sharing.csv', 'seoul_bike_sharing_converted.csv', 'seoul_bike_sharing_converted_normalized.csv')

for (dataset_name in dataset_list) {
  # Ler conjunto de dados
  dataset <- read_csv(dataset_name)

  # Padronizou suas colunas:
  # Converte todos os nomes de colunas para letras maiúsculas
  names(dataset) <- toupper(names(dataset))

  # Substitua quaisquer separadores de espaço em branco por sublinhado, usando a função str_replace_all
  names(dataset) <- str_replace_all(names(dataset), " ", "_")

  # Salve o conjunto de dados novamente
  write.csv(dataset, dataset_name, row.names = FALSE)
}
