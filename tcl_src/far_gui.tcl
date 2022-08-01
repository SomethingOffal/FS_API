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

#  Packages
package require Ttk
package require Tk

#package require sqlite3

#  use name spaces everywhere.
#   name spaces are used for most items in this file.
namespace eval sys {
    set cdir ""
    set helpVar ""
    set modeVar "R"
    set devmode 0
}

# # get the current location of where I am running from
set me [file normalize [info script]]
set me_path [string range $me 0 [string last "/" $me]]
#puts $me_path
set sys::cdir $me_path
source "$sys::cdir/tcl_db.tcl"
source "$sys::cdir/name_spaces.tcl"
source "$sys::cdir/popups.tcl"

set version "Alpha 2.31 BP Costing"
wm title . "Farsite Workbench $version"
# #############################
bind . <F12> {catch {console show}}
#console show


font create font_tabs -family Helvetica -size 10 -weight bold

# ##########################################################################
# #  Message, continue
proc usr_msg { msg } {
  tk_messageBox -message $msg -type ok
}
# This is the menu
#   menue  TBD
source "$sys::cdir/far_gui_menu.tcl"

#  command buttons and options frame
#set cmdf [frame .fc -borderwidth 4 -relief sunken]
#pack $mbar -side top -fill x -expand 1
#set cmdb [button $cmdf.bt1 -text "Reload" -command {source "$sys::cdir/user_procs.tcl"}]
#set cmdb [button $cmdf.bt1 -text "Reload"]
#pack $cmdb
#pack $cmdf -side top -anchor n -fill x -expand 1

# This is the message and command line frame
set c [ttk::frame .f1 -borderwidth 4 -relief sunken]
set cmd_ent [entry $c.cmd1]
#pack $cmd_ent -side bottom -anchor s -expand 1 -fill x -padx 2
set hlp_lb [label $c.hlb -textvariable sys::helpVar -justify left]
set sm_lb [label $c.sm1 -width 1 -textvariable sys::modeVar -justify left]
pack $sm_lb -side right -padx 4
pack $hlp_lb -side left -fill x -padx 4


ttk::style configure TNotebook.Tab -font font_tabs
ttk::style configure TNotebook.Tab -foreground #222288

# setup the notebook
set nb [ttk::notebook .note -height 1000]
pack $nb -anchor n -side top -expand 1 -fill both
pack .f1 -side bottom -anchor s -fill x
set mfr $nb.base

$nb add [frame $mfr -borderwidth 4 -relief sunken] -text "\[ Farsite DB \]" -padding {5 5 5 5}
# This is the planets list frame.
set w [ttk::frame $mfr.f2 -borderwidth 4 -relief sunken -width 96]

# ships name space
namespace eval cmp_dets {
    set slb {}
    set info_win {}
    set canv {}
    set header ""
    set bp_lb {}
    set bp_cnt 0
    set bp_filter {}
}
# components details frame
set cdfr [frame $w.cdfr -borderwidth 4 -relief sunken]
set cmp_dets::bp_lb [listbox $cdfr.bplb -width 26 -height 40]
set bfr [frame $cdfr.sf1]
set cmp_dets::bp_filter [entry $bfr.en1  -width 16 -borderwidth 4 -relief raised]
bind $cmp_dets::bp_filter <KeyRelease> { filter_lb %W $cmp_dets::bp_lb }
set cmp_cnt [label $bfr.clb1 -textvariable cmp_dets::bp_cnt]
pack $cmp_dets::bp_filter $cmp_cnt -side left
pack $bfr -fill x
pack $cmp_dets::bp_lb -anchor w -side left -fill y -expand 1
bind $cmp_dets::bp_lb <ButtonRelease-1> { update_view %W}
bind $cmp_dets::bp_lb <KeyRelease> { update_view_key %W %k}
#$cmp_dets::canv configure -scrollregion {0 0 450 3600}
#bind $cmp_dets::canv <ButtonRelease-1> { show_ship_details %W }
#bind $cmp_dets::canv <KeyRelease> { show_ship_details %W}
# components name space
namespace eval comp {
    set clb {}
    set info_win {}
    set comp_lst {}
    set comp_header ""
    set comp_filter {}
    set comp_cnt 0
    set comp_id ""
    set show_uzr_txt "Show Buildable"
    set show_uzr_comps 0
    set uzr_comps_lst {}
}
# components list box
set cfr [frame $w.cfr -borderwidth 4 -relief sunken]
set cctlfr [frame $cfr.cctl]
set comp::clb [listbox $cfr.cmp -width 34]
set comp::filter [entry $cctlfr.en1 -width 16 -borderwidth 4 -relief raised]
set comp_cnt [label $cctlfr.clb1 -textvariable comp::comp_cnt]
#set ccb1 [checkbutton $cctlfr.ckb1 -variable comp::show_uzr_comps -textvariable comp::show_uzr_txt -command fill_uzr_comps]
#pack $comp::filter $ccb1 -side left
pack $comp::filter $comp_cnt -side left
pack $cctlfr -fill x
bind $comp::filter <KeyRelease> { filter_lb %W $comp::clb}
pack $comp::clb -anchor w -side left -fill y -expand 1

