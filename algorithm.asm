# File:     maze.asm
# Author:   J. Lo <jcl5201>
# 
# Description:  algorithm to run, solve the maze and prints out the solution
#

# Direction Contants
UP =    0
RIGHT = 1 
DOWN =  2
LEFT =  3

        .data
        .align  2
# Mouse entity
# store x position
curr_x:
        .word   0
# store y position
curr_y:
        .word   0
# store direction
curr_dir:
        .word   UP

# count for turning
turn_count:
        .word   0

# scratch maze for comparing
scratch_maze:
        .space  80*82

# ASCII constants
error_msg:
        .asciiz "Error, unknown character found. Aborting solver\n"
end_found:
        .asciiz "Completed\n"
space:
        .asciiz " " 

        .text
        .align  2
        .globl  max_height
        .globl  max_width
        .globl  maze_array
        .globl  print_int
        .globl  print_string
        .globl  algorithm
        .globl  newline


#############################################################################
#       HELPER FUNCTIONS
#############################################################################

#############################################################################
# Name:         create_copy
# Description   creates a copy of the original maze
# Arguments:    none
# Returns:      none
#
create_copy:
        addi    $sp, $sp, -24
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)
        sw      $s4, 20($sp)
        
        la      $s0, max_height
        la      $s1, max_width
        lw      $s0, 0($s0)
        lw      $s1, 0($s1)
        addi    $s1, 2
        mul     $s0, $s0, $s1           # get total length to loop through

        la      $s1, maze_array
        la      $s2, scratch_maze       # get the arrays
        move    $t0, $zero              # set counter
copy_loop:
        beq     $t0, $s0, copy_loop_done
        lb      $s3, 0($s1)
        sb      $s3, 0($s2)             # load and store it into a copy
        
copy_loop_end:
        addi    $t0, 1
        addi    $s1, $s1, 1
        addi    $s2, $s2, 1             # increm all counts and ptrs
        j       copy_loop

copy_loop_done:
create_copy_done:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        lw      $s4, 20($sp)
        addi    $sp, $sp, 24

        jr      $ra

#############################################################################
# Name:         get_pos
# Description:  get the char (int) value at the specific board
# Arguments:    $a0     x pos, width
#               $a1     y pos, height
#               $a2     addr of array
# Returns:      $v0     int representation of the value returned
#                       returns 0 if failed
#                       
get_pos:
        addi    $sp, $sp, -16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        
        move    $s2, $a2
        li      $v0, 0                          # set up return

        la      $s0, max_height
        lw      $s0, 0($s0)                     # get actual height             
        blt     $a1, $zero, get_pos_done
        bge     $a1, $s0, get_pos_done          # check for valid length
        
        la      $s0, max_width
        lw      $s0, 0($s0)             
        blt     $a0, $zero, get_pos_done
        bge     $a0, $s0, get_pos_done          # check for valid width
        addi    $s0, 2

        mul     $s1, $a1, $s0
        add     $s1, $s1, $a0
        add     $s2, $s2, $s1                   # math to get to position in
                                                # array

        lb      $v0, 0($s2)                     # get value at position
get_pos_done:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 16

        jr      $ra

#############################################################################
# Name:         write_pos
# Description:  write a given character to the position
# Arguments:    $a0     x pos, width
#               $a1     y pos, height
#               $a2     ascii int value to insert
#               $a3     addr of array to go into
# Returns:      none
write_pos:
        addi    $sp, $sp, -16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        
        move    $s2, $a3
        la      $s0, max_height
        lw      $s0, 0($s0)             
        blt     $a1, $zero, write_pos_done
        bge     $a1, $s0, write_pos_done        # check for valid length
        
        la      $s0, max_width
        lw      $s0, 0($s0)             
        blt     $a0, $zero, write_pos_done
        bge     $a0, $s0, write_pos_done        # check for valid width
        addi    $s0, 2
        # does not alter newline or print statements
       
        mul     $s1, $a1, $s0
        add     $s1, $s1, $a0
        add     $s2, $s2, $s1                   # math to get to pos

        sb      $a2, 0($s2)                     # store into the array

write_pos_done:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 16

        jr      $ra

#############################################################################
# Name:         find_start
# Description:  does byte by byte checking to see where the starting position
#               is located at
# Arguments:    none
# Returns:      none
find_start:
        addi    $sp, $sp, -16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        
        la      $s0, max_height
        lw      $s0, 0($s0)
        la      $s1, max_width
        lw      $s1, 0($s1)
        addi    $s1, $s1, 2             # get shifted width

        mul     $t0, $s0, $s1           # get total chars

        la      $s0, maze_array
        li      $t1, 0                  # set up counter 
        li      $t2, 83                 # ASCII value for S
for_loop:
        lb      $t3, 0($s0)
        beq     $t3, $t2, found  
        j       for_loop_end
