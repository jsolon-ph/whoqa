* master.do
/* do files are just examples showing that your workflow can be modular
Each do file does a specific task.
This makes it easier 
- create and troubleshoot
- instruct users
- potentially automate with arguments per do file (ie, a do file can be a program)
*/

* Using GLOBALS
* Prerequisites
****Instructions here

version 19.5
clear all
macro drop _all
set more off
set seed 54321

log using logs/stata/log.txt, replace


do lib/stata/macros.do /// defines $lib_stata for example among others
include lib/stata/macros.do
do $lib_stata/packages.do
do $lib_stata/rclone.do
do $lib_stata/import.do
do $lib_stata/clean.do
do $lib_stata/cr_units.do
do $lib_stata/an_tables.do

macro drop lib_stata
log close

/* Globals versus locals***
Global macros have to be dropped but there is no guarantee that a user will run individual do files that have globals and not drop them.
There has to be a good justification to use global macros
- while in dev - maybe, but you would have to recode to locals and revise your calls to your macros

*/


* Using Locals
* Prerequisites 
****Instructions here

version 19.5
clear all
macro drop _all
set more off
set seed 54321

log using logs/stata/log.txt, replace

do lib/stata/macros.do
include lib/stata/macros.do
do "`lib_stata'/packages.do"
do "`lib_stata'/rclone.do"
do "`lib_stata'/import.do"
do "`lib_stata'/clean.do"
do "`lib_stata'/cr_units.do"
do "`lib_stata'/an_tables.do"

macro drop _all

log close 
/* If all locals no need for macro drop because they disappear, but good practice in your repo.  However if you have your own globals then you should know to modify that to specific macros excluding your personal global macros. 
