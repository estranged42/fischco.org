---
author: Mark Fischer
title: "Migrating a Squarespace Website to S3 Static Hosting"
date: 2017-09-18T06:30:00-07:00
draft: true
images:
  - "/technica/2017/cfn-sub-yaml.png"
type: post
categories:
  - geek
  - article
  - web
  - aws
  - s3

---

## Overview

In this article I will discuss the evolution of this website through its current migration from Squarespace to a static website built by [hugo][] and hosted in AWS [S3][]. We'll look at the pros and cons of Squarespace vs static HTML sites, and talk about why I chose hugo over the many other static site generators.

[hugo]: http://gohugo.io
[S3]: http://docs.aws.amazon.com/AmazonS3/latest/dev/Welcome.html

## History of fischco.org

The fischco.org website here has been through many iterations over its lifetime. It began back in 2002 or 2003 as a [PHPNuke][] site, although the earliest surviving post is from 2004. Then I migrated it to [serendipity][] for a while. Then I briefly drank the [Wordpress][] cool-aid and migrated to that for a few years. I did all this at a time when I was a working web developer & programmer. At some point I got tired of coming home after building websites and having to patch my own website. While I still wanted to have my own website, I got tired of having to maintain my own website. So I signed up for [Squarespace][] and breathed a sigh of relief for many years!

[PHPNuke]: https://www.phpnuke.org
[serendipity]: https://docs.s9y.org
[Wordpress]: https://wordpress.org
[Squarespace]: https://www.squarespace.com

## Why Squarespace?

Squarespace is great. Their drag-and-drop GUI web page editor is really good. They have real customer support. They're not terribly expensive considering all the features you get. You can run your own online store, do forms, email, all the things you'd want in a nice high quality website.

Its super great for non-technical people too, since the web interface is so good.

## Why Static a Site Website?

My only problem with Squarespace is that I simply had stopped updating my blog there.  I was creating maybe 1 or 2 posts a year. Paying for all the fancy editor features that I never use finally got me to thinking about just archiving the site as a static website.

Static website generators have been around for a while. The most widely know one is Jekyl.  The basic idea is you take a folder full of text files, run the site generator, and it cranks out a whole bunch of plain-old HTML files. You then upload this pile of HTML to your server and Bob's your Uncle. No more patching, no more databases, no more security concerns!

## Why Amazon S3?

Amazon's S3 service turns out to be a really cheap way to store static files! Most websites are really pretty small things.  Even with a ton of images, its unlikely this site will ever get much beyond a few GB. That's literally pennies a month.

## Conversion


----

