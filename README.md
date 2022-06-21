# FS_API
Python code to scrape the client-side API to create an inventory and status snapshot.
Requires Python 3, pandas, and dependencies.

Farsite Workbench TCL/TK GUI that provides graphical interface to the Farsite data base.
Requires TCL/TK  8.6.12 or later

### Resource_Master.py ###
Retrieves the anonymous universe data - components, resources, etc.
Creates data structures that flatten the cost, input, and output data.
no Blueprints available yet

**Phase 2** will add this data to a rdbms for SQL/analytics


**Far Tool**

Current state is prototype user access to user data.
provides viewing of current resources, rates and costs.

***Planned***

user ship data viewing, ships, modules and equipement status.
Looking for current user inventory for resources status ...
3D viewer of the Farsite star system.

### Install Instructions ###

Most of these instructions are also a one time event.  Once you are installed you are ready for using and coding in the two languages.

There are two software languages that need to be installed on your machine.
TCL/TK  and  Python
There is one application that needs to be installed as well:
Git

The languages are currently used in the tool functioning.
Python is used to log into your account and get current user data.
TCL/TK  is used to present Farsite data obtained from various links and user data pulled down by the Python login script.

Go to the link to install tcl/tk  on your windows machine.
I find this installation is quite good and easy.
Choose the file for your cpu 64 bit.  TCL  8.6+

https://sourceforge.net/projects/magicsplat/files/magicsplat-tcl/

You will be using a  "cmd" shell now and again.  in your windows search,  type  cmd  it should show you a shell.

For Python

https://www.python.org/downloads/

choose  3.9.10+   download and install.

During installation there may be some messages that packages are missing and to use "pip" to update Python. These commands are run in your "cmd"  shell as mentioned above.

Once you have these languages installed it is time to pull down the Application from "Git"

install git from here:

https://gitforwindows.org/

Once installed, it is time to pull down the repository that contains the code.  Currently there is no direct application, it is a collection of bare code.  Nothing compiled.

https://github.com/SomethingOffal/FS_API

Going here will let you view the project. Near the top right is a green button "Code"  with a dropdown arrow.
hit that and a drop down should offer you choices to get the code.

You want to "clone"  the repository.  This enables you to pull down updates very easily.
copy the link to the clipboard.

go to your "cmd"  shell.

At this point we are about to populate the repository to the directory where you run the following commands.
make a directory on your c: or other drive,  I use a "work" directory at the c:  level to put all "stuff" in it.  Then I made a farsite directory in work. (my setup, does not have to be yours)

cd to your chosen directory in the shell and type

git clone <pasted address>

After this you should see all the files that were in the repo on your drive.  If you modify any of these files git will know.  You can recover to previous states or branch off and create your own code on a private branch.  Git is an industry standard repository system.  It is not easy to use or understand if you are not a developer.

There will be updates to the source.  You can pull them down any time by typing in the shell in the directory
git fetch
git pull

###  Running Instructions  ###

Now to complete these instructions,  you now have the latest copy of the Farsite Workbench on your machine.

It is designed to enable you to place a shortcut on your desktop.  You know where you installed it so make a shortcut of the file "tcl_src\far_gui.tcl" and place it on your desktop,  double click to start.

If you do not like shortcuts, then you can do it the long way.  From the shell you have just pulled the repository into, and you are in the top directory.  Change directories to the "tcl_src" directory and type "wish far_gui.tcl"

In both cases you should have the tool up on your screen.  Quick look at the title to confirm the version is correct.

At this point you may notice that no user data is available, or is should not be if you exactly follow these instructions on a fresh checkout.

You will have to invoke the python inventory_scrape.py script in a "cmd"  shell.  This will ask you for your Farsite login email and password.  Once you enter that information, it will pause, and will be longer if your inventory is bigger.  It will complete, and once done you can restart the tool and your account data should be presented.

When you want to see your current account status, you will have to run the python script again.

###  Dev Instructions  ###

This tool will support custom development.  TBD when this will be enabled and documented.
