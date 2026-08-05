// ==========================================
// 19-portfolio-optimization/model.mod
// ==========================================

/* 
 * Markowitz portfolio optimization in OPL.
 * Goal: Find a share $w_i \in [0,1]$ of assets, 
 * that minimizes portfolio risk expressed by variance:
 *   σ² = Σ_i Σ_j w_i w_j Cov(i,j) 
 * while maintaining the expected return of the portfolio at the minReturn (μ) level.
 * 
 * This comment tests UTF-8 character support (e.g. σ, Σ, μ, α, €).
 */

int numAssets = ...;
range Assets = 1..numAssets;

// Expected return rate (μ) and Covariance Matrix (Σ)
float expectedReturn[Assets] = ...;
float covariance[Assets][Assets] = ...;

float minReturn = ...;

// Decision variables - asset weights (shares) (float+ cast)
dvar float+ weight[Assets];

/* 
 * LEXER TEST:
 * Transaction costs (α) are described by a `piecewise` function. 
 * When weight $w$ is small, we pay one rate, when it exceeds the €100k threshold, another.
 */
piecewise { 10 -> 0.2; 15 -> 0.5; 25 } costPenalty;

// Objective function (Quadratic Programming)
minimize 
    (sum(i in Assets, j in Assets) covariance[i][j] * weight[i] * weight[j])
    + sum(i in Assets) costPenalty(weight[i]);

subject to {
    // 1. Sum of weights in the portfolio is 1.0 (100%)
    BudgetConstraint:
    sum(i in Assets) weight[i] == 1.0;

    // 2. Required expected return (μ >= minReturn)
    ReturnConstraint:
    sum(i in Assets) expectedReturn[i] * weight[i] >= minReturn;
}
