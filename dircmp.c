/*
 * $Id: dircmp.c,v 1.4 2001/07/05 18:37:31 pcj Exp $
 *
 * dircmp: compare two directories for file timestamp differences.
 *
 * Copyright (C) 2001 Paul Cody Johnston - pcj@inxar.org
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.

 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
 * 02111-1307, USA.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <libgen.h>
#include <unistd.h>
#include <assert.h>
#include <sys/stat.h>
#include <sys/types.h>
				
#define OK_S 0x000F
#define OK_D 0x00F0
#define OK_P 0x0F00
#define OK_Q 0xF000
#define OK_ALL 0xFFFF
#define OK_NONE 0x0000

#define DEBUG 0

/* global variable declarations */

char *srcsfx, *dstsfx;		/* source and dest file suffixes */
char *srcdir, *dstdir;		/* source and dest directories */
int num;			/* number of filenames outputted */

int usage(void)
{
  fprintf(stderr, "dircmp - compare file timestamps between two directories\n");
  fprintf(stderr, "\n");
  fprintf(stderr, "Usage: dircmp -s <srcdir> -d <dstdir> -p <srcsfx> -q <dstsfx> <dirs>...\n");
  fprintf(stderr, "\n");
  fprintf(stderr, "srcdir: source directory\n");
  fprintf(stderr, "dstdir: destination directory\n");
  fprintf(stderr, "srcsfx: source directory file suffix\n");
  fprintf(stderr, "dstsfx: destination directory file suffix\n");
  fprintf(stderr, "  dirs: list of directories relative to srcdir and dstdir\n");
  fprintf(stderr, "\n");
  fprintf(stderr, "Example:  Given the following directory structure where \n");
  fprintf(stderr, "          hello.java has a more recent lastmodified date \n");
  fprintf(stderr, "          than hello.class, dircmp should output hello.java\n");
  fprintf(stderr, "tmp\n");
  fprintf(stderr, "|-- classes\n");
  fprintf(stderr, "|   `-- test\n");
  fprintf(stderr, "|       `-- hello.class\n");
  fprintf(stderr, "`-- src\n");
  fprintf(stderr, "    `-- test\n");
  fprintf(stderr, "        `-- hello.java\n");
  fprintf(stderr, "\n");
  fprintf(stderr, "$ dircmp -s tmp/src -d tmp/classes -p .java -q .class test\n");
  fprintf(stderr, "tmp/src/test/hello.java\n");

  fprintf(stderr, "\n");
  fprintf(stderr, "Report bugs to <pcj@inxar.org>.\n");
  return 1;
}

void printstr(char *str)
{
  int len = strlen(str);
  int i;

  for (i = 0; i <= len; i++) {
    printf("[%d]", str[i]);
  }
  printf("\n");
}

