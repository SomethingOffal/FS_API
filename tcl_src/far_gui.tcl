#! /usr/bin/env wish
##-------------------------------------------------------------------------------
##-------------------------------------------------------------------------------
##--                     Copyright 2014 Sckoarn
##--                        All Rights Reserved
##
##           This program is free software; you can redistribute it and/or modify
##               it under the terms of the GNU General Public License as published by
##               the Free Software Foundation; either version 2 of the License, or
##               (at your option) any later version.
##           
##               This program is distributed in the hope that it will be useful,
##               but WITHOUT ANY WARRANTY; without even the implied warranty of
##               MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##               GNU General Public License for more details.
##           
##               You should have received a copy of the GNU General Public License
##               along with this program; if not, write to the Free Software
##               Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##-------------------------------------------------------------------------------
##-- $Author: sckoarn $
##--
##-- $Date: 2013/12/29 04:01:43 $
##--
##-- $Name:  $
##--
##-- $Id:  $
##--
##-- $Source:  $
##--
##-- Description :
##--      This application assists the user by eabling the user to create their
##           own collection of items and BPO's to calculate manufacture cost.
##--      
##------------------------------------------------------------------------------
#  Packages
package require Ttk
package require Tk

#  put all the variables in one file.
#source "./far_var.tcl"
#source "c:/work/Farsite/src/far_var.tcl"

source "c:/work/Farsite/FS_API/tcl_src/tcl_db.tcl"

set version "Alpha 0.2"
wm title . "Farsite Workbench $version"
# #############################
bind . <F12> {catch {console show}}
console show

# This is the menu
#set mb [menu .mb1 -type menubar -tearoff 0]
#  menue source here

#  command buttons and options frame
set cmdf [frame .fc -borderwidth 4 -relief sunken]
set cmdb [button $cmdf.bt1 -text "Reload" -command {source "c:/work/Farsite/FS_API/tcl_src/user_procs.tcl"}]
pack $cmdb
pack $cmdf -side top -anchor n -fill x -expand 1

# This is the message and command line frame
set c [ttk::frame .f1 -borderwidth 4 -relief sunken]
set cmd_ent [entry $c.cmd1]
pack $cmd_ent -side bottom -anchor s -expand 1 -fill x -padx 2
set hlp_lb [label $c.hlb -textvariable helpVar -justify left]
pack $hlp_lb -side left -fill x -padx 4
#pack .f1 -side bottom -anchor s -fill x

# setup the notebook
set nb [ttk::notebook .note -height 1100]
pack $nb -anchor n -side top -expand 1 -fill both
pack .f1 -side bottom -anchor s -fill x
set mfr $nb.base
#$nb add [frame .note.reso -borderwidth 4 -relief sunken] -text  "Farsite DB" -underline 0
$nb add [frame $mfr -borderwidth 4 -relief sunken] -text "\[ Farsite DB \]" -underline 0 -padding {5 5 5 5}
# This is the planets list frame.
set w [ttk::frame $mfr.f2 -borderwidth 4 -relief sunken -width 96]
#pack $w -fill both -expand 1
# ships name space
namespace eval ship {
    set slb {}
    set info_win {}
    set ship_lst {}
    set ship_header ""
}
# ships list box
set sfr [frame $w.sfr -borderwidth 4 -relief sunken]
set ship::slb [listbox $sfr.shp -width 30]
pack $ship::slb -anchor w -side left -fill y -expand 1
bind $ship::slb <ButtonRelease-1> { show_ship_details %W }
bind $ship::slb <KeyRelease> { show_ship_details %W}
# components name space
namespace eval comp {
    set clb {}
    set info_win {}
    set comp_lst {}
    set comp_header ""
    set comp_filter {}
    set comp_id ""
}
# components list box
set cfr [frame $w.cfr -borderwidth 4 -relief sunken]
set comp::clb [listbox $cfr.cmp -width 34]
set comp::filter [entry $cfr.en1 -width 34 -borderwidth 4 -relief raised]
pack $comp::filter -fill x
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
pack $sfr $cfr $rfr -side left -fill y -expand 1

