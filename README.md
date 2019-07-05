# SVPB Music

This project contains all the ABC source files for the band
sheet music. The Makefile will make the music binder and
individual tune and set PDF files. When adding a tune, make
sure to update the Makefile so it is included in the build.

# Current Build Chain

~~We have a small server which is running [TeamCity](https://www.jetbrains.com/teamcity/). Periodically, this checks for updates to the __master__ branch of this project. When it detects a change, it pulls the project and builds the binder. It then copies all the freshly built PDFs onto the band's Box folder. The TeamCity server also sends a notification to the `music` channel in the band's Slack group when a fresh build has completed.~~

_In progress:_ TeamCity is a resource pig, requiring massive amounts of disk space as well as an external database. This
is great for enterprise development teams doing multiple builds and development on multiple code bases, but it's
overkill for what we're doing, here. We're working on reworking the tool chain so that what happens is, a commit pushed
to Github will trigger a webhook on a build server which will run the appropriate Makefile (the one on the committed
branch). Because Box is turning off support for WebDAV (for good reasons) and doesn't actually support Linux (for
mystifying reasons) the way we get files up there is via [rclone](https://rclone.org).

There's a webhook installed in Github so that when checkins happen to __master__ a notification gets sent to the `music` channel in the band's Slack group.


# Process and Tools

~~We use the [gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) workflow to keep the tunes for this year separate from the tunes for next year. Next year's set/tune edits happen on the [develop](https://github.com/sbeitzel/svpb-music/tree/develop) branch while changes to the current tunes happen on [master](https://github.com/sbeitzel/svpb-music/tree/master). To make using this flow easy, I suggest the free tool, [Sourcetree](https://www.sourcetreeapp.com/), from Atlassian.~~

_In progress:_ Each year's tunes are stored in a corresponding branch: 2019 tunes are in the 2019 branch, 2020 tunes are in the 2020
branch, etc. When we start making decisions about the next year's tunes, we create a new branch for the next year from
the current year.

We save our tunes as ABC files. For details on ABC, refer to the [ABC standard](http://abcnotation.com/wiki/abc:standard:v2.2). Most graphical music programs understand ABC and can import it (e.g. [CelticPipes](https://www.celticpipes.net/), [MuseScore](https://musescore.org/en), &c) but since it is a text format and not binary, it compresses well and is much friendlier for revision control systems than their native binary formats. Also, since ABC is a text format, you don't need a particular application which may not be available on your platform - just edit the text.

To produce PDF files which we print and put in our binders, we use a series of tools. First, we use [abcm2ps](https://github.com/leesavide/abcm2ps) to convert the ABC files to PostScript. Then, we convert the PostScript to PDF. MacOS ships with a script, `pstopdf`, which can do this, and other systems can install [Ghostscript](https://www.ghostscript.com/), which provides a similar tool, `ps2pdf`, which does the same thing.
