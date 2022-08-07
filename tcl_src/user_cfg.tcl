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
#           Description:  This file contains most of the procs that access the 
#               User Status tab.
#
# -------------------------------------------------------------------------------
# ###############################################################################
#   user info and config tab
namespace eval uzrcfg {
    set ufr {}
    set cost_tbl {}
    set mrcost_tbl {}
    set value_tbl {}
    set slide_lst {}
    set tr_percent 15
#    set canv {}
#    set sys_lst {}
#    set sys_conn_lst {}
#    set planet_lst {}
#    set origin {0.0,0.0,0.0}
}


$nb add [frame .note.tst -borderwidth 4 -relief sunken] -text  "\[ User Config \]" -padding {5 5 5 5}
set uzrcfg::ufr .note.tst

set uinfr [ttk::labelframe $uzrcfg::ufr.uinfo -text "User Inventory Information"]

set ustafr [ttk::labelframe $uinfr.mstat1 -text "Hardware Stats"]
set lslb1 [label $ustafr.lb1 -text "Large Sector cost:   $refine::lsec_cost"]
set lslb2 [label $ustafr.lb2 -text "Medium Sector cost:  $refine::msec_cost"]
set lslb3 [label $ustafr.lb3 -text "Small Sector cost:   $refine::ssec_cost"]
pack $lslb1 $lslb2 $lslb3
set lslb4 [label $ustafr.lb4 -text "Large Sectors:    $refine::lsec_cnt"]
set lslb5 [label $ustafr.lb5 -text "Medium Sectors:   $refine::msec_cnt"]
set lslb6 [label $ustafr.lb6 -text "Small Sectors:    $refine::ssec_cnt"]
set lslb7 [label $ustafr.lb7 -text "Mines Installed:    $refine::mine_cnt"]
pack $lslb4 $lslb5 $lslb6 $lslb7

set usec_tot [expr {$refine::lsec_cost * $refine::lsec_cnt + \
                   ($refine::msec_cost * $refine::msec_cnt) + \
                   ($refine::ssec_cost * $refine::ssec_cnt)}]
set lslb10 [label $ustafr.lb10 -text "Sectors Outlay:    $usec_tot"]
set umine_tot [expr {$refine::mine_cnt * $refine::mine_cost}]
set lslb11 [label $ustafr.lb11 -text "Mining Outlay:    $umine_tot"]
set lslb12 [label $ustafr.lb12 -text "Total Hardware Outlay:    [expr {$usec_tot + $umine_tot}]"]
pack $lslb10 $lslb11 $lslb12




#puts $ulsts::mine_reso_lst
set invstfr [ttk::labelframe $uinfr.mstat2 -text "Inventory Stats"]

set uzr_inv [get_uzr_mats_inv]
set w 1
foreach v $uzr_inv {
    set ivlbl [label $invstfr.ilb$w -text $v -font font_info_cou]
    pack $ivlbl
    incr w
}
#puts get_uzr_mats_inv
#    amortization

set cost_frm [frame $uzrcfg::ufr.mcf]

#pack $ustafr $invstfr -side left -fill y
#pack $uinfr -anchor n -expand 1 -fill x
# the users input for costing on travel addition to costing calculations.
set tcost_fr [ttk::labelframe $cost_frm.tcost1 -text "Travel cost % Multiplyer"]
set tcost_en [entry $tcost_fr.en1 -width 3 -textvariable uzrcfg::tr_percent]
set tlbl [label $tcost_fr.lb1 -text "Travel Cost:  50 = 50% or 0.5 multiplyer"]
#set zsids [checkbutton $tcost_fr.zs1 -text " :Zero Side Cost" -command update_zcost $zsids]
pack $tlbl $tcost_en
#pack $zsids
pack $tcost_fr


