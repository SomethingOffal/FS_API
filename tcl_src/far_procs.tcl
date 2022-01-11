
font delete font_info_txt font_info_res
font create font_info_txt -family Helvetica -size 8
font create font_info_res -family Helvetica -size 11 -weight bold




# #####################################
#   get the resource chain based on passed ID
proc get_reso_chain {rid lst} {
    #puts "get_reso_chain got:  $rid"
    if {$rid == ""} {
        return ""
    }
    set rtn $lst
    set rlst {}
    # #{input_resource_id max min output_resource_id}
    set mlst {}
    set dlst {}
    set $res::cur_type {}
    #puts "looking for idx is $rid"
    foreach r $far_db::refo_lst {
        #puts $r
        if {[lindex $r 0] == 0} {
            continue
        }
        #puts [lindex [lindex $r 1] end]
        if {[lindex $r 0] == $rid} {
            #puts "Got  a find  $r"
            set mlst [lappend mlst $r]
        } elseif {[lindex [lindex $r 1] end] == $rid} {
            #puts "Got  a deriviative of this  $r"
            set dlst [lappend dlst $r]
        }
    }
    #puts "prim list: $mlst"
    #puts "Derive list: $dlst"
    ## if we got a main list
    if {$mlst != {}} {
        #set rlst [lappend rlst $mlst]
        set rlst $mlst
        set res::cur_type "prim"
    } else {
    ## else got deriviative
        if {$dlst != {}} {
            foreach d $dlst {
                set sres [lindex $d 0]
                set rlst [lappend rlst [get_reso_chain $sres $rlst]]
            }
           set res::cur_type "deriv"
        } else {
            set rtn {}
        }
    }
    #puts "get_reso_chain returns :  $rtn"
    #set idx 0
    #foreach r $rlst {
        #puts "Index: $idx  list:  $r"
        #incr idx
    #}
    return $rlst
}

# #####################################
#   get the res_lst item from id
proc get_reso {id} {
    set rtn {}
    foreach res $far_db::res_lst {
        if {[lindex $res 0] == $id} {
            set rtn $res
            break
        }
    }
    return $rtn
}



# ######################################
#   get the material names from the ID
proc get_mat_code {id} {
    set header [lindex $far_db::res_lst 0]
    set header [lindex $header 1]
    set code_idx [lsearch $header "code"]
    set color_idx [lsearch $header "color"]
    
    set rtn {}
    #puts $id
    set mlst {}
    foreach i $id {
        #puts $i
        set mid [lindex $i 0]
        set rlst [lindex $i 1]
        #puts $rlst
        set mlst [lappend mlst [lindex [lindex $i 1] 2]]
    }
    #puts "mid :  $mid   mlst :  $mlst"
    foreach md $far_db::res_lst {
        if {[lindex $md 0] == $mid} {
            set rtn [lappend rtn $md]
        }
    }
    # get  resource chain list.
    foreach dd $mlst {
        foreach md $far_db::res_lst {
            if {[lindex $md end] == $dd} {
                set rtn [lappend rtn $md]
            }
        }
    }
    
   return $rtn
}

# ##########################################
#   make the resource list a single list if items
#   flatten to one index stream.
proc singlify {lst} {
    set rtn {}
    if {$res::cur_type == "prim"} {
        list lst $lst
        foreach c $lst {
            #puts "prim $c"
            set rtn [lappend rtn $c]
        }
    } elseif {$res::cur_type == "deriv"} {
        foreach c $lst {
            #puts "Deriv:  $c"
            foreach i $c {
                set rtn [lappend rtn $i]
            }
        }
        #puts $rtn
    } else {
        puts  "no list !!!"
    }
    return $rtn
}

# ##########################################
#  draw arrows on the canvase relative location x y
proc draw_arrows_r {canv x yt yb} {
    set xs [expr {$x + 4}]
    set xe [expr {$x + 16}]
    set ys [expr {($yb - $yt) / 2}]
    
    $canv create line $xs [expr {$ys + 6}] $xe $ys -width 2
    $canv create line $xs [expr {$ys - 6}] $xe $ys -width 2
    
}

