
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/graggsd/tidytableR.svg?branch=master)](https://travis-ci.org/graggsd/tidytableR) [![Build status](https://ci.appveyor.com/api/projects/status/nsalen7ay5tuwpqd/branch/master?svg=true)](https://ci.appveyor.com/project/graggsd/tidytabler/branch/master)

tidytableR
==========

The goal of tidytableR is to is to reshape data from a tidy format into one that is suitable for presentation. Specifically, it works best when used to make complex, publication-quality tables from output created by `dplyr::summarise` or `tidyr::gather`. It allows users to map column names from an input data frame to elements of an output table.

The package was developed from code meant to act as a wrapper script for the `htmlTable` function in the [htmlTable](https://CRAN.R-project.org/package=htmlTable) package. In fact, its first release was as the `tidyHtmlTable` function within the `htmlTable` package. Therefore, many of the variable names and symantics used within are related to those used in the `htmlTable` package.

Installation
------------

You can install tidytableR from github with:

``` r
# install.packages("devtools")
devtools::install_github("graggsd/tidytableR")
```

Examples
--------

``` r
library(tidytableR)
library(magrittr)
library(dplyr)
library(tidyr)
library(tibble)
```

### Prep Data

Turn `mtcars` data into a tidy dataset.

``` r
td <- mtcars %>%
    rownames_to_column %>%
    select(rowname, cyl, gear, hp, mpg, qsec) %>%
    gather(per_metric, value, hp, mpg, qsec)
```

Compute 4 summary statistics for each of the 3 performance metrics, grouped number of cylinders and gears.

``` r
tidy_summary <- td %>%
    group_by(cyl, gear, per_metric) %>% 
    summarise(Mean = round(mean(value), 1),
              SD = round(sd(value), 1),
              Min = round(min(value), 1),
              Max = round(max(value), 1)) %>%
    gather(summary_stat, value, Mean, SD, Min, Max) %>% 
    ungroup %>% 
    mutate(gear = paste(gear, "Gears"),
           cyl = paste(cyl, "Cylinders"))
```

### Output html table

#### Example 1

``` r
tidy_summary  %>% 
    tidy_htmlTable(header = "gear",
                   cgroup1 = "cyl",
                   cell_value = "value", 
                   rnames = "summary_stat",
                   rgroup = "per_metric")
```

<table class="gmisc_table" style="border-collapse: collapse; margin-top: 1em; margin-bottom: 1em;">
<thead>
<tr>
<th style="border-top: 2px solid grey;">
</th>
<th colspan="3" style="font-weight: 900; border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;">
4 Cylinders
</th>
<th style="border-top: 2px solid grey;; border-bottom: hidden;">
 
</th>
<th colspan="3" style="font-weight: 900; border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;">
6 Cylinders
</th>
<th style="border-top: 2px solid grey;; border-bottom: hidden;">
 
</th>
<th colspan="2" style="font-weight: 900; border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;">
8 Cylinders
</th>
</tr>
<tr>
<th style="border-bottom: 1px solid grey;">
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
3 Gears
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
4 Gears
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
5 Gears
</th>
<th style="border-bottom: 1px solid grey;" colspan="1">
 
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
3 Gears
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
4 Gears
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
5 Gears
</th>
<th style="border-bottom: 1px solid grey;" colspan="1">
 
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
3 Gears
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
5 Gears
</th>
</tr>
</thead>
<tbody>
<tr>
<td colspan="11" style="font-weight: 900;">
hp
</td>
</tr>
<tr>
<td style="text-align: left;">
  Max
</td>
<td style="text-align: center;">
97
</td>
<td style="text-align: center;">
109
</td>
<td style="text-align: center;">
113
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
110
</td>
<td style="text-align: center;">
123
</td>
<td style="text-align: center;">
175
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
245
</td>
<td style="text-align: center;">
335
</td>
</tr>
<tr>
<td style="text-align: left;">
  Mean
</td>
<td style="text-align: center;">
97
</td>
<td style="text-align: center;">
76
</td>
<td style="text-align: center;">
102
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
107.5
</td>
<td style="text-align: center;">
116.5
</td>
<td style="text-align: center;">
175
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
194.2
</td>
<td style="text-align: center;">
299.5
</td>
</tr>
<tr>
<td style="text-align: left;">
  Min
</td>
<td style="text-align: center;">
97
</td>
<td style="text-align: center;">
52
</td>
<td style="text-align: center;">
91
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
105
</td>
<td style="text-align: center;">
110
</td>
<td style="text-align: center;">
175
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
150
</td>
<td style="text-align: center;">
264
</td>
</tr>
<tr>
<td style="text-align: left;">
  SD
</td>
<td style="text-align: center;">
NaN
</td>
<td style="text-align: center;">
20.1
</td>
<td style="text-align: center;">
15.6
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
3.5
</td>
<td style="text-align: center;">
7.5
</td>
<td style="text-align: center;">
NaN
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
33.4
</td>
<td style="text-align: center;">
50.2
</td>
</tr>
<tr>
<td colspan="11" style="font-weight: 900;">
mpg
</td>
</tr>
<tr>
<td style="text-align: left;">
  Max
</td>
<td style="text-align: center;">
21.5
</td>
<td style="text-align: center;">
33.9
</td>
<td style="text-align: center;">
30.4
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
21.4
</td>
<td style="text-align: center;">
21
</td>
<td style="text-align: center;">
19.7
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
19.2
</td>
<td style="text-align: center;">
15.8
</td>
</tr>
<tr>
<td style="text-align: left;">
  Mean
</td>
<td style="text-align: center;">
21.5
</td>
<td style="text-align: center;">
26.9
</td>
<td style="text-align: center;">
28.2
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
19.8
</td>
<td style="text-align: center;">
19.8
</td>
<td style="text-align: center;">
19.7
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
15.1
</td>
<td style="text-align: center;">
15.4
</td>
</tr>
<tr>
<td style="text-align: left;">
  Min
</td>
<td style="text-align: center;">
21.5
</td>
<td style="text-align: center;">
21.4
</td>
<td style="text-align: center;">
26
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
18.1
</td>
<td style="text-align: center;">
17.8
</td>
<td style="text-align: center;">
19.7
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
10.4
</td>
<td style="text-align: center;">
15
</td>
</tr>
<tr>
<td style="text-align: left;">
  SD
</td>
<td style="text-align: center;">
NaN
</td>
<td style="text-align: center;">
4.8
</td>
<td style="text-align: center;">
3.1
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
2.3
</td>
<td style="text-align: center;">
1.6
</td>
<td style="text-align: center;">
NaN
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
2.8
</td>
<td style="text-align: center;">
0.6
</td>
</tr>
<tr>
<td colspan="11" style="font-weight: 900;">
qsec
</td>
</tr>
<tr>
<td style="text-align: left;">
  Max
</td>
<td style="text-align: center;">
20
</td>
<td style="text-align: center;">
22.9
</td>
<td style="text-align: center;">
16.9
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
20.2
</td>
<td style="text-align: center;">
18.9
</td>
<td style="text-align: center;">
15.5
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
18
</td>
<td style="text-align: center;">
14.6
</td>
</tr>
<tr>
<td style="text-align: left;">
  Mean
</td>
<td style="text-align: center;">
20
</td>
<td style="text-align: center;">
19.6
</td>
<td style="text-align: center;">
16.8
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
19.8
</td>
<td style="text-align: center;">
17.7
</td>
<td style="text-align: center;">
15.5
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
17.1
</td>
<td style="text-align: center;">
14.6
</td>
</tr>
<tr>
<td style="text-align: left;">
  Min
</td>
<td style="text-align: center;">
20
</td>
<td style="text-align: center;">
18.5
</td>
<td style="text-align: center;">
16.7
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
19.4
</td>
<td style="text-align: center;">
16.5
</td>
<td style="text-align: center;">
15.5
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
15.4
</td>
<td style="text-align: center;">
14.5
</td>
</tr>
<tr>
<td style="border-bottom: 2px solid grey; text-align: left;">
  SD
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
NaN
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
1.5
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
0.1
</td>
<td style="border-bottom: 2px solid grey;" colspan="1">
 
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
0.6
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
1.1
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
NaN
</td>
<td style="border-bottom: 2px solid grey;" colspan="1">
 
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
0.8
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
0.1
</td>
</tr>
</tbody>
</table>
#### Example 2

``` r
tidy_summary  %>% 
    tidy_htmlTable(header = "summary_stat",
                   cgroup1 = "per_metric",
                   cell_value = "value", 
                   rnames = "gear",
                   rgroup = "cyl")
```

<table class="gmisc_table" style="border-collapse: collapse; margin-top: 1em; margin-bottom: 1em;">
<thead>
<tr>
<th style="border-top: 2px solid grey;">
</th>
<th colspan="4" style="font-weight: 900; border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;">
hp
</th>
<th style="border-top: 2px solid grey;; border-bottom: hidden;">
 
</th>
<th colspan="4" style="font-weight: 900; border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;">
mpg
</th>
<th style="border-top: 2px solid grey;; border-bottom: hidden;">
 
</th>
<th colspan="4" style="font-weight: 900; border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;">
qsec
</th>
</tr>
<tr>
<th style="border-bottom: 1px solid grey;">
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
Max
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
Mean
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
Min
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
SD
</th>
<th style="border-bottom: 1px solid grey;" colspan="1">
 
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
Max
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
Mean
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
Min
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
SD
</th>
<th style="border-bottom: 1px solid grey;" colspan="1">
 
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
Max
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
Mean
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
Min
</th>
<th style="border-bottom: 1px solid grey; text-align: center;">
SD
</th>
</tr>
</thead>
<tbody>
<tr>
<td colspan="15" style="font-weight: 900;">
4 Cylinders
</td>
</tr>
<tr>
<td style="text-align: left;">
  3 Gears
</td>
<td style="text-align: center;">
97
</td>
<td style="text-align: center;">
97
</td>
<td style="text-align: center;">
97
</td>
<td style="text-align: center;">
NaN
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
21.5
</td>
<td style="text-align: center;">
21.5
</td>
<td style="text-align: center;">
21.5
</td>
<td style="text-align: center;">
NaN
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
20
</td>
<td style="text-align: center;">
20
</td>
<td style="text-align: center;">
20
</td>
<td style="text-align: center;">
NaN
</td>
</tr>
<tr>
<td style="text-align: left;">
  4 Gears
</td>
<td style="text-align: center;">
109
</td>
<td style="text-align: center;">
76
</td>
<td style="text-align: center;">
52
</td>
<td style="text-align: center;">
20.1
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
33.9
</td>
<td style="text-align: center;">
26.9
</td>
<td style="text-align: center;">
21.4
</td>
<td style="text-align: center;">
4.8
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
22.9
</td>
<td style="text-align: center;">
19.6
</td>
<td style="text-align: center;">
18.5
</td>
<td style="text-align: center;">
1.5
</td>
</tr>
<tr>
<td style="text-align: left;">
  5 Gears
</td>
<td style="text-align: center;">
113
</td>
<td style="text-align: center;">
102
</td>
<td style="text-align: center;">
91
</td>
<td style="text-align: center;">
15.6
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
30.4
</td>
<td style="text-align: center;">
28.2
</td>
<td style="text-align: center;">
26
</td>
<td style="text-align: center;">
3.1
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
16.9
</td>
<td style="text-align: center;">
16.8
</td>
<td style="text-align: center;">
16.7
</td>
<td style="text-align: center;">
0.1
</td>
</tr>
<tr>
<td colspan="15" style="font-weight: 900;">
6 Cylinders
</td>
</tr>
<tr>
<td style="text-align: left;">
  3 Gears
</td>
<td style="text-align: center;">
110
</td>
<td style="text-align: center;">
107.5
</td>
<td style="text-align: center;">
105
</td>
<td style="text-align: center;">
3.5
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
21.4
</td>
<td style="text-align: center;">
19.8
</td>
<td style="text-align: center;">
18.1
</td>
<td style="text-align: center;">
2.3
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
20.2
</td>
<td style="text-align: center;">
19.8
</td>
<td style="text-align: center;">
19.4
</td>
<td style="text-align: center;">
0.6
</td>
</tr>
<tr>
<td style="text-align: left;">
  4 Gears
</td>
<td style="text-align: center;">
123
</td>
<td style="text-align: center;">
116.5
</td>
<td style="text-align: center;">
110
</td>
<td style="text-align: center;">
7.5
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
21
</td>
<td style="text-align: center;">
19.8
</td>
<td style="text-align: center;">
17.8
</td>
<td style="text-align: center;">
1.6
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
18.9
</td>
<td style="text-align: center;">
17.7
</td>
<td style="text-align: center;">
16.5
</td>
<td style="text-align: center;">
1.1
</td>
</tr>
<tr>
<td style="text-align: left;">
  5 Gears
</td>
<td style="text-align: center;">
175
</td>
<td style="text-align: center;">
175
</td>
<td style="text-align: center;">
175
</td>
<td style="text-align: center;">
NaN
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
19.7
</td>
<td style="text-align: center;">
19.7
</td>
<td style="text-align: center;">
19.7
</td>
<td style="text-align: center;">
NaN
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
15.5
</td>
<td style="text-align: center;">
15.5
</td>
<td style="text-align: center;">
15.5
</td>
<td style="text-align: center;">
NaN
</td>
</tr>
<tr>
<td colspan="15" style="font-weight: 900;">
8 Cylinders
</td>
</tr>
<tr>
<td style="text-align: left;">
  3 Gears
</td>
<td style="text-align: center;">
245
</td>
<td style="text-align: center;">
194.2
</td>
<td style="text-align: center;">
150
</td>
<td style="text-align: center;">
33.4
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
19.2
</td>
<td style="text-align: center;">
15.1
</td>
<td style="text-align: center;">
10.4
</td>
<td style="text-align: center;">
2.8
</td>
<td style colspan="1">
 
</td>
<td style="text-align: center;">
18
</td>
<td style="text-align: center;">
17.1
</td>
<td style="text-align: center;">
15.4
</td>
<td style="text-align: center;">
0.8
</td>
</tr>
<tr>
<td style="border-bottom: 2px solid grey; text-align: left;">
  5 Gears
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
335
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
299.5
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
264
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
50.2
</td>
<td style="border-bottom: 2px solid grey;" colspan="1">
 
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
15.8
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
15.4
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
15
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
0.6
</td>
<td style="border-bottom: 2px solid grey;" colspan="1">
 
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
14.6
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
14.6
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
14.5
</td>
<td style="border-bottom: 2px solid grey; text-align: center;">
0.1
</td>
</tr>
</tbody>
</table>
