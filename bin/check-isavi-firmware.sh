#!/usr/bin/env bash

# Checks the AddValueTech website for newer listed iSavi Wideye firmware.

# *VERY* basic and brittle, just grepping the HTML for a magic string.

url="https://www.addvaluetech.com/pdf_categories/firmware/"
firmware_version="R02.0.2"
label="[iSavi firmware]"
message="${label} check for version ${firmware_version}"

ping -c1 -q google.com &> /dev/null
if [ $? -ne 0 ]; then
  logger "${label} no internet, test skipped"
  exit 1
fi

result=`curl -sS "${url}" | grep "<p>iSavi Firmware &#8211; ${firmware_version}</p>"`

if [ $? -ne 0 ] || [ -z "${result}" ]; then
  message="${message} FAILURE"
  /usr/bin/zenity --info --text="${message}" &
else
  message="${message} SUCCESS"
fi
logger "${message}"
exit 0
