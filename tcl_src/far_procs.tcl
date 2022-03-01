

# for reloading / sourcing more than once. ...
set fts [font names]
set is_f [lsearch $fts font_info_txt]
if {$is_f  >= 0} {
    font delete font_info_txt font_info_res
}
font create font_info_txt -family Helvetica -size 8
font create font_info_res -family Helvetica -size 11 -weight bold

# ###################################
proc scrol_canv  {wid diff} {
    if {$diff < 0} {
        $wid yview scroll $diff unit
    } else {
        $wid yview scroll $diff unit
    }
}


# #####################################
#   get the resource chain based on passed ID
proc get_reso_chain {rid lst} {

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
        if {[lindex $r 0] == 0} {
            continue
        }
        #puts $r
        if {[lindex $r 0] == $rid} {
            set mlst [lappend mlst $r]
            #puts "Found master $mlst"
        } elseif {[lindex [lindex $r 1] 0] == $rid} {
            set dlst [lappend dlst $r]
            #puts "Found deriv  $dlst"
        }
    }
    
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
    set mlst {}
    foreach i $id {
        set mid [lindex $i 0]
        set rlst [lindex $i 1]
        set mlst [lappend mlst [lindex [lindex $i 1] 2]]
    }
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
            set rtn [lappend rtn $c]
        }
    } elseif {$res::cur_type == "deriv"} {
        foreach c $lst {
            foreach i $c {
                set rtn [lappend rtn $i]
            }
        }
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

# ############################################
#  display the material info from id passed
#   canv   canvas
#   mid   master id, materials have several sources.
#   id    material ID
#   x y   coorinate start place
proc mater_info {canv mid id x y {side ""}} {
    set rtn {}
    set tmp_lst {}
    set mx  $x
    set my  $y
    set refo {}
    
    #puts "$mid  $id"
    set header [lindex $far_db::refo_lst 0]
    #puts "mater header :  $header  looking for :  $mid $id"
    foreach i $far_db::refo_lst {
        #puts "$i  [lindex $i 0]"
        if {[lindex $i 0] == $mid} {
            set tmp_lst [lindex $i 1]
            if {[lindex $tmp_lst 0] == $id} {
                set refo $i
                break
            }
        }
    }
    if {$refo == {}} {
        return 1
    }
    set mlst [lindex $refo 1]
    
    set midm [lindex $mlst 0]
    set minm [lindex $mlst 1]
    set maxm [lindex $mlst 2]
    #puts $refo
    
    # get the refinery info
    set inqua ""
    set refine_cost ""
    set refine_dur ""
    set ref_header {}
#    set ref_dat {}
    set done [$canv find withtag "tg$mid"]
    #puts "Found tag $done"
    if {$side == "" && $done == {}} {
        #puts "Is not a side ..."
        set ref_header [lindex [lindex $far_db::refreq_lst 0] 1]
        foreach re $far_db::refreq_lst {
            set a [lindex $re 1]
            set ref_dat [lindex $re 1]
            #puts "$ref_dat  id: $id   mid: $mid"
            set isr [lsearch $ref_dat $mid]
            if {$isr >= 0} {
                #puts "Found refine data:  $ref_dat"
                break
            }
        }

        set tx [expr {$mx - 14}]
        set ty [expr {$my + 110}]
        set bx [expr {$mx + 250}]
        set by [expr {$my + 152}]
        $canv create rectangle $tx $ty $bx $by -width 3 -fill white -tag "tg$mid"

        set lx [expr {$mx - 8}]
        set ly [expr {$my + 122}]
        set idx 1
        foreach r $ref_dat {
            #puts "$r   [lindex $ref_header $idx]"
            switch [lindex $ref_header $idx] {
                "credits" {set ttxt "Cred"}
                "duration" {
                    set ttxt "Drua"
                    set r "[string range [expr {$r / 3600}] 0 4] hrs"
                }
                "input_qty" {set ttxt "Input"}
                "input_resource_id" {set ttxt "Ore ID"}
                default {puts "refinery header type or text not found ..."
                         set ttxt "Problem"}
            }
            if {$idx == 3} {
                set lx [expr {$lx + 130}]
                set ly [expr {$my + 122}]
            }
            $canv create text $lx $ly -text "$ttxt: $r" -font font_info_txt -justify left -anchor w
            incr idx
            incr ly 16
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
    
    # this is not a side product.
    #if {$side == ""} {
    #    set refino_lst {}
    #    foreach m $
    #}
    
    set bcolr "black"
    set brcolr "white"
    #puts $res::cur_name
    #puts "$name  $id   $mid"
    if {$res::cur_name == $name} {
        set bcolr "red"
        set brcolr "yellow1"
    }
    
    set tx [expr {$mx - 4}]
    set ty [expr {$my - 14}]
    set bx [expr {$mx + 100}]
    set by [expr {$my + 30}]
    $canv create rectangle $tx $ty $bx $by -outline $bcolr -width 3 -fill $brcolr

    $canv create text $mx $my -text $name -font font_info_res -justify left -anchor w -fill $col
    $canv create text $mx [expr {$my + 18}] -text $minm -font font_info_txt -justify left -anchor w
    $canv create text [expr {$mx + 40}] [expr {$my + 18}] -text $maxm -font font_info_txt -justify left -anchor w
}

# ###########################################
#  display the mine costs in passed cavnas
#    canv  canvas
#    id  resource id
#    y   y coorinate to start place
proc mine_cost {canv id x y} {
    set tmp_lst {}
    set my $y
    set mx $x
    set header [lindex $far_db::mine_lst  0]
    # collect info
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
    # Draw in the info on the canvas.
    if {$tmp_lst != {}} {
        set idx 0
        # create the rectangle to draw on
        set ryb $y
        foreach h $hd_lst {
            incr ryb 20
        }
        ## add for the bottom cost text 3  60
        incr ryb 72
        set yt [expr {$y - 14}]
        set xb [expr {$x + 132}]
        set xt [expr {$x - 4}]
        $canv create rectangle $xt $yt $xb $ryb -width 3 -fill white
        # Draw in main resource name
        $canv create text $mx $my -text $name -font font_info_res -justify left -anchor w -fill $col
        incr my 22
        set cred 0
        set dura 0
        set exta 0
        foreach h $hd_lst {
            set dat [lindex $tmp_lst $idx]
            $canv create text $mx $my -text "$h:  $dat" -font font_info_txt -justify left -anchor w
            if {$h == "credits"} {
                set cred [lindex $tmp_lst $idx]
                #puts $cred
            }
            if {$h == "duration"} {
                set dura [lindex $tmp_lst $idx]
                #puts $dura
            }
            if {$h == "extraction"} {
                set exta [lindex $tmp_lst $idx]
                #puts $exta
            }
            incr idx
            incr my 20
        }
        set hr_dr [expr {$dura / 3600}]
        set cred_item [expr {$cred / $exta}]
        set itperhr [expr {$exta / $hr_dr}]
        $canv create text $mx $my -text "Hr/Cyc: [string range $hr_dr 0 6]" -font font_info_txt -justify left -anchor w
        incr my 20
        $canv create text $mx $my -text "Item / Hr: [string range $itperhr 0 6]" -font font_info_txt -justify left -anchor w
        incr my 20
        $canv create text $mx $my -text "Cost/Item: [string range $cred_item 0 6]" -font font_info_txt -justify left -anchor w
        
        #puts "Hours per cycle:  $hr_dr"
        #puts "Item at: $itperhr /hr costing  $cred_item  /unit"
    }
}

# ############################################
#  wid is expected to be a canvas
#  ch is the resource chain list.
proc disp_res_chain {cnv1 chain} {

    set rtn 1

    set col1 50
    set col2 220
    set col3 380
    set rw 50
    set hed 20


    set xc 50
    set yc 10
    set xm 192
    set xp 10
    set xs 340
    set yp 60
    set ym 0
    set ys 0
    
    set yincr 190
    set ymincr 60
    
    ##  canvas  column text
    $cnv1 create text $col1 $hed -text "Primary"
    $cnv1 create text $col2 $hed -text "Material"
    $cnv1 create text $col3 $hed -text "Side"
    $cnv1 create line 0 36 4500 36 -width 4
    
    #  create single list
    set res_chain [singlify $chain]
    
    set lastmid ""
    set mupdated 0
    foreach r $res_chain {
        set disp_lst {}
        set id [lindex $r 0]
        ##  update if different
        if {$id != $lastmid} {
            if {$lastmid != ""} {
                $cnv1 create line 0 [expr {$yp - 26}] 450 [expr {$yp - 26}] -width 4
            }
            set mreso [get_reso $id]
            #puts "Got res id :  $mreso"
            set lastmid $id
            set mupdated 1
            set disp_lst [lappend disp_lst $mreso]
            set ym $yp
            set ys $yp
        }
        ## get the derivative
        set der [lindex $r 1]
        #puts $der
        set der_id [lindex $der 0]
        #puts $der_id
        set dreso [get_reso $der_id]
        #puts "Got dres id :  $mreso"
        set disp_lst [lappend disp_lst $dreso]
        set orig_id ""
        
        foreach ir $disp_lst {
            set matid [lindex $ir 0]
            set dat [lindex $ir 1]
            set code [lindex $dat 0]
            set name [lindex $dat 1]
            set type [lindex $dat 2]
            set group [lindex $dat 3]
            set colr [lindex $dat 4]
            set vol [lindex $dat 5]
            if {$type == "Ore"} {
                set yc $yp
                set xc $xp
                mine_cost $cnv1 $id $xc $yc
                set orig_id $id
                incr yp $yincr
                
            } elseif {$type == "Material"} {
                set sidem 0
                if {$group == "Side"} {
                    set xc $xs
                    set  yc $ys
                    incr ys $ymincr
                    set sidem 1
                } else {
                    set xc $xm
                    set  yc $ym
                    incr ym $ymincr
                }
                #puts "ID:  $id   mat id:   $matid"
                if {$sidem == 0} {
                    mater_info $cnv1 $id $matid $xc $yc
                } else {
                    mater_info $cnv1 $id $matid $xc $yc $sidem
                }
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
    if {$reso == "All"} {
        load_base
        return
    }
    
    set res::cur_name $reso
    #puts $reso
    set id ""
    foreach r $far_db::res_lst {
        set info [lindex $r 1]
        set reso_info [string first $reso [lindex $info 0]]
        #puts $reso_info
        if {$reso_info >= 0} {
            set info $r
            set id [lindex $r 0]
            #puts $id
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
        set if_fr$idx [frame $fr.fr$idx -borderwidth 4 -relief sunken -width 60]
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
        pack $fr.fr$idx -anchor nw
        incr idx
    }
    # get the resource chain
    set chain {}
    set chain [get_reso_chain $id $chain]
    #puts $chain
    set lbc [label $fr.clb -text "Resource Chain" -justify center]
    pack $lbc -side top -fill x -expand 1
    set cnv1 [canvas $fr.canv1  -borderwidth 4 -relief sunken -width 450 -height 900 -background wheat]
    $cnv1 configure -yscrollincrement 1
    $cnv1 configure -scrollregion {0 0 450 1200}
    pack $cnv1 -side top -fill both -expand 1
    bind $cnv1 <MouseWheel> {scrol_canv %W %D}
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
    $res::plb delete 0 end
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
    
    $comp::clb delete 0 end
    set clst []
    foreach cmp $far_db::comps_lst {
        if {[lindex $cmp 0] == "0"} {
            set header [lindex $ore 1]
            continue
        }
        set cnumb [lindex $cmp 0]
        set nam [lindex [lindex $cmp 1] 1]
        set cid [lindex [lindex $cmp 1] 2]
        set csz [lindex [lindex $cmp 1] 4]
        set clst [lappend clst "$cnumb :  $nam $csz"]
        #$comp::clb insert end "$cnumb :  $nam $csz"
    }
    set clst [lsort -decreasing $clst]
    foreach c $clst {
        $comp::clb insert end $c
    }
}

load_base
# ##################################################################################
#   component stuff
# ##################################################################################

# #####################################
#   get the component spec from id sent
#    id :  name
proc get_comp_spec {cmp} {
    set rtn {}
    
    set scomp [split $cmp ":"]
    set cid [lindex $scomp 0]
    set header ""
    set rlst {}
    
    foreach c $far_db::compres_lst {
        if {[lindex $c 0] == 0} {
            set header [lindex $c 1]
            set rtn [lappend rtn $header]
        }
        
        if {[lindex $c 0] == $cid} {
            #  flatten  c
            set tlst {}
            set tlst [lappend tlst [lindex $c 0]]
            set tlst [lappend tlst [lindex [lindex $c 1] 0]]
            set tlst [lappend tlst [lindex [lindex $c 1] 1]]
            set rtn [lappend rtn $tlst]
        }
    }
    return $rtn
}


# #################################
#   filter the list box based on entry
#   wid   entry widget
#   lb    list box to filter.
proc filter_lb {wid lb} {
    set txt [$wid get]
    #puts $txt
    ## if no text reload 
    if {$txt == ""} {
        load_base
        return
    }
    
    $comp::clb delete 0 end
    foreach cmp $far_db::comps_lst {
        if {[lindex $cmp 0] == "0"} {
            continue
        }
        set cnumb [lindex $cmp 0]
        set nam [lindex [lindex $cmp 1] 1]
        set cid [lindex [lindex $cmp 1] 2]
        set compt [string tolower "$cid :  $nam"]
        set is_one [string first $txt $compt]
        if {$is_one >= 0} {
            $comp::clb insert end "$cnumb :  $nam"
        }
    }
}

# ##############################################
#  show the component details.
#   wid is the component list box
proc show_comp_details {wid} {
    
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set comp_txt [$wid get $sel_idx]
    set comp::comp_id $comp_txt
    #set res::cur_name $reso
    #puts $comp_txt
    set comp_spec [get_comp_spec $comp_txt]
    #puts $comp_spec
    
    ##  hard coded index ...
    set dlst [lrange $comp_spec 1 end]
    $cmp_dets::canv delete all
    $cmp_dets::canv configure -scrollregion {0 0 450 3600}
    bind $cmp_dets::canv <MouseWheel> {scrol_canv %W 1}
    set mlst {}
    foreach d $dlst {
        set r [lindex $d 1]
        set mlst [lappend mlst [get_reso $r]]
    }
    
    $res::plb delete 0 end
    $res::plb insert end "All"
    foreach r $mlst {
        #puts $r
        set mat [lindex [lindex $r 1] 0]
        foreach ore $far_db::res_lst {
            if {[lindex $ore 0] == "0"} {
                set header [lindex $ore 1]
                continue
            }
            set data [lindex $ore 1]
            #puts $data
            set name [lindex $data 0]
            #puts "Looking for '$mat'   but is  '$name'"
            if {$name == $mat} {
                #puts $name
                #break
            
                set txt [inv_color [lindex $data 4]]
                $res::plb insert end [lindex $data 0]
                $res::plb itemconfigure end -background [lindex $data 4]
                #puts $txt
                $res::plb itemconfigure end -foreground white
                #puts $ore
            }
        }
    }
}

