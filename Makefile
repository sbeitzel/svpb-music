#
# generate all the music for the band binder
# `make binder`
#

RM = rm

# The command which will be called with an ABC file as the one argument and which
# will generate the PostScript file.
ABC = abcm2ps -p -O =

# The command which will convert the PostScript file to a PDF file. On Mac OSX, the
# utility pstopdf ships with the operating system and is located at /usr/bin/pstopdf
# while non-Mac systems will generally have to install something else, such as
# GhostScript. GhostScript provides ps2pdf.
PDF = pstopdf

# This python script ships with Mac OS X and is probably found
# at /System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py
# Add it to your $PATH, or create a symlink to it on your $PATH, or change
# the location here.
# If you have installed GhostScript, then you can use that to join the PDFs:
# gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=finished.pdf file1.pdf file2.pdf
#
# JOIN = join.py --output 
JOIN = gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=

# The source files for all the music
G3MEDLEY = 2019_g3_medley_p1.abc 2019_g3_medley_p2.abc 2019_g3_medley_p3.abc \
   2019_g3_medley_harmonies.abc
G3MSR = 2019_g3_msr.abc
G4MEDLEY = 2019_g4_medley.abc
G4MSR = 2019_g4_msr.abc
PARADE = banks_of_the_lossie.abc Moonstar.abc al_walker_hana.abc irish_set.abc
WUSPBA = amazing_grace.abc green_hills.abc battles_oer.abc bonnie_dundee.abc \
   brown_haired_maiden.abc highland_laddie.abc scotland_the_brave.abc \
   no_awa.abc rowan_tree.abc
CHRISTMAS = highland_cathedral.abc hyfrydol.abc auld_lang_syne.abc

ABCFILES = $(G3MEDLEY) $(G3MSR) $(G4MEDLEY) $(G4MSR) $(PARADE) $(CHRISTMAS) $(WUSPBA)
PSFILES = $(ABCFILES:.abc=.ps)
PDFFILES = $(PSFILES:.ps=.pdf)

# What are the artifacts, and where do they go
BOX_ROOT = /Users/sbeitzel/Box\ Sync/Silicon\ Valley\ Pipe\ Band/
G3_DIR = $(BOX_ROOT)Grade\ 3/Bagpipes/
G4_DIR = $(BOX_ROOT)Grade\ 4/Bagpipe/2019\ Sets/
FULL_DIR = $(BOX_ROOT)Full\ Band/Books/Band\ Tunes\ 2019/
G3_FILES = $(G3MEDLEY) $(G3MSR)
G3_PDFS = $(G3_FILES:.abc=.pdf)
G4_FILES = $(G4MEDLEY) $(G4MSR)
G4_PDFS = $(G4_FILES:.abc=.pdf)
FULL_FILES = $(PARADE) $(WUSPBA) $(CHRISTMAS)
FULL_PDFS = $(FULL_FILES:.abc=.pdf)

# What's the install tool
INSTALL = /usr/bin/install
INSTALL_FLAGS = -C

# the binder PDF
BINDER = 2019_binder.pdf

$(BINDER): $(PDFFILES)
	$(JOIN)$(BINDER) $(PDFFILES)
	
$(PSFILES): %.ps: %.abc
	-$(ABC) $<

$(PDFFILES): %.pdf: %.ps
	$(PDF) $<

clean:
	-$(RM) *.ps *.pdf

dist : clean $(BINDER)
	-$(RM) *.ps

install : $(BINDER)
	$(INSTALL) $(INSTALL_FLAGS) $(BINDER) $(FULL_PDFS) $(FULL_DIR)
	$(INSTALL) $(INSTALL_FLAGS) $(G3_PDFS) $(G3_DIR)
	$(INSTALL) $(INSTALL_FLAGS) $(G4_PDFS) $(G4_DIR)

