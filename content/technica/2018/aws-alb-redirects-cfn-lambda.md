---
author: Mark Fischer
title: "Using CloudFormation Custom Resources and Lambda for ALB Redirection"
date: 2018-09-19T08:00:00-07:00
images:
  - "/technica/2018/alb-redirect/alb-redirect.png"
type: post
categories:
  - geek
  - article
  - cloudformation
  - aws
  - loadbalancer
  - lambda
  - https
  - webdev

---



[AWS announced full featured redirection support for Application Load Balancers][announcement] in the summer of 2018, but it lacked support for CloudFormation initially. Since I really like doing as much as I can with CloudFormation, I tossed around ideas for how to still get a redirection rule into an ELBv2 and settled on using Lambda and CloudFormation custom resources.

<!--more-->

**! Update ! 2018-12-28**

Amazon added CloudFormation support for the new ALB features in late November 2018, so the Lambda based solution is no longer needed. I was almost right in my guessed tempalte syntax, I just missed that you'll need to quote some of the values to avoid YAML parsing errors.

While the following solution is no longer needed, it provides a useful framework for executing AWS API calls from within a CloudFormation template. There will likely always continue to be things you can't quite do with direct CloudFormation syntax, so the following post still has some value I think.

Here is the updated CloudFormation template with redirection listener:

<a href="/technica/2018/alb-redirect/alb-redirect.yaml">
<img src="/images/cloudformation.png" style="text-align: center;"> ALB Redirection CloudFormation Template Example
</a>

The original post follows:

[announcement]: https://aws.amazon.com/about-aws/whats-new/2018/07/elastic-load-balancing-announces-support-for-redirects-and-fixed-responses-for-application-load-balancer/

> Note this is a follow on to my previous post about [Application Load Balancer Redirection][albpost] rules. This post assumes you've either read that have a good familiarity with it.

[albpost]: /technica/2018/aws-alb-redirects/

## Assumptions

* You have an AWS account and are comfortable creating and managing resources.
* You are familiar with AWS [Application Load Balancers][alb], [Listeners][listeners] and [Target Groups][tgs].
* You have a decent familiarity with AWS [CloudFormation][] syntax.
* You are familiar with [AWS Lambda][lambda] and can look at [Python][] code without cringing.

[alb]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
[listeners]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html
[tgs]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html
[CloudFormation]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html
[lambda]: https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
[Python]: https://www.python.org/doc/

One of the more powerful features of CloudFormation is the ability to create [Custom Resources][]. This is essentially a Lambda function which can be called as part of a CloudFormation stack deployment, and has a standard return message to communicate back to the CloudFormation service as the stack is being deployed.

> Custom resources enable you to write custom provisioning logic in templates that AWS CloudFormation runs anytime you create, update (if you changed the custom resource), or delete stacks. For example, you might want to include resources that aren't available as AWS CloudFormation resource types. You can include those resources by using custom resources. That way you can still manage all your related resources in a single stack.

[Custom Resource]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources.html

Since the ability to create the new redirection type listener rules for application load balancers isn't in CloudFormation yet, I decided to try and use a Lambda function as a Custom Resource to see if I could use that to keep as much of the deployment of a solution inside of CloudFormation as I could.

It works!

Admittedly, I will rip all this out the moment that there is propper CloudFormation support for this feature. However I believe this model can provide a template for any situation where there's _just those couple of things_ that you wish you could do with CloudFormation but just can't. Instead of having some sort of manual post-stack-deployment checklist, you should be able to use this model to put the handful of remaining commands into a lambda function.

## The Basic Idea

This method consists of two basic parts:

1. Create a Lambda function (along with associated IAM Role) which can perform the additional actions you need.
2. Call this function at some point in your CloudFormation template as a Custom Resource.

By deploying the Lambda function in the same template you're using to deploy the rest of your resources, you have the opportunity to customize the code itself, along with the roles and permissions required to perform your task.

### Figure out your API calls

I usually start with the AWS CLI tool, as it is usually faster to iterate when trying to figure out what exactly I need to do. The CLI syntax corresponds very closely to the actual API SDKs, so there's not much translation involved. I eventually figured out that the following CLI command worked to create my redirection listener.