int dircmp(char *dir)
{
  extern int errno;		/* defined dirent.h */
  int len;

  DIR *directory;		/* pointer to a directory */
  struct dirent *entry;		/* pointer to a directory entry */
  struct stat sbuf;		/* stat buffer for the stat function */
  char *sfx;			/* file suffix, like ".c" */
  char *srcfile, *dstfile;	/* name of source and destination files */
  char *abs_srcdir, *abs_dstdir; /* absolute source and dst directory */
  time_t srcmod, dstmod;	/* file modification times */

  /* Create the absolute source directory */
  if (dir[strlen(dir) - 1] != '/') {
      abs_srcdir = malloc( (strlen(srcdir) + strlen(dir) + 2) * sizeof(char) );
      assert(abs_srcdir != NULL);
      strcpy(abs_srcdir, srcdir);
      strcpy(&abs_srcdir[strlen(abs_srcdir)], dir);
      strcpy(&abs_srcdir[strlen(abs_srcdir)], "/");
  } else {
      abs_srcdir = malloc( (strlen(srcdir) + strlen(dir) + 1) * sizeof(char) );
      assert(abs_srcdir != NULL);
      strcpy(abs_srcdir, srcdir);
      strcpy(&abs_srcdir[strlen(abs_srcdir)], dir);
  }

  /* Create the absolute dst directory */
  if (dir[strlen(dir) - 1] != '/') {
      abs_dstdir = malloc( (strlen(dstdir) + strlen(dir) + 2) * sizeof(char) );
      assert(abs_dstdir != NULL);
      strcpy(abs_dstdir, dstdir);
      strcpy(&abs_dstdir[strlen(abs_dstdir)], dir);
      strcpy(&abs_dstdir[strlen(abs_dstdir)], "/");
  } else {
      abs_dstdir = malloc( (strlen(dstdir) + strlen(dir) + 1) * sizeof(char) );
      assert(abs_dstdir != NULL);
      strcpy(abs_dstdir, dstdir);
      strcpy(&abs_dstdir[strlen(abs_dstdir)], dir);
  }

  if (DEBUG) {
      printf("abs_srcdir: %s\n", abs_srcdir);
      printf("abs_dstdir: %s\n", abs_dstdir);
  }

  /* Open the directory */
  if ((directory = opendir(abs_srcdir)) == NULL) {
    fprintf(stderr, "Can't open directory `%s': %s\n", abs_srcdir, strerror(errno));
    return -1;
  }

  /* Read each entry */
  while ((entry = readdir(directory)) != NULL) {

    /* ignore the dot and dotdot files */
    if (entry->d_name[0] == '.') {
      switch ( strlen(entry->d_name) ) {
      case 1:
	continue;
      case 2:
	if (entry->d_name[1] == '.')
	  continue;
      }
    }

    sfx = strrchr(entry->d_name, '.');
    
    /* see if the file suffix matches the srcsfx */
    /* srcsfx will return 0 if strings are equal */
    if (!(sfx != NULL && strlen(sfx) == strlen(srcsfx) && !(strcmp(srcsfx, sfx)))) 
	continue;
    
    /* Okay, matched a file.  Now get the lastmodified timestamp. For
       this we need to make a source file string */
    srcfile = malloc( (strlen(abs_srcdir) + strlen(entry->d_name) + 1) * sizeof(char) );
    assert(srcfile != NULL);
    strcpy(srcfile, abs_srcdir);
    strcpy(&srcfile[strlen(srcfile)], entry->d_name);

    if (stat(srcfile, &sbuf) != 0) {

	fprintf(stderr, "Unable to stat `%s': %s\n", srcfile, strerror(errno));

    } else {
   
	srcmod = sbuf.st_mtime;

	/* ok, we have the timestamp.  Now we need to find the
	   corresponding file in the dstdir. */
	len = strlen(abs_dstdir) 
	  + strlen(entry->d_name) 
	  + strlen(dstsfx) 
	  + 1;			/* length is larger than the actual required length */

	dstfile = malloc( len * sizeof(char) );
	assert(dstfile != NULL);

	strcpy(dstfile, abs_dstdir);
	strcpy(&dstfile[strlen(dstfile)], entry->d_name);
	strcpy(strrchr(dstfile, '.'), dstsfx);

	/*
	printf("\ndstfile.1: %s\n", dstfile);
	printf("length of %s: %d\n", entry->d_name, strlen(entry->d_name));
	printf("dstfile.2: %s\n", dstfile);
	printf("dstfile.3: %s\n", dstfile);
	*/

	if (stat(dstfile, &sbuf) != 0) {
	    /* if we are unable to stat the filename, assume that the
	       classfile does not exist.  Therefore, output the filename */
	    if (num++ > 0)
		printf("  %s%s", abs_srcdir, entry->d_name);
	    else
		printf("%s%s", abs_srcdir, entry->d_name);
	    
	} else {

	    dstmod = sbuf.st_mtime;

	    /* okay, we now can compare the timestamps of the files.
	       If the srcfile is newer, output it. */
	    if (srcmod > dstmod) {
		if (num++ > 0)
		    printf(" %s%s", abs_srcdir, entry->d_name);
		else
		    printf("%s%s", abs_srcdir, entry->d_name);
	    }
	}

	free(dstfile);
    }
       
    free(srcfile);
  }
  
  free(abs_srcdir);
  free(abs_dstdir);

  /* Close the directory */
  closedir(directory);

  return 0;
}

int main(int argc, char * const argv[])
{
  int len;			/* string length */
  int i;			/* loop counter */
  char c;			/* tmp character */

  extern char *optarg;		/* defined getopt in unistd.h */
  extern int optind, optopt;	/* defined getopt in unistd.h */

  int ok_stat = OK_NONE;	/* status code to make sure all opts are set */

  while ((c = getopt(argc, argv, ":d:s:p:q:")) != -1) {
    switch (c) {
    case 's':
      len = strlen(optarg);
      if (optarg[len - 1] != '/') {
	srcdir = malloc( (len + 2) * sizeof(char) );
	assert(srcdir != NULL);
	strcpy(srcdir, optarg);
	srcdir[len] = '/';
	srcdir[len + 1] = '\0';
      } else {
	srcdir = strdup(optarg);
	assert(srcdir != NULL);
      }
      ok_stat |= OK_S;
      break;

    case 'd':
      len = strlen(optarg);
      if (optarg[len - 1] != '/') {
	dstdir = malloc( (len + 2) * sizeof(char) );
	assert(dstdir != NULL);
	strcpy(dstdir, optarg);
	dstdir[len] = '/';
	dstdir[len + 1] = '\0';
      } else {
	dstdir = strdup(optarg);
	assert(dstdir != NULL);
      }
      ok_stat |= OK_D;
      break;

    case 'p':
      srcsfx = strdup(optarg);
      assert(srcsfx != NULL);
      ok_stat |= OK_P;
      break;

    case 'q':
      dstsfx = strdup(optarg);
      assert(dstsfx != NULL);
      ok_stat |= OK_Q;
      break;

    case ':': 
      fprintf(stderr, "Option -%c requires an operand\n", optopt);
      break;

    case '?':
      fprintf(stderr, "Unrecognised option: -%c\n", optopt);
      break;
    }

    //printf("ok_stat: %d\n", ok_stat);
  }

  if (ok_stat != OK_ALL) {
    usage();
    exit(2);
  }

  if (DEBUG) {
    printf("srcsfx: %s\n", srcsfx);
    printf("dstdir: %s\n", dstdir);
    printf("srcdir: %s\n", srcdir);
    printf("dstsfx: %s\n", dstsfx);
  }

  argc -= optind;
  argv += optind;

  if (argc == 0) {
      fprintf(stderr, "ERROR:  Must specify at least one search subdirectory.\n");
      usage();
  }

  num = 0;

  for (i = 0; i < argc; i++) {
    dircmp(argv[i]);
  }

  if (num > 0)
      printf("\n");

  free(srcdir);
  free(dstdir);
  free(srcsfx);
  free(dstsfx);

  return 0;
}





