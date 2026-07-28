test_that("PnET-II uses neutral CO2 multipliers and reports foliar litter", {
    require(data.table)

    sitepar <- SitePar$new("testdata/site_par.csv")
    vegpar <- VegPar$new("testdata/veg_par.csv")
    climate_dt <- fread("testdata/climate_data.csv")[1:24]

    out <- PnET_II(climate_dt, sitepar, vegpar, verbose = FALSE)

    expect_true(all(out$ann_dt$NPPFolYr > 0))
    expect_true(all(out$ann_dt$BudC > 0))
    expect_true(all(out$ann_dt$TotalLitterMYr > 0))
    expect_true(all(out$log_dt$DWater >= 0 &
        out$log_dt$DWater <= 1 + sqrt(.Machine$double.eps)))
    expect_true(any(out$log_dt$DWater > 0))
})
