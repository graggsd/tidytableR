context("test-table_formatter.R")

test_that("table_formatter works with a simple table", {

    data_1 <- data.frame(cat1 = rep(c("A", "B"), 2),
                       cat2 = c(rep("X1", 2), rep("X2", 2)),
                       metric1 = 1:4,
                       stringsAsFactors = FALSE)

    skeleton <-
        table_formatter(data_1,
                        value = "metric1",
                        header = "cat1",
                        rnames = "cat2",
                        rgroup = NULL,
                        cgroup1 = NULL,
                        cgroup2 = NULL,
                        tspanner = NULL)

    test_that("formatted_df is as expected", {
        expect_equivalent(skeleton$formatted_df,
                          data.frame(matrix(as.character(1:4),
                                            nrow = 2,
                                            byrow = TRUE),
                                     stringsAsFactors = FALSE))
    })

})
