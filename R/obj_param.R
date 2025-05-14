# ******************************************************************************
# Parameters
# 
# Author: Xiaojie Gao
# Date: 2023-08-28
# ******************************************************************************

Param <- R6::R6Class("Param",

    private = list(
        # Use CSV file to init parameters
        parse_csv = function(csv_file) {
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
        },
        
        # Use json file to init parameters
        parse_json = function(json_file) {
            par_li <- jsonlite::read_json(json_file)
            for (varname in names(par_li)) {
                if (!is.null(self[[varname]])) {
                    self[[varname]] <- unlist(par_li[[varname]])
                }
            }
        }
    ),

    public = list(
        # Init the parameters using a csv file
        initialize = function(filename = NULL) {
            if (is.null(filename)) {
                return(self)
            }

            filetype <- tools::file_ext(filename)
            switch(filetype,
                "csv" = private$parse_csv(filename),
                "json" = private$parse_json(filename)
            )
        }
    )

)
