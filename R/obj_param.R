# ******************************************************************************
# Parameters
# 
# Author: Xiaojie Gao
# Date: 2023-08-28
# ******************************************************************************

Param <- R6::R6Class("Param",

    public = list(
        # Init the parameters using a csv file
        initialize = function(csv_file) {
            par_dt <- read.csv(csv_file)
            for (col_name in colnames(par_dt)) {
                if (!is.null(self[[col_name]])) {
                    self[[col_name]] <- par_dt[[col_name]]
                    # Test if the variable is a vector
                    if (grepl("\\[|\\]", self[[col_name]])) {
                        tmp <- gsub("\\[|\\]", "", self[[col_name]]) %>%
                            strsplit(";") %>%
                            unlist() %>%
                            as.integer()
                        self[[col_name]] <- tmp
                    }
                }
            }
        }
    )

)
