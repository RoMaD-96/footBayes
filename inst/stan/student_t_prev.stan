data {
    int N;                      // Number of observed matches
    int N_prev;                 // Number of predicted matches
    int nteams;                 // Number of teams
    int ntimes_rank;            // Number of dynamic periods for rankings
    matrix[ntimes_rank, nteams] ranking; // Rankings over time
    array[N] int instants_rank;       // Time indices for rankings for observed matches
    array[N] int team1;               // Team 1 indices for observed matches
    array[N] int team2;               // Team 2 indices for observed matches
    array[N_prev] int team1_prev;     // Team 1 indices for predicted matches
    array[N_prev] int team2_prev;     // Team 2 indices for predicted matches
    matrix[N, 2] y;             // Scores: column 1 is team1, column 2 is team2
    real nu;                    // Degrees of freedom for the Student's t-distribution

    // Priors part
    int<lower=1,upper=4> prior_dist_num;    // 1: Gaussian, 2: t, 3: Cauchy, 4: Laplace
    int<lower=1,upper=4> prior_dist_sd_num; // 1: Gaussian, 2: t, 3: Cauchy, 4: Laplace

    real hyper_df;
    real hyper_location;

    real hyper_sd_df;
    real hyper_sd_location;
    real hyper_sd_scale;
}
transformed data {
    vector[N] diff_y = y[,1] - y[,2];  // Modeled data: score differences
}
parameters {
    real beta;                      // Common coefficient for ranking
    vector[nteams] alpha;           // Per-team random effects
    real<lower=0> sigma_a;          // Standard deviation for random effects
    real<lower=0> sigma_y;          // Noise term in our estimate
    real<lower=0> sigma_alpha;      // Standard deviation for alpha prior
}
transformed parameters {
    matrix[ntimes_rank, nteams] ability;

    for (t in 1:ntimes_rank) {
        // Compute abilities for all teams at time t
        ability[t] = beta * ranking[t] + (alpha * sigma_a)';  // Transpose to get a row vector
    }
}
model {
    // Priors for team-specific random effects (alpha)
    if (prior_dist_num == 1) {
        alpha ~ normal(hyper_location, sigma_alpha);
    } else if (prior_dist_num == 2) {
        alpha ~ student_t(hyper_df, hyper_location, sigma_alpha);
    } else if (prior_dist_num == 3) {
        alpha ~ cauchy(hyper_location, sigma_alpha);
    } else if (prior_dist_num == 4) {
        alpha ~ double_exponential(hyper_location, sigma_alpha);
    }

    // Priors for standard deviations
    if (prior_dist_sd_num == 1) {
        sigma_a ~ normal(hyper_sd_location, hyper_sd_scale);
        sigma_alpha ~ normal(hyper_sd_location, hyper_sd_scale);
    } else if (prior_dist_sd_num == 2) {
        sigma_a ~ student_t(hyper_sd_df, hyper_sd_location, hyper_sd_scale);
        sigma_alpha ~ student_t(hyper_sd_df, hyper_sd_location, hyper_sd_scale);
    } else if (prior_dist_sd_num == 3) {
        sigma_a ~ cauchy(hyper_sd_location, hyper_sd_scale);
        sigma_alpha ~ cauchy(hyper_sd_location, hyper_sd_scale);
    } else if (prior_dist_sd_num == 4) {
        sigma_a ~ double_exponential(hyper_sd_location, hyper_sd_scale);
        sigma_alpha ~ double_exponential(hyper_sd_location, hyper_sd_scale);
    }

    beta ~ normal(0, 2.5);
    sigma_y ~ normal(0, 2.5);

    // Likelihood
    for (n in 1:N) {
        int rank_time = instants_rank[n];  // Time index for the current match
        diff_y[n] ~ student_t(
            nu,
            ability[rank_time, team1[n]] - ability[rank_time, team2[n]],
            sigma_y
        );
    }
}
generated quantities {
    vector[N] diff_y_rep;        // Replicated differences for posterior predictive checks
    vector[N] log_lik;           // Log-likelihood for model comparison
    vector[N_prev] diff_y_prev;  // Predicted differences for future matches

    for (n in 1:N) {
        int rank_time = instants_rank[n];
        diff_y_rep[n] = student_t_rng(
            nu,
            ability[rank_time, team1[n]] - ability[rank_time, team2[n]],
            sigma_y
        );
        log_lik[n] = student_t_lpdf(
            diff_y[n] | nu,
            ability[rank_time, team1[n]] - ability[rank_time, team2[n]],
            sigma_y
        );
    }

    for (n in 1:N_prev) {
        diff_y_prev[n] = student_t_rng(
            nu,
            ability[instants_rank[N], team1_prev[n]] - ability[instants_rank[N], team2_prev[n]],
            sigma_y
        );
    }
}
