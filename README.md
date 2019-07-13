# SVPB Music

This project contains all the ABC source files for the band
sheet music. The Makefile will make the music binder and
individual tune and set PDF files. When adding a tune, make
sure to update the Makefile so it is included in the build.

# Current Build Chain

Checkins to the Github project trigger a web hook on the build server; that
creates a file on the build server that records the branch and commit details. There is a periodic
job on the build server that looks for these files; when it finds one, it pulls the changes
from Github, builds the binder, syncs the files to Box (via [rclone](https://rclone.org))
and sends a message to Slack.

## Setting Up A New Year

1. create the new branch and push it to Github
1. log in to the build server and, in the `repos` directory, clone the new branch:
 `git clone --single-branch --branch <year> https://github.com/sbeitzel/svpb-music.git <year>`

# Process and Tools

Each year's tunes are stored in a corresponding branch: 2019 tunes are in the 2019 branch, 2020 tunes are in the 2020
branch, etc. When we start making decisions about the next year's tunes, we create a new branch for the next year from
the current year.

We save our tunes as ABC files. For details on ABC, refer to the [ABC standard](http://abcnotation.com/wiki/abc:standard:v2.2). Most graphical music programs understand ABC and can import it (e.g. [CelticPipes](https://www.celticpipes.net/), [MuseScore](https://musescore.org/en), &c) but since it is a text format and not binary, it compresses well and is much friendlier for revision control systems than their native binary formats. Also, since ABC is a text format, you don't need a particular application which may not be available on your platform - just edit the text.

To produce PDF files which we print and put in our binders, we use a series of tools. First, we use [abcm2ps](https://github.com/leesavide/abcm2ps) to convert the ABC files to PostScript. Then, we convert the PostScript to PDF. MacOS ships with a script, `pstopdf`, which can do this, and other systems can install [Ghostscript](https://www.ghostscript.com/), which provides a similar tool, `ps2pdf`, which does the same thing.
