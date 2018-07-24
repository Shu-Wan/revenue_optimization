functions {
  int neg_binomial_2_log_safe_rng(real eta, real phi) {
    real phi_div_exp_eta;
    real gamma_rate;
    phi_div_exp_eta = phi/exp(eta);
    gamma_rate = gamma_rng(phi, phi_div_exp_eta);
    if (gamma_rate >= exp(20.79))
      return -9;
    return poisson_rng(gamma_rate);
  }
}
data {
  int<lower=1> N;
  int<lower=1> K;
  int complaints[N];
  vector[N] traps;
  int<lower=1> J;
  int<lower=1, upper=J> building_idx[N];
  matrix[J,K] meta_data;
  vector[N] sq_foot;
}
parameters {
  real alpha;
  real<lower=0> sigma_alpha;
  real<lower=0> sigma_beta;
  vector[J] std_alphas;
  vector[J] std_betas;
  real beta;
  real<lower=0> inv_prec;
  vector[K] zeta;
  vector[K] gamma;
}
transformed parameters {
  vector[J] alphas = alpha + meta_data * zeta + sigma_alpha * std_alphas;
  vector[J] betas = beta + meta_data * gamma + sigma_beta * std_betas;
  real prec = inv(inv_prec);
}
model {
  beta ~ normal(0, 1);
  std_alphas ~ normal(0,1) ;
  std_betas ~ normal(0,1) ;
  sigma_alpha ~ normal(0, 1);
  sigma_beta ~ normal(0, 1);
  alpha ~ normal(0, 1);
  zeta ~ normal(0, 1);
  gamma ~ normal(0, 1);
  inv_prec ~ normal(0, 1);
  
  complaints ~ neg_binomial_2_log(alphas[building_idx] + betas[building_idx] .* traps 
                               + sq_foot,
                               prec);
} 
generated quantities {
  vector[N] pp_y;
  
  for (n in 1:N) 
    pp_y[n] = neg_binomial_2_log_safe_rng(alphas[building_idx[n]] + betas[building_idx[n]] * traps[n]
                                          + sq_foot[n],
                                          prec);
}
