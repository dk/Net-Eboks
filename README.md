perl API for eboks.dk
=====================

This is perl interface for http://eboks.dk/, Danish national email system. 

Included a simple POP server for proxying e-boks for read-only mail access
and a simple downloader.

You shall need your CPR#, password and activation key.
You can get the password and activation key from the e-Boks website. 
Here is a [video-guide](http://www.e-boks.dk/help.aspx?pageid=db5a89a1-8530-418a-90e9-ff7f0713784a) on how to get it (in Danish).

For the POP3 login, the username is be your CPR code and your e-boks activation
code, such as f.ex: 0123456-7890:kwdElkwjdc. The password is your mobile
pincode. 

Try online
==========

Direct your mail client to POP3 server eboks2pop.karasik.eu.org (port 8110).

WARNING!!! This is my own server, I do not log your data, and I guarantee my
best efforts to keep the server from being compromised. Still, if you use your
eboks login there it is at your own risk !!!

Try yourself
============

Prerequesites
-------------

1) For windows you'll need strawberry perl from http://strawberryperl.com/ .

2) Install this module by opening command line and typing 'cpanm git://github.com/dk/Net-Eboks'.
This gets you the latest code. If this fails, try this: 'cpan Net::Eboks', which can be older.

Download your mails as a mailbox
--------------------------------

On command line, type eboks\_dump, enter your passwords, and wait until it downloads
all into eboks.mbox. Use your favourite mail agent to read it.

Use eboks.dk as a POP3 server
-----------------------------

1) On command line, type eboks2pop

2) Connect your mail client to POP3 server at localhost, where username is
your CPR code and your e-boks activation code, such as f.ex: 0123456-7890:kwdElkwjdc
and password is your mobile pincode.

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