# ###########################################
#  display the mine costs in passed cavnas
#    canv  canvas
#    id  resource id
#    y   y coorinate to start place
proc mine_cost {canv id x y} {
    set rtn {}
    set tmp_lst {}
    set my $y
    set mx $x
    set header [lindex $far_db::mine_lst  0]
    #set hd_lst [lindex $header 0]
    foreach h [lindex $header 1] {
        set hd_lst [lappend hd_lst $h]
    }
    foreach r $far_db::mine_lst {
        if {[lindex $r 0] == $id} {
            set tmp_lst [lappend tmp_lst [lindex $r 0]]
            foreach i [lindex $r 1] {
                set tmp_lst [lappend tmp_lst $i]
            }
            break
        }
    }
    set name ""
    set col ""
    foreach r $far_db::res_lst {
        if {[lindex $r 0] == $id} {
            set name [lindex [lindex $r 1] 0]
            set col [lindex [lindex $r 1] 4]
        }
    }
    puts $name
    puts "tmp_lst is:  $tmp_lst"
    puts "header list is:  $hd_lst"
    if {$tmp_lst != {}} {
        set idx 0
        puts $hd_lst
        $canv create text $mx $my -text $name -font font_info_res -justify left -anchor w -fill $col
        incr my 22
        foreach h $hd_lst {
            set dat [lindex $tmp_lst $idx]
            $canv create text $mx $my -text "$h:  $dat" -font font_info_txt -justify left -anchor w
            incr idx
            incr my 20
        }
        incr my -10
        set yt [expr {$y - 12}]
        set xb [expr {$x + 132}]
        set xt [expr {$x - 4}]
        $canv create rectangle $xt $yt $xb $my -width 3
        draw_arrows_r $canv $xb $yt $my
    }
    
    return 
}

# ############################################
#  wid is expected to be a canvas
#  ch is the resource chain list.
proc disp_res_chain {cnv1 chain} {

    set rtn 1

    set col1 50
    set col2 150
    set col3 240
    set rw 50
    set hed 20


    set xc 50
    set yc 10
    set xp 50
    set xm 150
    set xs 240
    set xp 50
    set xm 150
    set xs 240
    set yp 20
    set ym 20
    set ys 20
    
    set yincr 30
    
    #puts "--------------------------------"
    #puts "Chain in:  $chain"
    
    ##  canvas  column text
    $cnv1 create text $col1 $hed -text "Primary"
    $cnv1 create text $col2 $hed -text "Material"
    $cnv1 create text $col3 $hed -text "Side"
    $cnv1 create line 0 40 360 40
    
    #puts $res::cur_type
    #  create single list
    set res_chain [singlify $chain]
    
    #set res_chain $lsing
    #puts "New res_chain :  $res_chain"
    #foreach r $res_chain {
    #    puts $r
    #}
    #id {code name type group color volume}
    set lastmid ""
    set mupdated 0
    foreach r $res_chain {
        set disp_lst {}
        set id [lindex $r 0]
        ##  update if different
        if {$id != $lastmid} {
            if {$lastmid != ""} {
                $cnv1 create line 0 [expr {$yp + 15}] 360 [expr {$yp + 15}]
            }
            set mreso [get_reso $id]
            set lastmid $id
            set mupdated 1
            set disp_lst [lappend disp_lst $mreso]
        }
        ## get the derivative
        set der [lindex $r 1]
        set der_id [lindex $der end]
        set dreso [get_reso $der_id]
        set disp_lst [lappend disp_lst $dreso]
        
        puts "Disp list : $disp_lst"
        #continue
        foreach ir $disp_lst {
            set dat [lindex $ir 1]
            set code [lindex $dat 0]
            set name [lindex $dat 1]
            set type [lindex $dat 2]
            set group [lindex $dat 3]
            set colr [lindex $dat 4]
            set vol [lindex $dat 5]
            if {$type == "Ore"} {
                set ys $yp
                set ym $yp
                incr yp $yincr
                set yc $yp
                set xc $xp
            } elseif {$type == "Material"} {
                if {$group == "Fossil"} {
                    set xc $xm
                    incr ym $yincr
                    set  yc $ym
                } elseif {$group == "Side"} {
                    set xc $xs
                    incr ys $yincr
                    set  yc $ys
                } elseif {$group == "Radioactive metal"} {
                    set xc $xm
                    incr ym $yincr
                    set  yc $ym
                } elseif {$group == "Nature resource"} {
                    set xc $xm
                    incr ym $yincr
                    set  yc $ym
                } elseif {$group == "Metal"} {
                    set xc $xm
                    incr ym $yincr
                    set  yc $ym
                } elseif {$group == "Gas"} {
                    set xc $xm
                    incr ym $yincr
                    set  yc $ym
                } elseif {$group == "Oil"} {
                    set xc $xm
                    incr ym $yincr
                    set  yc $ym
                } elseif {$group == "Stone rock"} {
                    set xc $xm
                    incr ym $yincr
                    set  yc $ym
                } elseif {$group == "Crystal"} {
                    set xc $xp
                } else {
                }
            }
#            $cnv1 create text $xc $yc -text $code -fill $colr
            $cnv1 create text $xc $yc -text $code -font font_info_res -fill $colr
            if {$ys > $yc} {
                set yp $ys
            } elseif {$ym > $yc} {
                set yp $ym
            } else {
                set yp $yc
            }
        }
    }
    set rtn 0
    return $rtn
}


