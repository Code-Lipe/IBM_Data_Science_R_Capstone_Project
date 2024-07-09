## Chamadas de APIs OpenWeather
## Coletando dados meteorológicos atuais e previstos em tempo real para cidades usando a API OpenWeather.
## Link para gerar sua API Key: https://home.openweathermap.org/users/sign_up

# Verifique se é necessário instalar a biblioteca rvest
install.packages("httr")
library(httr)


## Obter previsões meteorológicas de 5 dias para uma lista de cidades usando a
## API OpenWeather

# Crie alguns vetores vazios para armazenar dados temporariamente

# Coluna nome da cidade
city <- c()
# Coluna meteorológica, chuvoso ou nublado, etc.
weather <- c()
# Coluna de visibilidade do céu
visibility <- c()
# Coluna de temperatura atual
temp <- c()
# Coluna de temperatura mínima
temp_min <- c()
# Coluna de temperatura máxima
temp_max <- c()
# Coluna de pressão
pressure <- c()
# Coluna de umidade
humidity <- c()
# Coluna de velocidade do vento
wind_speed <- c()
# Coluna de direção do vento
wind_deg <- c()
# Carimbo de data e hora de previsão
forecast_datetime <- c()


# Criando função
get_weather_forecaset_by_cities <- function(city_names){
  df <- data.frame()
  # Criando sua variárivel de api_key
  your_api_key <- "d07f56210c6fbabf3719ea01e5712c2f"

  for (city_name in city_names) {
    # URL da API de previsão
    forecast_url <- 'https://api.openweathermap.org/data/2.5/forecast'

    # Cria parâmetros de consulta
    forecast_query <- list(q = city_name, appid = your_api_key, units = "metric")

    # Faça uma chamada HTTP GET para a cidade especificada
    response <- GET(forecast_url, query = forecast_query)

    json_result <- content(response, as = "parsed")

    # Observe que o resultado JSON da previsão de 5 dias é uma lista de listas. Você pode imprimir a resposta para verificar os resultados
    results <- json_result$list

    # Faça um loop no resultado json
    for (result in results) {
      city <- c(city, city_name)
      weather <- c(weather, result$weather[[1]]$main)
      # Obtenha visibilidade
      visibility <- c(visibility, result$visibility)
      # Obtenha a temperatura atual
      temp <- c(temp, result$main$temp)
      # Obtenha a temperatura mínima
      temp_min <- c(temp_min, result$main$temp_min)
      # Obtenha a temperatura máxima
      temp_max <- c(temp_max, result$main$temp_max)
      # Receba pressão
      pressure <- c(pressure, result$main$pressure)
      # Obtenha umidade
      humidity <- c(humidity, result$main$humidity)
      # Obtenha a velocidade do vento
      wind_speed <- c(wind_speed, result$wind$speed)
      # Obtenha a direção do vento
      wind_deg <- c(wind_deg, result$wind$deg)
      # Obtenha forcast_datetime
      forecast_datetime <- c(forecast_datetime, result$dt_txt)
    }
    # Adicione as listas R em um quadro de dados
    df <- data.frame(
      city = city,
      weather = weather,
      visibility = visibility,
      temp = temp,
      temp_min = temp_min,
      temp_max = temp_max,
      pressure = pressure,
      humidity = humidity,
      wind_speed = wind_speed,
      wind_deg = wind_deg,
      forecast_datetime = forecast_datetime
    )
  }

  # Retorna um quadro de dados
  return(df)

}

# Chamando função e armazenando dataframe
cities <- c("Seoul", "Washington, D.C.", "Paris", "Suzhou")
cities_weather_df <- get_weather_forecaset_by_cities(cities)

# Salvando dataframe como aquivo csv
write.csv(cities_weather_df, "cities_weather_forecast.csv", row.names = FALSE)

## Baixar conjuntos de dados como arquivos csv do armazenamento em nuvem

# Baixe vários conjuntos de dados

# Baixe algumas informações gerais da cidade, como nome e locais
url <- "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/raw_worldcities.csv"

# baixe o arquivo
download.file(url, destfile = "raw_worldcities.csv")

# Baixe um conjunto de dados específico de demanda horária de compartilhamento de bicicletas em Seul
url <- "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/raw_seoul_bike_sharing.csv"

# baixe o arquivo
download.file(url, destfile = "raw_seoul_bike_sharing.csv")
