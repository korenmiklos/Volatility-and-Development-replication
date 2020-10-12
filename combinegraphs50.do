clear;
#delimit;


graph combine lowess_Sectoral_Risk_loggdp.gph within_Sectoral_Risk_loggdp.gph, rows(2) cols(1)  scheme(s1mono);
graph display, xsize(5) ysize(9) ;
graph export fig0102.ps, as(ps) replace;


graph combine lowess_Weighted_Herfindahl_loggdp.gph  within_Weighted_Herfindahl_loggdp.gph, rows(2) cols(1)  scheme(s1mono);
graph display, xsize(5) ysize(9) ;
graph export fig0304.ps, as(ps) replace;


graph combine lowess_Textiles_loggdp.gph  within_Textiles_loggdp.gph, rows(2) cols(1)  scheme(s1mono);
graph display, xsize(5) ysize(9) ;
graph export fig0506.ps, as(ps) replace;


graph combine lowess_Electric_Machinery_loggdp.gph within_Electric_Machinery_loggdp.gph, rows(2) cols(1)  scheme(s1mono);
graph display, xsize(5) ysize(9) ;
graph export fig0708.ps, as(ps) replace;


graph use lowess_Country_Risk_loggdp.gph;
graph display, xsize(5.5) ysize(5) ;
graph export fig9.ps, as(ps) replace;

graph combine lowess_Sector_Country_Beta_loggdp.gph within_Sector_Country_Beta_loggdp.gph, rows(2) cols(1)  scheme(s1mono);
graph display, xsize(5) ysize(9) ;
graph export fig1011.ps, as(ps) replace;

graph combine lowess_Dist_to_Own_Frontier_loggdp.gph  within_Dist_to_Own_Frontier_loggdp.gph, rows(2) cols(1)  scheme(s1mono);
graph display, xsize(5) ysize(9) ;
graph export fig1213.ps, as(ps) replace;


graph use lowess_Dist_to_World_Frontier_loggdp.gph;
graph display, xsize(5.5) ysize(5) ;
graph export fig14.ps, as(ps) replace;

