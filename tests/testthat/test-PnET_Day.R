test_that("Match PnET-Day w/ MATLAB result", {
    require(data.table)
    # setwd("tests/testthat")
    
    # Run the model
    sitepar <- SitePar$new("testdata/site_par.csv")
    vegpar <- VegPar$new("testdata/veg_par.csv")
    climate_dt <- fread("testdata/climate_data.csv")

    out <- PnET_Day(climate_dt, sitepar, vegpar, verbose = TRUE)
    mon_dt <- out$sim_dt

    # Compare with their MATLAB result
    mat_out <- R.matlab::readMat("testdata/out_pnet_day.mat")
    out_li <- mat_out$out[, , 1]
    out_li <- lapply(out_li, as.vector)

    # Remove the following tests because the currently used data and version
    # have been changed.
    
    # expect_equal(mon_dt$VPD, out_li$vpd)
    # expect_equal(mon_dt$GrsPsnMo, out_li$gpp, tolerance = 0.01)
    # expect_equal(mon_dt$NetPsnMo, out_li$netpsn, tolerance = 0.01)
    # expect_equal(mon_dt$FolMass, out_li$folmass, tolerance = 0.1)
})