found: 
        la      $s1, max_width
        lw      $s1, 0($s1)
        addi    $s1, 2
        rem     $s2, $t1, $s1           # math to find X position
        
        la      $s1, curr_x
        sw      $s2, 0($s1)             # store value

        la      $s1, max_width
        lw      $s1, 0($s1)
        addi    $s1, 2 
        div     $s2, $t1, $s1           # math to find Y position
        
        la      $s1, curr_y
        sw      $s2, 0($s1)             # store value
        
        j       for_loop_done
for_loop_end:
        addi    $s0, $s0, 1
        addi    $t1, $t1, 1             # increment ptr and count
        j       for_loop
for_loop_done:
find_start_done:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 16
        jr      $ra

#############################################################################
# Name:         look_ahead
# Description:  look ahead one square for current direction
# Arguments:    $a0     addr of maze to look at
# Returns:      $v0     return char at the next square
#                       returns -1 on incomplete
look_ahead:
        addi    $sp, $sp, -24
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)
        sw      $s4, 20($sp)
        
        move    $s3, $a0
        la      $s0, curr_x
        lw      $s0, 0($s0)
        la      $s1, curr_y
        lw      $s1, 0($s1)
        la      $s2, curr_dir
        lw      $s2, 0($s2)             # get mouse attributes
        
        li      $v0, -1

        li      $t0, UP
        beq     $t0, $s2, look_up
        li      $t0, LEFT
        beq     $t0, $s2, look_left
        li      $t0, DOWN
        beq     $t0, $s2, look_down
        j       look_right              # check which direction mouse is
                                        # looking at.

look_up:
        move    $a0, $s0
        move    $a1, $s1
        addi    $a1, -1                 
        move    $a2, $s3
        jal     get_pos
        move    $s4, $v0

        j       look_ahead_done

look_left:
        move    $a0, $s0
        addi    $a0, -1
        move    $a1, $s1
        move    $a2, $s3
        jal     get_pos
        move    $s4, $v0
        
        j       look_ahead_done

look_down:
        move    $a0, $s0
        move    $a1, $s1
        addi    $a1, 1
        move    $a2, $s3
        jal     get_pos
        move    $s4, $v0
        
        j       look_ahead_done

look_right:
        move    $a0, $s0
        addi    $a0, 1
        move    $a1, $s1
        move    $a2, $s3
        jal     get_pos
        move    $s4, $v0
        
        j       look_ahead_done

look_ahead_done:
        move    $v0, $s4                # at this point, there return
                                        # should hold a value
        
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        lw      $s4, 20($sp)
        addi    $sp, $sp, 24
        jr      $ra  

#############################################################################
# Name:         turn_clockwise
# Description:  turn clockwise
# Arguments:    none
# Returns:      none
turn_clockwise:
        addi    $sp, $sp, -16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        
        la      $s0, curr_dir
        lw      $s1, 0($s0)
        addi    $s1, $s1, 1             # turn counter clockwise and saved
        rem     $s1, $s1, 4
        sw      $s1, 0($s0)
        la      $s0, turn_count
        lw      $s1, 0($s0)
        addi    $s1, $s1, 1
        sw      $s1, 0($s0)

turn_clockwise_done:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 16
        jr      $ra

#############################################################################
# Name:         backtrace
# Description:  looks at bread crumb and go back to the previous step
# Arguments:    none
# Returns:      none
backtrace:
        addi    $sp, $sp, -36
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)
        sw      $s4, 20($sp)
        sw      $s5, 24($sp)
        sw      $s6, 28($sp)
        sw      $s7, 32($sp)
        
        la      $s0, curr_x
        la      $s1, curr_y
        lw      $s0, 0($s0)
        lw      $s1, 0($s1)             # get mouse
        
        move    $a0, $s0
        move    $a1, $s1
        la      $a2, scratch_maze
        jal     get_pos
        move    $s2, $v0                # gets the bread crumb from scratch board

        li      $s3, 101
        beq     $s2, $s3, backtrack_east
        li      $s3, 110
        beq     $s2, $s3, backtrack_north
        li      $s3, 115
        beq     $s2, $s3, backtrack_south
        li      $s3, 119
        beq     $s2, $s3, backtrack_west
                                        # decide which direction to go in
backtrack_east:
        la      $s0, curr_x
        lw      $s1, 0($s0)
        addi    $s1, $s1, 1
        sw      $s1, 0($s0)             
        j       backtrace_done
backtrack_north:
        la      $s0, curr_y
        lw      $s1, 0($s0)
        addi    $s1, $s1, -1
        sw      $s1, 0($s0)             
        j       backtrace_done
backtrack_south:
        la      $s0, curr_y
        lw      $s1, 0($s0)
        addi    $s1, $s1, 1
        sw      $s1, 0($s0)
        j       backtrace_done
