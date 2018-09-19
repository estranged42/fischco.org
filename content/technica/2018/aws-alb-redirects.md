---
author: Mark Fischer
title: "Using AWS Application Load Balancer for HTTP to HTTPS Redirection"
date: 2018-07-26T09:00:00-07:00
images:
  - "/technica/2018/alb-redirect/alb-redirect.png"
type: post
categories:
  - geek
  - article
  - cloudformation
  - aws
  - loadbalancer
  - https
  - webdev

---



[AWS announced full featured redirection support for Application Load Balancers][announcement]. This solves one of the long standing problems with web applications—HTTP to HTTPS redirection.

<!--more-->

[announcement]: https://aws.amazon.com/about-aws/whats-new/2018/07/elastic-load-balancing-announces-support-for-redirects-and-fixed-responses-for-application-load-balancer/

HTTPS has been the best practice for web applications for years now, and providing a redirection path for people who go to the HTTP address has been a basic requirement for web applications for a long time now. This has traditionally been done by at the web server layer (apache/nginx) or at the load balancer layer (F5 BigIP etc). However AWS load balancers have not had the capability to do this function until now, necessitating application host redirection.

Now we can do this with Application Load Balancers!

## Assumptions

* You have an AWS account and are comfortable creating and managing resources.
* You are familiar with AWS [Application Load Balancers][alb], [Listeners][listeners] and [Target Groups][tgs].
* You have a decent familiarity with AWS [CloudFormation][] syntax.

[alb]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
[listeners]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html
[tgs]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html
[CloudFormation]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html

## AWS Web Console

Creating an HTTP to HTTPS redirection rule happens in the Listener, as a Rule. I assume that you're already familiar with setting up a basic ALB, Target Group, and Listener. Once you've created a Listener, you can add a new rule to it to handle the redirection.

In order for the ALB to respond on port 80 and 443, we'll need two separate Listeners, one for each. The redirection rule will be attached to the port 80 listener.

The documentation I've been able to find on how rules work are a little thin. I'd love if anyone has found some more in-depth examples of rule conditions! (twitter: @estranged). 

A rule has to have a condition and an action. Since we want to redirect *all* traffic that comes in on port 80 to the same URI, just with HTTPS instead, our condition should be simply "all". Unfortunately you can't just put a single asterisk in for the condition, the closest I've been able to come up with is `*.example.com`, where example.com is whatever your domain is.

{{< img-fit
    "12u" "rule.png" ""
    "/technica/2018/alb-redirect" >}}

The redirection itself happens in the action section. Select `Redirect to...` in the action section.

Since we just need to redirect HTTP to HTTPS, we'll leave the host, path, and query as-is, and just change the protocol to HTTPS and the port to 443.

That's it! Save it and you're good to go. Make sure your ALB security group allows both port 80 and 443 traffic, and all your incoming port 80 traffic will now be redirected to 443.

## CloudFormation?

Unfortunately, there is no CloudFormation support for these new features yet. If you have an AWS support rep let them know to add this as a feature request!

**! Update ! 2018-09-19**

I've come up with a [Lambda based solution for adding redirection listeners][lambdaredirect] from within a CloudFormation template. Its not ideal but it does work and should serve as a bridge until AWS releases proper CloudFormation support.

[lambdaredirect]: /technica/2018/aws-alb-redirects-cfn-lambda/
