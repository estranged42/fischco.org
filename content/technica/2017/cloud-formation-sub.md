---
author: Mark Fischer
title: "Understanding AWS CloudFormation !Sub Syntax"
date: 2017-09-04T09:00:00-07:00
images:
  - "/technica/2017/cfn-sub-yaml.png"
type: post
categories:
  - geek
  - article
  - cloudformation
  - aws

---


This article aims to demonstrate some of the many uses of the `Fn::Sub` syntax in the AWS CloudFormation service.  Topics include:

* Basic `Fn::Sub` and `!Sub` syntax
* Short and long form syntax
* Nested Sub and ImportValue statements

## Background

About a year ago ([Sept 2016][changelog], along with [YAML support][yaml-support]) AWS added a new intrinsic function to CloudFormation: [**Fn::Sub**][sub]. This greatly improved string concatenation in CloudFormation. 

[yaml-support]: https://aws.amazon.com/blogs/aws/aws-cloudformation-update-yaml-cross-stack-references-simplified-substitution/
[changelog]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/ReleaseHistory.html
[sub]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-sub.html
[join]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-join.html

<!--more-->

## Assumptions

* You have an AWS account and are comfortable creating and managing resources.
* You have a decent familiarity with AWS CloudFormation syntax, especially the [newer YAML format][yaml-support].

## Basic Examples

### Constructing an S3 ARN from a parameter.

Previously if you needed to append strings together, you had to use the clumsy [Fn::Join][join] syntax. This was really ugly and confusing in the JSON days, and only slightly improved with YAML syntax.

#### With JSON / Fn::Join
``` json
	"Resource": { "Fn::Join" : [ "", [ "arn:aws:s3::", {"Ref": "S3Bucket"}, "/*" ] ] }
```
This was barely readable, and required a lot of effort to parse and understand what this was trying to do.

#### With YAML / Fn::Join
``` yaml
	Resource:
		"Fn::Join": [ "", [ "arn:aws:s3::", !Ref S3Bucket, "/*" ] ]
```
The YAML syntax doesn't do much to improve this.

#### YAML / Fn::Sub
``` yaml
	Resource: !Sub "arn:aws:s3:::${S3Bucket}/*"
```
This is much more readable! The abbreviation of the intrinsic functions (denoted by the leading ! instead of Fn::) coupled with the Sub syntax of inline variable substitution makes it much clearer that this line aims to construct an ARN using a static string and a variable, in this case the `${S3Bucket}` which represents either an input parameter or a resource ID created elsewhere in the CloudFormation template.

## Abbreviated Functions

[CloudFormation intrinsic functions][intr_fn] have two different forms, the standard form, and a tag abbreviation.

[intr_fn]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html

#### Standard Form
``` yaml
	Name:
		Fn::Sub:
			"myapp.${HostedZoneName}"
```

#### Tag Abbreviation
``` yaml
	Name: !Sub "myapp.${HostedZoneName}"
```
The only limitation is that you cannot nest additional functions in the abbreviated tag. For example you cannot import a value inside the abbreviated version.

#### Invalid Syntax
``` yaml
	Name: !Sub "myapp.{!ImportValue SomeExportedValue}"
```


## Sub Long form

The `Fn::Sub` syntax has two very different forms. Above we saw the short form. There's also a more complicated long form, where the arguments to `Fn::Sub` are an array as opposed to a single string.

Unfortunately, you can't always use the short form of the Sub syntax. Only simple parameters or resources can be included inside the string argument. You can't use more complex syntax, such as additional Subs, or ImportValue statements.

This is especially true if you leverage the [Export/Import feature of CloudFormation][impex]. This allows you to reference values from other CloudFormation stacks without having to tediously pass them in as Parameters.

[impex]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/walkthrough-crossstackref.html

Say you have a common CloudFormation template which establishes a Route53 hosted zone for you. All future CloudFormation stacks can reference an exported value from this stack using the `!ImportValue` function.

### Route53 Template Fragment

Our first template creates a Route53 hosted zone. We pass in a single parameter which will be our Zone name (ie "aws.arizona.edu"). This template creates the Route53 zone, and exports three values: the zone ID, the zone name, and the DNS name. Note that the difference between the zone name and the DNS name is the trailing period required for zone names. (Which we append using the Sub short form).

``` yaml
	AWSTemplateFormatVersion: "2010-09-09"
	Description: Route53 Hosted Zone

	Parameters:
		ZoneName:
			Type: String

	Resources:
		Route53HostedZone:
			Type: "AWS::Route53::HostedZone"
			Properties: 
				Name: !Sub "${ZoneName}."

	Outputs:
		Route53HostedZone:
			Description: "Route 53 Hosted Zone ID"
			Value: !Ref Route53HostedZone
			Export:
				Name: !Sub "${AWS::StackName}-zone-id"

		Route53HostedZoneName:
			Description: "Route 53 Hosted Zone Name"
			Value: !Sub "${ZoneName}."
			Export:
				Name: !Sub "${AWS::StackName}-zone-name"

		Route53DNS:
			Description: "The DNS Name"
			Value: !Ref ZoneName
			Export:
				Name: !Sub "${AWS::StackName}-dns"
```
If we named this stack "HostedZone", then the three exported values will have the names: HostedZone-zone-id, HostedZone-zone-name, and HostedZone-dns. These values can be referenced in subsequent CloudFormation stacks using the ImportValue function:

