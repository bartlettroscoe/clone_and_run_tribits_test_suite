#!/bin/bash -e

#
# This script clones TriBITS from github then does a configure and runs its
# test suite timing the invocation.  This can be used to see how efficient a
# file system is since the TriBITS suite touches the file system a lot
# (i.e. creating dirs, creating files, updating files, deleting files, etc.).
#
# To run this script, just cd into some scratch directory and run it as:
#
#   $ cd <scratch-dir>/
#   $ env CC=gcc PARALLEL_NP=10 ~/clone_and_run_tribits_test_suite.sh
#
# This will clone the TriBITS git repo off of github under:
#
#   <scratch-dir>/TriBITS
#
# Then create the build dir
#
#   <scratch-dir>/TriBITS_BUILD
#
# then will configure a non-MPI version of TriBITS under that directory and
# then run the test suite using:
#
#   $ ctest -j$PARALLEL_NP
#
# The timings of each of these steps is also taken using the 'time' command.
#
# If the TriBITS and TRIBITS_BUILD dirs already exist from the last
# invocation, then they will be kept.

echo
echo "*****************************************************"
echo "*** Timing TriBITS test suite on $HOSTNAME under:"
echo "***"
echo "***   $PWD"
echo "***"

# A) Clone TriBITS

if [ -d TriBITS ] ; then

  echo
  echo "A) TriBITS directory already exists, using existing git repo ..."
  echo

else

  echo
  echo "A) Cloning TriBITS from github ..."
  echo

  time git clone https://github.com/TriBITSPub/TriBITS.git

fi

# B) Set up TRIBITS_BUILD/ dir

if [ -d TRIBITS_BUILD ] ; then

  echo
  echo "B) Using existing TRIBITS_BUILD dir and just cleaning cache ..."
  echo

  cd TRIBITS_BUILD/
  rm -r CMake* || echo "CMake* files don't exist, okay"

else

  echo
  echo "B) Creating new TRIBITS_BUILD dir ..."
  echo

  mkdir TRIBITS_BUILD
  cd TRIBITS_BUILD/

fi

# C) Configure TriBITS

echo
echo "C) Configure TriBITS tests (see configure.out) ..."
echo 

time cmake "$@" ../TriBITS &> configure.out

# D) Build TriBITS test suite

echo
echo "D) Build TriBITS test suite (see make.out) ..."
echo 

time make &> make.out

# E) Run the TriBITS test suite

if [ "$PARALLEL_NP" == "" ] ; then
  PARALLEL_NP=1
fi

echo
echo "E) Running TriBITS test suite with -j$PARALLEL_NP  (see ctest.out)..."
echo

time ctest -j$PARALLEL_NP &> ctest.out