namespace eval info {
    set info_fr {}
}

set info::info_fr [frame $mfr.inf -width 120 -borderwidth 4 -relief sunken]
set info_lb [label $info::info_fr.lb1 -text "This is a default message message .....  until something is clicked."]
pack $info_lb -side top -fill x
# pack the main frames.
#pack $w  -side left  -fill y -expand 1
pack $w  -side left  -fill y -expand 1 -anchor w
#pack $info::info_fr  -side left  -fill both -expand 1 -anchor w
pack $info::info_fr -anchor nw

# ##################
set modfr .note.mods
$nb add [frame .note.mods -borderwidth 4 -relief sunken] -text  "\[ User Ships \]" -underline 2 -padding {5 5 5 5}
ttk::notebook::enableTraversal $nb

# ##################
namespace eval uzr {
    set name ""
    set id ""
    set email ""
    set pw ""
    set key ""
    set user_note_frame {};  # user frame
}

$nb add [ttk::frame .note.usr -borderwidth 4 -relief sunken] -text  "\[ User Status \]" -underline 2 -padding {5 5 5 5}

set uzr_work_fr .note.usr
#set uzr::user_note_frame [ttk::frame $uzr_work_fr.uinfo -borderwidth 4 -relief sunken -height 800]
set uzr::user_note_frame [ttk::frame $uzr_work_fr.uinfo -borderwidth 4 -relief sunken -height 1800]
#set uzr::user_note_frame $uzr_work_fr

set ufr [frame $uzr_work_fr.bts -borderwidth 4 -relief sunken]
set ubfr [frame $ufr.bfr1 -height 10]
set nfr [frame $ubfr.nf]
set nlb [label $nfr.lb1 -text "Log Email: "]
set unen [entry $nfr.en1 -width 25 -textvariable uzr::email]
pack $nlb $unen -side left
set pfr [frame $ubfr.pf]
set plb [label $pfr.lb1 -text "Log Password: "]
set pnen [entry $pfr.en1 -width 35 -show "#" -textvariable uzr::pw]
set gbtn [button $pfr.bt1 -text "Get" -command get_uzr_info]
set lbtn [button $pfr.bt2 -text "Load" -command {load_uzr_info; generate_view}]
pack $plb $pnen -side left
pack $nfr $pfr -side left
pack $gbtn $lbtn -side left
pack $ubfr -side top -anchor n -expand 1 -fill x
pack $ufr -side top -anchor n -expand 1 -fill x


# ###############################################################################
#   test tab
namespace eval 3D {
    set ufr {}
    set canv {}
    set sys_lst {}
    set sys_conn_lst {}
    set planet_lst {}
    set origin {0.0,0.0,0.0}
    
}

$nb add [frame .note.tst -borderwidth 4 -relief sunken] -text  "\[ Test \]" -underline 2 -padding {5 5 5 5}
set 3D::ufr .note.tst
#pack $3D::ufr -side left -fill both -expand 1


#pack $uzr::user_note_frame -side top -anchor n -expand 1 -fill both
pack $uzr::user_note_frame -fill both -expand 1

#pack $uzr::user_note_frame  -side left -expand 1 -fill both
#set cfgs [ttk::style configure style]
#puts $cfgs
#?-option ?value option value...? ?
#ttk::notebook::enableTraversal $nb

source "c:/work/Farsite/FS_API/tcl_src/far_procs.tcl"
source "c:/work/Farsite/FS_API/tcl_src/user_procs.tcl"
source "c:/work/Farsite/FS_API/tcl_src/test_procs.tcl"

load_base




bind . <Motion> "+mouse_move %W %x %y"
# ###########
# #  the zone and action for mouse movement
proc mouse_move {wid x y} {
    global helpVar
    set helpVar "x: $x y: $y Win: $wid "
}


# ###   the universe
#https://farsite.online/api/1.0/universe
#https://farsite.online/api/1.0/universe  --> Constellations
#https://farsite.online/api/1.0/universe/star/1/planets  --> Planets of a Star
#https://farsite.online/api/1.0/universe/planets/HOM-11/sectors  ##  replace HOM-11 with planet.

