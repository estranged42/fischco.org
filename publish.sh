#!/bin/bash -ex

aws s3 sync --profile fischco --delete public s3://www.fischco.org
