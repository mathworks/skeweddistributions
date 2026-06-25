# Split Normal Distribution

The **Split Normal distribution** (also known as the two-piece normal or asymmetric normal)
extends the normal distribution by allowing **different scale parameters on either side of
the mode**. This enables asymmetric behavior while preserving a normal‐like shape on each side.

This class implements the Split Normal distribution as a subclass of `prob.ToolboxFittableParametricDistribution`, making it compatible with MATLAB's
Statistics and Machine Learning Toolbox.

---

## Class
```matlab
prob.SplitNormalDistribution
```
## Parameters
| Name | Description | Constraint |
|------|-------------|------------|
| $\sigma_1$ | Left-side standard deviation | $\sigma_1>0$ |
| $\sigma_2$ | Right-side standard deviation | $\sigma_2>0$ |

- The distribution is symmetric when $\sigma_1 = \sigma_2$.
- Asymmetry arises from unequal left/right spreads.

## Support
$x \in \left(-\infty, \infty\right)$

## Probability Density Function (PDF)
The PDF is defined piecewise as:

$$
f(x) = \left\{\begin{array}{cl}
\frac{\sqrt{2/\pi}}{\sigma_1 + \sigma_2}\exp\!\left(-\frac{(x-\mu)^2}{2\sigma_1^2}\right), & x \le \mu \\
\frac{\sqrt{2/\pi}}{\sigma_1 + \sigma_2}\exp\!\left(-\frac{(x-\mu)^2}{2\sigma_2^2}\right), & x > \mu
\end{array}\right.
$$

## Cumulative Distribution Function (CDF)

The CDF is given by:

$$
F(x) = \left\{\begin{array}{cl}
\frac{2\sigma_1}{\sigma_1+\sigma_2}\Phi\!\left(\frac{x-\mu}{\sigma_1}\right), & x \le \mu \\
1 - \frac{2\sigma_2}{\sigma_1+\sigma_2}\left[1-\Phi\!\left(\frac{x-\mu}{\sigma_2}\right)\right], & x > \mu
\end{array}\right.
$$

where $\Phi$ is the standard normal CDF.

## Moments
Moments exist only under specific parameter conditions.
### Mean

$$\mu + \sqrt{\frac{2}{\pi}}(\sigma_2 - \sigma_1)$$

## Variance

$$
\mathrm{Var}(X) = (1 - \frac{2}{\pi})(\sigma_2 - \sigma_1)^2+ \sigma_1\sigma_2
$$

## Construction

Fixed-parameter construction

```matlab
pd = makedist("SplitNormal", mu, sigma1, sigma2); 
```
If constructed explicitly:

- Parameters are treated as fixed
- ParameterIsFixed = [true, true, true]
- ParameterCovariance = 0

## Fitting to Data

The Split Normal distribution supports maximum likelihood estimation:

```matlab 
pdHat = fitdist(x, "SplitNormal"); 
```

## Example Usage

```matlab
% Create a distribution object
pd = makedist("SplitNormal", 3, 0.5);

% Evaluate the PDF
x = linspace(-5, 5, 200);
y = pdf(pd, x);

% Random sampling
r = random(pd, 10000, 1);

% Fit a distribution to data
pdHat = fitdist(r, 'SplitNormal');

% plot the fitted results
figure(Color = "w");
histogram(r, 100, Normalization = "pdf")
hold on; 
x = linspace(-6, 10, 200);
y = pdf(pdHat, x);
line(x, y, LineWidth = 2)
title('Split Normal Distribution')
```

## Supported Methods

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

- The split normal is unimodal at $\mu$
- Skewness arises solely from unequal scale parameters
- The distribution reduces to a standard normal when $\sigma_1 = \sigma_2$