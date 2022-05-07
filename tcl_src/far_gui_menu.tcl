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
#           Description: This file contains menue for the tool
#               
#
# -------------------------------------------------------------------------------

set mbar [menu .mu]
. configure -menu .mu
menu $mbar.f1
$mbar add cascade -menu $mbar.f1 -label File -underline 0
$mbar.f1 add command -label Exit -command {user_exit} -background #ffcccc


# veiw menu
menu $mbar.f4
$mbar add cascade -menu $mbar.f4 -label View -underline 0
#$mbar.f4 add command -label "View" -background #ffffff
menu $mbar.f4.sh
$mbar.f4.sh add command -label "From Reso (default)"   -command {load_base; set sys::modeVar "R"; set cmode::srch_mode "Reso"} -background #ffffff
$mbar.f4.sh add command -label "From Comp"   -command {load_base; set sys::modeVar "C"; set cmode::srch_mode "Comp"} -background #ffffff
$mbar.f4.sh add command -label "From Blue"   -command {load_base; set sys::modeVar "B"; set cmode::srch_mode "Blue"} -background #ffffff
$mbar.f4 add cascade -label "Sorting ..." -menu $mbar.f4.sh
$mbar.f4 add separator
#$mbar.f4 add command -label "Another CMD"   -command {set cmode::srch_mode "refine"} -background #ffffff
$mbar.f4 add command -label "Another CMD" -background #ffffff

#  Costing
proc src_cost {} {
    source "$sys::cdir/far_costing.tcl"
}
if {$sys::devmode == 1} {
    menu $mbar.f3
    $mbar add cascade -menu $mbar.f3 -label Costing -underline 0
    $mbar.f3 add command -label "Show Refine Costs"   -command {set cmode::mode "refine"} -background #ffffff
    $mbar.f3 add command -label "Show Compnent Costs" -command {set cmode::mode "comp"} -background #ffffff
    $mbar.f3 add command -label "Show Ship Cost"      -command {set cmode::mode "ship"} -background #ffffff
    $mbar.f3 add command -label "Comp from Mat"       -command {set cmode::srch_mode "c_from_m"} -background #ffffff

    #  Dev
    menu $mbar.f2
    $mbar add cascade -menu $mbar.f2 -label Dev -underline 0
    $mbar.f2 add command -label "Source User" -command {source "$sys::cdir/user_procs.tcl"} -background #ffffff
    $mbar.f2 add command -label "Source Far" -command {source "$sys::cdir/far_procs.tcl"} -background #ffffff
    $mbar.f2 add command -label "Source Menue" -command {source "$sys::cdir/far_gui_menu.tcl"} -background #ffffff
    $mbar.f2 add command -label "Source Costing" -command {source "$sys::cdir/far_costing.tcl"} -background #ffffff
    $mbar.f2 add command -label "Source Univ" -command {source "$sys::cdir/get_universe.tcl"} -background #ffffff
    $mbar.f2 add command -label "Test" -command gen_costing_list -background #ffffff
}

#  about
set contribs "wrongtack: pytyon scripts\nswimlane72: python scritps\nsckoarn: TCL/TK GUI"
set about "Farsite Workbench\nVersion $version\nA TCL/TK application with\npython account access."
menu $mbar.ab
$mbar add cascade -menu $mbar.ab -label About -underline 0
$mbar.ab add command -label "Contributers" -command {usr_msg $contribs} -background #ffffff
$mbar.ab add command -label "App" -command {usr_msg $about} -background #ffffff