set pur_fr [ttk::labelframe $cost_frm.pcost1 -text "Bought on Market"]
set rcnt 0
set ff [frame $pur_fr.f0 -borderwidth 2 -relief sunken]
foreach r $far_db::res_lst {
    if {[lindex $r 0] == "0"} {continue}
    set dat [lindex $r 1]
    if {[lindex $dat end] == {}} {continue}
    set id [lindex $r 0]
    set rfr [frame $ff.$id -borderwidth 2 -relief sunken]
    set nam $id
    append nam ":" [lindex $dat 0]
    set lbcolr [lindex $dat 4]
    set lb1 [label $rfr.lb1 -text $nam -font font_info_txt -background $lbcolr -foreground white]
    set en1 [entry $rfr.en1 -width 4]
    bind $en1 <KeyRelease> {update_cost_table $en1}
    #$en1 insert end "M"
    set uzrcfg::cost_tbl [lappend uzrcfg::cost_tbl "$nam:$en1"]
    pack $lb1 -side left -fill x -expand 1
    pack $en1 -side right
    pack $rfr -fill x -expand 1
    #puts $r
    incr rcnt
    if {$rcnt >= 20} {
        pack $ff -side left
        set ff [frame $pur_fr.$id -borderwidth 2 -relief sunken]
        set rcnt 0
    }
}
pack $ff -side left
#pack $pur_fr -side left

set mine_fr [ttk::labelframe $cost_frm.mcstm -text "Mined"]
set rcnt 0
set ff [frame $mine_fr.f0 -borderwidth 2 -relief sunken]
foreach r $far_db::res_lst {
    if {[lindex $r 0] == "0"} {continue}
    set dat [lindex $r 1]
    if {[lindex $dat end] == {}} {continue}
    set id [lindex $r 0]
    set rfr [frame $ff.$id -borderwidth 2 -relief sunken]
    set lbnam "$id:[lindex $dat 0]"
    set lbcolr [lindex $dat 4]
    set nam [lindex $dat 0]
    set ty [lindex $dat 2]
    if {$ty == "Side" || $ty == "Material"} {continue}
    set lb1 [label $rfr.lb1 -text $lbnam -width 9 -font font_info_txt -background $lbcolr -foreground white]
    set lnam [string tolower $nam 0 end]
    set en1 [scale $rfr.$lnam -orient horizontal -length 96 -sliderlength 22 -variable refine::$nam]
    set uzrcfg::slide_lst [lappend uzrcfg::slide_lst $en1]
    bind $en1 <ButtonRelease-1> {update_user_values}
    pack $lb1 $en1 -side left -fill y -expand 1
    pack $rfr -fill x -expand 1
    incr rcnt
    if {$rcnt >= 12} {
        pack $ff -side left
        set ff [frame $mine_fr.$id -borderwidth 2 -relief sunken]
        set rcnt 0
    }
}

pack $ff -side left
#pack $pur_fr $mine_fr -side left
pack $pur_fr -side left

#  show sides sliders.
set pur1_fr [ttk::labelframe $cost_frm.mcst1 -text "Sides"]
set rcnt 0
set ff [frame $pur1_fr.f0 -borderwidth 2 -relief sunken]

foreach r $far_db::res_lst {
    if {[lindex $r 0] == "0"} {continue}
    set dat [lindex $r 1]
    if {[lindex $dat end] == {}} {continue}
    set id [lindex $r 0]
    set rfr [frame $ff.$id -borderwidth 2 -relief sunken]
    set lbnam "$id:[lindex $dat 0]"
    set lbcolr [lindex $dat 4]
    set nam [lindex $dat 0]
    set ty [lindex $dat 2]
    set kind [lindex $dat 3]
    #puts $dat
    if {$ty == "Material" && $kind == "Side"} {
        set lb1 [label $rfr.lb1 -text $lbnam -width 9 -font font_info_txt -background $lbcolr -foreground white]
        set lnam [string tolower $nam 0 end]
        set en1 [scale $rfr.$lnam -orient horizontal -length 96 -sliderlength 22 -variable refine::$nam]
        set uzrcfg::slide_lst [lappend uzrcfg::slide_lst $en1]
        bind $en1 <ButtonRelease-1> {update_user_values}
        pack $lb1 $en1 -side left -fill y -expand 1
        pack $rfr -fill x -expand 1
        incr rcnt
        if {$rcnt >= 7} {
            pack $ff -side left
            set ff [frame $pur1_fr.$id -borderwidth 2 -relief sunken]
            set rcnt 0
        }
    }
}
pack $ff -side left
#pack $pur1_fr -side left

