#!/bin/bash -ex

hugo --cleanDestinationDir --minify --gc

aws s3 sync --profile fischco --delete public s3://www.fischco.org
