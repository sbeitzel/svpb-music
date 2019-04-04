# SVPB Music

This project contains all the ABC source files for the band
sheet music. The Makefile will make the music binder and
individual tune and set PDF files. When adding a tune, make
sure to update the Makefile so it is included in the build.

# Current Build Chain

We have a small server which is running [TeamCity](https://www.jetbrains.com/teamcity/). Periodically, this checks for updates to the __master__ branch of this project. When it detects a change, it pulls the project and builds the binder. It then copies all the freshly built PDFs onto the band's Box folder. The TeamCity server also sends a notification to the `music` channel in the band's Slack group when a fresh build has completed.

There's a webhook installed in Github so that when checkins happen to __master__ a notification gets sent to the `music` channel in the band's Slack group.


# Process and Tools

We use the [gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) workflow to keep the tunes for this year separate from the tunes for next year. Next year's set/tune edits happen on the [develop](https://github.com/sbeitzel/svpb-music/tree/develop) branch while changes to the current tunes happen on [master](https://github.com/sbeitzel/svpb-music/tree/master). To make using this flow easy, I suggest the free tool, [Sourcetree](https://www.sourcetreeapp.com/), from Atlassian.

We save our tunes as ABC files. For details on ABC, refer to the [ABC standard](http://abcnotation.com/wiki/abc:standard:v2.2). Most graphical music programs understand ABC and can import it (e.g. [CelticPipes](https://www.celticpipes.net/), [MuseScore](https://musescore.org/en), &c) but since it is a text format and not binary, it compresses well and is much friendlier for revision control systems than their native binary formats. Also, since ABC is a text format, you don't need a particular application which may not be available on your platform - just edit the text.

To produce PDF files which we print and put in our binders, we use a series of tools. First, we use [abcm2ps](https://github.com/leesavide/abcm2ps) to convert the ABC files to PostScript. Then, we convert the PostScript to PDF. MacOS ships with a script, `pstopdf`, which can do this, and other systems can install [Ghostscript](https://www.ghostscript.com/), which provides a similar tool, `ps2pdf`, which does the same thing.
