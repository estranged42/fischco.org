---
author: Mark Fischer
title: "Zoom Meetings with OBS an iPhone and a green screen"
date: 2020-07-30T21:00:00-07:00
draft: false
images:
  - "/technica/2020/zoom-obs/obs-camera-countdown.png"
type: post
categories:
  - geek
  - article
  - OBS
  - video
  - zoom
  - iphone
tags:
  - zoom
  - obs
  - green screen
  - background
  - iphone
  - virtual camera

---

Along with many other people, I decided to at leasty try and have fun with my new life as a Zoom jockey.

<!--more-->

With the Covid-19 situation in the spring of 2020, the University of Arizona, along with a lot of the country, sent us all home to work. Quickly our lives turned into hopping from Zoom meeting to Zoom meeting, with the oddball Teams, Slack, Skype, WebEx, Chime, BlueJeans... who am I missing?

I've always enjoed video production, and I had toyed with [Open Broadcast Software - OBS][obs] before just a little bit, so I decided I would try and up my Zoom game some.

A few people have asked me how I've done some of the things, so I thought I would write it up in blog form, since so much of these sort of setups seem to only be documented in hour long youtube rants.

# Major Components

## Computer

I've been a Mac user for decades now, and I'm still there. So all of the software described here is for MacOS 10.15. OBS is much more prevalent on Windows however, so I have no doubt that most of this setup will work on Windows.

## OBS

[OBS][obs] is the nexus of all of this. It takes in video sources, web pages, still images, video clips, streaming cameras, and orchestrates it all into a broadcast program. The end result is output to an NDI stream. This blog post will not go in to all the things you can do with OBS, as that is documented exhastivly elsewhere.

There's one setting in OBS you should set first before configuring anything else, and that is the output resolution of your Canvas. This is found in Preferences under the Video tab. I like to set my project to be 1920x1080, or '1080p', as that is a pretty standard size for uploading to Youtube etc, as well as being high enough resolution to read text on the screen. If you have other needs for your output size knock yourself out. It doesn't really matter much to Zoom, as it will scale and crop the input video to always fill the screen. Keep this in mind if you have screen elements you always want to be visible, as anything near the edges of the frame may be cropped out. 

{{< img-fit
    "6u" "preferences-video-settings.png" ""
    "/technica/2020/zoom-obs" >}}


[obs]: https://obsproject.com

## Camera

I am using an old iPhone as a camera. The cameras on phones are so much better than whatever built-in camera on your laptop. In addition to just a higher resolution, phone cameras are much better in low-light, which is important for a lot of home-office setups.

If you cable an iPhone to a mac, the screen of the iPhone can act as an input video source for most applications. Unfortunatley, the video stream comes in as the entire screen. This is great if what you want to do is demo iOS apps, which is what the feature is intended for. However its not so great if you want to just have a nice full-frame video source. This brings us to the OBS Camera App.

### OBS Camera App

The OBS folks make a great iOS app, [OBS Camera][obs-camera]. This app, along with the [associated plugin for OBS][obs-camera-plugin] allows a great video input into OBS. The OBS Camera app has a bunch of nice features like zoom, white balance, ISO settings, etc. I am not enough of a camera nerd to really know what all these settings are, but it remembers them once you set them, so for instance I tick up the zoom one notch so I fill a little more of the frame since I can't get the camera very close to me, and phones tend to have very wide-angle lenses.

[obs-camera]: https://obs.camera
[obs-camera-plugin]: https://obs.camera/docs/getting-started/ios-camera-plugin-usb/

## NDI

Once you have stuff in OBS and you're having fun with green screens and sandy beach backgrounds, the last step is getting the video into Zoom. Fortunately Zoom has fixed their issues with allowing virtual camera sources, so the only missing peice is [NDI Tools][ndi]. This bundle of software installs a few utilities, but the one we really need is NDI Virtual Input. This allows you to pick an NDI source, and have it be represented in the OS as a Camera source that you can select in Zoom.

To get an NDI source out of OBS, you need one more OBS plugin, [obs-ndi][].

[ndi]: https://ndi.tv/tools/
[obs-ndi]: https://github.com/Palakis/obs-ndi/releases

### Configure NDI Output in OBS

