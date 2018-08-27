#!/bin/bash -ex

aws s3 sync --profile fischco public s3://www.fischco.org