bind $comp::clb <ButtonRelease-1> { update_view %W}
bind $comp::clb <KeyRelease> { update_view_key %W %k}
# resources name space
namespace eval res {
    set plb {}
    set info_win {}
    set res_lst {}
    set res_header ""
    set res_fr {}
    set cur_type {}
    set cur_name ""
}
# resource  list box
set rfr [frame $w.rfr -borderwidth 4 -relief sunken]
set res::plb [listbox $rfr.res -width 10 -height 40]
pack $res::plb -anchor w -side left -fill y -expand 1
#bind $res::plb <ButtonRelease-1> { show_res_details %W }
bind $res::plb <ButtonRelease-1> { update_view %W}
bind $res::plb <KeyRelease> { update_view_key %W %k}


# pack main frames
pack $cdfr $cfr $rfr -side left -fill y -expand 1

namespace eval info {
    set info_fr {}
}

#set info::info_fr [frame $mfr.inf -width 120 -borderwidth 4 -relief sunken]
set info::info_fr [frame $mfr.inf -borderwidth 4 -relief sunken]
set info_lb [label $info::info_fr.lb1 -text "This is a default message message .....  until something is clicked."]
pack $info_lb -side top -fill x
# pack the main frames.
pack $w  -side left  -fill y -expand 1 -anchor w
pack $info::info_fr -fill both -expand 1 -anchor nw

# ##################
namespace eval uzr {
    set name ""
    set id ""
    set email ""
    set pw ""
    set key ""
    set user_note_frame {};  # user frame
    set bkup_en 1
    set univ_frame {}
    set univ_strlb {}
    set univ_pltlb {}
    set csel_star {}
    set univ_canv {}
    set canv_cent {650 500}
    set canv_nexts 0
    set canv_nsidx 0
    set canv_cnt2 0
    set canv_cnt3 0
    set canv_prev_star ""
    set canv_src_loc [list 0 0]
}

$nb add [ttk::frame .note.univ -borderwidth 4 -relief sunken] -text  "\[ Universe \]" -padding {5 5 5 5}

$nb add [ttk::frame .note.usr -borderwidth 4 -relief sunken] -text  "\[ User Status \]" -padding {5 5 5 5}

set uzr_work_fr .note.usr
set uzr::user_note_frame [ttk::frame $uzr_work_fr.uinfo -borderwidth 4 -relief sunken -height 1000]

set ufr [frame $uzr_work_fr.bts -borderwidth 4 -relief sunken]
set ubfr [frame $ufr.bfr1 -height 10]
set nfr [frame $ubfr.nf]
set pfr [frame $ubfr.pf]
set elb [label $pfr.lb1 -text "Email: "]
set enen [entry $pfr.en1 -width 26  -textvariable uzr::email]
set plb [label $pfr.lb2 -text "PassWord: "]
set pnen [entry $pfr.en2 -width 14 -show "#" -textvariable uzr::pw]
set gbtn [button $pfr.bt1 -text "Login" -command get_uzr_info]
set lbtn [button $pfr.bt2 -text "Load Status" -command {load_uzr_info; generate_view}]
#set bucb [checkbutton $pfr.cb1 -text "Backup Enable " -variable uzr::bkup_en -anchor w]
#pack $plb $pnen -side left
pack $nfr $pfr -side left
#pack $lbtn $elb $enen $plb $pnen $gbtn -side left
pack $lbtn -side left
#pack $bucb
pack $ubfr -side top -anchor n -expand 1 -fill x
pack $ufr -side top -anchor n -expand 1 -fill x

