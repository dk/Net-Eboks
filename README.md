perl API for eboks.dk
=====================

This is perl interface for http://eboks.dk/, Danish national email system. 

Included a simple POP server for proxying e-boks for read-only mail access
and a simple downloader.

You shall need your CPR# and password.
You can get the password from the e-Boks website. 
Here is a [video-guide](http://www.e-boks.dk/help.aspx?pageid=db5a89a1-8530-418a-90e9-ff7f0713784a) on how to get it (in Danish).

For the POP3 login, the username is be your CPR code, such as f.ex: 0123456-7890.
The password is your mobile pincode.

Prerequisites
-------------

1) You will need perl, openssl, and shell.  For windows you'll need either
strawberry perl from http://strawberryperl.com/, and standalone openssl and
bin/sh executables; or all of these installed by some othe ways, f.ex. via
cygwin or mingw.

2) Install this module by opening command line and typing 'cpanm
git://github.com/dk/Net-Eboks'.  This gets you the latest code. If this fails,
try this: 'cpan Net::Eboks', which can be older.

3) For each installation, you will need to create a pair of RSA keys and a
device ID.  This is done by running eboks-keygen that creates these files in
your home directory under .eboks entry.

Windows users: You will need openssl and bin/sh executable (cygwin will do).

4) For each user, you will need to register the device created in step #3 with
your personal NemID signature. Install prerequisites by running 'cpan
Gtk3::WebKit', then run eboks-authenticate that will ask your CPR, password,
and will try to show a standard NemID window, that you will need to log in, and
then confirm that indeed you allow the login by eBoks. If that works, the
script will send the public key to the eBoks server so that consequential
logins can be based on your private key.

You can copy files created in #3 on several locations in order to avoid running
step #4 for each instance you want to use, and to avoid installing Gtk3 as
well.

Download your mails as a mailbox
--------------------------------

On command line, type eboks-dump, enter your passwords, and wait until it downloads
all into eboks.mbox. Use your favourite mail agent to read it.

Use eboks.dk as a POP3 server
-----------------------------

1) On command line, type eboks2pop

2) Connect your mail client to POP3 server at localhost, where username is
your CPR code such as f.ex: 0123456-7890 and password is your mobile pincode.

Use on mail server
------------------

1) Create a startup script, f.ex. for FreeBSD see example/eboks2pop.freebsd .

2) Install procmail and fetchmail. Look into example/procmail and
and examples/fetchmail (the latter needs to have permissions 0600). 

3) Add a cron job f.ex.

  2       2       *       *       *       /usr/local/bin/fetchmail > /dev/null 2>&1

to fetch mails once a day. Only new mails will be fetched. This will also work for 
more than one user.

Enjoy!
