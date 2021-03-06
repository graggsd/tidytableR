% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tidy_df.R
\name{tidy_df}
\alias{tidy_df}
\title{Generate a data.frame using a ggplot2-like interface}
\usage{
tidy_df(x, value = "value", header = "header", rnames = "rnames",
  rgroup = NULL, cgroup1 = NULL, cgroup2 = NULL, tspanner = NULL,
  hidden_rgroup = NULL, hidden_cgroup1 = NULL, hidden_cgroup2 = NULL,
  hidden_tspanner = NULL, collapse = NULL, ...)
}
\arguments{
\item{x}{A tidy \code{data.frame}}

\item{value}{Column in \code{x} specifying values used to populate
individual cells of the output table}

\item{header}{Column in \code{x} specifying column headings}

\item{rnames}{Column in \code{x} specifying row names}

\item{rgroup}{Column in \code{x} specifying row groups}

\item{cgroup1}{Column in \code{x} specifying the inner most column
groups}

\item{cgroup2}{Column in \code{x} specifying the outer most column
groups}

\item{tspanner}{Column in \code{x} specifying tspanner groups}

\item{hidden_rgroup}{rgroup values that will be hidden.}

\item{hidden_cgroup1}{cgroup1 values that will be hidden.}

\item{hidden_cgroup2}{cgroup2 values that will be hidden.}

\item{hidden_tspanner}{tspanner values that will be hidden.}

\item{collapse}{Character used to separate combinations of cgroups and
rnames/rgroups/tspanners. If set to \code{NULL}, then row and column names
will be expanded to into extra rows and columns on the upper and left borders
of the table respectively.}

\item{...}{Additional arguments that will be passed to the inner
\code{htmlTable} function}
}
\value{
Returns a \code{data.frame}
}
\description{
Builds a \code{data.frame} by mapping columns from the input data, \code{x},
to elements of an \code{htmlTable} (e.g. rnames, header, etc.).
}
\details{
The \code{tidy_df} function is designed to work like ggplot2 in that
columns from \code{x} are mapped to specific parameters from the
\code{htmlTable} function in the \code{htmlTable} package, similar
to \code{tidy_htmlTable}. However, instead of outputting html code,
\code{tidy_df} constructs a \code{data.frame}, making
it easier to export output to a \code{.csv} or other tabular file.
}
\examples{
\dontrun{
library(tidyverse)
mtcars \%>\%
    rownames_to_column \%>\%
    select(rowname, cyl, gear, hp, mpg, qsec) \%>\%
    gather(per_metric, value, hp, mpg, qsec) \%>\%
    group_by(cyl, gear, per_metric) \%>\%
    summarise(Mean = round(mean(value), 1),
              SD = round(sd(value), 1),
              Min = round(min(value), 1),
              Max = round(max(value), 1)) \%>\%
     gather(summary_stat, value, Mean, SD, Min, Max) \%>\%
     ungroup \%>\%
     mutate(gear = paste(gear, "Gears"),
            cyl = paste(cyl, "Cylinders")) \%>\%
     tidy_df(header = "gear",
            cgroup1 = "cyl",
            cell_value = "value",
            rnames = "summary_stat",
            rgroup = "per_metric")
}
}
\seealso{
\code{\link{tidy_htmlTable}}

\code{\link[htmlTable]{htmlTable}}
}
