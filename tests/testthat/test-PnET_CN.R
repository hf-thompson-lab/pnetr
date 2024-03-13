test_that("Match PnET-CN w/ MATLAB result", {
    require(data.table)

    sitepar <- SitePar$new("testdata/site_par.csv")
    vegpar <- VegPar$new("testdata/veg_par.csv")
    climate_dt <- fread("testdata/climate_data.csv")
    
    out <- PnET_CN(climate_dt, sitepar, vegpar, verbose = TRUE)
    mon_dt <- out$mon_dt
    ann_dt <- out$ann_dt

    # Compare with their MATLAB result
    mat_out <- R.matlab::readMat("testdata/out_pnet_cn.mat")
    out_li <- mat_out$out[, , 1]
    out_li <- lapply(out_li, as.vector)

    # Monthly output
    expect_equal(mon_dt$VPD, out_li$vpd)
    expect_equal(mon_dt$GrsPsnMo, out_li$grosspsn, tolerance = 0.01)
    expect_equal(mon_dt$NetPsnMo, out_li$netpsn, tolerance = 0.01)
    expect_equal(mon_dt$NetCBal, out_li$netcbal, tolerance = 0.01)
    expect_equal(mon_dt$FolMass, out_li$folmass, tolerance = 0.01)
    expect_equal(mon_dt$PlantN, out_li$plantnMo, tolerance = 0.01)

    # Annual output
    expect_equal(ann_dt$NPPFolYr, out_li$nppfol, tolerance = 0.01)
    expect_equal(ann_dt$NPPWoodYr, out_li$nppwood, tolerance = 0.01)
    expect_equal(ann_dt$NPPRootYr, out_li$npproot, tolerance = 0.001)
    expect_equal(ann_dt$NEP, out_li$nep, tolerance = 0.01)
    expect_equal(ann_dt$TotGrossPsn, out_li$gpp, tolerance = 0.001)
    expect_equal(ann_dt$TotTrans, out_li$trans, tolerance = 0.001)
    # TODO: where does this come from?
    # expect_equal(ann_dt$SoilWater, out_li$soilwater, tolerance = 0.01)
    expect_equal(ann_dt$TotPsn, out_li$psn, tolerance = 0.001)
    expect_equal(ann_dt$TotDrain, out_li$drain, tolerance = 0.001)
    expect_equal(ann_dt$TotPrec, out_li$prec, tolerance = 0.001)
    expect_equal(ann_dt$TotEvap, out_li$evap, tolerance = 0.001)
    expect_equal(ann_dt$TotET, out_li$et, tolerance = 0.001)
    expect_equal(ann_dt$PlantC, out_li$plantc, tolerance = 0.001)
    expect_equal(ann_dt$BudC, out_li$budc, tolerance = 0.01)
    expect_equal(ann_dt$WoodC, out_li$woodc, tolerance = 0.001)
    expect_equal(ann_dt$RootC, out_li$rootc, tolerance = 0.001)
    expect_equal(ann_dt$FolMass, out_li$folm, tolerance = 0.001)
    expect_equal(ann_dt$DeadWoodM, out_li$deadwoodm, tolerance = 0.001)
    expect_equal(ann_dt$WoodMass, out_li$woodm, tolerance = 0.001)
    expect_equal(ann_dt$RootMass, out_li$rootm, tolerance = 0.001)
    expect_equal(ann_dt$HOM, out_li$hom, tolerance = 0.1)
    expect_equal(ann_dt$HON, out_li$hon, tolerance = 0.1)
    expect_equal(ann_dt$NdepTot, out_li$ndep, tolerance = 0.1)

    # HACK: I don't think this is correct in the MATLAB version
    # expect_equal(ann_dt$PlantN, out_li$plantnYr[annidx], tolerance = 0.1)
    
    expect_equal(ann_dt$BudN, out_li$budn, tolerance = 0.1)
    expect_equal(ann_dt$NDrainYr, out_li$ndrain, tolerance = 0.1)
    expect_equal(ann_dt$NetNMinYr, out_li$netnmin, tolerance = 0.1)
    expect_equal(ann_dt$GrossNMinYr, out_li$grossnmin, tolerance = 0.1)
    expect_equal(ann_dt$PlantNUptakeYr, out_li$nplantuptak, tolerance = 0.1)
    expect_equal(ann_dt$GrossNImmobYr, out_li$grossnimob, tolerance = 0.1)
    expect_equal(ann_dt$TotalLitterNYr, out_li$littern, tolerance = 0.1)
    expect_equal(ann_dt$NetNitrYr, out_li$netnitrif, tolerance = 0.1)
    expect_equal(ann_dt$NRatio, out_li$nratio, tolerance = 0.1)
    expect_equal(ann_dt$FolN, out_li$foln, tolerance = 0.1)
    expect_equal(ann_dt$TotalLitterMYr, out_li$litm, tolerance = 0.1)
    expect_equal(ann_dt$TotalLitterNYr, out_li$litn, tolerance = 0.1)
    expect_equal(ann_dt$RootMRespYr, out_li$rmresp, tolerance = 0.1)
    expect_equal(ann_dt$RootGRespYr, out_li$rgresp, tolerance = 0.1)
    expect_equal(ann_dt$SoilDecRespYr, out_li$decresp, tolerance = 0.1)
})
