## Você coletou alguns conjuntos de dados brutos de diversas fontes diferentes.
## Aqui, você precisará realizar tarefas de organização de dados para melhorar a qualidade dos dados.

# Verifique se é necessário instalar a biblioteca tidyverse
# require("tidyverse")
library(tidyverse)


## Escrevendo um loop 'for' para iterar sobre os conjuntos de dados e converter seus nomes de coluna.

dataset_list <- c('raw_bike_sharing_systems.csv', 'raw_seoul_bike_sharing.csv', 'cities_weather_forecast.csv', 'raw_worldcities.csv')

for (dataset_name in dataset_list) {
  # Ler conjunto de dados
  dataset <- read_csv(dataset_name)

  # Padronizando suas colunas:
  # Converte todos os nomes de colunas para letras maiúsculas
  names(dataset) <- toupper(names(dataset))

  # Substitua quaisquer separadores de espaço em branco por sublinhados, usando a função str_replace_all
  names(dataset) <- str_replace_all(names(dataset), " ", "_")

  # Salve o conjunto de dados
  write.csv(dataset, dataset_name, row.names = FALSE)
}


## Leia os conjuntos de dados resultantes e verifique se seus nomes de coluna seguem a convenção de nomenclatura

for (dataset_name in dataset_list) {
  # Imprima um resumo para cada conjunto de dados para verificar se os nomes das colunas foram convertidos corretamente
  dataset <- read_csv(dataset_name)
  print(colnames(dataset))
}


## Processar o conjunto de dados do sistema de compartilhamento de bicicletas raspado pela web

# Primeiro carregue o conjunto de dados
bike_sharing_df <- read_csv("raw_bike_sharing_systems.csv")

head(bike_sharing_df)

# Selecione as quatro colunas
sub_bike_sharing_df <- bike_sharing_df %>% select(COUNTRY, CITY, SYSTEM, BICYCLES)

# Vamos ver os tipos das colunas selecionadas
sub_bike_sharing_df %>%
  summarize_all(class) %>%
  gather(variable, class)

# Se encontrar caracteres que não sejam dígitos, a coluna da bicicleta não será puramente numérica
find_character <- function(strings) grepl("[^0-9]", strings)

sub_bike_sharing_df %>%
  select(BICYCLES) %>%
  filter(find_character(BICYCLES)) %>%
  slice(0:10)

# Em seguida, vamos dar uma olhada nas outras colunas
# Verifique se a coluna COUNTRY possui algum link de referência
ref_pattern <- "\\[[A-z0-9]+\\]"
find_reference_pattern <- function(strings) grepl(ref_pattern, strings)

# Vamos conferir a coluna: COUNTRY
sub_bike_sharing_df %>%
  select(COUNTRY) %>%
  filter(find_reference_pattern(COUNTRY)) %>%
  slice(0:10)

# Vamos conferir a coluna: CITY
sub_bike_sharing_df %>%
  select(CITY) %>%
  filter(find_reference_pattern(CITY)) %>%
  slice(0:10)

# Vamos conferir a coluna: SYSTEM
sub_bike_sharing_df %>%
  select(SYSTEM) %>%
  filter(find_reference_pattern(SYSTEM)) %>%
  slice(0:10)

# Após algumas investigações preliminares, identificamos que as colunas CITY e SYSTEM têm alguns links de referência indesejados, e a coluna BICYCLES tem links de referência e algumas anotações textuais.

## Remover links de referência indesejados usando expressões regulares

# remover link de referência
remove_ref <- function(strings) {
  ref_pattern <- "\\[[A-z0-9]+\\]" # "Defina um padrão que corresponda a um link de referência como [1]"
  # Substitua todas as substrings correspondentes por um espaço em branco usando str_replace_all()
  result <- stringr::str_replace_all(strings, ref_pattern, "")
  # Corte o resultado se quiser
  result <- trimws(result)
  # return(result)
  return(result)
}

# Use a função
sub_bike_sharing_df <- sub_bike_sharing_df %>%
  mutate(SYSTEM = remove_ref(SYSTEM),
         CITY = remove_ref(CITY))

# Use o código a seguir para verificar se todos os links de referência foram removidos:
sub_bike_sharing_df %>%
  select(CITY, SYSTEM, BICYCLES) %>%
  filter(find_reference_pattern(CITY) | find_reference_pattern(SYSTEM) | find_reference_pattern(BICYCLES))


## Extrair o valor numérico usando expressões regulares

# Extraia o primeiro número
extract_num <- function(columns){
  # Defina um padrão digital
  digitals_pattern <- "\\d+"  # "Definir um padrão que corresponda a uma substring digital"

  # Encontre a primeira correspondência usando str_extract
  str_extract(columns, digitals_pattern) %>%
    # Converte o resultado em numérico usando a função as.numeric()
    as.numeric()
}

# Use a função
# Use a função mutate() na coluna BICYCLES
sub_bike_sharing_df <- sub_bike_sharing_df %>%
  mutate(BICYCLES = extract_num(BICYCLES))

# Use a função de resumo para verificar as estatísticas descritivas
summary(sub_bike_sharing_df$BICYCLES)

# Grave o conjunto de dados em `bike_sharing_systems.csv`
write.csv(sub_bike_sharing_df, "bike_sharing_systems.csv")
