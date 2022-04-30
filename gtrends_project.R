# download data 

library(tidyverse)
library(dlm)

source('all_dlm_functions_unknown_v.R')
source('discountfactor_selection_functions.R')

data <- nz_ts

model_seasonal <- dlmModTrig(s=12, q=6, dV=10, dW=10)
model_trend <- dlmModPoly(order=2,dV=10,dW=rep(1,2),m0=c(5, 5))

model <- model_trend + model_seasonal
model$C0 <- 10*diag(13)
n0=1
S0=10
k=length(model$m0)

T <- length(data$yt)
h <- 12
t <- T - h

test_data <- data[(t+1):T,]
train_data <- data[1:t,]


Ft=array(0,c(1,k,T))
Gt=array(0,c(k,k,T))
for(t in 1:T){
  Ft[,,t]=model$FF
  Gt[,,t]=model$GG
}



matrices=set_up_dlm_matrices_unknown_v(Ft=Ft,Gt=Gt)
initial_states=set_up_initial_states_unknown_v(model$m0,
                                               model$C0,n0,S0)

df_range=seq(0.7,1,by=0.01)

## fit discount DLM
## MSE
results_MSE <- adaptive_dlm(train_data, matrices, initial_states, df_range,"MSE",forecast=FALSE)

## print selected discount factor
print(paste("The selected discount factor:",results_MSE$df_opt))

## retrieve filtered results
results_filtered <- results_MSE$results_filtered
ci_filtered <- get_credible_interval_unknown_v(
  results_filtered$ft,results_filtered$Qt,results_filtered$nt)

## plot filtering results 
train_data %>%
  ggplot(aes(x=date, y = yt)) + 
  geom_line(linetype=3) + 
  geom_line(aes(x = date, y = results_filtered$ft), col = 'red', linetype=1) +
  geom_line(aes(y = ci_filtered[, 1]), col = 'red', linetype=2, alpha=0.4) +
  geom_line(aes(y = ci_filtered[, 2]), col = 'red', linetype=2, alpha=0.4) +
  labs(x='time', y='Google hits', title= "Google Trends: 'queen's birthday' - filtering") +
  theme_bw()

## retrieve smoothed results
results_smoothed <- results_MSE$results_smoothed
ci_smoothed <- get_credible_interval_unknown_v(
  results_smoothed$fnt, results_smoothed$Qnt, 
  results_filtered$nt[length(results_smoothed$fnt)])

## plot smoothing results 
train_data %>%
  ggplot(aes(x=date, y = yt)) + 
  geom_point(alpha = 0.8, size=1.5) + 
  geom_line(aes(y = results_smoothed$fnt), col = 'red', linetype=1, size=0.5) +
  geom_line(aes(y = ci_smoothed[, 1]), col = 'red', linetype=3) +
  geom_line(aes(y = ci_smoothed[, 2]), col = 'red', linetype=3) +
  labs(x='time', y='Google hits', title= "Google Trends: 'queen's birthday' - smoothing") +
  theme_bw()

## forecasting results
results_forecast <- forecast_function_unknown_v(results_filtered,h, matrices, results_MSE$df_opt)

ci_forecast <- get_credible_interval_unknown_v(
  results_forecast$ft, results_forecast$Qt, 
  results_filtered$nt[length(results_smoothed$fnt)])

ggplot(data=train_data, aes(x=date, y=yt)) + 
  geom_line(linetype=3) + 
  geom_line(aes(x = date, y = results_filtered$ft), col = 'red', linetype=1) +
  geom_line(aes(y = ci_filtered[, 1]), col = 'red', linetype=2, alpha=0.4) +
  geom_line(aes(y = ci_filtered[, 2]), col = 'red', linetype=2, alpha=0.4) +
  geom_point(data = test_data, aes(x=date, y=yt), alpha = 0.8, size=1.5) + 
  geom_line(data = test_data, aes(x=date, y=yt), linetype=3) + 
  geom_line(data = test_data, aes(x=date, y = results_forecast$ft), col = 'blue', linetype=1, size=0.5) +
  geom_line(data = test_data, aes(x=date, y = ci_forecast[, 1]), col = 'blue', linetype=3) +
  geom_line(data = test_data, aes(x=date, y = ci_forecast[, 2]), col = 'blue', linetype=3) +
  labs(x='time', y='Google hits', title= "Google Trends: 'queen's birthday' - filtering + forecast") +
  theme_bw()