# ########################################
proc show_res_details {wid} {
    update
    
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set reso [$wid get $sel_idx]
    #puts $reso
    set id ""
    foreach r $far_db::res_lst {
        set info [lindex $r 1]
        set reso_info [string first $reso [lindex $info 0]]
        #puts $reso_info
        if {$reso_info >= 0} {
            set info $r
            set id [lindex $r 0]
            puts $id
            break
        }
    }
    #  make a single list
    set inflst [lindex $info 0]
    foreach i [lindex $info 1] {
        set inflst [lappend inflst $i]
    }
    set header [lindex $far_db::res_lst 0]
    # clean up from previous
    set info_cont [winfo children $info::info_fr]
    foreach w $info_cont {
        destroy $w
    }
    #  set up for gen fields
    set fr $info::info_fr
    $fr configure -height 10
    set hdr [lindex $header 1]
    set idx 0
    set lb [label $fr.tlb -text "Resource Information" -justify center]
    pack $lb -side top -fill x -expand 1
    foreach t $hdr {
        set if_fr$idx [frame $fr.fr$idx -borderwidth 4 -relief sunken]
        set lbname $t
        #puts $lbname
        if {$lbname == ""} {
            incr idx
            continue
        }
        set lb [label $fr.fr$idx.lb -text $lbname]
        set lb1 [label $fr.fr$idx.lb2 -text [lindex $inflst $idx]]
        pack $lb -side left -padx 20
        pack $lb1 -side right -padx 20
        pack $fr.fr$idx -anchor nw -fill x -expand 1
        incr idx
    }
    puts "sending in ID:  $id"
    set chain {}
    set chain [get_reso_chain $id $chain]
    #if {$chain == {}} {
    #    puts "Base material, no Refine.  $id"
    #    mine_cost $canv1 $id
    #    return
    #}
    puts "Got chain back: $chain"
    #if {$chain == {}} {
    #    return
    #}
    set lbc [label $fr.clb -text "Resource Chain" -justify center]
    pack $lbc -side top -fill x -expand 1
    set cnv1 [canvas $fr.canv1  -borderwidth 4 -relief sunken -width 300 -height 600 -background white]
    pack $cnv1 -side top -fill both -expand 1
    if {$chain == {}} {
        mine_cost $cnv1 $id 10 20
    } else {
        set ok [disp_res_chain $cnv1 $chain]
    }
    
    
}


# ##############################################
proc inv_color {col} {
    set sc [split $col ""]
    set rtn "#"
    for {set i 1} {$i < [string length $col]} {incr i} {
        set tmp ""
        switch [lindex $sc $i] {
            0 {set tmp "f"}
            1 {set tmp "e"}
            2 {set tmp "d"}
            3 {set tmp "c"}
            4 {set tmp "b"}
            5 {set tmp "a"}
            6 {set tmp "9"}
            7 {set tmp "8"}
            8 {set tmp "7"}
            9 {set tmp "6"}
            a {set tmp "5"}
            b {set tmp "4"}
            c {set tmp "3"}
            d {set tmp "2"}
            e {set tmp "1"}
            f {set tmp "0"}
        }
        append rtn $tmp
    }
    return $rtn
}


# ###############################################
proc load_base {} {
    puts "loading base ..."
    set header ""
    foreach ore $far_db::res_lst {
        if {[lindex $ore 0] == "0"} {
            set header [lindex $ore 1]
            continue
        }
        set data [lindex $ore 1]
        #set txt [inv_color [lindex $data 4]]
        $res::plb insert end [lindex $data 0]
        $res::plb itemconfigure end -background [lindex $data 4]
        #puts $txt
        $res::plb itemconfigure end -foreground white
        #puts $ore
    }
    
    foreach cmp $far_db::comps_lst {
        if {[lindex $cmp 0] == "0"} {
            set header [lindex $ore 1]
            continue
        }
        set nam [lindex [lindex $cmp 1] 1]
        $comp::clb insert end $nam
    }
}