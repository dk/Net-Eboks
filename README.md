perl API for eboks.dk
=====================

This is perl interface for http://eboks.dk/, Danish national email system. 

Included a simple POP server for proxying e-boks for read-only mail access
and a simple downloader.

Try online
==========

Direct your mail client to POP3 server eboks2pop.karasik.eu.org (port 8110).

Username is your CPR code and your e-boks activation code, 
such as f.ex: 0123456-7890:kwdElkwjdc and password is your 
mobile pincode. 

WARNING!!! This is my own server, I do not log your data, and I guarantee my
best efforts to keep the server from being compromised. Still, if you use your
eboks login there it is at your own risk !!!

Try yourself
============

Prerequesites
-------------

1) You need to configure this with your CPR#, password and activation key.
You get the password and activation key from the e-Boks website. 
Here is a [video-guide](http://www.e-boks.dk/help.aspx?pageid=db5a89a1-8530-418a-90e9-ff7f0713784a) on how to get it (in Danish).

2) For windows you'll need strawberry perl from http://strawberryperl.com/ .

3) Install this module by opening command line and typing 'cpanm git://github.com/dk/Net-Eboks'
If this fails, try this: 'cpan Net::Eboks'.

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

Enjoy!