#pack $uzr::user_note_frame -side top -anchor n -expand 1 -fill both
pack $uzr::user_note_frame -anchor w -fill both -expand 1

#pack $uzr::user_note_frame  -side left -expand 1 -fill both
#set cfgs [ttk::style configure style]
#puts $cfgs
#?-option ?value option value...? ?
#ttk::notebook::enableTraversal $nb

#source "$sys::cdir/test_procs.tcl"

# ##########################
#   set perm  universe items and pack.
set univ_fr .note.univ
set uzr::univ_frame [ttk::frame $univ_fr.univinfo -borderwidth 4 -relief sunken -height 1800]
set slfr [frame $uzr::univ_frame.lfr]
set uzr::univ_strlb [listbox $slfr.slb -width 12 -height 26]
bind $uzr::univ_strlb <ButtonRelease-1> { show_star_view %W }
bind $uzr::univ_strlb <KeyRelease> { show_star_view %W}
set uzr::univ_pltlb [listbox $slfr.plb -width 12 -height 14]
bind $uzr::univ_pltlb <ButtonRelease-1> { show_planet_view %W }
bind $uzr::univ_pltlb <KeyRelease> { show_planet_view %W}
set cafr [frame $uzr::univ_frame.rfr]
set uzr::univ_canv [canvas $cafr.canv -width 1300 -height 1000 -borderwidth 4 -relief sunken]
$uzr::univ_canv configure -background #000000

pack $uzr::univ_strlb
pack $uzr::univ_pltlb
pack $slfr -side left -fill y -expand 1
pack $uzr::univ_canv -fill both -expand 1
pack $cafr -side right -fill both -expand 1
pack $uzr::univ_frame -anchor w -fill both -expand 1


source "$sys::cdir/far_procs.tcl"
source "$sys::cdir/user_procs.tcl"
source "$sys::cdir/far_costing.tcl"
source "$sys::cdir/user_cfg.tcl"

# load base view
load_base
# generate the user costing list
gen_costing_list

# If the user has loaded accout data before
if {[file exists "../Account.csv"] == 1} {
    load_uzr_info
    generate_view
}

# ##########################################################
#   load user saved settings and ...
set is_ini [file exists $glbl::uzr_ini]
if {$is_ini == 1} {
    source $glbl::uzr_ini
} else {
    file mkdir "~/far_tool"
    set th [open $glbl::uzr_ini "w"]
    puts $th "puts \"Test out ...\""
    close $th
}


bind . <Motion> "+mouse_move %W %x %y"
# ###########
# #  the zone and action for mouse movement
proc mouse_move {wid x y} {
    #global helpVar
    set sys::helpVar "x: $x y: $y Win: $wid "
}

# #################################
#
proc update_ini {} {
    set th [open $glbl::uzr_ini "w"]
    foreach r $uzrcfg::cost_tbl {
        set sr [split $r ":"]
        set wpath [lindex $sr 2]
        set val [$wpath get]
        puts $val
        set ostr "$wpath delete 0 end"
        puts $th $ostr
        if {$val != ""} {
            set ostr "$wpath insert end $val"
        } else {
            set ostr "$wpath insert end \"\""
        }
        puts $th $ostr
    }
    
    foreach s $glbl::uzr_ini_sliders {
        set val [$s get]
        set tstr $s
        append tstr " set " $val
        puts $th $tstr
    }
    
    #puts $th $uzrcfg::cost_tbl
    close $th
}


#  when the user exits deal with ini
proc user_exit {} {
    if {[tk_messageBox -message "Quit?" -type yesno] eq "yes"} {
        if {[tk_messageBox -message "Update ini?" -type yesno] eq "yes"} {
           puts "updating ini ..."
           update_ini
        }
       exit
    }
}

# when user hits the "x" button, come here close down
wm protocol . WM_DELETE_WINDOW {
    user_exit
}


# ###   the universe
#https://farsite.online/api/1.0/universe
#https://farsite.online/api/1.0/universe  --> Constellations
#https://farsite.online/api/1.0/universe/star/1/planets  --> Planets of a Star
#https://farsite.online/api/1.0/universe/planets/HOM-11/sectors  ##  replace HOM-11 with planet.

