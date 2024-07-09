## Web scrape uma página Wiki Global Bike-Sharing Systems
## link: https://en.wikipedia.org/wiki/List_of_bicycle-sharing_systems

# Verifique se é necessário instalar a biblioteca rvest
require("rvest")
library(rvest)


## Extrair tabela HTML de sistemas de compatilhamento de bicicletas e
## convertê-la em um quadro de dados

url <- "https://en.wikipedia.org/wiki/List_of_bicycle-sharing_systems"
# Obtenha o nó HTML raiz chamando o método `read_html()` com URL
root_node <- read_html(url)
root_node

table_nodes <- html_nodes(root_node, "table")

for (table in table_nodes) {
  print(table)
}

# Converte a tabela do sistema de compartilhamento de bicicletas em um dataframe
raw_bike_sharing_systems <- html_table(table_nodes[[1]])
raw_bike_sharing_systems_df <- as.data.frame(raw_bike_sharing_systems)

head(raw_bike_sharing_systems_df)

# Resuma o dataframe
summary(raw_bike_sharing_systems_df)

# Exporta o dataframe para um arquivo csv
write.csv(raw_bike_sharing_systems_df, file = 'raw_bike_sharing_systems.csv')