# show refined  sliders
set pur2_fr [ttk::labelframe $cost_frm.mcst2 -text "Refined"]
set rcnt 0
set ff [frame $pur2_fr.f0 -borderwidth 2 -relief sunken]

foreach r $far_db::res_lst {
    if {[lindex $r 0] == "0"} {continue}
    set dat [lindex $r 1]
    if {[lindex $dat end] == {}} {continue}
    set id [lindex $r 0]
    set rfr [frame $ff.$id -borderwidth 2 -relief sunken]
    set lbnam "$id:[lindex $dat 0]"
    set lbcolr [lindex $dat 4]
    set nam [lindex $dat 0]
    set ty [lindex $dat 2]
    set kind [lindex $dat 3]
    
    if {$ty == "Material" && $kind != "Side"} {
        set lb1 [label $rfr.lb1 -text $lbnam -width 9 -font font_info_txt -background $lbcolr -foreground white]
        set lnam [string tolower $nam 0 end]
        set en1 [scale $rfr.$lnam -orient horizontal -length 96 -sliderlength 22 -variable refine::$nam]
        set uzrcfg::slide_lst [lappend uzrcfg::slide_lst $en1]
        bind $en1 <ButtonRelease-1> {update_user_values}
        pack $lb1 $en1 -side left -fill y -expand 1
        pack $rfr -fill x -expand 1
        incr rcnt
        if {$rcnt >= 6} {
            pack $ff -side left
            set ff [frame $pur2_fr.$id -borderwidth 2 -relief sunken]
            set rcnt 0
        }
    }
}
pack $ff -side left
#pack $pur2_fr -side left

pack $cost_frm


set calofr [ttk::labelframe $uzrcfg::ufr.mcost1 -text "Mining to Refining Cost Allocations"]
#  metals
set oreg1 [ttk::labelframe $calofr.m2s -text "Metal 1M 2S" -borderwidth 4 -relief sunken]
set orefr [frame $oreg1.ofr -borderwidth 4 -relief sunken]
set orelbp [ttk::labelframe $orefr.op -text "Material"]
set oreenp [entry $orelbp.en1 -width 10 -textvariable refine::m1m1]
set orelbm [ttk::labelframe $orefr.op1 -text "Sides"]
set oreenm [entry $orelbm.en11 -width 10 -textvariable refine::m1s1]
set oreenm1 [entry $orelbm.en111 -width 10 -textvariable refine::m1s2]
pack $oreenp
pack $orelbp
pack $oreenm $oreenm1
pack $orelbm
pack $orefr
pack $oreg1 -side left
set oreg2 [ttk::labelframe $calofr.m1s -text "Metal 2M 1S" -borderwidth 4 -relief sunken]
set orefr [frame $oreg2.ofr -borderwidth 4 -relief sunken]
set orelbp [ttk::labelframe $orefr.op -text "Materials"]
set oreenp [entry $orelbp.en1 -width 10 -textvariable refine::m2m1]
set oreenm [entry $orelbp.en11 -width 10 -textvariable refine::m2m2]
set orelbm [ttk::labelframe $orefr.op1 -text "Side"]
set oreenm1 [entry $orelbm.en111 -width 10 -textvariable refine::m2s1]
pack $oreenp
pack $orelbp
pack $oreenm $oreenm1
pack $orelbm
pack $orefr
pack $oreg2 -side left
# oils
set oreg1 [ttk::labelframe $calofr.o2s -text "Oil 1M 2S" -borderwidth 4 -relief sunken]
set orefr [frame $oreg1.ofr -borderwidth 4 -relief sunken]
set orelbp [ttk::labelframe $orefr.op -text "Material"]
set oreenp [entry $orelbp.en1 -width 10 -textvariable refine::o1m1]
set orelbm [ttk::labelframe $orefr.op1 -text "Sides"]
set oreenm [entry $orelbm.en11 -width 10 -textvariable refine::o1s1]
set oreenm1 [entry $orelbm.en111 -width 10 -textvariable refine::o1s2]
pack $oreenp
pack $orelbp
pack $oreenm $oreenm1
pack $orelbm
pack $orefr
pack $oreg1 -side left
set oreg2 [ttk::labelframe $calofr.o1s -text "Oil 2M 1S" -borderwidth 4 -relief sunken]
set orefr [frame $oreg2.ofr -borderwidth 4 -relief sunken]
set orelbp [ttk::labelframe $orefr.op -text "Materials"]
set oreenp [entry $orelbp.en1 -width 10 -textvariable refine::o2m1]
set oreenm [entry $orelbp.en11 -width 10 -textvariable refine::o2m2]
set orelbm [ttk::labelframe $orefr.op1 -text "Side"]
set oreenm1 [entry $orelbm.en111 -width 10 -textvariable refine::o2s1]
pack $oreenp
pack $orelbp
pack $oreenm $oreenm1
pack $orelbm
pack $orefr
pack $oreg2 -side left
# gass
set oreg1 [ttk::labelframe $calofr.g2s -text "Gas 1M 2S" -borderwidth 4 -relief sunken]
set orefr [frame $oreg1.ofr -borderwidth 4 -relief sunken]
set orelbp [ttk::labelframe $orefr.op -text "Material"]
set oreenp [entry $orelbp.en1 -width 10 -textvariable refine::g1m1]
set orelbm [ttk::labelframe $orefr.op1 -text "Sides"]
set oreenm [entry $orelbm.en11 -width 10 -textvariable refine::g1s1]
set oreenm1 [entry $orelbm.en111 -width 10 -textvariable refine::g1s2]
pack $oreenp
pack $orelbp
pack $oreenm $oreenm1
pack $orelbm
pack $orefr
pack $oreg1 -side left
set oreg2 [ttk::labelframe $calofr.g1s -text "Gas 2M 1S" -borderwidth 4 -relief sunken]
set orefr [frame $oreg2.ofr -borderwidth 4 -relief sunken]
set orelbp [ttk::labelframe $orefr.op -text "Materials"]
set oreenp [entry $orelbp.en1 -width 10 -textvariable refine::g2m1]
set oreenm [entry $orelbp.en11 -width 10 -textvariable refine::g2m2]
set orelbm [ttk::labelframe $orefr.op1 -text "Side"]
set oreenm1 [entry $orelbm.en111 -width 10 -textvariable refine::g2s1]
pack $oreenp
pack $orelbp
pack $oreenm $oreenm1
pack $orelbm
pack $orefr
pack $oreg2 -side left