{{< highlight bash >}}
aws elbv2 create-listener --profile myprofile --region us-west-2 \
  --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:000000000000:loadbalancer/app/your-load-balancer/somehexstuff \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=redirect,RedirectConfig='{Protocol=HTTPS,Port=443,Host="#{host}",Path="/#{path}",Query="#{query}",StatusCode=HTTP_301}'
{{< /highlight >}}

In the specific case of load balancers and redirection rules, I need to be able to call the `elbv2` API to call the `create_listener` method. The AWS API is always updated with support for new features, as AWS is an API driven company. API comes first, then other things like the web console and CloudFormation support. So falling back to the API is always an option.

Since the code we need to call this API ends up being pretty short, I was able to simply include the python code right inline within the CloudFormation template. This avoids needing to stage your code in an S3 bucket prior to deployment. You can see the similarities between the structure of the CLI command and the Python SDK.

{{< highlight python >}}
import boto3
def handler(event, context):
  client = boto3.client('elbv2')
  response = client.create_listener(
    LoadBalancerArn='${LoadBalancerArn}',
    Protocol='HTTP',
    Port=80,
    DefaultActions=[{
      'Type': 'redirect',
      'RedirectConfig': {
        'Protocol': 'HTTPS',
        'Port': '443',
        'Host': '#{host}',
        'Path': '/#{path}',
        'Query': '#{query}',
        'StatusCode': 'HTTP_301'
      }
    }]
  )
{{< /highlight >}}

Above is the core of what we're doing to add the redirection listener. We need to know the ARN of the load balancer to add this action to, and then we just need to configure the action as above. The `Protocol` and `Port` parameters refer to the listener itself. So this listener will be an HTTP listener and listen on port 80. This makes sense as we want to accept plain HTTP traffic on this port, and then redirect it to an HTTPS version.

The `DefaultActions` parameter takes a list of dictionaries for possible rules. We only want one rule, of `Type` `redirect`. The `RedirectConfig` section details how the redirection will work. We want to redirect to HTTPS on port 443, so we set those explicitly. The remaining parameters we use the pass through placeholders to the API. Lastly we need to pick the `StatusCode` to return in our redirection, either `HTTP_301` or `HTTP_302`.

## Lambda Events with Create and Delete

CloudFormation will call your lambda function each time there is a create, update, or delete stack operation. Your lambda function should be able to undo anything it does. So we need to add a call to `delete_listener` when this stack is deleted.

There's always an `event` object passed in to your lambda function, and the structure of a CloudFormation event looks something like this. (this is taken from the sample events in the lambda console)

{{< highlight json >}}
{
  "StackId": "arn:aws:cloudformation:us-west-2:EXAMPLE/stack-name/guid",
  "ResponseURL": "http://pre-signed-S3-url-for-response",
  "ResourceProperties": {
  "StackName": "stack-name"
},
  "RequestType": "Create",
  "ResourceType": "Custom::TestResource",
  "ServiceToken": "arn:aws:lambda:us-west-2:EAMPLE:function:lambdafunctionname",
  "LogicalResourceId": "MyTestResource"
}
{{< /highlight >}}

This allows us a way to pick up on the `RequestType` and do something different for a `Create` and `Delete`.

Below is the entire block of code embedded in the CloudFormation Lambda resource:

