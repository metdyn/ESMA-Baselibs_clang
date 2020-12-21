# Baselibs Build System
#
#    System/site dependent options.

#
# REVISION HISTORY:
#
# 08Aug2008  da Silva  Moved here from GNUmakefile for better CM.
#
#-------------------------------------------------------------------------

#
#                            ----------------
#                               Compiler
#                            ----------------
#

# Intel
# -----
  ifneq ($(wildcard $(shell which ifort 2> /dev/null)),)
       CPPFLAGS += -DpgiFortran
  endif

# PGI
# ---
  ifneq ($(wildcard $(shell which pgfortran 2> /dev/null)),)
       CPPFLAGS += -DpgiFortran
       PGI_FLAG = -PGI
  endif

#
#                            ----------------
#                                Modules
#                            ----------------
#
  ifneq ($(LMOD_CMD),)
     LMODULECMD = $(LMOD_CMD)
  else
     MODULECMD = $(shell which modulecmd 2> /dev/null)
  endif

#
#                            ----------------
#                                 Python
#                            ----------------
#

   PYTHON := $(dir $(shell which python))../

#
#                            ----------------
#                                 Linux
#                            ----------------
#

ifeq ($(ARCH),Linux)
   SITE := $(patsubst discover%,NCCS,$(SITE))
   SITE := $(patsubst dali%,NCCS,$(SITE))
   SITE := $(patsubst borg%,NCCS,$(SITE))
   SITE := $(patsubst pfe%,NAS,$(SITE))
   # This detects compute nodes at NAS
   ifneq ($(shell uname -n | egrep 'r[0-9]*i[0-9]n[0-9]*'),)
      SITE := NAS
   endif
   CFLAGS := -fPIC 
   export CFLAGS

   # Gentoo and Fedora put tiprc files in a weird place
   ifneq (,$(wildcard /usr/include/tirpc/.))
      INC_EXTRA += -I/usr/include/tirpc
      LIB_EXTRA += -ltirpc
   endif

   ifeq ($(SITE),NCCS)
      ENABLE_GPFS = --enable-gpfs
      LINK_GPFS = -lgpfs
   endif

# NAS is weird. The Intel compiler modules do not define
# CC, CXX, and FC. Thus, the Baselibs system only sees the
# definitions from the gcc module. This is to force intel at NAS
   ifeq ($(SITE),NAS)
      ifneq ($(wildcard $(shell which ifort 2> /dev/null)),)
         FC := ifort
         ES_FC := $(FC)
         ESMF_COMPILER := intel
         FLAP_COMPILER := intel
         FC_FROM_ENV := FALSE
      endif
      ifneq ($(wildcard $(shell which icc 2> /dev/null)),)
         CC := icc
         ES_CC := $(CC)
         CC_FROM_ENV := FALSE
      endif
      ifneq ($(wildcard $(shell which icpc 2> /dev/null)),)
         CXX := icpc
         ES_CXX := $(CXX)
         CXX_FROM_ENV := FALSE
      endif
      ifeq ($(ESMF_COMPILER),intel)
         ifeq ($(findstring g++,$(notdir $(CXX))),g++)
            ESMF_COMPILER := intelgcc
         endif
      endif
   endif

   ifeq ($(FC),gfortran)
      FFLAGS += -fno-second-underscore
      FCFLAGS += -fno-second-underscore
      CPPFLAGS += -DgFortran
   endif

endif

