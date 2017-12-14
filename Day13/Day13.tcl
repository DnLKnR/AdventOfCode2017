#Least Common Multiple from the following site:
#   https://rosettacode.org/wiki/Least_common_multiple#Tcl
proc lcm {p q} {
  set m [expr {$p * $q}]
  if {!$m} {return 0}
  while 1 {
  	set p [expr {$p % $q}]
  	if {!$p} {return [expr {$m / $q}]}
  	set q [expr {$q % $p}]
  	if {!$q} {return [expr {$m / $p}]}
  }
}

#Class that contains basic date on Towers,
#and computations (i.e. get_scan_level {start_time})
oo::class create Tower {
  variable Position
  variable Height
  variable Last_Index

  #Number of moves before a cycle is reached
  variable Moves_Per_Cycle

  constructor {position height} {
    set Position $position
    set Height $height
    set Last_Index [expr $Height - 1]
    set Moves_Per_Cycle [expr 2 * $Last_Index]
  }

  method get_scan_level {start_time} {
    #get the number of moves that have been made since
    #the start time to the arrival at this tower
    set current_moves [expr $start_time + $Position]

    #get the distance travelled since 0 was last hit
    set moves_since_zero [expr $current_moves % $Moves_Per_Cycle]
    #get current distance away from zero to compute current level
    return [expr $moves_since_zero > $Last_Index ? $moves_since_zero - $Last_Index : $moves_since_zero]
  }

  method get_moves_per_cycle {} {
    return $Moves_Per_Cycle
  }

  method get_position {} {
    return $Position
  }

  method get_height {} {
    return $Height
  }
}

#Class that contains a list of Towers
#and helper methods that compute across said towers
oo::class create City {
  variable Towers

  #number of moves before a scan cycle
  variable Moves_Per_Complete_Cycle

  constructor {input} {
    #get each line from the input
    set lines [split $input "\n"]

    #initialize variables that will be set in loop
    set Towers [list]
    set Moves_Per_Complete_Cycle 0

    #loop through each line and parse out the values
    foreach line $lines {
      #remove whitespace from the line
      set fixed [regsub " " $line ""]
      #if the line is empty, skip it
      if {$fixed == ""} {
        break
      }
      #split "#:#" (Position:Height) from line and load them into variables
      set parts [split $fixed ":"]
      set position [lindex $parts 0]
      set height [lindex $parts 1]

      #create the tower and use it to compute the total moves before this
      #city creates a cycle (or repeated pattern in tower scan levels)
      set tower [Tower new $position $height]
      set moves_per_cycle [$tower get_moves_per_cycle]

      #if Moves_Per_Complete_Cycle is 0, it hasn't been set yet
      if {$Moves_Per_Complete_Cycle == 0} {
        set Moves_Per_Complete_Cycle $moves_per_cycle
      } else {
        #use LCM to find the lowest value before a pattern amoung towers is repeated
        #TODO: May relate to https://en.wikipedia.org/wiki/Chinese_remainder_theorem
        set Moves_Per_Complete_Cycle [lcm $moves_per_cycle $Moves_Per_Complete_Cycle]
      }
      #accumulate all the towers
      lappend Towers $tower
    }
  }

  method get_towers {} {
    return $Towers
  }

  method get_moves_per_complete_cycle {} {
    return $Moves_Per_Complete_Cycle
  }

  method get_severity {start_time} {
    set severity 0

    #loop through all the towers
    foreach tower $Towers {

      #get the scan level
      set scan_level [$tower get_scan_level $start_time]

      #if the level is 0, we were hit
      if {$scan_level == 0} {

        #keep a running total of the severity
        set severity [expr [$tower get_position] * [$tower get_height] + $severity]
      }
    }
    #return the total severity accumulated for the start time
    return $severity
  }

  #Naively solves the earliest safe time (without getting caught)
  #using the cycles before a pattern is repeated
  method get_earliest_safe_time {} {
    for {set time 0} {$time < $Moves_Per_Complete_Cycle} {incr time} {

      #start with safe set to true since we haven't proven it isn't safe yet
      set is_safe true

      #check if any tower collisions occur
      #TODO: Chain computation for towers into a single recursive anonymous function
      #      which would potentially be faster than looping
      foreach tower $Towers {
        set level [$tower get_scan_level $time]

        #if the level is 0, we we're caught; so this start time is not safe
        if {$level == 0} {
          set is_safe false
          break
        }
      }
      #if we didn't collide with any scans, this time was safe
      if {$is_safe} {
        return $time
      }
    }
    return -1
  }
}

#read in our input file
set file [open "input.txt" "r"]
set text [read $file]
close $file

#create the city of towers
set city [City new $text]

#compute the severity if you start at 0
set start_time 0
puts "Departure: $start_time \bps, Severity: [$city get_severity $start_time]"

#compute the earliest start time with no severity
set safe_severity 0
puts "Departure: [$city get_earliest_safe_time] \bps, Severity: $safe_severity"

#TODO: Destroy objects properly
