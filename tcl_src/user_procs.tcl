# for reloading / sourcing more than once. ...
#set fts [font names]
#set is_f [lsearch $fts font_info_txt]
#if {$is_f  >= 0} {
#    font delete font_info_txt font_info_res
#}
#font create font_info_txt -family Helvetica -size 8
#font create font_info_res -family Helvetica -size 11 -weight bold

package require csv

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
               "../Modules.csv"}
    set info_lsts {{"this_header" "sectors" "sector_details" "ships" "ships_data" "account" "blueprints" "modules"}}
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

# #######################################
#   extract the clock value from the
#    farsite time string passed
proc get_time_val {tim} {
    puts $tim
    set stim [split $tim "T"]
    set mdate [lindex $stim 0]
    set mtime [lindex [split [lindex $stim 1] "."] 0]
    set ttime $mdate
    append ttime ",$mtime"
#    set timed [clock scan $ttime -format {%Y-%m-%d,%H:%M:%S} -timezone .015]
    set timed [clock scan $ttime -format {%Y-%m-%d,%H:%M:%S}]
        
    return $timed
}

# #################################
#   pad a string with passed value  space by default.
proc pad_str {str len {pad " "}} {
    set rtn $str
    set slen [string length $str]
    
    for {set i $slen} {$i <= $len} {incr i} {
        set rtn [append rtn $pad]
    }
    return $rtn
}

