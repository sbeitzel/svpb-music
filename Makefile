# This makefile is now set up so that the build system in AWS can use it. If
# you want to build the PDFs locally, then you'll want to read through all
# the comments carefully.
#
# To generate all the music for the band binder
# `make` (since the binder is the first target).
#
# YEAR is the year for which this project builds the binder

YEAR=2020

RM = rm

# The command which will be called with an ABC file as the one argument and which
# will generate the PostScript file.
ABC = abcm2ps -p -O =

# The command which will convert the PostScript file to a PDF file. On Mac OSX, the
# utility pstopdf ships with the operating system and is located at /usr/bin/pstopdf
# while non-Mac systems will generally have to install something else, such as
# GhostScript. GhostScript provides ps2pdf.
PDF = ps2pdf

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
PARADE = banks_of_the_lossie.abc Moonstar.abc Moonstar_seconds.abc grans.abc al_walker_hana.abc irish_set.abc \
   dovecote_park.abc leaving_port_askaig.abc
WUSPBA = amazing_grace.abc green_hills.abc battles_oer.abc bonnie_dundee.abc \
   brown_haired_maiden.abc highland_laddie.abc scotland_the_brave.abc \
   no_awa.abc rowan_tree.abc
CHRISTMAS = highland_cathedral.abc hyfrydol.abc auld_lang_syne.abc

ABCFILES = $(G3MEDLEY) $(G3MSR) $(G4MEDLEY) $(G4MSR) $(PARADE) $(CHRISTMAS) $(WUSPBA)
PSFILES = $(ABCFILES:.abc=.ps)
PDFFILES = $(PSFILES:.ps=.pdf)

# What are the artifacts, and where do they go
# We use rclone to sync the artifacts to Box, since it is going to
# stop supporting WebDAV some time soon. That, in turn, means that
# we don't get to just mount box.com somewhere on the file system and
# copy our artifacts there. Instead, we use install to put the artifacts
# in place on the local file system and then we call rclone to sync the
# local files with the service.

# LOCAL_FOLDER is the local directory that we'll install files to.
# BOX_FOLDER is the full rclone specifier for the Box folder. e.g.: "svpb-box:Silicon Valley Pipe Band/sheet_music"

G3_DIR = $(LOCAL_FOLDER)/$(YEAR)/g3/
G4_DIR = $(LOCAL_FOLDER)/$(YEAR)/g4/
FULL_DIR = $(LOCAL_FOLDER)/$(YEAR)/full_band/
G3_FILES = $(G3MEDLEY) $(G3MSR)
G3_PDFS = $(G3_FILES:.abc=.pdf)
G4_FILES = $(G4MEDLEY) $(G4MSR)
G4_PDFS = $(G4_FILES:.abc=.pdf)
FULL_FILES = $(PARADE) $(WUSPBA) $(CHRISTMAS)
FULL_PDFS = $(FULL_FILES:.abc=.pdf)

# What's the install tool
INSTALL = /usr/bin/install
INSTALL_FLAGS = -C
INSTALL_DIR_FLAGS = -d

# the binder PDF
BINDER = $(YEAR)_binder.pdf

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
	$(INSTALL) $(INSTALL_DIR_FLAGS) $(FULL_DIR) $(G3_DIR) $(G4_DIR)
	$(INSTALL) $(INSTALL_FLAGS) $(BINDER) $(FULL_PDFS) $(FULL_DIR)
	$(INSTALL) $(INSTALL_FLAGS) $(G3_PDFS) $(G3_DIR)
	$(INSTALL) $(INSTALL_FLAGS) $(G4_PDFS) $(G4_DIR)

sync : install
	rclone sync "$(LOCAL_FOLDER)/$(YEAR)" "$(BOX_FOLDER)/$(YEAR)" --checksum --dry-run
