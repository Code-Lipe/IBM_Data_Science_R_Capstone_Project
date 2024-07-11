## Análise Exploratória de Dados com SQL
## Realizando análise exploratória de dados usando consultas SQL com o pacote RSQLite R.
## Estabeleça sua conexão SQlIte
library("RSQLite")

conn <- dbConnect(RSQLite::SQLite(), "RDB.sqlite")
conn

## Carregando os csv's em 4 tabelas
df1 <- dbExecute(conn, "CREATE TABLE WORLD_CITIES (
    CITY VARCHAR(50) NOT NULL,
    CITY_ASCII VARCHAR(50) NOT NULL,
    LAT DECIMAL NOT NULL,
    LNG DECIMAL NOT NULL,
    COUNTRY VARCHAR(50) NOT NULL,
    ISO2 VARCHAR(10) NOT NULL,
    ISO3 VARCHAR(10) NOT NULL,
    ADMIN_NAME VARCHAR(100) NOT NULL,
    CAPITAL VARCHAR(50) NOT NULL,
    POPULATION BIGINT NOT NULL,
    ID BIGINT NOT NULL)")

df2 <- dbExecute(conn, "CREATE TABLE BIKE_SHARING_SYSTEMS (
    COUNTRY VARCHAR(20) NOT NULL,
    CITY VARCHAR(50) NOT NULL,
    SYSTEM VARCHAR(50) NOT NULL,
    BICYCLES NUMERIC NOT NULL)")

df3 <- dbExecute(conn, "CREATE TABLE CITIES_WEATHER_FORECAST (
    CITY VARCHAR(20) NOT NULL,
    WEATHER VARCHAR(10) NOT NULL,
    VISIBILITY SMALLINT NOT NULL,
    TEMP DECIMAL NOT NULL,
    TEMP_MIN DECIMAL NOT NULL,
    TEMP_MAX DECIMAL NOT NULL,
    PRESSURE SMALLINT NOT NULL,
    HUMIDITY SMALLINT NOT NULL,
    WIND_SPEED DECIMAL NOT NULL,
    WIND_DEG SMALLINT NOT NULL,
    SEASON VARCHAR(10) NOT NULL,
    FORECAST_DATETIME TIMESTAMP NOT NULL)")

df4 <- dbExecute(conn, "CREATE TABLE SEOUL_BIKE_SHARING (
    DATE VARCHAR(20) NOT NULL,
    RENTED_BIKE_COUNT SMALLINT NOT NULL,
    HOUR SMALLINT NOT NULL,
    TEMPERATURE DECIMAL NOT NULL,
    HUMIDITY SMALLINT NOT NULL,
    WIND_SPEED DECIMAL NOT NULL,
    VISIBILITY SMALLINT NOT NULL,
    DEW_POINT_TEMPERATURE DECIMAL NOT NULL,
    SOLAR_RADIATION DECIMAL NOT NULL,
    RAINFALL DECIMAL NOT NULL,
    SNOWFALL DECIMAL NOT NULL,
    SEASONS VARCHAR(10) NOT NULL,
    HOLIDAY VARCHAR(20) NOT NULL,
    FUNCTIONING_DAY VARCHAR(10) NOT NULL)")

worldcities <- read.csv("raw_worldcities.csv")
bike_sharing_systems <- read.csv("bike_sharing_systems.csv")
cities_weather_forecast <- read.csv("cities_weather_forecast.csv")
seoul_bike_sharing <- read.csv("seoul_bike_sharing.csv")

dbWriteTable(conn, "WORLD_CITIES", worldcities, overwrite = TRUE, header = TRUE)
dbWriteTable(conn, "BIKE_SHARING_SYSTEMS", bike_sharing_systems, overwrite = TRUE, header = TRUE)
dbWriteTable(conn, "CITIES_WEATHER_FORECAST", cities_weather_forecast, overwrite = TRUE, header = TRUE)
dbWriteTable(conn, "SEOUL_BIKE_SHARING", seoul_bike_sharing, overwrite = TRUE, header = TRUE)

dbListTables(conn)


