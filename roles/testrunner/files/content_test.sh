#!/bin/bash
# This gets the output from the loadbalancer and ensures the HTML contains "Hello World!" 
curl -s 172.17.177.21 | grep "Hello World!"