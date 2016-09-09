# $Id$ 
#---------------------------------------------------------------------
# This is an example Makefile that you may choose to start with and
# customize to your preference.  The Makefile is broken into several
# main sections:
#
# (1) System Settings: Names all the tools and system pathname needed
# by the makefile
#
# (2) Project Settings: Names all the properties and settings for this
# project.
#
# (3) General Targets: Defines targets to do all the standard stuff:
# compile the classes, generate the javadocs, create jars, etc...
#
# (4) Project-Specific Targets: Jobs that are unique to this project.
#
# You may need to adjust pathnames (or more) for your environment.
# Other tools that are non-standard to a unix environment but required
# include dircmp (included in the JWM distribution) and rsync.
#
#---------------------------------------------------------------------

#=====================================================================
# SYSTEM SETTINGS
#=====================================================================
JAVADIR    = /usr/java/jdk1.3
JAVABINDIR = ${JAVADIR}/bin

CP          = /bin/cp
CD          = /bin/cd
MV          = /bin/mv
RM          = /bin/rm
MKDIR       = /bin/mkdir
TAR         = /bin/tar
GZIP        = /bin/gzip

JAVA        = ${JAVABINDIR}/java
JAVAC       = ${JAVABINDIR}/javac
JAVADOC     = ${JAVABINDIR}/javadoc
JAR         = ${JAVABINDIR}/jar
RMIC        = ${JAVABINDIR}/rmic

JIKES       = /usr/bin/jikes
DIRCMP      = /usr/bin/dircmp
ZIP         = /usr/bin/zip
RSYNC       = /usr/bin/rsync
BZIP2       = /usr/bin/bzip2
NETSCAPE    = /usr/bin/netscape
FIND        = /usr/bin/find

# Flags
SYS_JCFLAGS      = 
SYS_JIFLAGS      = 
SYS_JAVADOCFLAGS = 
SYS_JARFLAGS     = 

# Java classpath
SYS_CLASSPATH = ${JAVADIR}/jre/lib/rt.jar


#=====================================================================
# PROJECT SETTINGS
#=====================================================================

#---------------------------------------------------------------------
# Basic Project Information
#---------------------------------------------------------------------
P_VENDOR  = <<your organization or name here>>
P_NAME    = <project name here>>
P_VERSION = 0_1_0

#---------------------------------------------------------------------
# Project Directory Structure
#---------------------------------------------------------------------
P_BINDIR     = ${P_ROOTDIR}/bin
P_CLASSESDIR = ${P_ROOTDIR}/classes
P_LIBDIR     = ${P_ROOTDIR}/lib
P_DOCSDIR    = ${P_ROOTDIR}/docs
P_APIDIR     = ${P_DOCSDIR}/api
P_SRCDIR     = ${P_ROOTDIR}/src
P_TMPDIR     = ${P_ROOTDIR}/tmp
P_BUILDDIR   = /tmp/.build
P_DISTDIR    = ${P_BUILDDIR}/${P_VENDOR}/${P_NAME}-${P_VERSION}

#---------------------------------------------------------------------
# Package List: Enter a space delimited list of package names.
#---------------------------------------------------------------------
P_PACKAGES = \
	org.myorg.myproject\
	org.myorg.myproject.util\

#---------------------------------------------------------------------
# Options, Flags, Misc
#---------------------------------------------------------------------

# Select a java compiler for use later in the makefile.
JC = ${JAVAC}
#JC = ${JIKES}

# Define the project classpath here.  It needs to be a colon-separated
# list of directories or jar files.
P_CLASSPATH = ${P_CLASSESDIR}

# Define the options and flags for the compiler
P_JCFLAGS = \
	-classpath ${SYS_CLASSPATH}:${P_CLASSPATH} \
	-d ${P_CLASSESDIR}

# Define the options and flags for javadoc
P_JAVADOCFLAGS = \
	-classpath ${P_CLASSPATH} \
	-sourcepath ${P_SRCDIR} \
	-d ${P_APIDIR} \
	-public \
	-use \
	-link http://java.sun.com/products/jdk/1.3/docs/api \
	-overview ${P_SRCDIR}/overview.html \
	-windowtitle "API Documentation for ${P_VENDOR}:${P_NAME} version ${P_VERSION}" \

# Define the options and flags for jar, if necessary
P_JARFLAGS = 

#=====================================================================
# MISC TARGETS
#=====================================================================

#---------------------------------------------------------------------
# default -- Alias for compile
#---------------------------------------------------------------------
default: check classes

