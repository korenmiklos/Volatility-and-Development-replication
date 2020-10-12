# Volatility-and-Development-replication
Replication package for 
> Koren, Miklós, and Silvana Tenreyro, 2007. “Volatility and Development.” Quarterly Journal of Economics. 122(1), pp. 243-287.

Please cite the above paper when using this code or data. All code (`*.do`) is licensed under the [3-clause BSD license](https://opensource.org/licenses/BSD-3-Clause). Derived data (`data/derived/`) are licensed under the [Open Database License 1.0](https://opendatacommons.org/licenses/odbl/1-0/). Please respect the original licenses of raw datasets, provided here for your convenience, as specified below.


## Data Availability and Provenance Statements
This research is based on publicly available data, reproduced in this repository. 

INDSTAT2 was downloaded from UNIDO (UNIDO 2002). Central European University has purchased ["secondary dissemination" license](https://stat.unido.org/content/legal/Terms%20and%20Conditions), which permits us to share large portions of the data for replication purposes. 

World Development Indicators (World Bank 2003) is available with a [Creative Commons License](https://data.worldbank.org/summary-terms-of-use).

[Penn World Table 6.1](https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt-6.1) (Heston, Summers and Aten 2002) does not provide an explicit license, but more recent versions are licensed under Creative Commons.

## Dataset list

Data file | Source | Notes | Provided
|--|--|--|--|
| `data/unido/*.dta` | UNIDO (2002) | Converted to Stata format | Yes
| `data/wdi/wdinew.dta` | World Bank (2003) | Converted to Stata format | Yes
| `data/pwt/*.dta` | Heston et al (2002) | Converted to Stata format | Yes
| `data/derived/*.dta` | Own calculations | | Yes


## Computational Requirements
### Software Requirements
* Stata (last run with version 16.0)
* GNU Make (optional)

### Memory and Runtime Requirements
The code was lust run on a 4-core Mac with 8GB RAM. Computation took a few minutes.

## Description of programs
The `Makefile` shows the order in which programs should be run and the dependency among them. 

* The program `meanreturns.do` loads all the data and creates sector-country-year level shares and productivity shocks. These are saved in the folder `data/derived/`.
* The program `preparefactors.do` extracts the latent factors from productivity shocks. These are saved under `data/derived/allfactors.dta`.
* The program `specmeasures.do` computes the risk measures as explained in the article. These are saved in `data/derived/specmeasures.dta`.
* The program `createallgraphs.do` creates all panels in Figure IIa, IIb and III of the article. These are saved in `graphs/` in .eps format.
* The program `drawgraphs.do` is an auxiliary program to create lowess figures with logged dependent variables. It is called by `createallgraphs.do`.

## Instructions to Replicators
If you have GNU Make on your system, type `make` in the folder containing the `Makefile`. This assumes that yout Stata can be called from the shell by typing `stata`. If not, edit the `Makefile` accordingly.

If you do not have GNU Make, call the .do files directly from Stata as follows.
```
cd <path to replication folder>
do meanreturns.do
do preparefactors.do
do specmeasures.do
do createallgraphs.do
```

## List of Tables and Figures

| Figure/Table #    | Program                  | Line Number | Output file                      | Note                            |
|-------------------|--------------------------|-------------|----------------------------------|---------------------------------|
| Figure IIa (top left) | `createallgraphs.do`  |  28 | `lowess_Sectoral_Risk_loggdp.eps` ||
| Figure IIa (top right) | `createallgraphs.do`  |  28 | `within_Sectoral_Risk_loggdp.eps` ||
| Figure IIa (bottom left) | `createallgraphs.do`  |  28 | `lowess_Idiosyncratic_Risk_loggdp.eps` ||
| Figure IIa (bottom right) | `createallgraphs.do`  |  28 | `within_Idiosyncratic_Risk_loggdp.eps` ||
| Figure IIb (top left) | `createallgraphs.do`  |  28 | `lowess_Sector_Country_Covariance_loggdp.eps` ||
| Figure IIb (top right) | `createallgraphs.do`  |  28 | `within_Sector_Country_Covariance_loggdp.eps` ||
| Figure IIb (bottom) | `createallgraphs.do`  |  38 | `lowess_Country_Risk_loggdp.eps` ||
| Figure III (top left) | `createallgraphs.do`  |  28 | `lowess_Herfindahl_loggdp.eps` ||
| Figure III (top right) | `createallgraphs.do`  |  28 | `within_Herfindahl_loggdp.eps` ||
| Figure III (bottom left) | `createallgraphs.do`  |  28 | `lowess_Average_Variance_loggdp.eps` ||
| Figure III (bottom right) | `createallgraphs.do`  |  28 | `within_Average_Variance_loggdp.eps` ||

## References
* Koren, Miklós, and Silvana Tenreyro, 2007. “Volatility and Development.” Quarterly Journal of Economics. 122(1), pp. 243-287. https://zenodo.org/record/1441497
* UNIDO, 2002. INDSTAT 2 Industrial Statistics Database at 2-digit level of ISIC Revision 3 [dataset]. Vienna. Available from http://stat.unido.org.
* World Bank, 2003. World Development Indicators [dataset]. Downloaded 2003-07-14. http://datatopics.worldbank.org/world-development-indicators/
* Heston, A., R. Summers, and B. Aten, 2002. Penn World Table Version 6.1 [dataset], Center for International Comparisons at the University of Pennsylvania (CICUP). https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt-6.1