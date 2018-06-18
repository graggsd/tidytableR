table_formatter <-
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
             ...) {

        argument_checker(x,
                         value = value,
                         header = header,
                         rnames = rnames,
                         rgroup = rgroup,
                         cgroup1 = cgroup1,
                         cgroup2 = cgroup2,
                         tspanner = tspanner,
                         hidden_rgroup = NULL,
                         hidden_tspanner = NULL)

        check_uniqueness(x,
                         header = header,
                         rnames = rnames,
                         rgroup = rgroup,
                         cgroup1 = cgroup1,
                         cgroup2 = cgroup2,
                         tspanner = tspanner)

        x <- remove_na_rows(x,
                            header = header,
                            rnames = rnames,
                            rgroup = rgroup,
                            cgroup1 = cgroup1,
                            cgroup2 = cgroup2,
                            tspanner = tspanner)

        # Create tables from which to gather row, column, and tspanner names
        # and indices
        row_ref_tbl <- x %>%
            get_row_tbl(rnames = rnames,
                        rgroup = rgroup,
                        tspanner = tspanner)

        # Hide row groups specified in hidden_rgroup
        if (!(is.null(hidden_rgroup))) {
            row_ref_tbl <- row_ref_tbl %>%
                dplyr::mutate_at(rgroup,
                                 function(x){ifelse(x %in% hidden_rgroup, "", x)})
        }

        # Hide tspanners specified in hidden_tspanner
        if (!(is.null(hidden_tspanner))) {
            row_ref_tbl <- row_ref_tbl %>%
                dplyr::mutate_at(tspanner,
                                 function(x){ifelse(x %in% hidden_tspanner, "", x)})
        }

        col_ref_tbl <- x %>%
            get_col_tbl(header = header,
                        cgroup1 = cgroup1,
                        cgroup2 = cgroup2)

        # Hide cgroup1 specified in hidden_cgroup1
        if (!(is.null(hidden_cgroup1))) {
            col_ref_tbl <- col_ref_tbl %>%
                dplyr::mutate_at(cgroup1,
                                 function(x){ifelse(x %in% hidden_cgroup1, "", x)})
        }

        # Hide cgroup2 specified in hidden_cgroup2
        if (!(is.null(hidden_cgroup2))) {
            col_ref_tbl <- col_ref_tbl %>%
                dplyr::mutate_at(cgroup2,
                                 function(x){ifelse(x %in% hidden_cgroup2, "", x)})
        }

        # Format the values for display
        to_select <- c("r_idx", "c_idx", value)
        formatted_df <- x %>%
            add_col_idx(header = header,
                        cgroup1 = cgroup1,
                        cgroup2 = cgroup2) %>%
            add_row_idx(rnames = rnames,
                        rgroup = rgroup,
                        tspanner = tspanner) %>%
            dplyr::select(to_select) %>%
            dplyr::mutate_at(value, as.character) %>%
            # Spread will fill missing values (both explict and implicit) with the
            # same value, so we need to convert these values to a character if we want
            # them to show up correctly in the final table
            tidyr::spread(key = "c_idx",
                          value = value,
                          fill = "")
        formatted_df$r_idx <- NULL

        return(list(row_ref_tbl = row_ref_tbl,
                    col_ref_tbl = col_ref_tbl,
                    formatted_df = formatted_df))

    }


# Removes rows containing NA values in any mapped columns from the tidy dataset
remove_na_rows <- function(x, ...) {
    cols <- as.character(get_col_vars(...))
    na.log <- x %>%
        dplyr::select(cols) %>%
        is.na

    na.row.sums <- na.log %>%
        rowSums

    keep.idx <- na.row.sums == 0
    removed <- sum(na.row.sums > 0)

    if (removed != 0) {
        na.col.sums <- na.log %>%
            colSums
        na.cols <- colnames(na.log)[na.col.sums > 0]
        warning(paste0("NA values were detected in the following columns of ",
                       "the tidy dataset: ",
                       paste(na.cols, collapse = ", "), ". ",
                       removed, " row(s) in the tidy dataset were removed."))
    }
    return(x %>% dplyr::filter(keep.idx))
}

