#
# generate all the music for the band binder
# `make binder`
#
RM = rm

ABC = abcm2ps -p -O =
PDF = ps2pdf

# This python script ships with Mac OS X and is probably found
# at /System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py
# Add it to your $PATH, or create a symlink to it on your $PATH, or change
# the location here.
JOIN = join.py

# The source files for all the music
G3MEDLEY = 2019_g3_medley_p1.abc 2019_g3_medley_p2.abc 2019_g3_medley_p3.abc
G3MSR = 2019_g3_msr.abc
G4MEDLEY = 2019_g4_medley.abc
G4MSR = 2019_g4_msr.abc
PARADE = banks_of_the_lossie.abc Moonstar.abc al_walker_hana.abc irish_set.abc
WUSPBA = amazing_grace.abc green_hills.abc battles_oer.abc bonny_dundee.abc \
	brown_haired_maiden.abc highland_laddie.abc scotland_the_brave.abc \
	no_awa.abc rowan_tree.abc
CHRISTMAS = highland_cathedral.abc

ABCFILES = $(G3MEDLEY) $(G3MSR) $(G4MEDLEY) $(G4MSR) $(PARADE) $(CHRISTMAS) $(WUSPBA)
PSFILES = $(ABCFILES:.abc=.ps)
PDFFILES = $(PSFILES:.ps=.pdf)

# the binder PDF
BINDER = 2019_binder.pdf

$(BINDER): $(PDFFILES)
	$(JOIN) --output $(BINDER) $(PDFFILES)
	
$(PSFILES): %.ps: %.abc
	-$(ABC) $<

$(PDFFILES): %.pdf: %.ps
	$(PDF) $<

clean:
	-$(RM) *.ps *.pdf

dist : clean $(BINDER)
	-$(RM) *.ps