#---------------------------------------------------------------------
# usage -- Print a list of standard targets 
#---------------------------------------------------------------------
usage: 
	echo "> Standard Targets"
	echo "> (default) - Make classes"
	echo "> classes   - Generate (compile) classfiles from source"
	echo "> clean     - Remove generated classfiles"
	echo "> api       - Generate the API Javadocs"
	echo "> libjar    - Archive the contents of the classes dir"
	echo "> srcjar    - Archive the contents of the src dir"
	echo "> srcjar    - Archive the contents of the src dir"
	echo "> zipdist   - Create a zip distribution archive"
	echo "> gzipdist  - Create a gzip distribution archive"
	echo "> bzip2dist - Create a bzip2 distribution archive"
	echo "> Please read the Makefile itself for more information"

#---------------------------------------------------------------------
# check -- Make sure the rootdir environment variable is set.
#---------------------------------------------------------------------
check:
	if [ "$$P_ROOTDIR" = "" ]; \
	then echo 'P_ROOTDIR is not set! (try "export P_ROOTDIR=`pwd`")'; \
	exit 1; fi

#---------------------------------------------------------------------
# clean -- Alias for classesclean
#---------------------------------------------------------------------
clean: check classesclean

#---------------------------------------------------------------------
# realclean -- Removes all generateables 
#---------------------------------------------------------------------
realclean: check apiclean classesclean tmpclean libjarclean srcjarclean buildclean usermanclean docsclean

#---------------------------------------------------------------------
# backupclean -- Removes all backup files 
#---------------------------------------------------------------------
backupclean: check
	${FIND} ${P_ROOTDIR} -name '*~' -exec ${RM} {} \;

#---------------------------------------------------------------------
# tmpdir -- Creates the temporary directory if necessary. 
#---------------------------------------------------------------------
tmpdir: check 
	${MKDIR} -p ${P_TMPDIR}

#---------------------------------------------------------------------
# tmpclean -- Removes the temporary directory
#---------------------------------------------------------------------
tmpclean: check 
	${RM} -rf ${P_TMPDIR}

#---------------------------------------------------------------------
# libdir -- Creates the library directory if necessary. 
#---------------------------------------------------------------------
libdir: check
	${MKDIR}  -p ${P_LIBDIR}

#=====================================================================
# DOCUMENTATION TARGETS
#=====================================================================

#---------------------------------------------------------------------
# apidir -- Creates the api directory if necessary
#---------------------------------------------------------------------
apidir: check
	${MKDIR} -p ${P_APIDIR}

#---------------------------------------------------------------------
# api -- Generates the API Javadocs from source
#---------------------------------------------------------------------
api: check apidir
	${JAVADOC} ${SYS_JAVADOCFLAGS} ${P_JAVADOCFLAGS} ${P_PACKAGES}

#---------------------------------------------------------------------
# apiclean -- Removes the API Javadocs
#---------------------------------------------------------------------
apiclean: check
	${RM} -rf ${P_APIDIR}

#---------------------------------------------------------------------
# apibrowse -- Opens the overview-summary in a pre-existing netscape
# window.
#---------------------------------------------------------------------
apibrowse: check
	${NETSCAPE} -remote "openURL(file:`cd ${P_APIDIR}; pwd`/overview-summary.html)"

#=====================================================================
# COMPILATION TARGETS
#=====================================================================

#---------------------------------------------------------------------
# classesdir -- Creates the classes directory if necessary
#---------------------------------------------------------------------
classesdir: check
	${MKDIR} -p ${P_CLASSESDIR}

#---------------------------------------------------------------------
# classes -- Compiles the sourcecode using a java compiler.  This
# target uses "dircmp", a utility that checks all the package
# directories and emits a list of sourcecode filenames that are newer
# than the corresponsing classfile.
#---------------------------------------------------------------------
classes: check classesdir
	P_FILES=`echo ${P_PACKAGES}| tr '.' '/'`; \
	P_FILES=`${DIRCMP} -s ${P_SRCDIR} -d ${P_CLASSESDIR} -p .java -q .class $$P_FILES`; \
	if [ "$$P_FILES" = "" ]; then echo "Project is up to date"; \
	else ${JC} ${SYS_JCFLAGS} ${P_JCFLAGS} $$P_FILES; fi

#---------------------------------------------------------------------
# classesclean -- Removes the generated classes
#---------------------------------------------------------------------
classesclean: check
	${RM} -rf ${P_CLASSESDIR}