backtrack_west:
        la      $s0, curr_x
        lw      $s1, 0($s0)
        addi    $s1, $s1, -1
        sw      $s1, 0($s0)
        j       backtrace_done

backtrace_done:
        # at this point, the mouse has moved exactly one step back

        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        lw      $s4, 20($sp)
        lw      $s5, 24($sp)
        lw      $s6, 28($sp)
        lw      $s7, 32($sp)
        addi    $sp, $sp, 36
        jr      $ra  

#############################################################################
#       Movement Functions
#############################################################################
# Name:         move_once
# Description:  moves the mouse forward by one dirction, based on its current
#               heading
# Arguments:    none
# Returns:      none
move_once:
        addi    $sp, $sp, -16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        
        la      $s0, curr_dir
        lw      $s0, 0($s0)
        li      $s1, UP
        beq     $s0, $s1, move_n
        li      $s1, RIGHT
        beq     $s0, $s1, move_e
        li      $s1, LEFT
        beq     $s0, $s1, move_w
        j       move_s
move_n:
        jal     move_north
        j       move_once_done
move_e:
        jal     move_east
        j       move_once_done
move_s:
        jal     move_south
        j       move_once_done
move_w:
        jal     move_west
        j       move_once_done
move_once_done:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 16
        jr      $ra

#############################################################################
# Name:         move_DIRECTION
# Description:  moves the "mouse" as specified
# Arguments:    none
# Returns:      none
move_north:
        addi    $sp, $sp, -16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        
        la      $s0, curr_y
        lw      $s1, 0($s0)
        addi    $s1, $s1, -1
        sw      $s1, 0($s0)             # change the mouse position
leave_crumb_north:
        la      $a0, curr_x
        lw      $a0, 0($a0)
        la      $a1, curr_y
        lw      $a1, 0($a1)
        li      $a2, 115
        la      $a3, scratch_maze
        jal     write_pos               # write to that spot in the scratch maze
                                        # leaves an ascii character telling
                                        # where it was before hand
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 16
        jr      $ra


move_east:
        addi    $sp, $sp, -16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)

        la      $s0, curr_x
        lw      $s1, 0($s0)
        addi    $s1, $s1, 1
        sw      $s1, 0($s0)
leave_crumb_east:
        la      $a0, curr_x
        lw      $a0, 0($a0)
        la      $a1, curr_y
        lw      $a1, 0($a1)
        li      $a2, 119
        la      $a3, scratch_maze
        jal     write_pos               # write to that spot in the scratch maze
                                        # leaves an ascii character telling
                                        # where it was before hand
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 16
        jr      $ra

move_south:
        addi    $sp, $sp, -16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        
        la      $s0, curr_y
        lw      $s1, 0($s0)
        addi    $s1, $s1, 1
        sw      $s1, 0($s0)
leave_crumb_south:
        la      $a0, curr_x
        lw      $a0, 0($a0)
        la      $a1, curr_y
        lw      $a1, 0($a1)
        li      $a2, 110
        la      $a3, scratch_maze
        jal     write_pos               # write to that spot in the scratch maze
                                        # leaves an ascii character telling
                                        # where it was before hand
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 16
        jr      $ra

move_west:
        addi    $sp, $sp, -16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        
        la      $s0, curr_x
        lw      $s1, 0($s0)
        addi    $s1, $s1, -1
        sw      $s1, 0($s0)
leave_crumb_west:
        la      $a0, curr_x
        lw      $a0, 0($a0)
        la      $a1, curr_y
        lw      $a1, 0($a1)
        li      $a2, 101
        la      $a3, scratch_maze
        jal     write_pos               # write to that spot in the scratch maze
                                        # leaves an ascii character telling
                                        # where it was before hand
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 16
        jr      $ra
#############################################################################
# Name:         follow_up
# Description:  from the breadcrumbs of scratch board, move the mouse back
#               to start
# Arguments:    none
# Retunrs:      none
follow_up:
        addi    $sp, $sp, -36
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)
        sw      $s4, 20($sp)
        sw      $s5, 24($sp)
        sw      $s6, 28($sp)
        sw      $s7, 32($sp)

        la      $s0, curr_x
        la      $s1, curr_y
        lw      $s0, 0($s0)
        lw      $s1, 0($s1)             # get mouse

        move    $a0, $s0
        move    $a1, $s1
        la      $a2, scratch_maze
        jal     get_pos                 # get character at mouse

        li      $s3, 101
        beq     $s2, $s3, follow_east
        li      $s3, 110
        beq     $s2, $s3, follow_north
        li      $s3, 115
        beq     $s2, $s3, follow_south
        li      $s3, 119
        beq     $s2, $s3, follow_west
                                        # decide which direction to go in
