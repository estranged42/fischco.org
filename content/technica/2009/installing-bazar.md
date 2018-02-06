---
author: Mark Fischer
title: "Installing Bazaar (bzr) GUI Tools"
date: 2009-12-29T05:00:00-07:00
type: post
categories:
  - geek
  - articles
aliases:
  - /blog/2009/12/28/installing-bazaar-bzr-gui-tools.html

---

I've been trying out [Bazaar][1], a version control system, lately. One of the things that caught my eye is that the core team develops a cross platform GUI interface for the system. Installing bzr itself was pretty straight forward, they even have a simple Mac OS X installer package for it. Installing the GUI tools was&#8230; less intuitive.

[1]: http://bazaar.canonical.com

There's some [really basic instructions][2] out there on how to do it, but the documentation is [somewhat lacking in specifics][3]. Fortunately there's a great project out there called [macports][4] that was able to do 98% of the work for me.

[2]: https://answers.launchpad.net/qbzr/+question/10213
[3]: http://doc.bazaar.canonical.com/explorer/en/tutorials/foss-contribute.html
[4]: http://wiki.bazaar.canonical.com/MacPorts

<!--more-->

The last 2% came down to two errors involving path info, or the lack there of. The GUI parts are all written in Python, on top of Qt. Adding the following lines to my .profile file fixed several hours of frustration in terms of "Why won't you work!"

    export DYLD_FRAMEWORK_PATH=/opt/local/Library/Frameworks:${DYLD_FRAMEWORK_PATH} 
    export PYTHONPATH=/Library/Python/2.6/site-packages/:${PYTHONPATH}


Gotta love free tools, but whew, they aren't always the easiest things to install...

