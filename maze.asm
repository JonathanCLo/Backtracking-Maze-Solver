# File:     maze.asm
# Author:   J. Lo <jcl5201>
# 
# Description:  This program reads a list of numbers from stdin and creates
#               a maze
#

# CONSTANTS
#
# syscalls
PRINT_INT =     1
PRINT_STRING =  4
READ_INT =      5
READ_STRING =   8
EXIT =          10

# space allocations
        .data
        .align  2
max_height:
        .word   0
max_width:
        .word   0
maze_array:
        .space  80*82
        .align  2
str_buffer:
        .space  80*82        

        # Print constants
        #
        .align  2
banner:
        .ascii  "===\n"
        .ascii  "=== Maze Solver\n"
        .ascii  "=== by\n"
        .ascii  "=== Jonathan Lo\n"
        .asciiz "===\n"

newline:
        .asciiz "\n"
two_newlines:
        .asciiz "\n\n"

input_maze:
        .asciiz "Input Maze:\n\n"
solution_maze:
        .asciiz "Solution:\n\n"

        .text
        .align  2
        .globl  main
        .globl  max_height
        .globl  max_width
        .globl  maze_array
        .globl  algorithm
        .globl  print_int
        .globl  print_string

#############################################################################
#       MAIN FUNCTION
#############################################################################
main:
        addi    $sp, $sp, -12
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)

print_banners:
        la      $a0, banner
        jal     print_string            # print the banner strings
        
        la      $a0, two_newlines
        jal     print_string            # two new lines

read:
        jal     read_inputs             # read all inputs

print_maze:
        la      $s0, max_height
        lw      $s0, 0($s0)             # get actual height of maze

        la      $s1, max_width
        lw      $s1, 0($s1)             # get actual width of maze
        
        addi    $s1, 2
        la      $s2, maze_array         # get maze addr

        li      $t0, 0

        la      $a0, input_maze
        jal     print_string            # print input maze prompt

print_input:
        beq     $t0, $s0, print_done    # if count == height; break
        move    $a0, $s2
        jal     print_string            # print a line of the maze
        
        add     $s2, $s1
        addi    $t0, 1                  # increment counters and ptr

        j       print_input

print_done:
        la      $a0, two_newlines
        jal     print_string            # print two new lines

        la      $a0, solution_maze
        jal     print_string            # print solution prompt string

        jal     algorithm               # run to algorithm
main_done:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 16

        jr      $ra

#############################################################################
#       HELPER FUNCTIONS
#############################################################################

#############################################################################
# Name:         read_int
# Description:  reads and returns an integer from stdin
# Arguments:    None
# Return:       $v0 with the integer read
read_int:
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)
        
        li      $v0, READ_INT
        syscall
        
        lw      $ra, 0($sp)
        addi    $sp, $sp, 4

        jr      $ra

#############################################################################
# Name:         read_string
# Description:  reads and returns an string from stdin
# Arguments:    None
# Return:       $v0 with the string read
read_string:
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)
               
        li      $v0, READ_STRING
        syscall
        
        lw      $ra, 0($sp)
        addi    $sp, $sp, 4

        jr      $ra

#############################################################################
# Name:         print_int
# Description:  prints out a single integer
# Arguments:    $a0 the number to print
# Retunrs:      None
print_int:
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)
        
        li      $v0, PRINT_INT
        syscall
        
        lw      $ra, 0($sp)
        addi    $sp, $sp, 4

        jr      $ra

#############################################################################
# Name:         print_string
# Description:  prints out a string
# Arguments:    $a0, the string to print
# Returns:      Nonw
print_string:
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)
        
        li  $v0, PRINT_STRING
        syscall
        
        lw      $ra, 0($sp)
        addi    $sp, $sp, 4

        jr      $ra

#############################################################################
#   Function Calls
#############################################################################

#############################################################################
# Name:         read_inputs
# Description:  read the inputs from stdin and stores them to appropriate
#               values
# Arguments:    none
# Returns:      none
#############################################################################
read_inputs:
        addi    $sp, $sp, -20
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)
        
        la      $s0, max_height
        la      $s1, max_width
        la      $s2, maze_array
        
        jal     read_int
        sw      $v0, 0($s0)
        
        jal     read_int
        sw      $v0, 0($s1)             # reads all int input
        
        lw      $s0, 0($s0)             # get actual height
        lw      $s1, 0($s1)
        addi    $s1, $s1, 2             # gets actual width
        
read_array:
        li      $t1, 0                  # sets up count for height         

ra_loop:
        # loop through lines in input
        beq     $t1, $s0, ra_done

        move    $a0, $s2
        move    $a1, $s1
        jal     read_string             # reads the line from input and stores
                                        # line into maze       
        add     $s2, $s2, $s1           # move pointer of maze_array
        addi    $t2, $t2, 1

ra_loop_end:
        addi    $t1, $t1, 1
        j       ra_loop

ra_done:

read_inputs_done:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        addi    $sp, $sp, 20

        jr      $ra
