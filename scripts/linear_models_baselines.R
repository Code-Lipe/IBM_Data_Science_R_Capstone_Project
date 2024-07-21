## Agora que você realizou uma análise exploratória no conjunto de dados de demanda de compartilhamento de bicicletas e obteve alguns insights sobre os atributos, é hora de criar modelos preditivos para prever a contagem de bicicletas alugadas por hora usando informações relacionadas ao clima e à data.

library("tidymodels")
library("tidyverse")
library("stringr")

# dados
bike_sharing_df <- read_csv("seoul_bike_sharing_converted_normalized.csv")
spec(bike_sharing_df)


## Dividir dados de treinamento e teste
set.seed(1234)
# prop = 3/4
bike_sharing_split <- initial_split(bike_sharing_df, prop = 0.75)
# train_data
bike_sharing_training <- training(bike_sharing_split)
# test_data
bike_sharing_testing <- testing(bike_sharing_split)


## Criar um modelo de regressão linear usando apenas variáveis meteorológicas
lm_model_weather <- linear_reg(mode = "regression", engine = "lm")

training_fit <- lm_model_weather %>%
  fit(RENTED_BIKE_COUNT ~ TEMPERATURE + HUMIDITY + WIND_SPEED +
        VISIBILITY + DEW_POINT_TEMPERATURE + SOLAR_RADIATION +
        RAINFALL + SNOWFALL, data = bike_sharing_training)

print(training_fit)


## Construir um modelo de regressão linear usando todas as variáveis
lm_model_all <- linear_reg(mode = "regression", engine = "lm")

all_fit <- lm_model_all %>%
  fit(RENTED_BIKE_COUNT ~ ., data = bike_sharing_training)

summary(all_fit)
print(all_fit)


## Avaliação do modelo e identificação de variáveis importantes
weather_train_results <- training_fit %>%
  predict(new_data = bike_sharing_training)

all_train_results <- all_fit %>%
  predict(new_data = bike_sharing_training)

weather_train_results <- weather_train_results %>%
  mutate(truth = bike_sharing_training$RENTED_BIKE_COUNT)

all_train_results <- all_train_results %>%
  mutate(truth = bike_sharing_training$RENTED_BIKE_COUNT)

head(weather_train_results)

head(all_train_results)


## Usando as funções testersq() para calcular métricas R-quadrado e rmse() RMSE para os dois resultados de teste
rsq_weather <- rsq(weather_train_results, truth = truth, estimate = .pred)

rsq_all <- rsq(all_train_results, truth = truth, estimate = .pred)

rmse_weather <- rmse(weather_train_results, truth = truth, estimate = .pred)

rmse_all <- rmse(all_train_results, truth = truth, estimate = .pred)

# Primeiro vamos imprimir todos os coeficientes:
lm_model_all$fit$coefficients


## Classificando a lista de coeficientes em ordem decrescente e visualizando o resultado usando ggplot e geom_bar
all_fit %>%
  tidy() %>%
  arrange(desc(abs(estimate)))

all_fit %>%
  tidy() %>%
  filter(!is.na(estimate)) %>%
  ggplot(aes(x = fct_reorder(term, abs(estimate)), y = abs(estimate))) +
  geom_bar(stat = "identity", fill = "black") +
  coord_flip() +
  theme(axis.text.y = element_text(angle = 10, colour = "black", size = 7)) +
  xlab("variable")