{{< highlight yaml >}}
# #### RedirectionRule Lambda Function
#
# This lambda function will make the API calls required to create and delete a redirection
# listener. 
LambdaFunction:
  Type: AWS::Lambda::Function
  DependsOn:
  - LoadBalancer
  - LambdaRole
  Properties:
    Handler: index.handler
    Description: ELBv2 Redirection CloudFormation Custom Resource
    Role: !GetAtt LambdaRole.Arn
    Runtime: 'python3.6'
    Timeout: '60'
    Code:
      ZipFile: !Sub
      - |
        import boto3
        import json
        import cfnresponse
        msg = ""
        def handler(event, context):
          client = boto3.client('elbv2')
          if event["RequestType"] == "Create":
            response = client.create_listener(
              LoadBalancerArn='${LoadBalancerArn}',
              Protocol='HTTP',
              Port=80,
              DefaultActions=[{
                'Type': 'redirect',
                'RedirectConfig': {
                  'Protocol': 'HTTPS',
                  'Port': '443',
                  'Host': '#{host}',
                  'Path': '/#{path}',
                  'Query': '#{query}',
                  'StatusCode': 'HTTP_301'
                }
              }]
            )
            msg = "Redirect Listener Created"
          elif event["RequestType"] == "Delete":
            listenersResp = client.describe_listeners( LoadBalancerArn='${LoadBalancerArn}' )
            listenerArn = ""
            for l in listenersResp['Listeners']:
              if l['Port'] == 80:
                listenerArn = l['ListenerArn']
            if listenerArn != "":
              response = client.delete_listener( ListenerArn=listenerArn )
              msg = "Redirect Listener Deleted"
            else:
              msg = "Could not find listener on port 80 to delete"
          else:
            msg = "Unknown Event: " + event["RequestType"]
          
          responseData = {}
          responseData['Data'] = msg
          cfnresponse.send(event, context, cfnresponse.SUCCESS, responseData, "arn:aws:uits.arizona.edu:ecs:httpsredirect")
      - LoadBalancerArn: !Ref LoadBalancer
{{< /highlight >}}


This resource block takes advantage of the [CloudFormation Fn::Sub syntax][cfnsub] to substitue in the ARN of the LoadBalancer resource we build elsewhere in the template. This allows you to create a customized lambda function just for this stack, without having to pass in a bunch of things at runtime.

[cfnsub]: /technica/2017/cloud-formation-sub

There's always room for improvement in this function. Astute readers will see that I'm returning `cfnresponse.SUCCESS` no matter what. I should more properly catch errors and exceptions and report them back to CloudFormation. Hopefully I will tighten this up when I use this in a production service!

## Calling our function

Creating the Lambda function doesn't actually run the code however. It just creates a lambda function that is ready to be run. To execute our code, we need to call the function by creating a Custom Resource in our template. This turns out to be pretty simple, all we need is the ARN of the lambda function.

{{< highlight cli >}}
CreateRedirectListener:
  Type: Custom::RedirectListener
  DependsOn:
  - LambdaFunction
  - LambdaLogGroup
  Properties:
    ServiceToken: !GetAtt LambdaFunction.Arn
{{< /highlight >}}


The `Type: Custom::RedirectListener` is what tells CloudFormation this is a custom resource. You're free to use whatever string you want after the `Custom::` part. You should just be consistant within a template.

We have a few `DependsOn` constraints here, to make sure that the Lambda function and its CloudWatch Logs group have been created before we try and call it.

You have the option of passing in additional properties here, and they will be available in the `event` within your Lambda function.

## Deploy your stack

Those are the main pieces! Below I have attached a complete CloudFormation template which will create a load balancer, target group, lambda function, and associated roles, log groups, security groups etc. You should be able to deploy this template in your account. The only piece you may not have handy is the ARN for an SSL certificate stored in the Certificates Manager service. You'll need this in order to create an HTTPS listener.

You can test the redirection in action with a basic cURL command:

{{< highlight bash >}}
~ $ curl -I http://yourloadblaancerURL.us-west-2.elb.amazonaws.com
HTTP/1.1 301 Moved Permanently
Server: awselb/2.0
Date: Wed, 19 Sep 2018 17:42:00 GMT
Content-Type: text/html
Content-Length: 150
Connection: keep-alive
Location: https://yourloadblaancerURL.us-west-2.elb.amazonaws.com:443/
{{< /highlight >}}

<a href="/technica/2018/alb-redirect/alb-redirect-lambda.yaml">
<img src="/images/cloudformation.png" style="text-align: center;"> ALB Redirection CloudFormation Template Example
</a>

## Future Use

As I mentioned earlier, the specific use case presented here will likely not be needed in the near future. However AWS is constantly releasing new features, and while CloudFormation support is usually very strong, there's always edge cases where certain features lag behind. I think this method of including simple API calls in a lambda function which can be called directly from the same template does a good job of encapsulating a solution in a single document, and should make for a more maintainable deployment method.

Hopefully this is useful to other people!

<a href="https://twitter.com/intent/tweet?screen_name=estranged&ref_src=twsrc%5Etfw" class="twitter-mention-button" data-size="large" data-show-count="false">Tweet to @estranged</a><script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>