set oreg2 [ttk::labelframe $calofr.n2s -text "Natural 1M 2S" -borderwidth 4 -relief sunken]
set orefr [frame $oreg2.ofr -borderwidth 4 -relief sunken]
set orelbp [ttk::labelframe $orefr.op -text "Natural"]
set oreenp [entry $orelbp.en1 -width 10 -textvariable refine::n1n1]
set orelbm [ttk::labelframe $orefr.op1 -text "Sides"]
set oreenm [entry $orelbm.en11 -width 10 -textvariable refine::n1s1]
set oreenm1 [entry $orelbm.en111 -width 10 -textvariable refine::n1s2]
pack $oreenp
pack $orelbp
pack $oreenm $oreenm1
pack $orelbm
pack $orefr
pack $oreg2 -side left

set oreg2 [ttk::labelframe $calofr.n22s -text "Natural 2M 2S" -borderwidth 4 -relief sunken]
set orefr [frame $oreg2.ofr -borderwidth 4 -relief sunken]
set orelbp [ttk::labelframe $orefr.op -text "Naturals"]
set oreenp [entry $orelbp.en1 -width 10 -textvariable refine::n2n1]
set oreenp1 [entry $orelbp.en2 -width 10 -textvariable refine::n2n2]
set orelbm [ttk::labelframe $orefr.op1 -text "Sides"]
set oreenm [entry $orelbm.en11 -width 10 -textvariable refine::n2s1]
set oreenm1 [entry $orelbm.en111 -width 10 -textvariable refine::n2s2]
pack $oreenp
pack $oreenp1
pack $orelbp
pack $oreenm $oreenm1
pack $orelbm
pack $orefr
pack $oreg2 -side left


#pack $calofr -anchor s -expand 1
