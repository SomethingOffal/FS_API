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
#           Description:  Costing functions
#
# -------------------------------------------------------------------------------

# ###############################################
#   get the current setting of value scale wids
#     write to uzrcfg::value_tbl
proc update_user_values {} {
    set uzrcfg::value_tbl {}
    
    foreach v $uzrcfg::slide_lst {
        set val [$v get]
        set sv [split $v '.']
        set name [string toupper [lindex $sv end] 0 1]
        #puts $name
        #puts $val
        set uzrcfg::value_tbl [lappend uzrcfg::value_tbl [list $name $val]]
    }
    
}

# #################################################
#  get the costing ratio for the type / refine list passed.
#    the return is a list of fractions / doubles
#    the user input is the field of entries
#       User Config >>>  Mining to Refining Cost Allocations
proc get_costing_ratios {rlst} {
    set rtn {}
    
    set side 0
    set other 0
    set main ""
    set side1 ""
    set side2 ""
    
    #puts $rlst
    foreach r $rlst {
        set id [lindex $r 0]
        set ty [lindex $r 1]
        if {$ty == "Side"} {
            incr side
            set test [lsearch -all -index 0 $refine::sides_cost_lst $id]
            #puts $test
            set sidx [lsearch -index 0 $refine::sides_cost_lst $id]
            if {$side == 1} {
                set side1 [lindex $refine::sides_cost_lst $sidx]
            } else {
                set side2 [lindex $refine::sides_cost_lst $sidx]
            }
        } else {
            set main $ty
            incr other
        }
    }
    #puts "side 1:  $side1   and  Side 2:  $side2" 
    ##  get the variables holding the user input ratio
    set ratlst {}
    switch $side {
        1 {
            switch $main {
                "Metal" {set ratlst [list $refine::m2m1 $refine::m2m2 $refine::m2s1]}
                "Gas" {set ratlst [list $refine::g2m1 $refine::g2m2 $refine::g2s1]}
                "Oil" {set ratlst [list $refine::o2m1 $refine::o2m2 $refine::o2s1]}
                default {puts "Error:  type not found matching one side output ..."}
            }
        }
        2 {
            #puts $main
            switch $main {
                "Metal" {set ratlst [list $refine::m1m1 $refine::m1s1 $refine::m1s2]}
                "Gas" {set ratlst [list $refine::g1m1 $refine::g1s1 $refine::g1s2]}
                "Oil" {set ratlst [list $refine::o1m1 $refine::o1s1 $refine::o1s2]}
                "Natural resource" {
                    switch $other {
                        1 {set ratlst [list $refine::n1n1 $refine::n1s1 $refine::n1s2]}
                        2 {set ratlst [list $refine::n2n1 $refine::n2n2 $refine::n2s1 $refine::n2s2]}
                        default {puts "Error:  Natural resouce count not as expected ..."}
                    }
                }
                default {puts "Error:  type  $main   not found matching two side output ..."}
            }
        }
        default {puts "Error:  Expected side count not in range ... $side"}
    }
    ## calculate the ratio for each resource on the list.
    set isum 0.0
    foreach v $ratlst {
        set isum [expr {$isum + double($v)}]
    }
    set iisum [expr {1.0 / $isum}]
    
    #create list of resource ID and refine cost ratio
    set idx 0
    foreach r $rlst {
        set tmp [lindex $r 0]
        set rat [expr {$iisum * [lindex $ratlst $idx]}]
        set tmp [lappend tmp $rat]
        set rtn [lappend rtn $tmp]
        incr idx
    }
    #puts $rtn
    #puts $iisum
    #puts $ratlst
    return $rtn
}

# ##########################################
#   get the manufacturing duration and cost for id
proc get_manuf_cost {id} {
    set rtn {}
    foreach c $far_db::compmain_lst {
        set mid [lindex $c 0]
        if {$mid == 0} {
            set rtn [lappend rtn [lindex $c 1]]
        }
        if {$mid == $id} {
            set rtn [lappend rtn [lindex $c 1]]
            break
        }
    }
    return $rtn
 }

