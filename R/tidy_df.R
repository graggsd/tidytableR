#' Generate a data.frame using a ggplot2-like interface
#'
#' Builds a \code{data.frame} by mapping columns from the input data, \code{x},
#' to elements of an \code{htmlTable} (e.g. rnames, header, etc.).
#'
#' The \code{tidy_df} function is designed to work like ggplot2 in that
#' columns from \code{x} are mapped to specific parameters from the
#' \code{htmlTable} function in the \code{htmlTable} package, similar
#' to \code{tidy_htmlTable}. However, instead of outputting html code,
#' \code{tidy_df} constructs a \code{data.frame}, making
#' it easier to export output to a \code{.csv} or other tabular file.
#'
#' @inheritParams tidy_htmlTable
#' @param collapse Character used to separate combinations of cgroups and
#' rnames/rgroups/tspanners. If set to \code{NULL}, then row and column names
#' will be expanded to into extra rows and columns on the upper and left borders
#' of the table respectively.
#' @return Returns a \code{data.frame}
#' @export
#' @seealso \code{\link{tidy_htmlTable}}
#' @seealso \code{\link[htmlTable]{htmlTable}}
#' @examples
#' \dontrun{
#' library(tidyverse)
#' mtcars %>%
#'     rownames_to_column %>%
#'     select(rowname, cyl, gear, hp, mpg, qsec) %>%
#'     gather(per_metric, value, hp, mpg, qsec) %>%
#'     group_by(cyl, gear, per_metric) %>%
#'     summarise(Mean = round(mean(value), 1),
#'               SD = round(sd(value), 1),
#'               Min = round(min(value), 1),
#'               Max = round(max(value), 1)) %>%
#'      gather(summary_stat, value, Mean, SD, Min, Max) %>%
#'      ungroup %>%
#'      mutate(gear = paste(gear, "Gears"),
#'             cyl = paste(cyl, "Cylinders")) %>%
#'      tidy_df(header = "gear",
#'             cgroup1 = "cyl",
#'             cell_value = "value",
#'             rnames = "summary_stat",
#'             rgroup = "per_metric")
#' }
tidy_df <-
    function(x,
             value = "value",
             header = "header",
             rnames = "rnames",
             rgroup = NULL,
             cgroup1 = NULL,
             cgroup2 = NULL,
             tspanner = NULL,
             hidden_rgroup = NULL,
             hidden_cgroup1 = NULL,
             hidden_cgroup2 = NULL,
             hidden_tspanner = NULL,
             collapse = NULL,
             ...) {
        UseMethod("tidy_df")
    }

#' @export
tidy_df.default <- function(x, ...) {
    stop("x must be of class data.frame")
}

#' @export
tidy_df.data.frame <-
    function(x,
             value = "value",
             header = "header",
             rnames = "rnames",
             rgroup = NULL,
             cgroup1 = NULL,
             cgroup2 = NULL,
             tspanner = NULL,
             hidden_rgroup = NULL,
             hidden_cgroup1 = NULL,
             hidden_cgroup2 = NULL,
             hidden_tspanner = NULL,
             collapse = NULL,
             ...) {

        skeleton <-
            table_formatter(x,
                            value = value,
                            header = header,
                            rnames = rnames,
                            rgroup = rgroup,
                            cgroup1 = cgroup1,
                            cgroup2 = cgroup2,
                            tspanner = tspanner,
                            hidden_rgroup = hidden_rgroup,
                            hidden_cgroup1 = hidden_cgroup1,
                            hidden_cgroup2 = hidden_cgroup2,
                            hidden_tspanner = hidden_tspanner,
                            ...)

        row_ref <- skeleton$row_ref_tbl %>%
            dplyr::select(-"r_idx")

        row_ref_name <- skeleton$row_ref_tbl %>%
            dplyr::select(-"r_idx") %>%
            colnames

        col_ref <- skeleton$col_ref_tbl %>%
            dplyr::select(-"c_idx")

        df <- skeleton$formatted_df

        if (!is.null(collapse)) {

            row_ref <- row_ref %>%
                apply(1, paste, collapse = collapse)

            row_ref_name <- row_ref_name %>%
                paste(collapse = collapse)

            col_ref <- col_ref %>%
                apply(1, paste, collapse = collapse)
            colnames(df) <- col_ref

            df <- data.frame(row_ref, df, stringsAsFactors = FALSE)
            colnames(df)[1] <- row_ref_name
            return(df)

        } else {

            col_ref <- data.frame(col_ref %>% t,
                                  stringsAsFactors = FALSE)
            colnames(col_ref) <- 1:ncol(col_ref)
            df <- rbind(col_ref, df)

            N_cells <- length(row_ref_name) * nrow(col_ref)
            empty_block <- data.frame(matrix(rep("", N_cells),
                                             nrow = nrow(col_ref)),
                                      stringsAsFactors = FALSE)
            colnames(empty_block) <- row_ref_name

            row_ref <- rbind(empty_block, row_ref)
            return(cbind(row_ref, df))
        }
    }
