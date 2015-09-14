
# Makefile for CompOrg Experiment 3 - tree
#

#
# Location of the processing programs
#
RASM  = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink
RSIM  = /home/fac/wrc/bin/rsim

#
# Suffixes to be used or created
#
.SUFFIXES:	.asm .obj .lst .out

#
# Object files to be created
#
OBJECTS = maze.obj algorithm.obj

#
# Transformation rule: .asm into .obj
#
.asm.obj:
	$(RASM) -l $*.asm > $*.lst

#
# Transformation rule: .obj into .out
#
.obj.out:
	$(RLINK) -o $*.out $*.obj

#
# Main target
#
tree.out:	$(OBJECTS)
	$(RLINK) -m -o maze.out $(OBJECTS) > maze.map

run:	maze.out
	$(RSIM) maze.out
