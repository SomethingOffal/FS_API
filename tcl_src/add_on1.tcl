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
#           Description:  This file contains all static GUI elements.  Many others
#               are created in other files but they are dynamic, elements here are
#               static.
#
# -------------------------------------------------------------------------------

if {[file exists "$sys::cdir/far_loc.tcl"]} {
    wm title . "Farsite Workbench: Comet Hunter Alpha 1.0"
    source "$sys::cdir/far_loc.tcl"
    set srch_bt [button $srch_fr.bt1 -text "Locate" -command {locate_ship}]
    set rep_lbl [label $srch_fr.lb1 -text " Reps"]
    set floc::reps_en [entry $srch_fr.enr -width 2]
    $floc::reps_en insert 0 "5"
    
    set g1en [checkbutton $srch_fr.cb1 -text "G1 en" -variable floc::g1_en ]
    set g2en [checkbutton $srch_fr.cb2 -text "G2 en" -variable floc::g2_en ]
    set g3en [checkbutton $srch_fr.cb3 -text "G3 en" -variable floc::g3_en ]
    set floc::trak_btn [button $srch_fr.bt2 -text "Track" -bg #a04040 -command tracking]
    set sld1 [scale $srch_fr.scl1 -from 3 -to 20 -orient horizontal -length 100 \
              -variable floc::tr_inter]
    $sld1 set 5
    set tlb  [label $srch_fr.lbt -text "Sample time in seconds"]
    pack $srch_fr -fill x -expand 1
    #pack $srch_bt $floc::s_ent $rep_lbl $floc::reps_en $g1en $g2en $g3en $floc::trak_btn $sld1 $tlb -side left -padx 6
    pack $srch_bt $rep_lbl $floc::reps_en $g1en $g2en $g3en $floc::trak_btn $sld1 $tlb -side left -padx 6
}
