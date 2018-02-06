---
author: Mark Fischer
title: Are virus writers getting smarter or dumber?
date: 2005-06-22
type: post
categories:
  - geek
  - tech
  - security
---


So I got another virus in my email again today.  Now since I'm a mac head, these usually don't cause me to raise an eyebrow at them, they just go into the trash.  However this one piqued my interest...

> Dear user estranged,
>
> It has come to our attention that your Mac User Profile ( x ) records are out of date. For further details see the attached document.
>
> Thank you for using Mac! 
> The Mac Support Team 
>
> +++ Attachment: No Virus (Clean)
> +++ Mac Antivirus - www.mac.com
> &lt;attached account-info.zip&gt;

Now this has VIRUS written all over it!  .zip attachment, short obscure message about
account info that came unsolicited etc.  However, since it was specifically targeting <a
title="Mac Dot Com" target="_blank" href="http://www.mac.com">.Mac</a> users, I had to
stop and scratch my head a second.  It is quite possible that someone actually DID write a
MacOS X virus, and is trying to spread it.  So I took a chance and saved the .zip file to
my drive, and unzipped it with the unzip shell command, so that Stuffit wouldn't try to
auto-do-something with it.  Now for the truly interesting part.  It unzipped into:

    account-info.htm                                                                              .exe 

I love it!  Cute way to try and hide the fact that it's a .exe with all the spaces there,
but c'mon!  It's still a Windows executable!  Mac users can't even get infected with this!
Why specifically target mac users with a windows virus?  I just can't understand this one
at all.

