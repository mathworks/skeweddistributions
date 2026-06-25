# Log-gamma Distribution

The **Log-Gamma distribution** is a transformation of the Gamma distribution.
If a random variable

$$
X \sim \text{Gamma}(a, b)
$$

then the transformed variable  

$$
Y = \exp(X)
$$

follows a **Log-Gamma distribution**.

This class implements the Log-Gamma distribution as a subclass of `prob.ToolboxFittableParametricDistribution`, making it compatible
with MATLAB's Statistics and Machine Learning Toolbox.

## Class

```matlab
prob.LoggammaDistribution
```

## Parameters
| Name | Description | Constraint |
|------|-------------|------------|
| a | Shape | $a>0$ |
| b | Scale | $b > 0$ |

## Support

$$x \in \left(1, \infty\right)$$

## Probability Density Function (PDF)
The PDF of the Log-Gamma distribution is given by:

$$
f(x) = \frac{\log(x)^{a-1}}{b^a\Gamma(a)}\frac{1}{x^{1+1/b}}\qquad x>1
$$

## Cumulative Distribution Function (CDF)

The CDF is expressed in terms of the incomplete Gamma function:

$$F(x)=\Gamma\left(a,\frac{\log⁡(x)}{b}\right), \qquad x>1 $$

Internally, the implementation uses gammainc for improved numerical stability.
Both lower and upper tail probabilities are supported.

## Moments
Moments exist only under specific parameter conditions.
### Mean
The mean exists if:
$$
b<1 \qquad 
$$
In that case:
$$\mathbb E\left[X\right]=(1−b)^{−a}$$

Otherwise, the mean is undefined and returned as NaN.

## Variance
The variance exists if:

$$b < \frac{1}{2}$$

In that case:

$$\mathrm{Var}(X) =
(1 - 2b)^{-a} - (\mathbb{E}[X])^2$$

Otherwise, the variance is returned as NaN.

## Construction

Fixed-parameter construction

```matlab
pd = makedist("Loggamma", a, b); 
```
If constructed explicitly:

- Parameters are treated as fixed
- ParameterIsFixed = [true, true]
- ParameterCovariance = 0

## Fitting to Data

The Log-Gamma distribution supports maximum likelihood estimation
using fitdist.

```matlab 
pdHat = fitdist(x, "Loggamma"); 
```

## Example Usage

```matlab
% Create a distribution object
pd = makedist("LogGamma", 2, 0.2);

% Evaluate the PDF
x = linspace(1, 4, 1000);
y = pdf(pd, x);

% Random sampling
r = random(pd, 10000, 1);

% Fit a distribution to data
pdHat = fitdist(r, 'LogGamma');

% plot the fitted results
figure(Color = "w");
histogram(r, 400, Normalization = "pdf")
hold on; 
x = linspace(1, 4, 1000);
y = pdf(pdHat, x);
line(x, y, LineWidth = 2)
xlim([0 4])
title('LogGamma Distribution')
```

## Supported methods

### Distribution Functions
- `pdf`
- `cdf`
- `icdf`
- `random`
- `truncate`

### Statistical Measures
- `mean`
- `median`
- `var`
- `std`
- `iqr`

### Inference
- `fit`
- `paramci`
- `proflik`
- `negloglik`

## Random Number Generation

Random values are generated using inverse transform sampling:
```matlab
r = random(pd, n, 1); 
```

## Notes

- The Log-Gamma distribution is positive with support $x>1$ and right-skewed
- Heavy-tailed behavior can occur depending on parameter values
- Moment existence depends explicitly on the scale parameter b
- Numerical stability is improved using log-density calculations
