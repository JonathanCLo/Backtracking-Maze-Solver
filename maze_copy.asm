# File:     $Id$
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

        .data
        .align  2
#maze_array:
#        .space  80*80   # store one byte chars,
max_height:
        .word   0
max_width:
        .word   0

        .align  2
str_buffer:
        .space  80

        #
        # Print constants
        #
        .align  0
banner:
        .ascii  "===\n"
        .ascii  "=== Maze Solver\n"
        .ascii  "=== by\n"
        .ascii  "=== Jonathan Lo\n"
        .asciiz "===\n"

two_newlines:
        .asciiz "\n\n"

input_maze:
        .asciiz "Input Maze:\n"


        # main code
        .text
        .align  2
        .globl  main
        .globl  print_int
        .globl  print_string
main:
        addi    $sp, $sp, -14
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)

        la      $s0, max_height
        la      $s1, max_width
#        la      $s2, maze_array

read_inputs:
        jal     read_int
        sw      $v0, 0($s0)             # save height
        
        jal     read_int
        sw      $v0, 0($s1)             # save width
        
#        la      $t0, max_height
#        lw      $s0, 0($t0)
#        la      $t0, max_width
#        lw      $s1, 0($t0)
print_banner:
        la      $a0, banner
        jal     print_string
        
        la      $a0, two_newlines
        jal     print_string

#        li      $t1, 0                  # current height
#        li      $t2, 0                  # current width
#ra_loop:
#        beq     $t1, $s0, ra_done       # if reached max_height
#        jal     read_string
#        move    $t0, $v0
#str_loop:
#        # reads the individual bytes passed per string line
#        
#        beq     $t2, $s1, str_loop_done # if reached max_width
#        lb      $t3, 0($t0)             # get first byte of input line
#        sb      $t3, 0($s2)             # saves byte into array
#        
#str_loop_done:
#        addi    $t0, $t0, 1             # move the pointer of input line by one
#        addi    $s2, $s2, 1             # move array addr by onw byte
#        addi    $t2, $t2, 1             # increment width count
#    
#ra_end:        
#        addi    $t1, $t1, 1             # increment height count
#        j       ra_loop
#ra_done:

main_done:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 14
        jr      $ra

#############################################################################
#       HELPER FUNCTIONS
#############################################################################

# Nmae:         read_int
# Description:  reads and returns an integer from stdin
# Arguments:    None
# Return:       $v0 with the integer read
read_int:
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)
        
        li      $v0, READ_INT
        syscall
        
        sw      $ra, 0($sp)
        addi    $sp, $sp, 4

        jr      $ra

# Nmae:         read_string
# Description:  reads and returns an string from stdin
# Arguments:    None
# Return:       $v0 with the string read
read_string:
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)
        
        la      $a0, str_buffer
        li      $a1, 80
        li      $v0, READ_STRING
        syscall
        
        sw      $ra, 0($sp)
        addi    $sp, $sp, 4

        jr      $ra



# Name:         print_int
# Description:  prints out a single integer
# Arguments:    $a0 the number to print
# Retunrs:      None
print_int:
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)
        
        li      $v0, PRINT_INT
        syscall
        
        sw      $ra, 0($sp)
        addi    $sp, $sp, 4

        jr      $ra

# Name:         print_string
# Description:  prints out a string
# Arguments:    $a0, the string to print
# Returns:      Nonw
print_string:
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)
        
        li  $v0, PRINT_STRING
        syscall
        
        sw      $ra, 0($sp)
        addi    $sp, $sp, 4

        jr      $ra

