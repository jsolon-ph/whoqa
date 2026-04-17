capture macro drop a
capture frames drop newframe
frames change default
frames create newframe
frames change newframe
frames dir
pwf

* Create a global macro while in newframe

global a "myglobal"

pwf

* use global
display "$a"

* change to default frame
frames change default
pwf
* use macro while in default
display "$a"
macro list


capture macro drop a
capture frames drop newframe
frames change default
frames create newframe
frames change newframe
frames dir
pwf

* LOCALS Create a local macro while in newframe

frames change default
local b "mylocal"
display "`b'"
macro list
pwf

* change to  newframe and use macro
frames change newframe
pwf
display "`b'"
macro list

* change back to default and use macro
frame change default
pwf
display "`b'"
