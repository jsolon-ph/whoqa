* master.do

do lib/stata/macros.do
include lib/stata/macros.do

do $lib/packages.do
do $lib/clean.do
do $lib/cr_units.do
do $lib/an_tables.do