#=====================================================================
# JAR TARGETS
#=====================================================================

#---------------------------------------------------------------------
# libjar -- Packages everything in the classes directory into a jar
# and places it into the lib directory.
#---------------------------------------------------------------------
libjar: check libdir 
	cd ${P_CLASSESDIR} \
		&& ${JAR} cfm ${P_NAME}.jar \
		${P_SRCDIR}/MANIFEST.MF ${SYS_JARFLAGS} ${P_JARFLAGS} .

	${MV} ${P_CLASSESDIR}/${P_NAME}.jar ${P_LIBDIR}

#---------------------------------------------------------------------
# libjarclean -- Removes the package jar.
#---------------------------------------------------------------------
libjarclean: check
	${RM} -f ${P_LIBDIR}/${P_NAME}.jar

#---------------------------------------------------------------------
# srcjar -- Packages everything in the src directory into a jar and
# places it into the root directory.
#---------------------------------------------------------------------
srcjar: check 
	cd ${P_ROOTDIR} && ${JAR} cfm src.jar ${P_SRCDIR}/MANIFEST.MF src

#---------------------------------------------------------------------
# srcjarclean -- Removes the source jar.
#---------------------------------------------------------------------
srcjarclean: check
	${RM} -f src.jar


#=====================================================================
# DISTRIBUTION TARGETS
#=====================================================================

#---------------------------------------------------------------------
# distdir -- Creates the dist build dir if necessary
#---------------------------------------------------------------------
distdir: check
	${MKDIR} -p ${P_DISTDIR}

#---------------------------------------------------------------------
# distclean -- Removes the dist build directory
#---------------------------------------------------------------------
distclean: check
	${RM} -rf ${P_DISTDIR}

#---------------------------------------------------------------------
# distclean -- Removes the entire build directory
#---------------------------------------------------------------------
buildclean: check
	${RM} -rf ${P_BUILDDIR}

#---------------------------------------------------------------------
# dist -- Generates all the classes, api, jars, and copies it all to
# another directory using rsync.
#---------------------------------------------------------------------
dist: check classes libjar srcjar api distdir distsync

#---------------------------------------------------------------------
# distsync -- Synchronize the dist build directory with this one sans
# files we dont care to include in the final distribution.
#---------------------------------------------------------------------
distsync: check distdir
	${RSYNC} -azu --delete \
	--exclude '*CVS' \
	--exclude '*~' \
	--exclude 'classes' \
	--exclude 'src' \
	--exclude 'tmp' \
	${P_ROOTDIR}/* ${P_DISTDIR}

#---------------------------------------------------------------------
# zipdist -- Construct a project zip distribution archive.
#---------------------------------------------------------------------
zipdist: check tmpdir dist mkzip

#---------------------------------------------------------------------
# mkzip -- Create the zip archive from the dist build dir
#---------------------------------------------------------------------
mkzip: check 
	cd ${P_BUILDDIR} && ${ZIP} -r ${P_NAME}-${P_VERSION}.zip . 
	${MV} ${P_BUILDDIR}/${P_NAME}-${P_VERSION}.zip ${P_TMPDIR}

#---------------------------------------------------------------------
# tardist -- Create a project tar distribution archive.
#---------------------------------------------------------------------
tardist: check tmpdir dist mktar

mktar: check 
	${TAR} cf ${P_TMPDIR}/${P_NAME}-${P_VERSION}.tar -C ${P_BUILDDIR} ${P_VENDOR}

#---------------------------------------------------------------------
# gzipdist -- Create a project gzip distribution archive.
#---------------------------------------------------------------------
gzipdist: check tardist mkgzip

#---------------------------------------------------------------------
# mkgzip -- Create the gzip archive from the tar archive
#---------------------------------------------------------------------
mkgzip: check 
	${GZIP} -f ${P_TMPDIR}/${P_NAME}-${P_VERSION}.tar

#---------------------------------------------------------------------
# bzip2dist -- Create a project bzip2 distribution archive.
#---------------------------------------------------------------------
bzip2dist: check tardist mkbzip2

#---------------------------------------------------------------------
# mkbzip2 -- Create the bzip2 archive from the tar archive
#---------------------------------------------------------------------
mkbzip2: check 
	${BZIP2} -f ${P_TMPDIR}/${P_NAME}-${P_VERSION}.tar


#=====================================================================
# PROJECT-SPECIFIC TARGETS
#=====================================================================
# Add more non-general targets here.