follow_east:
        la      $s0, curr_x
        lw      $s1, 0($s0)
        addi    $s1, 1
        sw      $s1, 0($s0)
        j       follow_up_done
follow_north:
        la      $s0, curr_y
        lw      $s1, 0($s0)
        addi    $s1, -1
        sw      $s1, 0($s0)
        j       follow_up_done
follow_south:
        la      $s0, curr_y
        lw      $s1, 0($s0)
        addi    $s1, 1
        sw      $s1, 0($s0)
        j       follow_up_done
follow_west:
        la      $s0, curr_x
        lw      $s1, 0($s0)
        addi    $s1, -1
        sw      $s1, 0($s0)
        j       follow_up_done

follow_up_done:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        lw      $s4, 20($sp)
        lw      $s5, 24($sp)
        lw      $s6, 28($sp)
        lw      $s7, 32($sp)
        addi    $sp, $sp, 36
        jr      $ra  
#############################################################################
#       ALGORITHM
#############################################################################
# Name:         algorithm
# Description:  run the algorithm. this is really op.
# Arguments:    none
# Returns:      none
algorithm:
        addi    $sp, $sp, -36
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)
        sw      $s4, 20($sp)
        sw      $s5, 24($sp)
        sw      $s6, 28($sp)
        sw      $s7, 32($sp)
        jal     create_copy

step1:
        jal     find_start
step2:
        la      $s0, curr_x
        lw      $s0, 0($s0)             # get curr x pos
        la      $s1, curr_y
        lw      $s1, 0($s1)             # get curr y pos
        
        move    $a0, $s0
        move    $a1, $s1
        la      $a2, maze_array
        jal     get_pos                 # get square 
        move    $s2, $v0
        
        la      $s7, turn_count
        sw      $zero, 0($s7)

        li      $t0, 69
        beq     $s2, $t0, step5         # check if square is 'E'
        li      $t0, 32
        beq     $s2, $t0, step3         # check if square is ' '
        li      $t0, 83
        beq     $s2, $t0, step3         # check is square is 'S'
        j       error_exit
step3:    
        la      $a0, maze_array
        jal     look_ahead
        
        move    $s3, $v0
        li      $t9, 32
        beq     $s3, $t9, step3_cond    # check for space in main board
        li      $t9, 69
        beq     $s3, $t9, step4
        j       else
step3_cond:
        la      $a0, scratch_maze
        jal     look_ahead
        move    $s3, $v0                # look at next square

        li      $t9, 101                 
        beq     $s3, $t9, else         
        li      $t9, 110
        beq     $s3, $t9, else
        li      $t9, 115
        beq     $s3, $t9, else
        li      $t9, 119
        beq     $s3, $t9, else          # check for breadcrumbs
        j       step4
else:
        jal     turn_clockwise
check_turn_count:
        la      $s4, turn_count
        lw      $s4, 0($s4)
        li      $t9, 4
        beq     $s4, $t9, turn_max      # check if turned max times already
        j       step3

turn_max:
        la      $s4, turn_count
        sw      $zero, 0($s4)           # reset turn count and backtrack
backtrack:
        jal     backtrace
        j       step3 
step4:
        jal     move_once
        j       step2
step5:   
        jal     backtrace               # back track one step

        la      $s0, curr_x
        la      $s1, curr_y
        lw      $s0, 0($s0)
        lw      $s1, 0($s1)
        la      $a2, maze_array         # load mous and stuff

        move    $a0, $s0
        move    $a1, $s1
        jal     get_pos
        move    $s2, $v0                # get char at position

        li      $s5, 83
        beq     $s2, $s5, step6         # if reached the start, done reading
                                        # bread crumbs.        
        move    $a0, $s0                
        move    $a1, $s1
        li      $a2, 46
        la      $a3, maze_array
        jal     write_pos               # if not, leave a physical crumb

        j       step5
step6:
        # done with reading, solving, writing.
print_solution:
        la      $s0, max_height
        la      $s1, max_width
        lw      $s0, 0($s0)
        lw      $s1, 0($s1)
        addi    $s1, 2
        la      $s2, maze_array

        li      $s3, 0                  # count
print_s_loop:
        beq     $s3, $s0, print_s_done
        
        move    $a0, $s2
        jal     print_string            # print the line of the maze, ends with
                                        # null        
        addi    $s3, 1
        add     $s2, $s1                # shift ptrs and add count

        j       print_s_loop
print_s_done:
        j       algorithm_done          # done completely
error_exit:
        la      $a0, error_msg
        jal     print_string
        li      $v0, 10
        syscall                         # error message ready to be sued
algorithm_done:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        lw      $s4, 20($sp)
        lw      $s5, 24($sp)
        lw      $s6, 28($sp)
        lw      $s7, 32($sp)
        addi    $sp, $sp, 36
        jr      $ra                     # DONE!
