
[![Travis build
status](https://travis-ci.org/ITSLeeds/stats19.svg?branch=master)](https://travis-ci.org/ITSLeeds/stats19)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# stats19

The goal of **stats19** is to make it easy to work with road crash data.
Specifically it enables access to and processing of the UK’s official
road traffic casualty database, which is called
[STATS19](https://data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data).
The name comes from the form used by the police to record car crashes
and other incidents resulting in casualties on the
roads.

<!-- A description of the stats19 data and variables they contain can be found at: http://data.dft.gov.uk/road-accidents-safety-data/Brief-guide-to%20road-accidents-and-safety-data.doc. -->

The package builds on previous work including:

  - code in the [bikeR](https://github.com/Robinlovelace/bikeR) repo
    underlying an academic paper on collisions involving cyclists
    (Lovelace, Roberts, and Kellar 2016)
  - functions in
    [**stplanr**](https://github.com/ropensci/stplanr/blob/master/R/load-stats19.R)
    for downloading Stats19 data
  - updated functions related to the
    [CyIPT](https://github.com/cyipt/stats19) project.

## Installation

Install the latest version
with:

``` r
devtools::install_github("ITSLeeds/stats19")
```

<!-- You can install the released version of stats19 from [CRAN](https://CRAN.R-project.org) with: -->

<!-- ``` r -->

<!-- install.packages("stats19") -->

<!-- ``` -->

## Data download

**stats19** enables download of raw stats19 data with `dl_*` functions.
The following code chunk, for example, downloads and unzips a .zip file
containing Stats19 data from 2005 to 2014:

``` r
dl_stats19_2005_2014()
```

Data files from other years can be downloaded with corresponding
functions:

``` r
dl_stats19_2015()
dl_stats19_2016_ac()
dl_stats19_2017_ac()
```

## Reading-in data

Data can be read-in as follows (assuming the data download went OK):

``` r
d14 = "Stats19_Data_2005-2014"
ac_2005_2014 = read_stats19_2005_2014_ac(data_dir = d14)
ac_2005_2014_f = format_stats19_2005_2014_ac(ac_2005_2014)
d15 = "RoadSafetyData_2015"
ac_2015 = read_stats19_2005_2014_ac(data_dir = d15, filename = "Accidents_2015.csv")
ac_2015_f = format_stats19_2015_ac(ac_2015)
d16 = "dftRoadSafety_Accidents_2016"
ac_2016 = read_stats19_2005_2014_ac(data_dir = d16, filename = "dftRoadSafety_Accidents_2016.csv")
ac_2016_f = format_stats19_2016_ac(ac_2016)
d17 = "dftRoadSafetyData_Accidents_2017"
ac_2017 = read_stats19_2005_2014_ac(data_dir = d17, filename = "Acc.csv")
ac_2017_f = format_stats19_2016_ac(ac_2017)
ac = rbind(ac_2015_f, ac_2016_f, ac_2017_f)
table(ac$Accident_Severity)
```

## References

<div id="refs" class="references">

<div id="ref-lovelace_who_2016">

Lovelace, Robin, Hannah Roberts, and Ian Kellar. 2016. “Who, Where,
When: The Demographic and Geographic Distribution of Bicycle Crashes in
West Yorkshire.” *Transportation Research Part F: Traffic Psychology and
Behaviour*, Bicycling and bicycle safety, 41, Part B.
<https://doi.org/10.1016/j.trf.2015.02.010>.

</div>

</div>