# ########################################
#  get costs of the list of resources
#    return list of ordered costs
proc get_res_cost_list {lst} {
    set rtn {}
    #puts $lst
    set clst {}
    set idx 0
    foreach r $lst {
        #puts $r
        if {$idx == 0} {incr idx; continue}
        set tmp {}
        set rid [lindex $r 1]
        #puts $rid
        set val -10.0
        set t {}
        foreach w $refine::cost_table {
            set sid [lindex $w 0]
            if {$rid == $sid} {
                set val [lindex $w end]
                #puts "Got Value $val  for $name  $rid"
                break
            }
        }
        if {$val == -10.0} {
            puts "Error: $w Id not found in sliders"
        }
        set rtn [lappend rtn [list $rid $val]]
        #puts $r
        #puts $rid
    }
    return $rtn
}

proc get_pur_cost_list {lst} {
    #puts "List passed $lst"
    foreach p $uzrcfg::cost_tbl {
        set sp [split $p ":"]
        set id [lindex $sp 0]
        set wid [lindex $sp end]
        set pval [$wid get]
        if {$pval == ""} {
            continue
        }
        #puts "ID is:  $id"
        for {set i 0} {$i < [llength $lst]} {incr i} {
            set r [lindex $lst $i]
            #puts $r
            set rid [lindex $r 0]
            if {$rid == $id} {
                #puts ">>>  Found match"
                set r [lreplace $r 1 1 $pval ]
                set lst [lreplace $lst $i $i $r]
            }
        }
    }
    #puts "Returning:  $lst"
    return $lst
}

# ##############################################
#  get the material cost from the list of
#    resources refined.
proc get_material_costs {mlst} {
    set rlst {}
    set minlst {}
    set maxlst {}
    set msum 0.0
    set misum 0.0
    foreach m $mlst {
        set main [lindex $m 0]
        set dat [lindex $m 1]
        #puts $dat
        set rlst [lappend rlst [lindex $dat 0]]
        set minlst [lappend minlst [lindex $dat 1]]
        set misum [expr {$misum + double([lindex $dat 1])}]
        set maxlst [lappend maxlst [lindex $dat 2]]
        set msum [expr {$msum + double([lindex $dat 2])}]
    }
    set tylst {}
    foreach r $rlst {
        set tmp {}
        set mat [get_reso $r]
        set mid [lindex $mat 0]
        set mdat [lindex $mat 1]
        set tmp [lappend tmp $mid]
        set side [lindex $mdat 3]
        set tmp [lappend tmp $side]
        set tylst [lappend tylst $tmp]
        #puts $mat
    }
    
    set cost_dist [get_costing_ratios $tylst]
    #puts $main
    ## get the mining cost and output from main
    set mat_info {}
    foreach m $far_db::mine_lst {
        set id [lindex $m 0]
        if {$id == $main} {
            set mat_info $m
            break
        }
    }
    
    set mine_info [lindex $mat_info 1]
    set mcost [lindex $mine_info 2]
    set mquant [lindex $mine_info 1]
    
    set ref_info {}
    foreach r $far_db::refreq_lst {
        set dat [lindex $r 1]
        set rid [lindex $dat 0]
        if {$rid == $main} {
            set ref_info $dat
        }
    }
    
    set rcost [lindex $ref_info end]
    set rinput [lindex $ref_info 1]
    
    #puts $mine_info
    #puts "Cost to mine: $mcost  and  output: $mquant"
    #puts "Cost to refine:  $rcost   with input:  $rinput"
    set rin_mout_rat [expr {$rinput / $mquant}]
    set rin1_cost [expr {$rin_mout_rat * $mcost + $rcost}]
    #puts "Total cost of refine run:  $rin1_cost"
    #puts "Output total units: $msum"
    set idx 0
    set out_rat {}
    foreach r $tylst {
        set tlst {}
        set max [lindex $maxlst $idx]
        set min [lindex $minlst $idx]
        set id [lindex $r 0]
        set ty [lindex $r 1]
        #ratios of min max of this mat
        set mrat [expr {$max / $msum}]
        set mirat [expr {$min / $misum}]
        #puts "Produces:  $id  with min,max:  $min,$max   of type $ty"
        #puts "Ratio min for this ID:  $mirat"
        #puts "Ratio max for this ID:  $mrat"
        
    #puts "here..  $rin1_cost  x  $mrat  /  $max"
    #puts "here..  $rin1_cost  x  $mirat  /  $min"
        #set uzr_rat [lindex [lindex $cost_dist $idx] end]
        set this_mcost [string range [expr {double($rin1_cost) * $mrat / double($max)}] 0 7]
        if {$mirat != 0.0} {
            set this_micost [string range [expr {double($rin1_cost) * $mirat / double($min)}] 0 7]
        } else {
            set this_micost $this_mcost
        }
        
        #puts "This mat cost Max:  $this_mcost  per unit"
        #puts "This mat cost Min:  $this_micost  per unit"
        incr idx
        
        set tlst [lappend tlst $id]
        set tlst [lappend tlst $this_mcost]
        set tlst [lappend tlst $this_micost]
        set out_rat [lappend out_rat $tlst]
        #puts $name
    }
    return $out_rat
    #puts $tylst
}


