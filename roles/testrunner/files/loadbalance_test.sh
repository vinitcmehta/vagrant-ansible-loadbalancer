#!/bin/bash
# Remove the output file from previous runs of this test if it exists
rm -f output.txt

# Repeatedly query the loadbalancer and from the headers returned, capture the X-Backend-Server header each time to a file
for query in {1..100};
do
  curl -s -I 172.17.177.21 | grep -Fi X-Backend-Server >> output.txt
done

# Get the number of unique webservers serving us content
number_of_webservers=$(sort output.txt | uniq | wc -l)

# If the number of unique webservers is greater than 1, this test passes otherwise it fails
if [ "$number_of_webservers" -gt 1 ]
then
  echo "Test successful!"
  exit 0
else
  echo "Test failed!"
  exit 1
fi