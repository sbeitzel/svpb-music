# This makefile is now set up so that the build system in AWS can use it. If
# you want to build the PDFs locally, then you'll want to read through all
# the comments carefully.
#
# To generate all the music for the band binder
# `make` (since the binder is the first target).
#
# YEAR is the year for which this project builds the binder

YEAR=2019

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
CHRISTMAS = we_wish_merry.abc jingle_bells.abc scotland_the_brave.abc auld_lang_syne.abc amazing_grace.abc \
    highland_cathedral.abc hector_hero.abc grans.abc water_wide_air.abc o_faithful.abc

ABCFILES = $(G3MEDLEY) $(G3MSR) $(G4MEDLEY) $(G4MSR) $(PARADE) $(WUSPBA)
PSFILES = $(ABCFILES:.abc=.ps)
PDFFILES = $(PSFILES:.ps=.pdf)

CONCERT_ABC = $(CHRISTMAS)
CONCERT_PS = $(CONCERT_ABC:.abc=.ps)
CONDERT_PDF = $(CONCERT_PS:.ps=.pdf)

WUSPBA_SECTION = wuspba.pdf
PARADE_SECTION = parade.pdf
CHRISTMAS_SECTION = christmas.pdf
G4_SECTION = g4.pdf
G3_SECTION = g3.pdf


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
G3_PS = $(G3_FILES:.abc=.ps)
G3_PDFS = $(G3_PS:.ps=.pdf)

G4_FILES = $(G4MEDLEY) $(G4MSR)
G4_PS = $(G4_FILES:.abc=.ps)
G4_PDFS = $(G4_PS:.ps=.pdf)

CHRISTMAS_PS = $(CHRISTMAS:.abc=.ps)
CHRISTMAS_PDFS = $(CHRISTMAS_PS:.ps=.pdf)

PARADE_PS = $(PARADE:.abc=.ps)
PARADE_PDFS = $(PARADE_PS:.ps=.pdf)

WUSPBA_PS = $(WUSPBA:.abc=.ps)
WUSPBA_PDFS = $(WUSPBA_PS:.ps=.pdf)

# What's the install tool
INSTALL = /usr/bin/install
INSTALL_FLAGS = -C
INSTALL_DIR_FLAGS = -d

# the binder PDF
BINDER = $(YEAR)_binder.pdf

$(BINDER): $(G3_SECTION) $(G4_SECTION) $(PARADE_SECTION) $(WUSPBA_SECTION)
	$(JOIN)$(BINDER) $(G3_SECTION) $(G4_SECTION) $(PARADE_SECTION) $(WUSPBA_SECTION)
	
install_concert: $(CHRISTMAS_SECTION)
	$(INSTALL) $(INSTALL_FLAGS) $(CHRISTMAS_SECTION) $(FULL_DIR)

$(G3_SECTION): $(G3_PDFS)
	perl scripts/section_titles.pl g3_section.pdf "Grade 3 Tunes"
	$(JOIN)$(G3_SECTION) g3_section.pdf $(G3_PDFS)

$(G4_SECTION): $(G4_PDFS)
	perl scripts/section_titles.pl g4_section.pdf "Grade 4 Tunes"
	$(JOIN)$(G4_SECTION) g4_section.pdf $(G4_PDFS)

$(PARADE_SECTION): $(PARADE_PDFS)
	perl scripts/section_titles.pl parade_section.pdf "Parade Tunes"
	$(JOIN)$(PARADE_SECTION) parade_section.pdf $(PARADE_PDFS)

$(WUSPBA_SECTION): $(WUSPBA_PDFS)
	perl scripts/section_titles.pl wuspba_section.pdf "Massed Bands / WUSPBA"
	$(JOIN)$(WUSPBA_SECTION) wuspba_section.pdf $(WUSPBA_PDFS)

$(CHRISTMAS_SECTION): $(CHRISTMAS_PDFS)
	perl scripts/section_titles.pl christmas_section.pdf "Christmas Concert Tunes"
	$(JOIN)$(CHRISTMAS_SECTION) christmas_section.pdf $(CHRISTMAS_PDFS)

$(PSFILES): %.ps: %.abc style.abh
	-$(ABC) $<

$(PDFFILES): %.pdf: %.ps
	$(PDF) $<

$(CONCERT_PS): %.ps: %.abc
	-$(ABC) $<

$(CONDERT_PDF): %.pdf: %.ps
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

sync : install install_concert
	rclone sync "$(LOCAL_FOLDER)/$(YEAR)" "$(BOX_FOLDER)/$(YEAR)" --checksum