# #############################################
#   get the min cost of sides
#     some cost very little and will set the market price
#     The min price will be subtracted from others and
#
#   output  list of  {id cost_min}
proc get_min_sides {} {
    set dlst [lrange $far_db::res_lst 1 end]
    set refine::sides_cost_lst {}
    set slst {}
    foreach r $dlst {
        set idx [lindex $r 0]
        set info [get_reso $idx]
        set d [lindex $info 1]
        #puts $info
        #puts $d
        set tlst $idx
        set minp 50000.0
        set type [lindex $d 3]
        if {$type == "Side"} {
            #puts "Pricing for side :  $idx"
            set info {}
            set info [get_reso_chain $idx $info]
            #puts $info
            foreach i $info {
                #puts $i
                set mclst [get_material_costs $i]
                foreach m $mclst {
                    if {[lindex $m 0] == $idx} {
                        if {$minp > [lindex $m end]} {
                            set minp [lindex $m 1]
                            set maxp [lindex $m end]
                        }
                    }
                }
                #puts $mclst
            }
            set tlst [lappend tlst [string range $minp 0 7]]
            set tlst [lappend tlst [string range $maxp 0 7]]
            set refine::sides_cost_lst [lappend refine::sides_cost_lst $tlst]
            set refine::cost_table [lappend refine::cost_table $tlst]
            #puts "Min price: $minp"
        }
    }
}
# ##############################################
#  get / add to the cost_table the single output
#    materials which are usually the lowest cost
#
proc get_single_mats {} {
    set dlst [lrange $far_db::res_lst 1 end]
    
    set smlst {}
    foreach r $dlst {
        set idx [lindex $r 0]
        set info [get_reso $idx]
        set d [lindex $info 1]
        if {[lindex $d end] != "True"} {
            continue
        }
        #puts $d
        set type [lindex $d 2]
        set group [lindex $d 4]
        set cinfo {}
        if {$type == "Ore"} {
            set cinfo [get_reso_chain $idx $cinfo]
            set sid 0
            set man 0
            set side_min_tot 0
            set side_max_tot 0
            foreach c $cinfo {
                set dat [lindex $c 1]
                set manid [lindex $c 0]
                set idat [get_reso [lindex $dat 0]]
                set mdat [lindex $idat 1]
                set mid  [lindex $idat 0]
                if {[lindex $mdat 3] == "Side"} {
                    incr sid
                    #puts $mid
                    set tmp [lindex $refine::sides_cost_lst [lsearch -index 0 $refine::sides_cost_lst $mid]]
                    set side_min_tot [string range [expr {double($side_min_tot) + double([lindex $tmp 1])}] 0 7]
                    set side_max_tot [string range [expr {$side_max_tot + double([lindex $tmp 2])}] 0 7]
                    #puts $side_min_tot
                } else {
                    incr man
                    set omanid  [lindex $idat 0]
                }
            }
            
            if {$man == 1} {
                #puts "****************** ****************"
                #set mclst [get_material_costs $cinfo]
                #puts $mclst
                #puts [lindex $cinfo 0]
                #set 
                ## get the mining cost and output from main
                #puts $manid
                set mat_info {}
                foreach m $far_db::mine_lst {
                    set id [lindex $m 0]
                    #puts $id
                    if {$id == $manid} {
                        set mat_info $m
                        break
                    }
                }
                
                #puts $mat_info
                set mine_info [lindex $mat_info 1]
                #puts $mine_info
                set mcost [lindex $mine_info 2]
                set mquant [lindex $mine_info 1]
                # get refining info
                set ref_info {}
                foreach r $far_db::refreq_lst {
                    set dat [lindex $r 1]
                    set rid [lindex $dat 0]
                    if {$rid == $manid} {
                        set ref_info $dat
                    }
                }
                #puts $ref_info
                
                set rcost [lindex $ref_info end]
                set rinput [lindex $ref_info 1]
                
                #puts $mine_info
                #puts "Cost to mine: $mcost  and  output: $mquant"
                #puts "Cost to refine:  $rcost   with input:  $rinput"
                set rin_mout_rat [expr {$rinput / $mquant}]
                set rin1_cost [expr {$rin_mout_rat * $mcost + $rcost}]
                #puts "Total cost of refine run:  $rin1_cost"
                #puts "Sides min:  $side_min_tot   Max:  $side_max_tot"
                set nlst {}
                #set alinfo [get_reso_chain $manid $nlst]
                set alinfo [get_refine_info $manid]
                set outs [lindex $alinfo 2]
                set minout 0
                set maxout 0
                foreach v $outs {
                    set vdat [lindex $v end]
                    if {[lindex $vdat 0] == $omanid} {
                        set minout [lindex $vdat 1]
                        set maxout [lindex $vdat 2]
                        break
                    }
                }
                #puts "Main single out is : $omanid"
                #puts "refine info: $v"
                #puts "Min: $minout  Max: $maxout"
                
                set mrl_costm [expr {$rin1_cost - $side_min_tot}]
                #puts $mrl_costm
                set mrl_min_cost [string range [expr {$mrl_costm / $maxout}] 0 7]
                set mrl_max_cost [string range [expr {$mrl_costm / $minout}] 0 7]
                
                #puts "Main cost min: $mrl_min_cost  max: $mrl_max_cost"
                set $refine::cost_table [lappend refine::cost_table [list $omanid $mrl_min_cost $mrl_max_cost]]
            }
        }
    }
}

