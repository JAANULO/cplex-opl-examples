# Portfolio Optimization (Markowitz Model)

The classic investment portfolio selection problem, minimizing its variance risk, while maintaining a given minimum rate of return. The model is formulated as a Quadratic Programming (QP) task.

## Mathematical Formulation (QP)

Let $n$ denote the number of assets. We define:
- $w_i$: weight shares in the portfolio (continuous variables, $\sum w_i = 1$)
- $\mu_i$: expected rate of return from asset $i$
- $\Sigma_{i,j}$: covariance matrix between returns of assets $i$ and $j$
- $R_{min}$: minimum required expected rate of return for the entire portfolio

**Objective Function:**
Minimize risk (variance):
$$ \min \sum_{i=1}^n \sum_{j=1}^n \Sigma_{i,j} w_i w_j $$

**Constraints:**
1. Budget equation (all weights sum up to 1):
   $$ \sum_{i=1}^n w_i = 1 $$
2. Profitability requirement:
   $$ \sum_{i=1}^n \mu_i w_i \geq R_{min} $$

The model also includes an additional transaction penalty term approximated as a nonlinear piecewise linear function (*piecewise*).

## Tested Constructs (OPL)
- Quadratic Programming (QP): the parser must correctly bind the multiplication of two variables `weight[i] * weight[j]`.
- Approximation functions `piecewise { ... }`.
- Multi-line comment tokens tests `/* ... */` containing UTF-8 characters (such as $\Sigma, \mu, \sigma$).
- `settings.ops` files configuring the CPLEX engine for MIQP.