# ##############################################
#   load the user info
#
proc load_uzr_info {} {
    
    set ulsts::sec_lst {}
    set ulsts::secd_lst {}
    set ulsts::ship_lst {}
    set ulsts::shipd_lst {}
    set ulsts::acc_lst {}
    set ulsts::bp_lst {}
    
    
    set idx 0
    foreach f $dfiles::uflst {
        if {[file exists $f] == 1 } {
            set fh [open "$f" "r"]
            set tlst {}
            while {![eof $fh]} {
                set s [gets $fh]
                set tlst [lappend tlst $s]
            }
            #puts $tlst
            switch $idx {
                0 {
                    foreach i $tlst {
                        set ulsts::sec_lst [lappend ulsts::sec_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                1 {
                    foreach i $tlst {
                        set ulsts::secd_lst [lappend ulsts::secd_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                2 {
                    foreach i $tlst {
                        set ulsts::ship_lst [lappend ulsts::ship_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                3 {
                    foreach i $tlst {
                        set ulsts::shipd_lst [lappend ulsts::shipd_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                4 {
                    foreach i $tlst {
                        set ulsts::acc_lst [lappend ulsts::acc_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                5 {
                    foreach i $tlst {
                        set ulsts::bp_lst [lappend ulsts::pb_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                6 {
                    foreach i $tlst {
                        set ulsts::mod_lst [lappend ulsts::mod_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                default {puts "Error File index out side  range."}
            }
            incr idx
        }
    }
    
    #foreach s $dfiles::info_lsts {
    #    puts $s
    #}
    
}

# ############################################
#  fill the planet list box
proc fill_planet_listbox {fr} {
    
    $fr delete 0 end
    update
    set header [lindex $ulsts::sec_lst 0]
    set sheader [csv::split -alternate $header]
    #foreach s $sheader {
    #    puts $s
    #}
    set pidx [lsearch $sheader "planet.name"]
    #puts $pidx
    set dlst [lrange $ulsts::sec_lst 1 end]
    set idx 0
    set tlst {}
    foreach p $dlst {
        set pid [lindex [csv::split -alternate $p] $pidx]
        if {[lsearch $tlst $pid] >= 0} {
            continue
        } else {
            if {$pid < 0} {
                continue
            } else {
                set tlst [lappend tlst $pid]
                $fr insert end $pid
            }
        }
    }
}

# ############################################
#   fill sector list box
proc fill_sector_listbox {fr} {
    
    $fr delete 0 end
    update
    set header [lindex $ulsts::sec_lst 0]
    set sheader [csv::split -alternate $header]
    #foreach s $sheader {
    #    puts $s
    #}
    set sidx [lsearch -exact $sheader "name"]
    #puts $pidx
    set dlst [lrange $ulsts::sec_lst 1 end]
    set idx 0
    foreach s $dlst {
        set pid [lindex [csv::split -alternate $s] $sidx]
        if {$pid < 0} {
            continue
        } else {
            $fr insert end $pid
        }
    }
}

# ############################################
#   fill base list box
proc fill_base_listbox {fr} {
    
    $fr delete 0 end
    update
    set header [lindex $ulsts::secd_lst 0]
    set sheader [csv::split -alternate $header]
    #foreach s $sheader {
    #    puts $s
    #}
    set sidx [lsearch -exact $sheader "Full_Name"]
    set iidx [lsearch -exact $sheader "id"]
    set cycs [lsearch -exact $sheader "productionCyclesLeft"]
    puts $cycs
    set dlst [lrange $ulsts::secd_lst 1 end]
    set idx 0
    foreach s $dlst {
        if {$s == ""} {
            continue
        }
        set pid [lindex [csv::split -alternate $s] $sidx]
        append pid ":[lindex [csv::split -alternate $s] $iidx]"
        if {$pid < 0} {
            continue
        } else {
            set cy [lindex [csv::split -alternate $s] $cycs]
            $fr insert end $pid
            if {$cy == 0} {
                $fr itemconfigure end  -background pink1
            } elseif {$cy < 6} {
                $fr itemconfigure end -background orange1
            } else {
                $fr itemconfigure end -background green3
            }
        }
    }
}

# ############################################
#   fill sector list box
proc fill_ship_listbox {fr} {
    
    $fr delete 0 end
    update
    set header [lindex $ulsts::ship_lst 0]
    set sheader [csv::split -alternate $header]
    #foreach s $sheader {
    #    puts $s
    #}
    set IDidx [lsearch -exact $sheader "id"]
    set sidx [lsearch -exact $sheader "original.name"]
    set dlst [lrange $ulsts::ship_lst 1 end]
    set idx 0
    set dis_lst {}
    foreach s $dlst {
        set pid [lindex [csv::split -alternate $s] $sidx]
        if {$pid < 0} {
            continue
        } else {
            set tstr "$pid"
            append tstr ">[lindex [csv::split -alternate $s] $IDidx]"
            set dis_lst [lappend dis_lst $tstr]
        }
    }
    
    set dis_lst_sort [lsort $dis_lst]
    foreach s $dis_lst_sort {
        $fr insert end $s
    }
}

# ######################################
#  fill inventory list box with selections.
proc fill_inv_mods_listbox {fr} {
    $fr delete 0 end
    update
    set header [lindex $ulsts::mod_lst 0]
    set sheader [csv::split -alternate $header]
    set IDidx [lsearch -exact $sheader "id"]
    set name_idx [lsearch $sheader "original.name"]
    
    foreach s $sheader {
        if {[string first "id" $s] >= 0} {
            puts $s
        }
        if {[string first "ID" $s] >= 0} {
            puts $s
        }
    }
    
    # list of module ids on ships.
    set mheader [lindex $ulsts::shipd_lst 0]
    #puts $mheader
    set smheader [split $mheader ","]
    set sm_id_idx [lsearch $smheader "module.id"]
    #puts $sm_id_idx

    set mdlst [lrange $ulsts::shipd_lst 1 end]
    set sm_id_lst []
    foreach m $mdlst {
        set sm [split $m ","]
        if {[lindex $sm $sm_id_idx] != ""} {
            set tmp [split [lindex $sm $sm_id_idx] "."]
            set sm_id_lst [lappend sm_id_lst [lindex $tmp 0]]
        }
    }
    
    
    #foreach i $sm_id_lst {
    #    puts $i
    #}


    set dlst [lrange $ulsts::mod_lst 1 end]
    set name_len 0
    foreach m $dlst {
        set sm [split $m ","]
        set mname [lindex $sm $name_idx]
        set nlen [string length $mname]
        if {$nlen > $name_len} {
            set name_len $nlen
        }
    }
    
    foreach m $dlst {
        if {$m == ""} {break}
        set sm [split $m ","]
        #puts $sm
        set name [pad_str [lindex $sm $name_idx] $name_len]
        #puts $name
        #puts $name_idx
        set id [lindex $sm $IDidx]
        set mstr $name
        append mstr "id:$id"
        set is_eq [lsearch $sm_id_lst $id]
        $fr insert end $mstr
        if {$is_eq >= 0} {
            $fr itemconfigure end -background #ffe8e8
        }
    }
}
# #############################################
#   show the base details in the canvas passed
proc show_base_details {wid} {
    set sel_idx [$wid curselection]
    
    set base [$wid get $sel_idx]
    #puts $base
    set sbase [split $base ":"]
    set bid [lindex $sbase 1]
    set base [lindex $sbase 0]
    #  Clean up.
    $uwids::bcanv delete all
    
    set header [lindex $ulsts::secd_lst 0]
    set sheader [csv::split -alternate $header]
    #puts $sheader
    set pidx [lsearch $sheader "name"]
    set dlst [lrange $ulsts::secd_lst 1 end]
    
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    foreach i $dlst {
        set si [csv::split -alternate $i]
        if {[lsearch $si $base] >= 0 && [lsearch $si $bid] >= 0 &&$found == 0} {
            set idx 0
            set found 1
            foreach h $sheader {
                if {[string first "planet" $h] >= 0} {
                    incr idx
                    continue
                }
                $uwids::bcanv create text $lx $ly -anchor e -text "$h:"
                #  if the start time
                if {[string first "Start" $h] >= 0 } {
                    set stim [get_time_val [lindex $si $idx]]
                    #puts $stim
                    set cleft [lindex $si [lsearch $sheader "productionCyclesLeft"]]
                    #puts "cycles left:  $cleft"
                # if the end time
                } elseif { [string first "End" $h] >= 0 } {
                    set etim [get_time_val [lindex $si $idx]]
                    set rlst [get_reso [lindex $si [lsearch $sheader "productionData.resourceId"]]]
                    set rid [lindex $rlst 0]
                    set ridx [lsearch -index 0 $far_db::mine_lst $rid]
                    set rinfo [lindex $far_db::mine_lst $ridx]
                    #puts $rinfo
                    set cyc_dur [lindex [lindex $rinfo 1] 0]
                    set tim_left [expr {$cyc_dur * $cleft}]
                    #puts "seconds left: $tim_left"
                    #puts $etim
                    set ddone [expr {int($etim + $tim_left)}]
                    set done_time [clock format $ddone -format {%Y-%m-%d %H:%M:%S} -timezone :America/New_York]
                    #puts "Date done :  $done_time"
                }
                if {[string first "\]" [lindex $si $idx]] >= 0 || $h == "productionData.resourceId"} {
                    set lstr [string trim [lindex $si $idx] "\[\]"]
                    set slstr [split $lstr ","]
                    set rcnt 0
                    foreach r $slstr {
                        set rids [lsearch -index 0 $far_db::res_lst [string trim $r]]
                        if {$rids >= 1} {
                            set res [lindex [lindex $far_db::res_lst $rids] 1]
                            set rcol [lindex $res 4];  ##  the color
                            set rnm [lindex $res 0];   ## the name
                            $uwids::bcanv create rectangle $vx [expr {$vy-7}] [expr {$vx+60}] [expr {$vy+10}]  -fill $rcol
                            $uwids::bcanv create text [expr {$vx+6}] [expr {$vy+2}] -anchor w -text $rnm -fill white -font font_info_txt
                            if {$rcnt < 2} {
                                incr vx 64
                                incr rcnt
                            } else {
                                set vx 200
                                incr vy 20
                                incr ly 20
                                set rcnt 0
                            }
                        }
                    }
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                } else {
                    $uwids::bcanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                }
            }
        }
    }    
        
    incr vy 20
    set tf black
    if {$cleft == 0} {
        set tf red
        $uwids::bcanv create text $vx $vy -anchor c -text "Finished Production :" -font font_info_res -fill red
    } elseif {$cleft < 2} {
        $uwids::bcanv create text $vx $vy -anchor c -text "Close to Production End :" -font font_info_res
        set tf orange
    } else {
        $uwids::bcanv create text $vx $vy -anchor c -text "Current production ends on :" -font font_info_res
    }
    incr vy 20
    $uwids::bcanv create text $vx $vy -anchor c -text $done_time -font font_info_res -fill $tf
}

# #############################################
#   show the sector details in the canvas passed
proc show_sector_details {wid} {
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set sec [$wid get $sel_idx]
    #puts $sec
    #  Clean up.
    $uwids::scanv delete all
    
    set header [lindex $ulsts::sec_lst 0]
    set sheader [csv::split -alternate $header]
    #puts $sheader
    set pidx [lsearch $sheader "name"]
    set dlst [lrange $ulsts::sec_lst 1 end]
    
    #puts $pidx
    #puts $dlst
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    foreach i $dlst {
        set si [csv::split -alternate $i]
        if {[lsearch $si $sec] >= 0 && $found == 0} {
            #puts "found [lindex $si $pidx]"        
            set idx 0
            set found 1
            foreach h $sheader {
                if {[string first "planet." $h] >= 0} {
                    incr idx
                    continue
                }
                $uwids::scanv create text $lx $ly -anchor e -text "$h:"
                if {[string first "\]" [lindex $si $idx]] >= 0} {
                    set lstr [string trim [lindex $si $idx] "\[\]"]
                    set slstr [split $lstr ","]
                    #puts $lstr
                    #puts $slstr
                    #set xrst $vx
                    set rcnt 0
                    foreach r $slstr {
                        #puts $r
                        set rids [lsearch -index 0 $far_db::res_lst [string trim $r]]
                        if {$rids >= 1} {
                            set res [lindex [lindex $far_db::res_lst $rids] 1]
                            #puts $res
                            set rcol [lindex $res 4];  ##  the color
                            #puts $rcol
                            set rnm [lindex $res 0];   ## the name
                            #puts $rnm
                            $uwids::scanv create rectangle $vx [expr {$vy-7}] [expr {$vx+60}] [expr {$vy+10}]  -fill $rcol
                            $uwids::scanv create text [expr {$vx+6}] [expr {$vy+2}] -anchor w -text $rnm -fill white -font font_info_txt
                            if {$rcnt < 2} {
                                incr vx 64
                                incr rcnt
                            } else {
                                set vx 200
                                incr vy 20
                                incr ly 20
                                set rcnt 0
                            }
                            #incr ly 20
                        }
                    }
                    #$uwids::pcanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                } else {
                    $uwids::scanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                }
            }
        }
    }    
}

# #############################################
#   show the planet details in the canvas passed
proc show_planet_details {wid} {
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set plnt [$wid get $sel_idx]
    if {$plnt == {}} {
        return
    }
    #puts $plnt
    #  Clean up.
    $uwids::pcanv delete all
    #$uwids::pcanv create text 50 50 -text "Primary"
    set header [lindex $ulsts::sec_lst 0]
    set sheader [csv::split -alternate $header]
    #set pidx [lsearch $sheader "planet.name"]
    set dlst [lrange $ulsts::sec_lst 1 end]
    
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    foreach i $dlst {
        set si [csv::split -alternate $i]
        if {[lsearch $si $plnt] >= 0 && $found == 0} {
            #puts "found [lindex $si $pidx]"        
            set idx 0
            set found 1
            foreach h $sheader {
                if {[string first "planet." $h] < 0} {
                    incr idx
                    continue
                }
                # strip the planet. from header name.
                set h [string replace $h 0 6 ""]
                $uwids::pcanv create text $lx $ly -anchor e -text "$h:"
                if {[llength [split [lindex $si $idx] ","]] > 1} {
                    set lstr [string trim [lindex $si $idx] "\[\]"]
                    set slstr [split $lstr ","]
                    #puts $slstr
                    #set xrst $vx
                    set rcnt 0
                    foreach r $slstr {
                        #puts $r
                        set rids [lsearch -index 0 $far_db::res_lst [string trim $r]]
                        if {$rids >= 1} {
                            set res [lindex [lindex $far_db::res_lst $rids] 1]
                            #puts $res
                            set rcol [lindex $res 4];  ##  the color
                            #puts $rcol
                            set rnm [lindex $res 0];   ## the name
                            #puts $rnm
                            $uwids::pcanv create rectangle $vx [expr {$vy-7}] [expr {$vx+60}] [expr {$vy+10}]  -fill $rcol
                            $uwids::pcanv create text [expr {$vx+6}] [expr {$vy+2}] -anchor w -text $rnm -fill white -font font_info_txt
                            if {$rcnt < 2} {
                                incr vx 64
                                incr rcnt
                            } else {
                                set vx 200
                                incr vy 20
                                incr ly 20
                                set rcnt 0
                            }
                            #incr ly 20
                        }
                    }
                    #$uwids::pcanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                } else {
                    $uwids::pcanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                }
            }
        }
    }
}

# #############################################
#   show the sector details in the canvas passed
proc show_ship_module_details {wid} {
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set sec [$wid get $sel_idx]
    #puts $sec
    #  Clean up.
    $uwids::shicanv delete all
    update
    
    set header [lindex $ulsts::mod_lst 0]
    set sheader [csv::split -alternate $header]
    #  lame search, need to get module ID and match from list.  <<<<<  TBD
    set name_idx [lsearch $sheader "original.name"]
    set dlst [lrange $ulsts::mod_lst 1 end]
    
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    foreach i $dlst {
        set si [split $i ","]
        #puts $si
        set name [lindex $si $name_idx]
        set mtxt [string first $name $sec]
        #puts $mtxt
        if {$mtxt > 0} {
            #puts "found [lindex $si $pidx]"        
            set idx 0
            set found 1
            foreach h $sheader {
                ## skip fields with 0 or no content.  may need refinement.
                if {[lindex $si $idx] != "0" && [lindex $si $idx] != ""} {
                    #puts [lindex $si $idx]
                    $uwids::shicanv create text $lx $ly -anchor e -text "$h:"
                    $uwids::shicanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                } else {
                    incr idx
                }
            }
            break
        }
    }    
}

# #############################################
#   show the inventory module details in the canvas passed
proc show_inv_module_details {wid} {
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set mod [$wid get $sel_idx]
    set smod [split $mod ":"]
    set this_mod_id [lindex $smod end]
    set this_name [string trim [lindex $smod 0] "id "]
    #puts $sec
    #  Clean up.
    $uwids::inv_mod_canv delete all
    update
    
    set header [lindex $ulsts::mod_lst 0]
    set sheader [csv::split -alternate $header]
    #  lame search, need to get module ID and match from list.  <<<<<  TBD
    set name_idx [lsearch $sheader "id"]
    set dlst [lrange $ulsts::mod_lst 1 end]
    
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    foreach i $dlst {
        set si [split $i ","]
        #puts $si
        set name [lindex $si $name_idx]
        if {$name == $this_mod_id} {
            #puts "found [lindex $si $pidx]"        
            set idx 0
            set found 1
            $uwids::inv_mod_canv create text $lx $ly -text $this_name -font font_info_res
                    incr ly 20
                    incr vy 20
            foreach h $sheader {
                ## skip fields with 0 or no content.  may need refinement.
                if {[lindex $si $idx] != "0" && [lindex $si $idx] != ""} {
                    #puts [lindex $si $idx]
                    $uwids::inv_mod_canv create text $lx $ly -anchor e -text "$h:"
                    $uwids::inv_mod_canv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                } else {
                    incr idx
                }
            }
            break
        }
    }    
}

# #############################################
#  generate a container group.
#   fr   frame to build in
#   title   Text titleof box
#   lstbx   the list box of items
#   canv    the canvas to display info
#   rtn     the return of the created items.
proc gen_info_container {fr title lstbx canv} {
    set l1 [label $fr.lb1 -text $title]
    pack $l1
    set lstbx [listbox $fr.lsb1 -borderwidth 4 -relief sunken -width 30 -height 10]
    set canv [canvas $fr.pc1 -borderwidth 4 -relief sunken  -width 400 -height 500  -yscrollincrement 1]
    $canv configure -scrollregion {0 0 400 900}
    bind $canv <MouseWheel> {scrol_canv %W %D}
    pack $lstbx
    pack $canv
    pack $fr -side left -fill y -expand 1
    set rtn $lstbx
    set rnt [lappend rtn $canv]
    return $rtn
}


# #############################################
#   show the planet details in the canvas passed
proc show_ship_details {wid} {
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set ship [$wid get $sel_idx]
    if {$ship == {}} {
        return
    }
    #puts $ship
    #  Clean up.
    $uwids::shcanv delete all
    #  header info
    set header [lindex $ulsts::ship_lst 0]
    set sheader [csv::split -alternate $header]
    # get some ship info indexs
    set shipID [lsearch -exact $sheader "id"]
    set sidx [lsearch -exact $sheader "original.name"]
    set iidx [lsearch -exact $sheader "combinedTextureName"]
    set sid [lindex $sheader $sidx]
    append sid "-[lindex $sheader $sidx]"
    set dlst [lrange $ulsts::ship_lst 1 end]
    
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    foreach i $dlst {
        set si [split $i ","]
        set styp [lindex $si $sidx]
        append styp ">[lindex $si $shipID]"
        
        if {$styp != $ship} {
            continue
        }
        ## get the ship ID
        set cship_id [lindex $si $shipID]
        set idx 0
        set found 1
        foreach h $sheader {
            #  put down text
            $uwids::shcanv create text $lx $ly -anchor e -text "$h:"
            $uwids::shcanv create text $vx $vy -anchor w -text [lindex $si $idx]
            incr idx
            incr ly 20
            incr vy 20
            set vx 200
        }
    }
    
    ##  now get the modules for this shipe and display.
    set mheader [lindex $ulsts::shipd_lst 0]
    set mdlst [lrange $ulsts::shipd_lst 1 end]
    # get some indexs from the header.
    set smheader [csv::split -alternate $mheader]
    set name_idx [lsearch $smheader "module.original.name"]
    set mod_slot [lsearch $smheader "slot"]
    set mod_place [lsearch $smheader "place"]
    
    ## from the list of modules get the ones for this ship.
    $uwids::module_lsb delete 0 end
    set mods_lst []
    foreach m $mdlst {
        set sm [split $m ","]
        set slot [lindex $sm $mod_slot]
        set place [lindex $sm $mod_place]
        set id [lindex $sm 0]
        set this_name [lindex $sm $name_idx]
        #if module and ship id match
        if {$id == $cship_id} {
            set mods_lst [lappend mods_lst $m]
            # Add this to the ship equipted modules list box
            $uwids::module_lsb insert end "Slot  $slot:$place - $this_name"
        }
    }
    $uwids::shicanv delete all

}
# ##############################################
#  create Views of user data
#   planets
#   sectors
#   installations
#   ships
#   blue prints
proc generate_view {} {
    # delete everything if it exists.
    if {[winfo exists $uzr::user_note_frame] == 1} {
        set info_cont [winfo children $uzr::user_note_frame]
        puts $info_cont
        foreach w $info_cont {
            destroy $w
        }
    }
    ##  note book for user sections
    set uzr_tbs [ttk::notebook $uzr::user_note_frame.note -height 1100]
    pack $uzr_tbs
    set mfr $uzr_tbs.t1
    set shipfr $uzr_tbs.t2
    set bpfr $uzr_tbs.t3
#    $uzr_tbs add [frame $mfr -borderwidth 4 -relief sunken] -text "\[ Resources \]" -bordercolor brown -tabmargins 3 -padding {5 5 5 5}
#    $uzr_tbs add [frame $shipfr -borderwidth 4 -relief sunken] -text "\[ Ships \]" -bordercolor brown -padding {5 5 5 5}
    $uzr_tbs add [frame $mfr -borderwidth 4 -relief sunken] -text "\[ Resources \]" -padding {5 5 5 5}
    $uzr_tbs add [frame $shipfr -borderwidth 4 -relief sunken] -text "\[ Ships \]" -padding {5 5 5 5}
    $uzr_tbs add [frame $bpfr -borderwidth 4 -relief sunken] -text "\[ Blue Prints \]" -padding {5 5 5 5}
    
    ###########################################################
    ##  planet info
    set pfr [ttk::frame $mfr.pl1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $pfr "Planets" $uwids::planet_lsb $uwids::pcanv]
    set uwids::planet_lsb [lindex $wids 0]
    set uwids::pcanv [lindex $wids 1]

    bind $uwids::planet_lsb <ButtonRelease-1> { show_planet_details %W}
    bind $uwids::planet_lsb <KeyRelease> { show_planet_details %W}
    
    fill_planet_listbox $uwids::planet_lsb
    
    # #########################################################
    ##  Sector info
    set sfr [ttk::frame $mfr.sl1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $sfr "Sectors" $uwids::sector_lsb $uwids::scanv]
    set uwids::sector_lsb [lindex $wids 0]
    set uwids::scanv [lindex $wids 1]

    bind $uwids::sector_lsb <ButtonRelease-1> { show_sector_details %W}
    bind $uwids::sector_lsb <KeyRelease> { show_sector_details %W}
    
    fill_sector_listbox $uwids::sector_lsb
    
    # #########################################################
    ##  installation (bases) info
    set ifr [ttk::frame $mfr.il1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $ifr "Installations" $uwids::base_lsb $uwids::bcanv]
    set uwids::base_lsb [lindex $wids 0]
    set uwids::bcanv [lindex $wids 1]

    bind $uwids::base_lsb <ButtonRelease-1> { show_base_details %W}
    bind $uwids::base_lsb <KeyRelease> { show_base_details %W}
    
    fill_base_listbox $uwids::base_lsb
    
    ##########################################################
    ##  Ship info
    set shfr [ttk::frame $uzr_tbs.t2.il1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $shfr "Ships" $uwids::ship_lsb $uwids::shcanv]
    set uwids::ship_lsb [lindex $wids 0]
    set uwids::shcanv [lindex $wids 1]
    $uwids::shcanv configure -scrollregion {0 0 400 1800}


    bind $uwids::ship_lsb <ButtonRelease-1> { show_ship_details %W}
    bind $uwids::ship_lsb <KeyRelease> { show_ship_details %W}
    
    fill_ship_listbox $uwids::ship_lsb
    
    ##########################################################
    ##  Ship Modules info
    set shifr [ttk::frame $uzr_tbs.t2.sil1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $shifr "Ships Equiped Modules" $uwids::module_lsb $uwids::shicanv]
    set uwids::module_lsb [lindex $wids 0]
    set uwids::shicanv [lindex $wids 1]

    bind $uwids::module_lsb <ButtonRelease-1> { show_ship_module_details %W}
    bind $uwids::module_lsb <KeyRelease> { show_ship_module_details %W}
        
     ##########################################################
    ##  Inventory Modules info
    set imfr [ttk::frame $uzr_tbs.t2.iml1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $imfr "Inventory Modules" $uwids::inv_module_lsb $uwids::inv_mod_canv]
    set uwids::inv_module_lsb [lindex $wids 0]
    set uwids::inv_mod_canv [lindex $wids 1]
    $uwids::inv_module_lsb configure -width 40

    bind $uwids::inv_module_lsb <ButtonRelease-1> { show_inv_module_details %W}
    bind $uwids::inv_module_lsb <KeyRelease> { show_inv_module_details %W}
    
    fill_inv_mods_listbox $uwids::inv_module_lsb
        
}

# #################################################
#   backup current files before downloading
#    if enabled.
proc uzr_history_add {} {
    ## return if history logging not enabled.
    if {$uzr::bkup_en == 0} {
        return
    }
    puts "Updating history ..."
    if {[file exists "user_history"] == 1 && [file isdirectory "user_history"] == 1} {
        set time [clock seconds]
        set time [clock format $time -format {%Y-%m-%dh%Hm%Ms%S} -timezone :America/New_York]
        file mkdir "user_history/$time"
        
    } else {
        file mkdir "user_history"
        set time [clock seconds]
        set time [clock format $time -format {%Y-%m-%dh%Hm%Ms%S} -timezone :America/New_York]
        file mkdir "user_history/$time"
        
    }
    
    file copy "../Account.csv" "user_history/$time/Account.csv"
    file copy "../Blueprints.csv" "user_history/$time/Blueprints.csv"
    file copy "../Modules.csv" "user_history/$time/Modules.csv"
    file copy "../Sectors.csv" "user_history/$time/Sectors.csv"
    file copy "../Sectors_Bases_Detail.csv" "user_history/$time/Sectors_Bases_Detail.csv"
    file copy "../Ships.csv" "user_history/$time/Ships.csv"
    file copy "../Ships_Slot_Detail.csv" "user_history/$time/Ships_Slot_Detail.csv"
    
    return
}

# ###############################
#   get user info from the web
proc get_uzr_info {} {
    puts "Getting user info ..."
    uzr_history_add
    set status 0
    puts $uzr::email
    if {[catch {exec python ../inventory_scrape.py $uzr::email $uzr::pw} results options]} {
        set details [dict get $options -errorcode]
        if {[lindex $details 0] eq "CHILDSTATUS"} {
            set status [lindex $details 2]
        } else {
            # Some other error; regenerate it to let caller handle
            return -options $options -level 0 $results
        }
    }
    
    puts "TCL  got back:  $results"
    #puts $details
    puts $status
    #puts "Options $options"
    load_uzr_info
    generate_view
}

