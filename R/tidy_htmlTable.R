#' Generate an htmlTable using a ggplot2-like interface
#'
#' Builds an \code{htmlTable} by mapping columns from the input data, \code{x},
#' to elements of an output \code{htmlTable} (e.g. rnames, header, etc.)
#'
#' @section Column-mapping parameters:
#'   The \code{tidy_htmlTable} function is designed to work like ggplot2 in that
#'   columns from \code{x} are mapped to specific parameters from the
#'   \code{htmlTable} function. At minimum, \code{x} must contain the names
#'   of columns mapping to \code{rnames}, \code{header}, and \code{rnames}.
#'   \code{header} and \code{rnames} retain the same meaning as in the
#'   htmlTable function. \code{value} contains the individual values that will
#'   be used to fill each cell within the output \code{htmlTable}.
#'
#'   A full list of parameters from \code{htmlTable} which may be mapped to
#'   columns within \code{x} include:
#'
#'   \itemize{
#'     \item \code{value}
#'     \item \code{header}
#'     \item \code{rnames}
#'     \item \code{rgroup}
#'     \item \code{cgroup1}
#'     \item \code{cgroup2}
#'     \item \code{tspanner}
#'   }
#'
#'   Note that unlike in \code{htmlTable} which contains \code{cgroup},
#'   and which may specify a variable number of column groups,
#'   \code{tidy_htmlTable} contains the parameters \code{cgroup1} and
#'   \code{cgroup2}. These parameters correspond to the inward most and outward
#'   most column groups respectively.
#'
#'   Also note that the coordinates of each \code{value} within \code{x} must be
#'   unambiguously mapped to a position within the output \code{htmlTable}.
#'   Therefore, for each row-wise combination of the variables
#'   contained in \code{x} must be unique.
#'
#' @section Hidden values:
#'   \code{htmlTable} Allows for some values within \code{rgroup},
#'   \code{cgroup}, etc. to be specified as \code{""}. The following parameters
#'   allow for specific values to be treated as if they were a string of length
#'   zero in the \code{htmlTable} function.
#'
#'   \itemize{
#'     \item \code{hidden_rgroup}
#'     \item \code{hidden_cgroup1}
#'     \item \code{hidden_cgroup2}
#'     \item \code{hidden_tspanner}
#'   }
#'
#' @param x A tidy \code{data.frame}
#' @param value Column in \code{x} specifying values used to populate
#' individual cells of the output table
#' @param header Column in \code{x} specifying column headings
#' @param rnames Column in \code{x} specifying row names
#' @param rgroup Column in \code{x} specifying row groups
#' @param cgroup1 Column in \code{x} specifying the inner most column
#'  groups
#' @param cgroup2 Column in \code{x} specifying the outer most column
#'  groups
#' @param tspanner Column in \code{x} specifying tspanner groups
#' @param hidden_rgroup rgroup values that will be hidden.
#' @param hidden_cgroup1 cgroup1 values that will be hidden.
#' @param hidden_cgroup2 cgroup2 values that will be hidden.
#' @param hidden_tspanner tspanner values that will be hidden.
#' @param ... Additional arguments that will be passed to the inner
#' \code{htmlTable} function
#' @return Returns html code that will build a pretty table
#' @export
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
#'      tidy_htmlTable(header = "gear",
#'                   cgroup1 = "cyl",
#'                   cell_value = "value",
#'                   rnames = "summary_stat",
#'                   rgroup = "per_metric")
#' }
tidy_htmlTable <- function(x,
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
                          ...) {
    UseMethod("tidy_htmlTable")
}

#' @export
tidy_htmlTable.default <- function(x, ...) {
    stop("x must be of class data.frame")
}

#' @export
tidy_htmlTable.data.frame <- function(x,
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

    row_ref_tbl <- skeleton$row_ref_tbl
    col_ref_tbl <- skeleton$col_ref_tbl
    formatted_df <- skeleton$formatted_df

    # Get names and indices for row groups and tspanners
    htmlTable_args <- list(x = formatted_df,
                           rnames = row_ref_tbl %>% dplyr::pull(rnames),
                           header = col_ref_tbl %>% dplyr::pull(header),
                           ...)

    if (!is.null(rgroup)) {

        # This will take care of a problem in which adjacent row groups
        # with the same value will cause rgroup and tspanner collision
        comp_val <- row_ref_tbl %>% dplyr::pull(rgroup)

        if (!is.null(tspanner)) {
            comp_val <- paste0(comp_val,
                               row_ref_tbl %>% dplyr::pull(tspanner))
        }

        lens <- rle(comp_val)$lengths
        idx <- cumsum(lens)

        htmlTable_args$rgroup <- row_ref_tbl %>%
            dplyr::slice(idx) %>%
            dplyr::pull(rgroup)

        htmlTable_args$n.rgroup <- lens
    }

    if (!is.null(tspanner)) {
        htmlTable_args$tspanner <-
            rle(row_ref_tbl %>% dplyr::pull(tspanner))$value
        htmlTable_args$n.tspanner <-
            rle(row_ref_tbl %>% dplyr::pull(tspanner))$lengths
    }

    # Get names and indices for column groups
    if(!is.null(cgroup1)) {
        cgroup1_out <- rle(col_ref_tbl %>% dplyr::pull(cgroup1))$value
        n.cgroup1 <- rle(col_ref_tbl %>% dplyr::pull(cgroup1))$lengths
        if(!is.null(cgroup2)) {
            cgroup2_out <- rle(col_ref_tbl %>% dplyr::pull(cgroup2))$value
            n.cgroup2 <- rle(col_ref_tbl %>% dplyr::pull(cgroup2))$lengths
            len_diff <- length(cgroup1_out) - length(cgroup2_out)
            if (len_diff < 0) {
                stop("cgroup2 cannot contain more categories than cgroup1")
            } else if (len_diff > 0) {
                cgroup2_out <- c(cgroup2_out, rep(NA, len_diff))
                n.cgroup2 <- c(n.cgroup2, rep(NA, len_diff))
            }
            cgroup1_out <- rbind(cgroup2_out, cgroup1_out)
            n.cgroup1 <- rbind(n.cgroup2, n.cgroup1)
        }
        htmlTable_args$cgroup <- cgroup1_out
        htmlTable_args$n.cgroup <- n.cgroup1
    }

    do.call(htmlTable::htmlTable, htmlTable_args)
}
