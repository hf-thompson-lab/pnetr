# ******************************************************************************
# Parse LANDIS format data files
# 
# Author: Xiaojie Gao
# Date: 2023-08-20
# ******************************************************************************


# Species 
# ex <- "pnetTest/NE_species.txt"

ParseLandisFile <- function(filename) {
    txt <- readLines(filename)
    header <- gsub("\\s+", " ", tolower(txt[1])) %>%
        trimws()
    
    if (header == "landisdata species") {
        # Species
        return(ParseSpeciesTxt(txt))
    } else if (header == "landisdata ecoregionparameters") {
        # Ecoregion
        return(ParseEcoregionTxt(txt))
    } else {
        stop("Error in file")
    }
}


ParseSpeciesTxt <- function(txt) {
    # Skip comment lines
    data_line_start <- 0
    for (i in 2:length(txt)) {
        is_data_line <- !grepl(">>", txt[i])
        if (is_data_line && gsub("\\s+", "", tolower(txt[i])) != "") {
            data_line_start <- i
            break
        }
    }
    
    data_line_end <- 0
    for (i in data_line_start:length(txt)) {
        is_data_line <- !grepl(">>", txt[i])
        if (is_data_line && gsub("\\s+", "", tolower(txt[i])) != "") {
            data_line_end <- i
        }
    }

    header_line <- data_line_start - 1

    header_txt <- txt[header_line] %>%
        gsub(">>", "", .)
    
    data_txt <- c(header_txt, txt[data_line_start:data_line_end]) %>%
        gsub("\\t|\\s+", " ", .)
    
    species_dt <- fread(text = data_txt, header = TRUE)

    return(species_dt)
}

ParseClimate <- function(filename) {
    climate_dt <- fread(filename)
    return(climate_dt)
}


ParseEcoregionTxt <- function(txt) {
    # Skip comment lines
    data_line_start <- 0
    for (i in 2:length(txt)) {
        is_data_line <- !grepl(">>", txt[i])
        if (is_data_line && gsub("\\s+", "", tolower(txt[i])) != "") {
            data_line_start <- i
            break
        }
    }

    data_line_end <- 0
    for (i in data_line_start:length(txt)) {
        is_data_line <- !grepl(">>", txt[i])
        if (is_data_line && gsub("\\s+", "", tolower(txt[i])) != "") {
            data_line_end <- i
        }
    }
    
    data_txt <- txt[data_line_start:data_line_end] %>%
        gsub("\\t|\\s+", " ", .)

    eco_dt <- fread(text = data_txt, header = TRUE)

    return(eco_dt)
}