# #############################################
#  generate the costing table to reduce overhead
#   of costing.
#  This takes the rations defined on user_config
proc gen_costing_list {} {

    #return

    set refine::cost_table {}
    set glbl::uzr_ini_sliders {}
    get_min_sides
    get_single_mats
    set clst {}
    set dlst [lrange $far_db::res_lst 1 end]
    foreach r $dlst {
        set idx [lindex $r 0]
        set info [get_reso $idx]
        set d [lindex $info 1]
        #puts $info
        #puts $d
        set rful $idx
        foreach i $d {
            #puts $i
            set rful [lappend rful $i]
        }
        set clst [lappend clst $rful]
        #puts $rful
    }
    
    foreach c $clst {
        set exists [lindex $c end]
        if {$exists != "True"} {continue}
        set type [lindex $c 3]
        set kind [lindex $c 4]
        #puts $type
        switch $type {
            "Mineral" {
                #puts $c
                set info [get_mine_info $c]
                set cinfo [lindex $info 2]
                set cidx [lindex $cinfo 0]
                set ci [lindex $cinfo 1]
                set mcost [lindex $ci end]
                set mqu [lindex $ci 1]
                set mti [lindex $ci 0]
                if {$kind == "Unique resource"} {continue}
                #puts "$c  $mcost  $mqu"
                #continue
                set unit_cost [expr {$mcost / $mqu}]
                set ct $cidx
                set ct [lappend ct $unit_cost]
                set refine::cost_table [lappend refine::cost_table $ct]
                #puts $info
                set this [get_reso $cidx]
                set name [lindex [lindex $this 1] 0]
                foreach w $uzrcfg::slide_lst {
                    set is_wid [string first [string tolower $name] $w]
                    if {$is_wid >= 0} {
                        set wid $w
                        break
                    }
                }
                #puts $wid
                $wid configure -to $unit_cost
                $wid configure -from $unit_cost
            }
            "Material" {
                #puts $c
                set info {}
                set id [lindex $c 0]
                set info [get_reso_chain $id $info]
                #set info [get_refine_info $c]
                foreach r $info {
                    #puts $r
                    set mclst [get_material_costs $r]
                    foreach c $mclst {
                        #puts $c
                        set tid [lindex $c 0]
                        set mcost [lindex $c 1]
                        set micost [lindex $c 2]
                        #puts $tid
                        set is_on [lsearch -index 0 $refine::cost_table $tid]
                        #puts $is_on
                        if {$is_on >= 0} {
                            continue
                        }
                        set refine::cost_table [lappend refine::cost_table $c]
                        ## setup slider
                        set this [get_reso $tid]
                        set name [lindex [lindex $this 1] 0]
                        ## get the slider for this mat  set it for the range.
                        foreach w $uzrcfg::slide_lst {
                            set is_wid [string first [string tolower $name] $w]
                            if {$is_wid >= 0} {
                                set wid $w
                                break
                            }
                        }
                        
                        $wid configure -to [expr {int($micost + 2.0)}]
                        $wid configure -from [expr {int($mcost - 2.0)}]
                        $wid set [expr int($micost)]
                        set glbl::uzr_ini_sliders [lappend glbl::uzr_ini_sliders $wid]
                        #update
                        #puts $mcost
                    }
                    #puts $mclst
                }
                update
            }
            "Ore" {
                #puts $c
                set info [get_mine_info $c]
                set cinfo [lindex $info 2]
                set cidx [lindex $cinfo 0]
                set ci [lindex $cinfo 1]
                set mcost [lindex $ci end]
                set mqu [lindex $ci 1]
                set mti [lindex $ci 0]
                
                set unit_cost [expr {$mcost / $mqu}]
                set ct $cidx
                set ct [lappend ct $unit_cost]
                set refine::cost_table [lappend refine::cost_table $ct]
                
                set this [get_reso $cidx]
                set name [lindex [lindex $this 1] 0]
                foreach w $uzrcfg::slide_lst {
                    set is_wid [string first [string tolower $name] $w]
                    if {$is_wid >= 0} {
                        set wid $w
                        break
                    }
                }
                #puts $wid
                $wid configure -to $unit_cost
                $wid configure -from $unit_cost
            }
            default {puts "Error:  unknown resource type"}
        }
    }
    set refine::cost_table [lsort -integer -index 0 $refine::cost_table ]
    update_user_values
}

