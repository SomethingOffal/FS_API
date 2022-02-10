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
               "../Blueprints.csv"}
    set info_lsts {{"this_header" "sectors" "sector_details" "ships" "ships_data" "account" "blueprints"}}
}

namespace eval uwids {
    set planet_lsb {}
    set pcanv {}
    set sector_lsb {}
    set scanv {}
    set ship_lsb {}
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
                    puts $stim
                    set cleft [lindex $si [lsearch $sheader "productionCyclesLeft"]]
                    puts "cycles left:  $cleft"
                # if the end time
                } elseif { [string first "End" $h] >= 0 } {
                    set etim [get_time_val [lindex $si $idx]]
                    set rlst [get_reso [lindex $si [lsearch $sheader "productionData.resourceId"]]]
                    set rid [lindex $rlst 0]
                    set ridx [lsearch -index 0 $far_db::mine_lst $rid]
                    set rinfo [lindex $far_db::mine_lst $ridx]
                    puts $rinfo
                    set cyc_dur [lindex [lindex $rinfo 1] 0]
                    set tim_left [expr {$cyc_dur * $cleft}]
                    puts "seconds left: $tim_left"
                    puts $etim
                    set ddone [expr {int($etim + $tim_left)}]
                    set done_time [clock format $ddone -format {%Y-%m-%d %H:%M:%S} -timezone :America/New_York]
                    puts "Date done :  $done_time"
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

# ##############################################
#  create Views of user data
#   planets
#   sectors
#   installations
#   ships
#   blue prints
proc generate_view {} {
    # usr frame   uzr::ufr
    if {[winfo exists $uzr::user_note_frame] == 1} {
        set info_cont [winfo children $uzr::user_note_frame]
        puts $info_cont
        foreach w $info_cont {
            destroy $w
        }
        #destroy $uzr::user_note_frame.disp
    }
    
    set mfr [ttk::frame $uzr::user_note_frame.mf1]
    ###########################################################
    ##  planet info
#    set pfr [ttk::frame $uzr::user_note_frame.pl1 -borderwidth 4 -relief sunken]
    set pfr [ttk::frame $mfr.pl1 -borderwidth 4 -relief sunken]
    set l1 [label $pfr.lb1 -text "Planets"]
    pack $l1
    set uwids::planet_lsb [listbox $pfr.lsb1 -borderwidth 4 -relief sunken -width 30 -height 10]
    set uwids::pcanv [canvas $pfr.pc1 -borderwidth 4 -relief sunken  -width 400 -height 500  -yscrollincrement 1c]
    $uwids::pcanv configure -scrollregion {0 0 400 900}
    bind $uwids::pcanv <MouseWheel> {scrol_canv %W %D}
    #set f2 [frame $f1.p1]
    pack $uwids::planet_lsb
    pack $uwids::pcanv
    pack $pfr -side left -fill y -expand 1
#    pack $pfr -anchor n -fill y -expand 1

    bind $uwids::planet_lsb <ButtonRelease-1> { show_planet_details %W}
    bind $uwids::planet_lsb <KeyRelease> { show_planet_details %W}
    
    fill_planet_listbox $uwids::planet_lsb
    
    # #########################################################
    ##  Sector info
#    set sfr [ttk::frame $uzr::user_note_frame.sl1 -borderwidth 4 -relief sunken]
    set sfr [ttk::frame $mfr.sl1 -borderwidth 4 -relief sunken]
    set l2 [label $sfr.lb1 -text "Sectors"]
    pack $l2
    #set sector_lsb {}
    #set scanv {}
    set uwids::sector_lsb [listbox $sfr.lsb1 -borderwidth 4 -relief sunken -width 30 -height 10]
    set uwids::scanv [canvas $sfr.sc1 -borderwidth 4 -relief sunken  -width 400 -height 500  -yscrollincrement 1c]
    $uwids::scanv configure -scrollregion {0 0 400 900}
    bind $uwids::scanv <MouseWheel> {scrol_canv %W %D}
    #set f2 [frame $f1.p1]
    pack $uwids::sector_lsb
    pack $uwids::scanv
    #pack $sfr -anchor w -fill y
    pack $sfr -side left -fill y -expand 1
    bind $uwids::sector_lsb <ButtonRelease-1> { show_sector_details %W}
    bind $uwids::sector_lsb <KeyRelease> { show_sector_details %W}
    
    fill_sector_listbox $uwids::sector_lsb
    
    # #########################################################
    ##  installation (bases) info
    set ifr [ttk::frame $mfr.il1 -borderwidth 4 -relief sunken]
    set l2 [label $ifr.lb1 -text "Installations"]
    pack $l2
    #set sector_lsb {}
    #set scanv {}
    set uwids::base_lsb [listbox $ifr.lsb1 -borderwidth 4 -relief sunken -width 30 -height 10]
    set uwids::bcanv [canvas $ifr.sc1 -borderwidth 4 -relief sunken  -width 400 -height 500  -yscrollincrement 1c]
    $uwids::bcanv configure -scrollregion {0 0 400 900}
    bind $uwids::bcanv <MouseWheel> {scrol_canv %W %D}
    #set f2 [frame $f1.p1]
    pack $uwids::base_lsb
    pack $uwids::bcanv
    #pack $sfr -anchor w -fill y
    pack $ifr -side left -fill y -expand 1
    bind $uwids::base_lsb <ButtonRelease-1> { show_base_details %W}
    bind $uwids::base_lsb <KeyRelease> { show_base_details %W}
    
    fill_base_listbox $uwids::base_lsb
    
    
    
    
    pack $mfr -anchor n -fill both -expand 1
    
    
    
    
}



# ###############################
#   get user info from the web
proc get_uzr_info {} {
    puts "Getting user info ..."
    set status 0
    puts $uzr::email
    if {[catch {exec python ../inventory_scrape_tmp.py $uzr::email $uzr::pw} results options]} {
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

