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


# ########################################
proc show_res_details {wid fr} {
    update
    
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set reso [$wid get $sel_idx]
    #puts $reso
    foreach r $res::res_lst {
        set reso_info [string first $reso $r]
        if {$reso_info >= 0} {
            set info $r
            break
        }
    }
    set idx 0
    set sr [split $r ","]
    set sh [split $res::res_header ","]
    # clean up from previous
    foreach t $sh {
        destroy $fr.fr$idx
        incr idx
    }
    
    set idx 0
    foreach t $sh {
        destroy .main.fr$idx
        set if_fr$idx [frame $fr.fr$idx]
        set lbname [lindex $sr $idx]
        puts $lbname
        if {$lbname == ""} {
            incr idx
            continue
        }
        set lb [label $fr.fr$idx.lb -text $lbname]
        set lb1 [label $fr.fr$idx.lb2 -text $t]
        pack $lb1 $lb -side left -padx 20
        pack $fr.fr$idx -anchor w
        incr idx
    }
    #puts $r
}





set version "Alpha 0.1"
wm title . "Farsite Workbench $version"
# #############################
bind . <F12> {catch {console show}}
console show

# This is the menu
#set mb [menu .mb1 -type menubar -tearoff 0]
#  menue source here

#  command buttons and options frame
set cmdf [frame .fc -borderwidth 4 -relief sunken]
set cmdb [button $cmdf.bt1 -text "Reload" -command {source "c:/work/Farsite/FS_API/tcl_src/far_procs.tcl"}]
pack $cmdb
pack $cmdf -side top -anchor n -fill x -expand 1

# This is the message and command line frame
set c [ttk::frame .f1 -borderwidth 4 -relief sunken]
set cmd_ent [entry $c.cmd1]
pack $cmd_ent -side bottom -anchor s -expand 1 -fill x -padx 2
set hlp_lb [label $c.hlb -textvariable helpVar -justify left]
pack $hlp_lb -side left -fill x -padx 4
pack .f1 -side bottom -anchor s -fill x

# setup the notebook
set nb [ttk::notebook .note]
pack $nb -side top -fill both -expand 1 -anchor n 
set mfr $nb.base
#$nb add [frame .note.reso -borderwidth 4 -relief sunken] -text  "Farsite DB" -underline 0
$nb add [frame $mfr -borderwidth 4 -relief sunken] -text  "Farsite DB" -underline 0
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
$nb add [frame .note.mods -borderwidth 4 -relief sunken] -text  "Modules" -underline 2
ttk::notebook::enableTraversal $nb

source "c:/work/Farsite/FS_API/tcl_src/far_procs.tcl"

load_base




bind . <Motion> "+mouse_move %W %x %y"
# ###########
# #  the zone and action for mouse movement
proc mouse_move {wid x y} {
    global helpVar
    set helpVar "x: $x y: $y Win: $wid "
}