To have the NDI OBS Plugin send out its video stream, you'll need to enable it in the Tools menu. Note that once you are outputting your program to anything, you can no longer change certain settings in Preferences, such as the Video settings Canvas and Output resolutions. If you ever need to change those, come back to the NDI settings and disable output, then re-enable it after you're done changing things.

{{< img-fit
    "6u" "tools-menu.png" ""
    "6u" "ndi-output-settings.png" ""
    "/technica/2020/zoom-obs" >}}

### Launch NDI Virtual Input

Find the "NDI Virtual Input" app in your Applications folder and launch it. You won't notice much, but there's a new item in your menu toolbar.

{{< img-fit
    "6u" "ndi-input-menu.png" ""
    "/technica/2020/zoom-obs" >}}

## Zoom

Once you have your NDI source selected in the NDI Virtual Input menu, you will find a new Camera in Zoom named "NDI Video". Select this, and you will see whatever your current OBS output is. This may be nothing but a black screen at this point, but we'll make it more interesting in a moment.

{{< img-fit
    "6u" "zoom-video-settings.png" ""
    "/technica/2020/zoom-obs" >}}


# OBS Basics

Ok, so we've got the major pieces connected. Now lets add something in OBS so we have something to see.

## iPhone Source

Connect your iPhone up to your laptop with a lightning USB cable. Then launch the OBS Camera app on your phone. You should see the camera image, along with a message at the bottom "USB: Waiting for connection".

Now in OBS, find the "Sources" pane, and click on the Plus ( + ) button. This will bring up the Sources menu and you can see all the various sources available to you. Near the bottom should be the "iOS Camera" source. Select that. OBS remembers all the sources you've defined, so when adding a new source type to a scene, you're presented with an option to create a new one, or use an existing one. We don't have any sources yet, so we'll make a new iPhone Camera Source by clicking "OK".

{{< img-fit
    "4u" "obs-camera-screenshot.png" ""
    "4u" "obs-sources-menu.png" ""
    "4u" "obs-sources-pane.png" ""
    "4u" "obs-source-add-ios-camera.png" ""
    "/technica/2020/zoom-obs" >}}

A configuration window will pop up for the new source. Here you can choose the iOS device you want to use for your camera source. This part is a little finiky, and sometimes you just have to click the "Reconnect to Device" button once or twice to get the video to work. Click "OK" once you've got it, and your new source will be placed into the current Scene. 

If you resized the Canvas as I did, you'll notice that the video from the iOS camera doesn't fill the Canvas. OBS Camera only sends a 720p video stream, so we'll have to scale it up to fill our 1080p Canvas. Just click on the video to select it, and crab a corner to resize. If you're used to holding down the Shift key to contrain aspect ratios as in other graphics programs, do not do that here, OBS has this reversed. Sources will keep their aspect ration when scaled by default, and if you hold the Shift key down it will NOT preserve the aspect ratio.

{{< img-fit
    "6u" "obs-source-ios-camera-config.png" ""
    "6u" "obs-scene-default-ios-camera.png" ""
    "6u" "obs-scene-ios-camera-scaled.png" ""
    "/technica/2020/zoom-obs" >}}

The hardest stuff is now done! Everything else is now the fun part. If you still have Zoom open, go back to the Video section in Preferences, and you should see your Scene from OBS!

{{< img-fit
    "6u" "zoom-video-settings2.png" ""
    "/technica/2020/zoom-obs" >}}

### Troubleshooting

If you don't see your NDI video, double check the following:

1. Make sure the OBS NDI Plugin is installed and configured. In OBS from the Tools menu, select NDI Output Settings and be sure the Main Output is checked and has a name.
2. Be sure you see something in OBS. If your Scene is still blank, re-visit setting up your camera.
3. Be sure you launched the NDI Virtual Input application. You should see "NDI" in your menubar.
4. Be sure you have the OBS output selected in the NDI menu in your menubar. There should only be one item to choose from.
5. Be sure that "NDI Video" is selected in the Zoom video settings.

## Webcam Source

If you don't have a spare iPhone lying around, you can just use your laptop's webcam. From the Sources + menu, select "Video Capture Device" instead. You will create a new Source, name it, and click "OK". Then select your FaceTime camera from the Device list. Note that in this list you will also see NDI Video as an option. Don't select that as that's actually a loopback of your OBS output at this point.