# ##############################################
#  new cost calculate
proc update_cost {fen tlbl} {
    set cfen [$fen get]
    set cc [$tlbl cget -text]
    set nt [expr {$cfen + $cc}]
    $tlbl configure text $nt
}

# ######################################################
#  in the frame passed put in costing details for
#  the resource passed.
proc show_res_costing {fr res} {
    set rd1  [lindex $res 1]
    set res_name [lindex [lindex $rd1 1] 0]
    set res_type [lindex [lindex $rd1 1] 2]
    #puts $rd1
    #puts $res_type
    #far_db::mine_lst
    if {$res_type == "Ore"} {
        set minfo [get_mine_info $res]
        set header [lindex $minfo 1]
        set tinfo [lindex $minfo end]
        set info [lindex $tinfo 0]
        foreach i [lindex $tinfo 1] {
            set info [lappend info $i]
        }
        set rid [lindex $info 0]
        set orefr [ttk::labelframe $fr.fr$rid -text $res_name -width 50 -borderwidth 4 -relief sunken]
        set idx 0
        foreach h $header {
            set tf [frame $orefr.fr$h]
            set hlb [label $tf.$h -text $h]
            set ilb [label $tf.i$h -text [lindex $info $idx] -justify right -bg #ffffff]
            pack $hlb -side left -fill x
            pack $ilb -side right -padx 5 -fill x
            pack $tf -anchor nw -fill x -expand 1
            if {$h == "extraction"} {
               set ext [lindex $info $idx]
            } elseif {$h == "credits"} {
               set cred [lindex $info $idx]
            }
            incr idx
        }
#        puts $header
#        puts $info
        
        set clst [list cost "fuel/1k" amortization total]
        foreach c $clst {
            #puts $c
            set tf [frame $orefr.fr$c]
            set clbl [label $tf.$c -text $c]
            switch $c {
                "cost" {
                    #puts "cost"
                    set ucost [expr {$cred / $ext}]
                    set co [label $tf.co -text $ucost]
                    pack $clbl -side left
                    pack $co -side right
                }
                "fuel/1k" {
                    set fu [entry $tf.fen -width 5]
                    #bind $fu <KeyPress> {update_cost $tf.fen $tot}
                    pack $clbl -side left
                    pack $fu
                }
                "amortization" {}
                
                "total" {
                    set fco [$fu get]
                    if {$fco == ""} {
                        set fco 0
                    }
                    set ntot [expr {$ucost + $fco}]
                    set tot [label $tf.tot -text $ntot]
                    pack $clbl -side left
                    pack $tot -side right
                }
            }
            pack $tf
        }
        pack $orefr -side left
    } else {
        #puts $res
        set minfo [get_mine_info $res]
        set rinfo [get_mine_info $res]
        #puts $rinfo
    }
#    set nlbl [label $fr.rn -text $res]
}


# #####################################################
#   show the component passed  Costing
proc show_cmp_costing {wid spec} {
    set idx 0
    #puts $spec
    set clst  [lindex $spec end-1]
    #puts "clst: $clst"
    set mcost [lindex $spec end]
    #puts "mcost: $mcost"
    set ress [lrange $spec 1 end-2]
    #puts "ress:  $ress"
    set rtot 0.0
    set rmc_fr [ttk::labelframe $wid.rmc1 -text "Refined Material Cost"]
    set clb [label $rmc_fr.lbinfo -text " MAT:ID        C x Qu        Total  " -background #8080c0 -foreground white]
    pack $clb -fill x -expand 1
    foreach s $ress {
        #if {$idx == 0} {incr idx; continue}
        set rc [lindex [lindex $clst $idx] end]
        #puts $rc
        set qu [lindex [lindex $ress $idx] end]
        #puts $qu
        set rid [lindex [lindex $ress $idx] 1]
        set res_dat [lindex [get_reso $rid] 1]
        set rname [lindex $res_dat 0]
        set rcol [lindex $res_dat 4]
        
        #puts "res_dat:  $res_dat"
        
        set trc [expr {int($rc) * int($qu)}]
        set rtot [expr {$rtot + $trc}]
        set txt [pad_str "$rname:$rid" 9]
        append txt [pad_str "$rc x $qu:" 12]
        append txt "   $trc"
        set clb [label $rmc_fr.lb$idx -text $txt -font font_info_cou]
        pack $clb
        incr idx
    }
    set clb [label $rmc_fr.tlb -text "Total:        $rtot" -background #40c020]
    pack $clb -side right
    pack $rmc_fr -side left -fill y -expand 1
    
    set oth_fr [ttk::labelframe $wid.tco1 -text "Manufacture Cost"]
    set mc [lindex [lindex $mcost 1] end]
    set mt [lindex [lindex $mcost 1] 0]
    set mtlbl [label $oth_fr.tim1 -text "Production Time: $mt"]
    pack $mtlbl
    set rclbl [label $oth_fr.rc1 -text "Resource Cost: $rtot" -background #40c020]
    pack $rclbl
    set mclbl [label $oth_fr.mc1 -text "Production Cost: $mc"]
    pack $mclbl
    set mtot [expr {$rtot + $mc}]
    set mclbl [label $oth_fr.toc1 -text "Output Cost: $mtot" -borderwidth 2 -relief sunken -background white]
    pack $mclbl
    set fr1 [frame $oth_fr.rfr1]
    set lfr1 [label $fr1.lb1 -text "Transport Costs: "]
    set efr1 [entry $fr1.en1 -width 6]
    $efr1 insert end [expr {double($uzrcfg::tr_percent) / 100.0 * double($mtot)}]
    $efr1 configure -state disabled
    pack $lfr1 $efr1 -side left
    pack $fr1
    set fr2 [frame $oth_fr.rfr2]
    set lfr2 [label $fr2.lb1 -text "Total Costs: " -background #ffe0e0]
    set efr2 [entry $fr2.en1 -width 8]
    $efr2 insert end [expr {$mtot + [expr {double($uzrcfg::tr_percent) / 100.0 * double($mtot)}]}]
    $efr2 configure -state disabled
    pack $lfr2 $efr2 -side left
    pack $fr2
    
    pack $oth_fr -side right
    
}
# #######################################################
#   Refining costing dump.
proc show_costing {wid} {

    set swid [split $wid "."]
    set lb [lindex $swid end]
    if {$lb == "res"} {
        set res_info [get_reso_id $wid]
        set rd1  [lindex $res_info 1]
        set res_name [string tolower [lindex [lindex $rd1 1] 0]]
        set res_title [lindex [lindex $rd1 1] 0]
        if {[winfo exists .$res_name] >= 0} {
            destroy .$res_name
        }
        toplevel .$res_name
        wm minsize .$res_name 600 300
        wm title .$res_name "Costing for $res_title"
        set res_fr [frame .$res_name.f1]
        pack $res_fr -anchor nw
        show_res_costing $res_fr $res_info
        
    } elseif {$lb == "cmp"} {
        #set cspec {}
        set item [$wid get [$wid curselection]]
        set cspec [get_comp_spec $item]
        if {[llength $cspec] <= 1} {
            return
        }
        #puts $cspec
        if {[winfo exists .$item] >= 0} {
            destroy .$item
        }
        toplevel .$item
        wm minsize .$item 600 300
        wm title .$item "Costing for $item"
        set rlst [lrange $cspec 1 end]
        set rfrm [frame .$item.cmp]
        # get the purchase costs.
        #   get_pur overwrites get_res where purchases are indicated.
        set cspec [lappend cspec [get_pur_cost_list [get_res_cost_list $cspec]]]        
        # get the  cmp id
        set sitem [split $item ":"]
        set cid [lindex $sitem 0]
        
        set cspec [lappend cspec [get_manuf_cost $cid]]
        show_cmp_costing $rfrm $cspec
        pack $rfrm
        
    } elseif {$lb == "bplp"} {
    } else {
    }
    #puts $lb

    # if costing window exists destroy it
    #if {[winfo exists .cost]} {
    #    destroy .cost
    #}
    #toplevel .cost
    #wm title .cost "Costing Window"
    
}


proc update_cost_table {wid} {
    puts "Updating ..."
    foreach e $uzrcfg::cost_tbl {
        set se [split $e ":"]
        set val [[lindex $se end] get]
        #puts $val
    }
}