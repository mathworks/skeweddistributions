# Skewed & Heavy-Tailed Distributions for MATLAB

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=mathworks/skeweddistributions&project=SkewDistributions.prj&file=tbx\doc\mfiles\GettingStarted.m)
 [![SkewDistributions CI](https://github.com/mathworks/skeweddistributions/actions/workflows/build-and-release.yml/badge.svg)](https://github.com/mathworks/skeweddistributions/actions/workflows/build-and-release.yml)

Skewed and heavy-tailed parametric distributions are widely used to model asymmetric data and tail-risk behaviour, particularly in applications such as modeling asset returns, and are commonly employed in Bayesian statistical frameworks. This repository brings together these and related parametric distributions in a consistent, MATLAB-compatible framework for the wider statistics community.

Each distribution is designed to:

- Integrate seamlessly with **Statistics and Machine Learning Toolbox&trade;**
- Support **PDF, CDF, ICDF, random generation**, and **fitting**
- Be usable with standard **MATLAB&reg;** functions such as:
  - `makedist`
  - `fitdist`
  - `random`
  - `cdf`, `pdf`, `icdf`
  - `mean`, `var`, `std`

The repository focuses on **clarity**, **numerical stability**, and
**compatibility** with MATLAB's distribution framework. For detailed documentation please visit:

[Documentation](./tbx/doc/index.md)

## Installation and setup

### Requirements

- MATLAB&reg; R2022b or newer (recommended)
- Statistics and Machine Learning Toolbox&trade; 
---

Get the latest version of the toolbox from releases. 

Install by double-clicking on the file or:

```matlab
matlab.addons.install("skewdists.mltbx") 
```

Once installed, run (once) the command below to refresh the Statistics and Machine Learning Toolbox with the new options:

```matlab
makedist -reset 
```

## Implemented Distributions

| Distribution | Class Name |
|-------------|------------|
| Epsilon-Skew-Normal | `EpsilonSkewNormalDistribution` |
| Inverse-Gamma | `InverseGammaDistribution` |
| Log-Gamma | `LoggammaDistribution` |
| Skew-Normal | `SkewNormalDistribution` |
| Split-Normal | `SplitNormalDistribution` |
| Skew-t | `SkewTDistribution` |

---

## Example Usage

```matlab
% Create a distribution object
pd = makedist("SkewNormal", 0, 1, 5);

% Evaluate the PDF
x = linspace(-5, 5, 200);
y = pdf(pd, x);

% Random sampling
r = random(pd, 10000, 1);

% Fit a distribution to data
pdHat = fitdist(r, 'skewnormal');

% plot the fitted results
figure(Color = "w");
histogram(r, 100, Normalization = "pdf")
hold on; 
x = linspace(-1, 5, 200);
y = pdf(pdHat, x);
line(x, y, LineWidth = 2)
```

![FitResults](/tbx/doc/media/Fig1.png "Fit Results")

## Repository Structure

```text

├── README.md
├── SECURITY.md
├── License.txt
├── buildfile.m
├── tbx
│   ├── skewdist
│       ├── +prob
│           ├── EpsilonSkewNormalDistribution.m
│           ├── InverseGammaDistribution.m
│           ├── LoggammaDistribution.m
│           ├── SkewNormalDistribution.m
│           ├── SplitNormalDistribution.m
│           └── SkewTDistribution.m
│   ├── doc
│      ├── EpsilonSkewNormalDistribution.md
│      ├── InverseGammaDistribution.md
│      ├── LoggammaDistribution.md
│      ├── SkewNormalDistribution.md
│      ├── SplitNormalDistribution.md
│      └── SkewTDistribution.md
```

- `tbx/skewdist/+prob/*.m` files contain the distribution class implementations.
- `tbx/doc/` contains **one Markdown file per distribution**, documenting:
  - Mathematical definition
  - Parameters and constraints
  - Supported methods
  - Usage examples
  - Implementation notes

## Contributing

Each new distribution should include:

1. A `.m` class file implementing the distribution
2. A corresponding documentation file in `tbx/doc/`
3. Full support for `pdf`, `cdf`, `icdf`, `mean`, `var`, `std`, `fitdist`, `makedist`