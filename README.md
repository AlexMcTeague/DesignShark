# DesignShark

DesignShark is an Excel workbook that makes heavy use of VBA macros.

While working as a Fiber Designer for Charter Communications, I noticed the standard workflow was often repetetive. I created DesignShark as a way to assist myself in these workflows, and give myself a central dashboard to store information. Once I added the Naming Tool, it became apparent that my entire team could benefit from my work. After receiving approval from my supervisor, manager, and director, DesignShark was distributed to all teams within my department. DesignShark evolved with feedback from my peers; I continued to add features, including macros to automatically fill out several deliverables using raw exports from Magellan (Charter's design software).

**Disclaimer:** DesignShark is available in this repository, but the sample data used in the screenshots and videos below is not publicly available. I can provide a full demonstration of DesignShark's features on request.

**Note:** The macros ran much slower while recording software was active; in reality most of DesignShark's macros are near-instantaneous.

# Features

**Data Entry:** This first page allows the user to store values which are frequently used, such as OLT and Hub information. The right-hand column calculates a few more fields, including deliverable names and circuit information. All cells on this page come with a button to copy the data directly to the clipboard, to avoid cases where the user copies a cell and pastes invisible Excel data into other programs.

![First page example](https://i.imgur.com/Q8Hudpg.png)

**Equipment Naming:** Per Charter's naming standards, equipment is named sequentially, and sheath names contain the names of adjacent equipment. The naming tool provides a button interface to name equipment and sheaths with ease, without needing to keep track of the last number used manually. Clicking each button copies the new equipment/sheath name to the clipboard, eliminating the need to type while naming. In the video linked below, I'm using mouse hotkeys for copy and paste, so I don't interact with the keyboard at all.

![Click to see naming tool video demonstration](https://i.imgur.com/wcOmtpW.mp4)

After running time trials, management determined naming a medium-size OLT with previous procedures took 2-3 hours. With DesignShark, naming a similar-size OLT takes ~1 hour.

**MOP:** The user provides a set of raw exports from Magellan - trace reports and splice reports. DesignShark re-formats and inserts these reports into a new MOP file, and fills out the first page using data from these reports and info from the Data Entry tab. The new MOP file needs only a small amount of manual work to complete it.

![Click to see MOP tool video demonstration](https://i.imgur.com/wcOmtpW.mp4)

Time to complete a MOP with previous procedures: ~1.5 hours
Time to complete a MOP with MOP tool: ~20 minutes

**HAF:** HAF exports from Magellan require lots of data cleaning; this is normally an intensive manual process, but the HAF tab of DesignShark does most of this work for you. The most time-saving feature of this tab is the CBG solver: Normally to check which CBG boundary a given address belongs to, you need to manually check the KMZ file. DesignShark instead checks the coordinates of each address in the HAF against a KMZ containing the CBG boundaries. It lists the results, and even automatically exports the results into the HAF.

![Click to view HAF CBG-solver video demonstration](https://i.imgur.com/L9RwpVW.mp4)

Time saved by using HAF tool (including CBG solver): ~1.5 hours

**BOMs:** Similar to the MOP and HAF tools, the DesignShark is capable of re-formatting and processing raw exports into nearly-complete deliverables (in this case the BOMs and Overall BOM), saving 30+ minutes for each deliverable.

**Email:** DesignShark can generate a standard "footage and passings MQMS update" email based on the info in the Data Entry tab, and open it as a draft in Outlook.

# See also: ![RDOF QC Tool](https://github.com/AlexMcTeague/RDOF-QC-Tool)
DesignShark aids the designer; the RDOF QC Tool is its counterpart, which aids the user in quality-checking a finished project.