### DNS Example
``` yaml
  AppDnsRecord:
    Type: AWS::Route53::RecordSet
    Properties:
      HostedZoneId: !ImportValue HostedZone-zone-id
      Name:
        Fn::Sub:
        - "myapp.${HostedZoneName}"
        - HostedZoneName: !ImportValue HostedZone-zone-name
```
Here you can see a more complex version of the Fn::Sub syntax, where the argument is an array of two elements. The first element is the string to be substituted into, and the second value is a map of Key/Value pairs to be used in the above substitution string.
``` yaml
        - "myapp.${HostedZoneName}"
```
Here the parameter name `HostedZoneName` is not passed into the template as a parameter, nor is it the name of a resource created elsewhere in this template.  It is a temporary parameter that exists only in the scope of this Fn::Sub function. Its value is supplied in the map of the second argument:
``` yaml
        - HostedZoneName: !ImportValue HostedZone-zone-name
```
This second argument is a map, so there can be multiple key/value pairs defined in it, consider this contrived example:
``` yaml
      Name:
        Fn::Sub:
        - "myapp.${SubDomain}.${HostedZoneName}"
        - HostedZoneName: !ImportValue HostedZone-zone-name
          SubDomain: !ImportValue HostedZone-subzone-name
```
**Note:** It is important to see that the two map values, `HostedZoneName` and `SubDomain` are elements of a map, and it is that map which is the second array element. Don't put a dash in front of `SubDomain`. This is where YAML syntax gets a little odd. If this were a function call, the arguments might look something like this:
``` javascript
 name = sub( "myapp.${SubDomain}.${HostedZoneName}", {"HostedZoneName": "", "SubDomain": ""} )
```
Here it's a little clearer that the function takes two arguments, the first is a string, and the second is a map.

# Nested Sub functions

However, what if our previous stack name isn't always the same? If we needed to pass in the name of our stack, we would have to include additional Sub functions to put together our import values:

``` yaml
	Parameters:
		Route53StackName:
			Type: String

	Resources:
		AppDnsRecord:
			Type: AWS::Route53::RecordSet
			Properties:
				HostedZoneName:
					Fn::ImportValue:
						!Sub "${Route53StackName}-zone-name"
				Name:
					Fn::Sub:
					- "myapp.${ZoneName}"
					- ZoneName: 
							Fn::ImportValue:
								!Sub "${Route53StackName}-zone-name"
```

There's a lot more to unpack in this example.

First off, we're passing in a stack name as an input parameter `Route53StackName`. This is the name of the CloudFormation stack that was deployed earlier with our Route53 zone and exported values.  The exported values were named like: `${AWS::StackName}-zone-name` so the name of the stack is incorporated into the export name.

We use this passed in stack name as a prefix to reconstruct the naming convention we've established. This is done by the innermost `!Sub` expression:
``` yaml
              !Sub "${Route53StackName}-zone-name"
```
This expression concatenates the stack name parameter with our naming convention. This resolves to the export parameter name, which can then be used by the Fn::ImportValue function above it.  This in turn is used as the value for the `ZoneName` local parameter, which in turn is used in the outermost `Fn::Sub` function to finally piece together our desired DNS name.

Note that we're using the `Fn::ImportValue` format and not the `!ImportValue` abbreviation because we can't nest abbreviations (the following `!Sub`).

## Multi-Line Strings and the Sub Syntax

Another really useful place to use the `Fn::Sub` function is when you need to have long blocks of text interspersed with parameters. The best example of this is in the `UserData:` section of an EC2 Instance.

``` yaml
  Ec2Instance:
    Type: "AWS::EC2::Instance"
    Properties:
      ImageId: ami-12345678
      KeyName: !Ref KeyName
      InstanceType: !Ref InstanceType
      IamInstanceProfile: !Ref EnvInstanceProfile
      NetworkInterfaces:
        - AssociatePublicIpAddress: "true"
          DeviceIndex: "0"
          GroupSet:
            - !Ref InstanceSecurityGroup
          SubnetId: !Ref InstanceSubnet
      UserData:
        Fn::Base64: !Sub |
            #!/bin/bash -e
            #
            # Install Amazon SSM
            curl https://amazon-ssm-${AWS::Region}.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o /tmp/amazon-ssm-agent.rpm
            yum install -y /tmp/amazon-ssm-agent.rpm
```
In this example, we want to install the EC2 Systems Manager agent on a host at deployment time. The RPM installer needs to be pulled from a region specific S3 bucket however, so we can't just hard-code the URL in the script.

The first new thing you might notice is the pipe symbol following the `!Sub` abbreviation. The pipe in YAML syntax turns all following indented lines into a multi-line string, and preserves newlines, while stripping out the leading spaces needed for indenting. This makes typing long blocks of text for scripts etc much easier.

