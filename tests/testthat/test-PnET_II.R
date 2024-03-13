test_that("Match PnET-II w/ MATLAB result", {
    require(data.table)

    # Run the model
    sitepar <- SitePar$new("testdata/site_par.csv")
    vegpar <- VegPar$new("testdata/veg_par.csv")
    climate_dt <- fread("testdata/climate_data.csv")

    out <- PnET_II(climate_dt, sitepar, vegpar, verbose = TRUE)
    mon_dt <- out$mon_dt
    ann_dt <- out$ann_dt

    # Compare with their MATLAB result
    mat_out <- R.matlab::readMat("testdata/out_pnet_ii.mat")
    out_li <- mat_out$out[, , 1]
    out_li <- lapply(out_li, as.vector)

    # Monthly output
    expect_equal(mon_dt$GrsPsnMo, out_li$grosspsn, tolerance = 0.001)
    expect_equal(mon_dt$NetPsnMo, out_li$netpsn, tolerance = 0.01)
    expect_equal(mon_dt$NetCBal, out_li$netcbal, tolerance = 0.1)
    expect_equal(mon_dt$VPD, out_li$vpd)
    expect_equal(mon_dt$FolMass, out_li$folmass, tolerance = 0.01)
    expect_equal(mon_dt$DWater, out_li$waterstress, tolerance = 0.001)
    expect_equal(mon_dt$Drainage, out_li$drainage, tolerance = 0.01)
    expect_equal(mon_dt$ET, out_li$et, tolerance = 0.001)

    # Annual output
    expect_equal(ann_dt$NPPFolYr, out_li$nppfol, tolerance = 0.01)
    expect_equal(ann_dt$NPPWoodYr, out_li$nppwood, tolerance = 0.01)
    expect_equal(ann_dt$NPPRootYr, out_li$npproot, tolerance = 0.01)
    expect_equal(ann_dt$NEP, out_li$nep, tolerance = 0.01)
    expect_equal(ann_dt$TotGrossPsn, out_li$gpp, tolerance = 0.001)
    expect_equal(ann_dt$TotTrans, out_li$trans, tolerance = 0.001)
    expect_equal(ann_dt$TotPsn, out_li$psn, tolerance = 0.001)
    expect_equal(ann_dt$TotDrain, out_li$drain, tolerance = 0.001)
    expect_equal(ann_dt$TotPrec, out_li$prec, tolerance = 0.001)
    expect_equal(ann_dt$TotEvap, out_li$evap, tolerance = 0.001)
    expect_equal(ann_dt$PlantC, out_li$plantc, tolerance = 0.01)
    expect_equal(ann_dt$BudC, out_li$budc, tolerance = 0.01)
    expect_equal(ann_dt$WoodC, out_li$woodc, tolerance = 0.01)
    expect_equal(ann_dt$RootC, out_li$rootc, tolerance = 0.01)
    expect_equal(ann_dt$FolMass, out_li$folm, tolerance = 0.001)
    expect_equal(ann_dt$DeadWoodM, out_li$deadwoodm, tolerance = 0.001)
    expect_equal(ann_dt$WoodMass, out_li$woodm, tolerance = 0.001)
    expect_equal(ann_dt$RootMass, out_li$rootm, tolerance = 0.001)
})



test_that("Match w/ C++ result", {
    skip("C++ result is different b/c some nuances!")

    require(data.table)
    require(magrittr)

    # Read the C++ version input data
    testfilename <- "testdata/input.txt"
    datain <- ReadCData(testfilename)
    vegpar <- datain$vegpar
    sitepar <- datain$sitepar
    climate_dt <- datain$clim_dt
    # Rename climate columns to match the algorithm
    colnames(climate_dt) <- c("Year", "DOY", "Tmax", "Tmin", "Par", "Prec", 
        "O3", "CO2", "NH4dep", "NO3dep"
    )

    # Run pnetr
    out <- PnET_II(climate_dt, sitepar, vegpar, verbose = TRUE)
    mon_dt <- out$mon_dt
    ann_dt <- out$ann_dt

    # Compare with C++ output
    # There is a spared "," in the output file which I think it's unneccessary
    c_mon_dt <- fread("testdata/Output_monthly.csv", fill = TRUE) %>%
        .[-1,] %>%
        .[, lapply(.SD, as.numeric)]
    c_ann_dt <- fread("testdata/Output_annual.csv", skip = 2)[, 1:38]
    c_ann_dt_names <- readLines("testdata/Output_annual.csv", n = 1L) %>%
        strsplit(",") %>%
        unlist() %>%
        trimws()
    setnames(c_ann_dt, 1:ncol(c_ann_dt), c_ann_dt_names)

    # Monthly output
    expect_equal(mon_dt$VPD, c_mon_dt$vpd, tolerance = 0.01)
    expect_equal(mon_dt$GrsPsnMo, c_mon_dt$GrsPsnMo)
    expect_equal(mon_dt$NetPsnMo, c_mon_dt$NetPsnMo)
    expect_equal(mon_dt$FolMass, c_mon_dt$Foliage, tolerance = 0.01)
    expect_equal(mon_dt$DWater, c_mon_dt$Water)
    expect_equal(mon_dt$Drainage, c_mon_dt$Drain)
    expect_equal(mon_dt$ET, c_mon_dt$ET, tolerance = 0.01)

    # Annual output
    expect_equal(ann_dt$NPPFolYr, c_ann_dt$nppfol)
    expect_equal(ann_dt$NPPWoodYr, c_ann_dt$nppwood)
    expect_equal(ann_dt$NPPRootYr, c_ann_dt$npproot)
    expect_equal(ann_dt$NEP, c_ann_dt$nep)
    # TODO: double-check
    expect_equal(ann_dt$TotGrossPsn, c_ann_dt$psn)
    expect_equal(ann_dt$DWater, c_ann_dt$wtrstress)
    expect_equal(ann_dt$TotTrans, c_ann_dt$trans)
    # TODO: double-check
    expect_equal(ann_dt$TotPsn, c_ann_dt$psn)
    expect_equal(ann_dt$TotDrain, c_ann_dt$drain)
    expect_equal(ann_dt$TotPrec, c_ann_dt$prec, tolerance = 0.001)
    expect_equal(ann_dt$TotEvap, c_ann_dt$evap)
    expect_equal(ann_dt$ET, c_ann_dt$et)
    expect_equal(ann_dt$PlantC, c_ann_dt$plantc)
    expect_equal(ann_dt$BudC, c_ann_dt$budc)
    expect_equal(ann_dt$WoodC, c_ann_dt$woodc)
    expect_equal(ann_dt$RootC, c_ann_dt$rootc)
    # TODO: why all 0?
    expect_equal(ann_dt$FolMass, c_ann_dt$folm)
    # TODO: why all the same?
    expect_equal(ann_dt$DeadWoodM, c_ann_dt$deadwoodm)
    # expect_equal(ann_dt$WoodMass, c_ann_dt$)
    # TODO: why all the same?
    expect_equal(ann_dt$RootMass, c_ann_dt$rootm)
    # TODO: why all 0?
    expect_equal(ann_dt$TotalLitterMYr, c_ann_dt$litm)
    # expect_equal(ann_dt$RootMRespYr, c_ann_dt$)
    # expect_equal(ann_dt$RootGRespYr, c_ann_dt$)
    # expect_equal(ann_dt$SoilDecRespYr, c_ann_dt$)
})
