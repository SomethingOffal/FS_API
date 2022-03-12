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

#  use name spaces everywhere.
#   name spaces are used for most items in this file.
namespace eval sys {
    set cdir ""
    set helpVar ""
}

# # get the current location of where I am running from
set me [file normalize [info script]]
set me_path [string range $me 0 [string last "/" $me]]
#puts $me_path
set sys::cdir $me_path
source "$sys::cdir/tcl_db.tcl"

set version "Alpha 0.5"
wm title . "Farsite Workbench $version"
# #############################
bind . <F12> {catch {console show}}
console show


font create font_tabs -family Helvetica -size 10 -weight bold

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
pack $cmd_ent -side bottom -anchor s -expand 1 -fill x -padx 2
set hlp_lb [label $c.hlb -textvariable sys::helpVar -justify left]
pack $hlp_lb -side left -fill x -padx 4


ttk::style configure TNotebook.Tab -font font_tabs
ttk::style configure TNotebook.Tab -foreground #222288

# setup the notebook
set nb [ttk::notebook .note -height 1100]
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
}
# components details frame
set cdfr [frame $w.cdfr -borderwidth 4 -relief sunken]
set cmp_dets::canv [canvas $cdfr.cav1 -width 450 -height 1200]
pack $cmp_dets::canv -anchor w -side left -fill y -expand 1
$cmp_dets::canv configure -scrollregion {0 0 450 3600}
#bind $cmp_dets::canv <ButtonRelease-1> { show_ship_details %W }
#bind $cmp_dets::canv <KeyRelease> { show_ship_details %W}
# components name space
namespace eval comp {
    set clb {}
    set info_win {}
    set comp_lst {}
    set comp_header ""
    set comp_filter {}
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
#set ccb1 [checkbutton $cctlfr.ckb1 -variable comp::show_uzr_comps -textvariable comp::show_uzr_txt -command fill_uzr_comps]
#pack $comp::filter $ccb1 -side left
pack $comp::filter -side left
pack $cctlfr -fill x
bind $comp::filter <KeyRelease> { filter_lb %W $comp::clb}
pack $comp::clb -anchor w -side left -fill y -expand 1

bind $comp::clb <ButtonRelease-1> { show_comp_details %W }
bind $comp::clb <KeyRelease> { show_comp_details %W}
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
bind $res::plb <ButtonRelease-1> { show_res_details %W }
bind $res::plb <KeyRelease> { show_res_details %W}


# pack main frames
pack $cdfr $cfr $rfr -side left -fill y -expand 1

namespace eval info {
    set info_fr {}
}

set info::info_fr [frame $mfr.inf -width 120 -borderwidth 4 -relief sunken]
set info_lb [label $info::info_fr.lb1 -text "This is a default message message .....  until something is clicked."]
pack $info_lb -side top -fill x
# pack the main frames.
pack $w  -side left  -fill y -expand 1 -anchor w
pack $info::info_fr -anchor nw

# ##################
#set modfr .note.mods
#$nb add [frame .note.mods -borderwidth 4 -relief sunken] -text  "\[ User Ships \]" -underline 2 -padding {5 5 5 5}
#ttk::notebook::enableTraversal $nb

# ##################
namespace eval uzr {
    set name ""
    set id ""
#    set email ""
#    set pw ""
    set key ""
    set user_note_frame {};  # user frame
    set bkup_en 1
}

$nb add [ttk::frame .note.usr -borderwidth 4 -relief sunken] -text  "\[ User Status \]" -padding {5 5 5 5}

set uzr_work_fr .note.usr
set uzr::user_note_frame [ttk::frame $uzr_work_fr.uinfo -borderwidth 4 -relief sunken -height 1800]

set ufr [frame $uzr_work_fr.bts -borderwidth 4 -relief sunken]
set ubfr [frame $ufr.bfr1 -height 10]
set nfr [frame $ubfr.nf]
set pfr [frame $ubfr.pf]
#set plb [label $pfr.lb1 -text "User ID: "]
#set pnen [entry $pfr.en1 -width 7 -show "#" -textvariable uzr::id]
#set gbtn [button $pfr.bt1 -text "Get Status" -command get_uzr_info]
set lbtn [button $pfr.bt2 -text "Load Status" -command {load_uzr_info; generate_view}]
#set bucb [checkbutton $pfr.cb1 -text "Backup Enable " -variable uzr::bkup_en -anchor w]
#pack $plb $pnen -side left
pack $nfr $pfr -side left
pack $lbtn -side left
#pack $gbtn $lbtn -side left
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

source "$sys::cdir/far_procs.tcl"
source "$sys::cdir/user_procs.tcl"
#source "$sys::cdir/test_procs.tcl"

load_base

# If the user has loaded accout data before
if {[file exists "../Account.csv"] == 1} {
    load_uzr_info
    generate_view
}

# ##########################################################
#   load user saved settings and ...
set is_ini [file exists "~/far_tool/.far_ini"]
if {$is_ini == 1} {
    source "~/far_tool/.far_ini"
} else {
    file mkdir "~/far_tool"
    set th [open "~/far_tool/.far_ini" "w"]
    puts $th "puts \"Test out ...\""
    close $th
}

namespace eval glbl  {
    set uzr_mat_lst {}
    set uzr_sec_lst {}
}


bind . <Motion> "+mouse_move %W %x %y"
# ###########
# #  the zone and action for mouse movement
proc mouse_move {wid x y} {
    #global helpVar
    set sys::helpVar "x: $x y: $y Win: $wid "
}

#  when the user exits deal with ini
proc user_exit {} {
    if {[tk_messageBox -message "Quit?" -type yesno] eq "yes"} {
        #if {[tk_messageBox -message "Update ini?" -type yesno] eq "yes"} {
        #   puts "updating ini ..."
        #}
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