## Image Source

OBS offers a lot of other Sources to choose from. Lets add an Image source. Find some photo you like, and make sure you know where it is located on your computer. I created an OBS/Images folder in my Documents directory to store all of the assets I bring into OBS.

Click the + button in the Sources panel again, and select Image. OBS has a single flat namespace for everything, so I always call my sources something like "[description] Image Source" or something. So if I had a picture of the Grand Canyon, I would call this Source "Grand Canyon Image Source". Once you click "OK" and get to the source properties window, click the "Browse" button and find your image, then click "OK.

Your image will now be in your Scene, and covering up your camera. Play around moving and resizing the Image. You can also move the Sources up and down the visibility stack by dragging to re-order them in the Sources panel.

{{< img-fit
    "6u" "obs-image-source.png" ""
    "6u" "obs-image-scene.png" ""
    "/technica/2020/zoom-obs" >}}

## Green Screen

I bought a green screen, a stand, and some lights because I wanted to do a better virtual background than what you get by default with Zoom. This allows you to get a much tighter crop of your torso, with much less bluring and... oddness... that you see with the Zoom virtual background feature.

* [Impact Collapsible Background - 5 x 7' (Chroma Green)][green-screen]
* [Impact Air-Cushioned Light Stand (Black, 8')][stand]

[green-screen]: https://www.bhphotovideo.com/c/product/541119-REG/Impact_BGC_CG_57_Collapsible_Background_5.html
[stand]: https://www.bhphotovideo.com/c/product/1258466-REG/impact_ls_8ai_air_cushioned_light_stand_black.html

With a green screen behind you, and some lights on either side of you, you're in a pretty good spot to use the Chroma Key filter in OBS on your iOS Camera source. 

Right-click on your iOS Camera Source in the source panel to bring up the source pop-up menu. Select "Filters" from near the bottom. With the filters window up, add a new Effects Filter in the bottom left by clicking on the + button, and selecting "Chroma Key" from the popup-up menu.

The defaults were pretty good for me, so I left them alone. Depending on your screen and lighting you may need to fiddle around in here a lot. If you can't get settings that look good, the solution is almost always to add more light somehow. 

More Light == Good.

{{< img-fit
    "3u" "source-popup-menu.png" ""
    "6u" "filter-chroma-key.png" ""
    "/technica/2020/zoom-obs" >}}

With the Chroma Key in place, things are really starting to come together. You can now move your image back behind your camera source, and resize it to fill the scene.

{{< img-fit
    "4u" "scene-chroma-key.png" ""
    "/technica/2020/zoom-obs" >}}

## Window Capture

One of the other sources you can bring in is a Window Capture. This will take a live view of any window currently on your computer and bring it in as a video source. So for example I could bring up a Reminders list, and add items to it during a meeting, and everyone can see what I'm adding without me having to share my desktop.

Remember that you can move and resize any source in the scene, so we can slide over the camera source to make room for the reminders window.

<iframe src="https://player.vimeo.com/video/443881585" width="768" height="482" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>

<br><br>

## Browser Source

One of the most flexible sources OBS offers is the Browser Source. This allows you to embed a fully functioning web browser as a source. You can't interact with the source, but any web page that you can look at, you can capture. This can be used for remote pages as well as local html files.

As just one example, I created a local html page to count down until the start of the fall semester at The University of Arizona. 

<iframe src="https://player.vimeo.com/video/443883805" width="768" height="480" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>

<br><br>

## Other Ideas

That's the basics of what I've been doing. From here you can go crazy :)

* Video backgrounds
* Multiple Cameras. Use the iPhone as a document camera pointing down on your desktop, and your laptop webcam for you.
* iPad whiteboard. Connect an iPad with a cable, and it will be available as a Video Capture Device.
* Layer your camera image over your desktop during demos
* Live feeds from web cams (I bring in feeds from the [Tucson Reid Park Zoo webcams][rpz])
* HTML clock to bring up 5m before the end of a meeting as a subtle reminder ;) 
* Cutouts from Minecraft

[rpz]: http://reidparkzoo.org/cameras/elephant-cam/
