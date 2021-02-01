******************************
*** CLEAN CENSUS FOR MERGE ***
******************************

	*** Load census data
		use "$output/pca_census01_india_withshrugnames.dta", clear
		
	*** Drop wards and villages (below sub-districts)
		drop if ward != 0 | town_vill != 0
	
	*** Drop rural and urban splits
		drop if ward == 0 & town_vill == 0 & tru == "Rural" 
		drop if ward == 0 & town_vill == 0 & tru == "Urban"
		
	*** Drop two police stations with missing names	
		count if missing(name)
		//assert `r(N)'==2
		drop if missing(name)
		
	*** Fix city center in Mandya, Karnataka
		replace name = "Mandya - Taluk" if name == "Mandya" & level == "TALUK" & state == 29 & district == 22 & tahsil == 0
		replace tahsil = 8 if name == "Mandya - Taluk"
		
	*** Assert that everything is unique now	
		//gisid state district tahsil
		
	*** Assign states
		preserve
			tempfile statenames
			keep if level == "STATE"
			keep state name
			rename name statename
			save `statenames'
		restore 
		merge m:m state using `statenames'
		assert _merge == 3
		drop _merge
		
	*** Assign districts 
		preserve
			tempfile districtnames 
			keep if level == "DISTRICT"
			keep state district name
			rename name districtname
			save `districtnames'
		restore
		merge m:m state district using `districtnames'
		assert _merge == 3 if level != "STATE"
		drop _merge 
		drop if level == "STATE" | level == "DISTRICT"
		//labmask state, values(statename)
	
	*** Create literacy gaps
		gen femalelitrate = f_lit/tot_f
		gen malelitrate = m_lit/tot_m 
		gen gaplitrate = malelitrate - femalelitrate
		
		keeporder state statename state_name district districtname district_name tahsil name subdistrict_name level femalelitrate malelitrate gaplitrate f_lit tot_f m_lit tot_m tru town_vill ward
		rename name blockname

	*** Clean names	
		foreach var in statename districtname blockname state_name district_name subdistrict_name{
			replace `var' = strupper(`var')
			replace `var' = strtrim(subinstr(`var'," *","",1))
			replace `var' = strtrim(subinstr(`var',"*","",1))
			replace `var' = strtrim(subinstr(`var',"*","",2))
			replace `var' = strtrim(subinstr(`var',"CIRCLE","",1))
			replace `var' = strtrim(subinstr(`var',"SUB-DIVISION","",1))
			replace `var' = strtrim(subinstr(`var',"SUB-DIV.","",1))
			replace `var' = strtrim(subinstr(`var',"T.D.BLOCK","",1))
			//replace `var' = strtrim(subinstr(`var',"(T)","",1))
			replace `var' = strtrim(subinstr(`var',"(P)","",1))
			replace `var' = strtrim(subinstr(`var',"(S.T)","",1))
		} 
		replace blockname = "GAYA" if blockname == "GAYA TOWN CD BLOCK" & districtname == "GAYA"
		replace statename = "MANIPUR" if statename == "MANIPUR (EXCL. 3 SUB-DIVISIONS)"
		replace statename = "MANIPUR" if statename == "MANIPUR (EXCL. 3 S)"
		
	*** Check for and display observations not uniquely identified
		capture gisid state districtname blockname
		if  _rc != 0 {
			sort statename districtname blockname
			quietly by statename districtname blockname: gen dup = cond(_N==1,0,_n)
			br if dup != 0
			drop dup
		}
			
		//gisid state district tahsil 
		compress
		save "$output/census01_blocks.dta", replace
