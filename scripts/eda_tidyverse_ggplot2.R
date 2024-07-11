## Análise Exploratória de Dados com tidyverse e ggplot2
## Carregar os dados seoul_bike_sharing em um dataframe

# Carregar pacotes
library(tidyverse)
library(ggplot2)

# Carregar o conjunto de dados
seoul_bike_sharing <- read.csv("seoul_bike_sharing.csv")

#  Reformulação como data. Use o formato dos dados, ou seja, "%d/%m/%Y"
seoul_bike_sharing$DATE <- as.Date(seoul_bike_sharing$DATE, format = "%d/%m/%Y")

# Transmitir 'HOURS' como uma variável categórica
seoul_bike_sharing$HOUR <- as.factor(seoul_bike_sharing$HOUR)

# Verificar a estrutura do dataframe
str(seoul_bike_sharing)

# Finalmente, certifique-se de que não há valores ausentes
sum(is.na(seoul_bike_sharing))

## Estatística Descritiva

# Resumo do conjunto de dados
summary(seoul_bike_sharing)

# Com base nas estatísticas acima, calcule quantos feriados existem.
holidays_count <- seoul_bike_sharing %>%
  filter(HOLIDAY == "Holiday") %>%
  count() %>%
  summarise(count = n / 24)
holidays_count
# Os dados brutos passam de 400 feriados, pois temos uma contagem por HOUR,
# dividindo por 24, descobrimos que temos 17 feriados no ano


#  Calcular a porcentagem de registros que caem em um feriado
records <- seoul_bike_sharing %>%
  count() %>%
  summarise(count = n / 24)

holidays_percentage <- (holidays_count / records) * 100
holidays_percentage

# Dado que há exatamente um ano inteiro de dados, determine quantos registros esperamos ter.
records

# Dadas as observações para o 'FUNCTIONING_DAY', quantos registros devem existir?
seoul_bike_sharing %>%
  count(FUNCTIONING_DAY)

## Detalhamento

# Carregue o pacote dplyr, agrupe os dados por SEASONS, e use a função summarize() para calcular a precipitação total sazonal e a queda de neve.
seoul_bike_sharing %>%
  group_by(SEASONS) %>%
  summarize(total_rainfall = sum(RAINFALL), total_snowfall = sum(SNOWFALL))


## Visualização de dados

# Criar um gráfico de dispersão de .RENTED_BIKE_COUNT vs DATE
ggplot(seoul_bike_sharing, aes(x = DATE, y = RENTED_BIKE_COUNT,
                               color = "blue", alpha = 0.25)) +
  geom_point() +
  theme(legend.position = "none")

# Crie o mesmo enredo da série temporal .RENTED_BIKE_COUNT , mas agora adicione HOURS como a cor
ggplot(seoul_bike_sharing, aes(x = DATE, y = RENTED_BIKE_COUNT,
                               color = HOUR, alpha = 0.25)) +
  geom_point()


## Distribuições

# Criarggplot(seoul_bike_sharing, aes(x = RENTED_BIKE_COUNT)) +
geom_histogram(aes(y = ..density..),
               colour = 1, fill = "white", alpha = 0.5) +
  geom_density(aes(color = "blue")) +
  theme(legend.position = "none")


## Correlação entre duas variáveis (gráfico de dispersão)

# Use um gráfico de dispersão para visualizar a correlação entre RENTED_BIKE_COUNT e TEMPERATURE por SEASONS
ggplot(seoul_bike_sharing, aes(x = TEMPERATURE, y = RENTED_BIKE_COUNT, color = HOUR, alpha = 0.25)) +
  geom_point() +
  facet_wrap(~SEASONS)


## Outliers (boxplot)

# Criar uma exibição de quatro boxplots de .RENTED_BIKE_COUNT vs .HOUR agrupados por SEASONS
ggplot(seoul_bike_sharing, aes(x = HOUR, y = RENTED_BIKE_COUNT)) +
  geom_boxplot(fill = "bisque") +
  facet_wrap(~SEASONS)

# Agrupar os dados por DATE, e usar a função summarize() para calcular o total diário de chuva e queda de neve. Além disso, vá em frente e plote os resultados, se desejar.

seoul_bike_sharing %>%
  group_by(DATE) %>%
  summarise(daily_rainfall = sum(RAINFALL), daily_snowfall = sum(SNOWFALL))

seoul_bike_sharing %>%
  group_by(DATE) %>%
  summarise(daily_rainfall = sum(RAINFALL), daily_snowfall = sum(SNOWFALL)) %>%
  pivot_longer(!DATE) %>%
  ggplot() +
  geom_point(aes(x = DATE, y = value, color = name))

# Determinar quantos dias teve queda de neve.
seoul_bike_sharing %>%
  group_by(DATE) %>%
  summarise(daily_snowfall = sum(SNOWFALL)) %>%
  filter(daily_snowfall > 0) %>%
  count()