# Determine quantos registros estão no conjunto de dados seoul_bike_sharing.
dbGetQuery(conn, "SELECT COUNT(*) AS RECORDS_IN_DATASET
           FROM SEOUL_BIKE_SHARING")

# Determine quantas horas tiveram contagem de bicicletas alugadas diferente de zero.
dbGetQuery(conn, "SELECT COUNT(HOUR) AS NUMBER_OF_HOURS
           FROM SEOUL_BIKE_SHARING
           WHERE RENTED_BIKE_COUNT > 0")

# Consulte a previsão do tempo para Seul nas próximas 3 horas.
dbGetQuery(conn, "SELECT * FROM CITIES_WEATHER_FORECAST
           WHERE CITY = 'Seoul'
           LIMIT 1")

# Encontre quais estações estão incluídas no conjunto de dados de compartilhamento de bicicletas seoul.
dbGetQuery(conn, "SELECT DISTINCT(SEASONS) FROM SEOUL_BIKE_SHARING")

# Encontre a primeira e a última datas no conjunto de dados Seoul Bike Sharing.
dbGetQuery(conn, "SELECT MIN(DATE) AS START_DATE, MAX(DATE) AS END_DATE
           FROM SEOUL_BIKE_SHARING")

# Determine qual data e hora tiveram mais aluguel de bicicletas.
dbGetQuery(conn, "SELECT DATE, HOUR, RENTED_BIKE_COUNT AS MAXIMUM_COUNT
           FROM SEOUL_BIKE_SHARING
           WHERE RENTED_BIKE_COUNT = (SELECT MAX(RENTED_BIKE_COUNT)
                                      FROM SEOUL_BIKE_SHARING)")

# Determine a temperatura média horária e o número médio de aluguéis de bicicletas por hora ao longo de cada estação. Liste os dez melhores resultados por contagem média de bicicletas.
dbGetQuery(conn, "SELECT SEASONS, HOUR, AVG(RENTED_BIKE_COUNT), AVG(TEMPERATURE)
           FROM SEOUL_BIKE_SHARING
           GROUP BY SEASONS, HOUR
           ORDER BY AVG(RENTED_BIKE_COUNT) DESC
           LIMIT 10")

# Encontre a contagem média horária de bicicletas durante cada temporada.
dbGetQuery(conn, "SELECT SEASONS, AVG(RENTED_BIKE_COUNT) AS AVG_S_COUNT,
           MIN(RENTED_BIKE_COUNT) AS MIN_S_COUNT,
           MAX(RENTED_BIKE_COUNT) AS MAX_S_COUNT,
           SQRT(AVG(RENTED_BIKE_COUNT * RENTED_BIKE_COUNT) - AVG(RENTED_BIKE_COUNT )*AVG(RENTED_BIKE_COUNT )) AS DETOUR_S_COUNT
           FROM SEOUL_BIKE_SHARING
           GROUP BY SEASONS
           ORDER BY AVG_S_COUNT DESC")

# Considere o clima ao longo de cada estação. Em média, quais foram a TEMPERATURA, UMIDADE, WIND_SPEED, VISIBILIDADE, DEW_POINT_TEMPERATURE, SOLAR_RADIATION, PRECIPITAÇÃO e QUEDA de NEVE por estação?
dbGetQuery(conn, "SELECT SEASONS, AVG(RENTED_BIKE_COUNT) AS AVG_S_COUNT,
           AVG(TEMPERATURE) AS AVG_S_TEMP, AVG(HUMIDITY) AS AVG_S_HUMIDITY,
           AVG(WIND_SPEED) AS AVG_WIND_SPEED, AVG(VISIBILITY) AS AVG_VISIBILITY,
           AVG(DEW_POINT_TEMPERATURE) AS AVG_DEW_POINT,
           AVG(SOLAR_RADIATION) AS AVG_SOLAR_RADIATION, AVG(RAINFALL) AS AVG_RAINFALL,
           AVG(SNOWFALL) AS AVG_SNOWFALL
           FROM SEOUL_BIKE_SHARING
           GROUP BY SEASONS
           ORDER BY AVG_S_COUNT DESC")

# Use uma junção implícita nas tabelas WORLD_CITIES e BIKE_SHARING_SYSTEMS para determinar o número total de bicicletas disponíveis em Seul, além das seguintes informações sobre a cidade de Seul: CITY, COUNTRY, LAT, LON, POPULATION, em uma única exibição.
dbGetQuery(conn, "SELECT B.BICYCLES, B.CITY, B.COUNTRY,
           W.LAT, W.LNG, W.POPULATION
           FROM BIKE_SHARING_SYSTEMS AS B
           LEFT JOIN WORLD_CITIES AS W ON B.CITY = W.CITY_ASCII
           WHERE B.CITY = 'Seoul'")

# Encontre todas as cidades com contagens totais de bicicletas entre 15000 e 20000. Retorne os nomes da cidade e do país, além das coordenadas (LAT, LNG), população e número de bicicletas para cada cidade.
dbGetQuery(conn, "SELECT B.BICYCLES, B.CITY, B.COUNTRY, W.LAT, W.LNG, W.POPULATION
           FROM BIKE_SHARING_SYSTEMS AS B
           LEFT JOIN WORLD_CITIES AS W ON B.CITY = W.CITY_ASCII
           WHERE B.CITY = 'Seoul' OR B.BICYCLES BETWEEN 15000 AND 20000
           ORDER BY B.BICYCLES DESC")
