#! /usr/bin/env wish
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# --                     Copyright 2022 Sckoarn
# --                        All Rights Reserved
#
#           This program is free software; you can redistribute it and/or modify
#               it under the following terms:
#               1) reproduction of this code shall include this header.
#               2) This program is distributed in the hope that it will be useful,
#               but WITHOUT ANY WARRANTY; without even the implied warranty of
#               MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#               3)  You may NOT sell this code, or any part there of.  
#
#           Description:  global name spaces
#
# -------------------------------------------------------------------------------

##  global  name space
namespace eval glbl  {
    set uzr_ini "~/far_tool/.far_ini"
    set uzr_mat_lst {}
    set uzr_sec_lst {}
    set uzr_slider {}
    set uzr_ini_sliders {}
}
#   User name spaces.
# ##############################################
#   variable for refining costing 
#    m  = metal
#    g  = gas
#    o  = oil
namespace eval refine {
    # variables for refine out cost distrubution
    set m1m1 1
    set m1s1 1
    set m1s2 1
    set m2m1 1
    set m2m2 1
    set m2s1 1
    set g1m1 1
    set g1s1 1
    set g1s2 1
    set g2m1 1
    set g2m2 1
    set g2s1 1
    set o1m1 1
    set o1s1 1
    set o1s2 1
    set o2m1 1
    set o2m2 1
    set o2s1 1
    set n1n1 1
    set n1s1 1
    set n1s2 1
    set n2n1 1
    set n2n2 1
    set n2s1 1
    set n2s2 1
    ##  other variables and constants.
    set lsec_cost "1200000"
    set msec_cost "650000"
    set ssec_cost "350000"
    set mine_cost "350000"
    set lsec_cnt 0
    set msec_cnt 0
    set ssec_cnt 0
    set mine_cnt 0
    set resources {}
    set refine_cnt 0
    set refine_lst {}
    set ammor_mines 0
    set ammor_refines 0
    set tot_outlay 0
    set inv_value 0
    set cost_table {}
}

# ###########################################
#   costing and search mode variables.
namespace eval cmode {
    set mode "None"
    set srch_mode "Reso"
}

# ############################
#  name space to hold all file names.
namespace eval ulsts {
    set sec_lst {}
    set secd_lst {}
    set ship_lst {}
    set shipd_lst {}
    set acc_lst {}
    set bp_lst {}
    set mod_lst {}
    set comps_lst {}
    set mine_reso_lst {}
    set comp_build_lst {}
    set ureso_lst {}
}

namespace eval dfiles {
    set usectors "../Sectors.csv"
    set usec_detail "../Sectors_Bases_Detail.csv"
    set uships "../Ships.csv"
    
    set uflst {"../Sectors.csv" \
               "../Sectors_Bases_Detail.csv" \
               "../Ships.csv" \
               "../Ships_Slot_Detail.csv" \
               "../Account.csv" \
               "../Blueprints.csv" \
               "../Modules.csv" \
               "../uzrResources.csv" \
               "../uzrComponents.csv"}
    set info_lsts {{"this_header" "sectors" "sector_details" "ships" "ships_data" "account" "blueprints" "modules" "components"}}
}

namespace eval uwids {
    set planet_lsb {}
    set pcanv {}
    set sector_lsb {}
    set scanv {}
    set ship_lsb {}
    set shcanv {}
    set module_lsb {}
    ##  shipe module canv
    set shicanv {}
    set inv_module_lsb {}
    set inv_mod_canv {}
    set base_lsb {}
    set bcanv {}
    set bluep_lsb {}
}

