# Skewed & Heavy-Tailed Distributions for MATLAB

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=mathworks/skeweddistributions&project=SkewDistributions.prj&file=tbx/doc/mfiles/GettingStarted.m)
 [![SkewDistributions CI](https://github.com/mathworks/skeweddistributions/actions/workflows/build-and-release.yml/badge.svg)](https://mathworks.github.io/skeweddistributions/results.html) [![coverage](https://img.shields.io/badge/dynamic/xml?url=https://mathworks.github.io/skeweddistributions/coverage.xml&query=round%28//coverage/@line-rate%2A100%29&suffix=%25&label=coverage)](https://mathworks.github.io/skeweddistributions/coverage.html)

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

or run

```matlab
skewdoc 
```

## Installation and setup

### Requirements

- MATLAB&reg; R2022b or newer (recommended)
- Statistics and Machine Learning Toolbox&trade; 
---

1. **Download** the [latest release](https://github.com/mathworks/skeweddistributions/releases/latest/download/skewdists.mltbx), or pick an older version from the [releases page](https://github.com/mathworks/skeweddistributions/releases).

2. **Install** the toolbox by double-clicking `skewdists.mltbx`, or from the MATLAB command window (with the file in your current folder):

   - **R2026b and later:**

    ```matlab
    mpminstall("skewdists.mltbx", Prompt = false)
    ```

   - **Earlier releases:**

    ```matlab
    matlab.addons.install("skewdists.mltbx")
    ```


3. **Register the distributions** with Statistics and Machine Learning Toolbox. Run this once after installing or upgrading:
   ```matlab
   makedist -reset
   ```
   To confirm, run `makedist` with no arguments; the new distributions should appear in the list.

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
|       ├── skewdoc
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