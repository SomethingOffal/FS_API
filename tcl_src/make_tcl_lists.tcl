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
# -------------------------------------------------------------------------------
#  Packages
package require Ttk
package require Tk
# #############################
bind . <F12> {catch {console show}}
source get_universe.tcl

gen_planet_db
gen_gate_db
gen_star_db
gen_station_db

set univers {}
foreach s $spg::sdb {
    set slst {}
    set slst [lappend slst $spg::sfields]
    set nlst {}
    foreach f $s {
        #puts $f
        set q [string trimleft $f "{"]
        set q [string trimright $q "}"]
        set q [string trim $q "\""]
        set nlst [lappend nlst $q]
    }
    set slst [lappend slst $nlst]
    set sid [lindex $s 0]
    # planets
    set plst {}
    set plst [lappend plst $spg::pfields]
    foreach p $spg::pdb {
        if {[lindex $p 0] == $sid} {
            set nlst {}
            foreach f $p {
                #puts $f
                set q [string trimleft $f "{"]
                set q [string trimright $q "}"]
                set q [string trim $q "\""]
                set nlst [lappend nlst $q]
            }
            set plst [lappend plst $nlst]
        }
    }
    # gates
    set glst {}
    set glst [lappend glst $spg::gfields]
    foreach p $spg::gdb {
        if {[lindex $p 0] == $sid} {
            set nlst {}
            foreach f $p {
                #puts $f
                set q [string trimleft $f "{"]
                set q [string trimright $q "}"]
                set q [string trim $q "\""]
                set sq [split $q " "]
                if {[llength $sq] > 1} {
                    set nlst [lappend nlst [lindex $sq 1]]
                } else {
                    set nlst [lappend nlst $q]
                }
            }
            set glst [lappend glst $nlst]
        }
    }
    # stations
    set stlst {}
    set stlst [lappend stlst $spg::stfields]
    foreach s $spg::stdb {
        if {[lindex $s 0] == $sid} {
            set nlst {}
            foreach f $s {
                puts $f
                set s [string trimleft $f "{"]
                set s [string trimright $s "}"]
                set s [string trim $s "\""]
                set ss [split $s " "]
                if {[llength $ss] > 1} {
                    set nlst [lappend nlst [lindex $ss 1]]
                } else {
                    set nlst [lappend nlst $s]
                }
            }
            set stlst [lappend stlst $nlst]
        }
    }
    
    set slst [lappend slst $plst]
    set slst [lappend slst $glst]
    set slst [lappend slst $stlst]
    set univers [lappend univers $slst]
}



proc csv2tlst {fh} {
    # get the header of the csv file
    set header [gets $fh]
    # set up variables
    set res_lst {}
    #  set up the header at index zero, with ID of zero
    set lheader [lappend lheader "0"]
    set sheader [split $header "," ]
    set header_lst {}
    foreach sh $sheader {
        set header_lst [lappend header_lst $sh]
    }
    set lheader [lappend lheader $header_lst]
    set res_lst [lappend res_lst $lheader]
    ##  get the rest of the file.
    while {![eof $fh]} {
        set tl [gets $fh]
        if {$tl == ""} {
            continue
        }
        set stl [split $tl ","]
        set tlst [lindex $stl 0]
        set idx 1
        set dlst {}
        while {$idx < [llength $stl]} {
            set dlst [lappend dlst [lindex $stl $idx]]
            incr idx
        }
        set tlst [lappend tlst $dlst]
        set res_lst [lappend res_lst $tlst]
    }
    # return the converted list.
    return $res_lst
}

set fo [open "C:/work/Farsite/FS_API/tcl_src/tcl_db.tcl" "w"]
set fh [open "C:/work/Farsite/FS_API/Resources.csv" "r"]
set res_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/refinery_outputs.csv" "r"]
set refo_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/refinery_main_requirements.csv" "r"]
set refreq_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/mining_requirements.csv" "r"]
set mine_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/component_resource_requirements.csv" "r"]
set compres_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/component_main_requirements.csv" "r"]
set compmain_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/components.csv" "r"]
set comps_lst [csv2tlst $fh]
close $fh

set fh [open "C:/work/Farsite/FS_API/module_main_reqs.csv" "r"]
set modules_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/module_input_reqs.csv" "r"]
set modules_input_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/ship_main_reqs.csv" "r"]
set ships_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/ship_comp_reqs.csv" "r"]
set ship_input_lst [csv2tlst $fh]
close $fh


set blueprints [get_bp_lst]

puts $fo "#! /usr/bin/env wish"
puts $fo "# -------------------------------------------------------------------------------"
puts $fo "# -------------------------------------------------------------------------------"
puts $fo "# --                     Copyright 2022 Sckoarn"
puts $fo "# --                        All Rights Reserved"
puts $fo "#"
puts $fo "#           This program is free software; you can redistribute it and/or modify"
puts $fo "#               it under the following terms:"
puts $fo "#               1) reproduction of this code shall include this header."
puts $fo "#               2) This program is distributed in the hope that it will be useful,"
puts $fo "#               but WITHOUT ANY WARRANTY; without even the implied warranty of"
puts $fo "#               MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
puts $fo "#               3)  You may NOT sell this code, or any part there of."  
puts $fo "#  *** This is a generated file, see make_tcl_lists.tcl for the details   ***"
puts $fo "# -------------------------------------------------------------------------------"
puts $fo ""

puts $fo "namespace eval far_db \{"
puts $fo "    set res_lst \{\}"
puts $fo "    set refo_lst \{\}"
puts $fo "    set refreq_lst \{\}"
puts $fo "    set mine_lst \{\}"
puts $fo "    set compres_lst \{\}"
puts $fo "    set compmain_lst \{\}"
puts $fo "    set comps_lst \{\}"
puts $fo "    set bp_lst \{\}"
puts $fo "    set star_lst \{\}"
puts $fo "    set ship_lst \{\}"
puts $fo "    set ship_input_lst \{\}"
puts $fo "    set modules_lst \{\}"
puts $fo "    set modules_input_lst \{\}"
puts $fo "\}"
puts $fo ""

puts $fo "set far_db::res_lst \{ $res_lst \}"
puts $fo ""
puts $fo "set far_db::refo_lst \{ $refo_lst \}"
puts $fo ""
puts $fo "set far_db::refreq_lst \{ $refreq_lst \}"
puts $fo ""
puts $fo "set far_db::mine_lst \{ $mine_lst \}"
puts $fo ""
puts $fo "set far_db::compres_lst \{ $compres_lst \}"
puts $fo ""
puts $fo "set far_db::compmain_lst \{ $compmain_lst \}"
puts $fo ""
puts $fo "set far_db::comps_lst \{ $comps_lst \}"
puts $fo ""
puts $fo "set far_db::bp_lst \{$blueprints \}"
puts $fo ""
puts $fo "set far_db::ship_lst \{$ships_lst \}"
puts $fo ""
puts $fo "set far_db::ship_input_lst \{$ship_input_lst \}"
puts $fo ""
puts $fo "set far_db::modules_lst \{$modules_lst \}"
puts $fo ""
puts $fo "set far_db::modules_input_lst \{$modules_input_lst \}"
puts $fo ""
puts $fo "set far_db::star_lst \{$univers \}"

close $fo

exit