# This checks to make sure that the mapping columns of the tidy dataset
# uniquely specify a given value
check_uniqueness <- function(x, ...) {
    # Get arguments
    args <- simplify_arg_list(...)
    cols <- as.character(args)
    dupes <- x %>%
        dplyr::select(cols) %>%
        duplicated
    if (sum(dupes) != 0) {

        stop(paste0("The input parameters ",
                    paste(paste0("\"", names(args), "\""), collapse = ", "),
                    " do not specify unique rows. The following rows ",
                    "are duplicated: ",
                    paste(which(dupes), collapse = ", ")))
    }
}

# Converts arguments from ... into a list and removes those that have been set
# to NULL
simplify_arg_list <- function(...) {
    x <- list(...)
    idx <- sapply(x, is.null)
    return(x[!idx])
}

# This function gets arguments from ..., removes those that are NULL,
# and then subsets those that should map tidy data columns to htmlTable
# parameters
get_col_vars <- function(...) {
    out <- simplify_arg_list(...)
    return(out[names(out) %in%
                   c("value", "header",
                     "rnames", "rgroup",
                     "cgroup1", "cgroup2",
                     "tspanner")])
}

# Checks a variety of assumptions about input arguments and prepares an
# appropriate error message if those assumptions are violated
argument_checker <- function(x, ...) {

    # Check if x is a grouped tbl_df
    if(dplyr::is.grouped_df(x)) {
        stop("x cannot be a grouped_df")
    }

    # Check that all the input are characters
    all_args <- simplify_arg_list(...)
    idx <- which(!sapply(all_args, is.character))

    if (length(idx) > 0) {
        stop("The following parameters must be of type character: ",
             paste(names(all_args)[idx], collapse = ", "))
    }

    # Check that all of the arguments that would be used map columns to
    # character attributes are of length 1
    col_vars <- get_col_vars(...)

    idx <- which(sapply(col_vars, length) > 1)
    if (length(idx) > 0) {
        stop("The following parameters must be of length 1: ",
             paste(names(col_vars)[idx], collapse = ", "))
    }

    # Find column variables that are not columns in the dataset
    idx <- which(!(as.character(col_vars) %in% colnames(x)))
    if (length(idx) > 0) {
        stop("The following arguments need values that correspond to column ",
             "names in x: ",
             paste0(names(col_vars), " = ",
                    as.character(col_vars),
                    collapse = ", "))
    }
}

get_col_tbl <- function(x,
                        header,
                        cgroup1 = NULL,
                        cgroup2 = NULL) {

    cols <- c(cgroup2, cgroup1, header)

    out <- x %>%
        dplyr::select(cols) %>%
        unique %>%
        dplyr::arrange_at(cols) %>%
        # This is necessary in order to not generate NA values when setting
        # hidden elements to ""
        dplyr::mutate_if(is.factor, as.character)

    out$c_idx <- 1:nrow(out)
    return(out)
}

get_row_tbl <- function(x,
                        rnames,
                        rgroup = NULL,
                        tspanner = NULL) {

    cols <- c(tspanner, rgroup, rnames)

    out <- x %>%
        dplyr::select(cols) %>%
        unique %>%
        dplyr::arrange_at(cols) %>%
        # This is necessary in order to not generate NA values when setting
        # hidden elements to ""
        dplyr::mutate_if(is.factor, as.character)

    out$r_idx <- 1:nrow(out)
    return(out)
}

add_col_idx <- function(x,
                        header,
                        cgroup1 = NULL,
                        cgroup2 = NULL) {

    cols <- c(cgroup2, cgroup1, header)

    col_idx_df <- x %>%
        get_col_tbl(header = header,
                    cgroup1 = cgroup1,
                    cgroup2 = cgroup2)

    out <- suppressWarnings(
        x %>%
            dplyr::left_join(col_idx_df, cols)
    )
    return(out)
}

add_row_idx <- function(x,
                        rnames,
                        rgroup = NULL,
                        tspanner = NULL) {

    cols <- c(tspanner, rgroup, rnames)

    row_idx_df <- x %>%
        get_row_tbl(rnames = rnames,
                    rgroup = rgroup,
                    tspanner = tspanner)

    out <- suppressWarnings(
        x %>%
            dplyr::left_join(row_idx_df, by = cols)
    )
    return(out)
}