Because the whole indented block below the `!Sub` is just a string, we're using the short form of the function still. This allows us to include parameters, resources, or [Pseudo Parameters][pseudo] such as `AWS::Region` right in the string. These will be substituted for their values by the CloudFormation service.

[pseudo]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html

The long form of `Fn::Sub` could still be used here in the event where we couldn't use simple substitution within the string, again for example if needing to import a value:

``` yaml
      UserData:
        Fn::Base64: 
          Fn::Sub:
            - |
              #!/bin/bash -e
              #
              # Cache a bucket name on this host
              echo ${S3BucketName} > /tmp/target-bucket.txt
            - S3BucketName: !ImportValue some-exported-value
```

## Complete Example

Here are two basic, but complete example templates you can deploy to test this out. In the first template, we'll deploy an S3 Bucket.  Because bucket names must be globally unique, there's no good way to know in subsequent templates what the bucket name will be.  However we can use the name of the CloudFormation stack as a parameter, and then use the [export/import feature of CloudFormation][impex] to pass this value from stack to stack.

#### First Template: S3 Bucket
``` yaml
---
	# S3 Bucket CloudFormation Deployment
	# -----------------------------------------
	# 
	# This CloudFormation template will deploy an S3 bucket.

	AWSTemplateFormatVersion: '2010-09-09'
	Description: Deploy an S3 Bucket

	# Parameters
	# ----------
	#
	# These are the input parameters for this template. All of these parameters
	# must be supplied for this template to be deployed.
	Parameters:
		# The name of the bucket.
		BucketName:
			Type: String
			Description: The globally unique name of the S3 Bucket.

	# Metadata
	# --------
	#
	# Metadata is mostly for organizing and presenting Parameters in a better way
	# when using CloudFormation in the AWS Web UI.
	Metadata:
		AWS::CloudFormation::Interface:
			ParameterGroups:
			- Label:
					default: S3 Bucket Configuration
				Parameters:
				- BucketName
			ParameterLabels:
				BucketName:
					default: 'Bucket Name:'

	# Resources
	# ---------
	#
	# These are all of the resources deployed by this template.
	#
	Resources:
		# #### S3 Bucket    
		#
		# This deploys the S3 bucket.
		S3Bucket:
			Type: AWS::S3::Bucket
			Properties:
				BucketName: !Ref "BucketName"
				AccessControl: Private

	# Outputs
	# ---------
	#
	# Output values that can be viewed from the AWS CloudFormation console, 
	# and imported into subsiquent stacks.
	#
	Outputs:
		BucketName:
			Value: !Ref S3Bucket
			Export:
				Name: !Sub "${AWS::StackName}-bucket"
```

In the second template, we will pass in the name of the CloudFormation stack we created from the first template. With that parameter we can build an IAM user who will have access to this bucket.

``` yaml
---
	# S3 Bucket User CloudFormation Deployment
	# -----------------------------------------
	# 
	# This CloudFormation template will deploy an S3 bucket IAM user.

	AWSTemplateFormatVersion: '2010-09-09'
	Description: IAM User with access to an S3 Bucket

	# Parameters
	# ----------
	#
	# These are the input parameters for this template. All of these parameters
	# must be supplied for this template to be deployed.
	Parameters:
		# The name of the bucket.
		StackName:
			Type: String
			Description: The name of the S3 Bucket Stack.

	# Metadata
	# --------
	#
	# Metadata is mostly for organizing and presenting Parameters in a better way
	# when using CloudFormation in the AWS Web UI.
	Metadata:
		AWS::CloudFormation::Interface:
			ParameterGroups:
			- Label:
					default: S3 Bucket Stack
				Parameters:
				- StackName
			ParameterLabels:
				StackName:
					default: 'Stack Name:'

	# Resources
	# ---------
	#
	# These are all of the resources deployed by this template.
	#
	Resources:
		# #### S3 Bukcet User
		#
		# Creates an IAM user that can only connect to the S3 bucket specified.
		S3BucketUser:
			Type: AWS::IAM::User
			Properties:
				Path: "/"
				Policies:
				- PolicyName: giveaccesstobucketonly
					PolicyDocument:
						Version: '2012-10-17'
						Statement:
						- Effect: Allow
							Action:
							- s3:List*
							Resource:
							- "*"
						- Effect: Allow
							Action:
							- s3:*
							Resource: 
								Fn::Sub:
									- "arn:aws:s3:::${S3Bucket}/*"
									- S3Bucket:
											Fn::ImportValue:
												!Sub "${StackName}-bucket"
```

## Conclusion

Hopefully I've demonstrated some of the many uses to which the `Fn::Sub` function can be used within CloudFormation. Although the long form syntax is complex, it is very powerful, and allows for many combinations of strings and values which were previously not possible, or very cumbersome. 

----

Like this article or have questions? <a href="https://twitter.com/intent/tweet?screen_name=estranged&url=http%3A%2F%2Fwww.fischco.org%2Ftechnica%2F2017%2Fcloud-formation-sub%2F" class="twitter-mention-button" data-show-count="false">Tweet to @estranged</a><script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
