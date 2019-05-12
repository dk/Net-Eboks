perl API for eboks.dk
=====================

This is perl interface for http://eboks.dk/, Danish national email system. 

Included a simple POP server for proxying e-boks for read-only mail access
and a simple downloader.

You shall need your CPR# and password.
You can get the password from the e-Boks website. 
Here is a
[video-guide](http://www.e-boks.dk/help.aspx?pageid=db5a89a1-8530-418a-90e9-ff7f0713784a)
on how to get it (in Danish).

For the POP3 login, the username is be your CPR code, such as f.ex: 0123456-7890.
The password is your mobile pincode.

Prerequisites
-------------

1) You will need perl.  For windows you'll need either strawberry perl from
http://strawberryperl.com/ or cygwin's perl.

2) Install this module by opening command line and typing 'cpan Net::Eboks'.
It will ask you if you want gtk3 modules. Short answer: yes for desktop, no for
server (see below why).

3) For each user, you will need to go through one-time registration through you
personal NemID signature. Run eboks-authenticate that will ask your CPR,
password, and will try to show a standard NemID window, that you will need to
log in, and then confirm that indeed you allow the login by eBoks. If that
works, the script will send that to the eBoks so it recognized your future
logins.

This step should be done one time only, for each user, not for each
installation.  So it is optional unless you're running it first time or intend
to add more users.

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

1) Create a startup script, f.ex. for FreeBSD see example/eboks2pop.freebsd,
and for Debian/Ubuntu see examples/eboks2pop.debian

2) Install procmail and fetchmail. Look into example/procmail and
and examples/fetchmail (the latter needs to have permissions 0600). 

3) Add a cron job f.ex.

  2       2       *       *       *       /usr/local/bin/fetchmail > /dev/null 2>&1

to fetch mails once a day. Only new mails will be fetched. This will also work for 
more than one user.

Enjoy!
