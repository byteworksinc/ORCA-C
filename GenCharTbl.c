/*
 * This program is designed to parse the Unicode DerivedCoreProperties.txt
 * file and produce tables indicating if a code point has the XID_Start or
 * XID_Continue properties.  This is needed to define the legal universal
 * character names in identifiers under C23.
 *
 * The DerivedCoreProperties.txt file for the current Unicode version is at:
 * https://www.unicode.org/Public/UCD/latest/ucd/DerivedCoreProperties.txt
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PLANE 16

/* Maximum number of ranges supported -- increase if necessary. */
#define MAX_RANGES 2000

#define MAX_LINE 1000

#define OUTPUT_FILE "CharTables.asm"

typedef struct CharRange {
        unsigned long start, end;
} CharRange;

static CharRange XID_Start_Ranges[MAX_RANGES];
static CharRange XID_Continue_Ranges[MAX_RANGES];

static char line[MAX_LINE];

static int cmp(const void *a_, const void *b_) {
        const CharRange *a = a_;
        const CharRange *b = b_;
        
        if (a->start < b->start) {
                return -1;
        } else if (a->start > b->start) {
                return 1;
        } else {
                if (a->end < b->end) {
                        return -1;
                } else if (a->end > b->end) {
                        return 1;
                } else {
                        return 0;
                }
        }
}

int main(int argc, char *argv[]) {
        FILE *infile, *outfile;
        unsigned xid_start_idx = 0;
        unsigned xid_continue_idx = 0;
        CharRange range;
        char property[101];
        int i;
        int last_plane;

        if (argc != 2) {
                fprintf(stderr, "Usage: %s DerivedCoreProperties.txt\n",
                        argc > 0 ? argv[0] : "GetIDChars");
                return EXIT_FAILURE;
        }

        infile = fopen(argv[1], "r");
        if (!infile) {
                fprintf(stderr, "Error opening %s\n", argv[1]);
                return EXIT_FAILURE;
        }

        outfile = fopen(OUTPUT_FILE, "w");
        if (!outfile) {
                fclose(infile);
                fprintf(stderr, "Error opening %s\n", OUTPUT_FILE);
                return EXIT_FAILURE;
        }
        
        fprintf(outfile, "*****************************************************************\n");
        fprintf(outfile, "*\n");
        fprintf(outfile, "*  %s\n", OUTPUT_FILE);
        fprintf(outfile, "*\n");
        fprintf(outfile, "*  These tables record the Unicode code points that have the\n");
        fprintf(outfile, "*  XID_Start or XID_Continue properties as defined in the\n");
        fprintf(outfile, "*  Unicode Character Database.  These define the legal\n");
        fprintf(outfile, "*  universal character names in identifiers under C23.\n");
        fprintf(outfile, "*\n");
        fprintf(outfile, "*  THIS FILE IS AUTO-GENERATED FROM UNICODE DATA BY GenCharTbl.\n");
        fprintf(outfile, "*  DO NOT EDIT IT MANUALLY.\n");
        fprintf(outfile, "*\n");
        fprintf(outfile, "*  Generated from:\n");
        fgets(line, MAX_LINE, infile);
        if (line[0]) line[strlen(line)-1] = 0;
        fprintf(outfile, "*  %-61s\n", line);
        fgets(line, MAX_LINE, infile);
        if (line[0]) line[strlen(line)-1] = 0;
        fprintf(outfile, "*  %-61s\n", line);
        fprintf(outfile, "*\n");
        fprintf(outfile, "*****************************************************************\n");
        fprintf(outfile, "\n");

        
        fseek(infile, 0, SEEK_SET);
        
        for (; !feof(infile); fgets(line, MAX_LINE, infile)) {
                int count = fscanf(infile, "%lx..%lx", &range.start, &range.end);
                if (count == 1) {
                        range.end = range.start;
                } else if (count != 2) {
                        continue;
                }
                
                count = fscanf(infile, " ; %100s", property);
                if (count != 1) {
                        fclose(infile);
                        fclose(outfile);
                        remove(OUTPUT_FILE);
                        fprintf(stderr, "Unexpected file format\n");
                        return EXIT_FAILURE;
                }
                
                if (strcmp(property, "XID_Start") == 0) {
                        XID_Start_Ranges[xid_start_idx++] = range;
                        //printf("XID_Start range: %04lx..%04lx\n", range.start, range.end);
                        //printf("%lu\n", range.end-range.start);
                        if (xid_start_idx == MAX_RANGES) {
                                fclose(infile);
                                fclose(outfile);
                                remove(OUTPUT_FILE);
                                fprintf(stderr, "Too many XID_Start ranges\n");
                                return EXIT_FAILURE;
                        }
                } else if (strcmp(property, "XID_Continue") == 0) {
                        if (bsearch(&range, XID_Start_Ranges, xid_start_idx, 
                                sizeof(CharRange), cmp)) {
                                //printf("Skipping XID_Continue range: %04lx..%04lx\n", range.start, range.end);
                                continue;
                        }
                        XID_Continue_Ranges[xid_continue_idx++] = range;
                        //printf("XID_Continue range: %04lx..%04lx\n", range.start, range.end);
                        if (xid_continue_idx == MAX_RANGES) {
                                fclose(infile);
                                fclose(outfile);
                                remove(OUTPUT_FILE);
                                fprintf(stderr, "Too many XID_Continue ranges\n");
                                return EXIT_FAILURE;
                        }
                }
        }

        fprintf(outfile, "* Declarations (to be copied into Table.pas):\n");
        fprintf(outfile, "*\n");
        fprintf(outfile, "*    XID_Start_Table: array[0..%u] of charRange;\n", xid_start_idx-1);
        fprintf(outfile, "*    XID_Continue_Table: array[0..%u] of charRange;\n", xid_continue_idx-1);
        fprintf(outfile, "*    XID_Start_PlaneStart: array[0..17] of integer;\n");
        fprintf(outfile, "*    XID_Continue_PlaneStart: array[0..17] of integer;\n");
        fprintf(outfile, "\n");

        fprintf(outfile, "XID_Start_Table start\n");
        last_plane = -1;
        for (i = 0; i < xid_start_idx; i++) {
                while (XID_Start_Ranges[i].start >> 16 != last_plane)
                        fprintf(outfile, "plane%d anop\n", ++last_plane);
                if (XID_Start_Ranges[i].end >> 16 != last_plane) {
                        fprintf(stderr, "Range spans multiple planes\n");
                        return EXIT_FAILURE;
                }
                fprintf(outfile, "         dc    i2'$%04lx,$%04lx'\n",
                        XID_Start_Ranges[i].start & 0xFFFF,
                        XID_Start_Ranges[i].end & 0xFFFF);
        }
        while (last_plane < MAX_PLANE + 1)
                fprintf(outfile, "plane%d anop\n", ++last_plane);
        fprintf(outfile, "\n");
        fprintf(outfile, "XID_Start_PlaneStart entry\n");
        for (i = 0; i <= MAX_PLANE + 1; i++) {
                fprintf(outfile, "         dc    i2'(plane%d-plane0)/4'\n", i);
        }
        fprintf(outfile, "         end\n");

        fprintf(outfile, "\n");
        fprintf(outfile, "\n");

        fprintf(outfile, "* This table only contains XID_Continue ranges that are not in XID_Start_Table.\n");
        fprintf(outfile, "* A code point has the XID_Continue property if it is in either table.\n");
        fprintf(outfile, "XID_Continue_Table start\n");
        last_plane = -1;
        for (i = 0; i < xid_continue_idx; i++) {
                while (XID_Continue_Ranges[i].start >> 16 != last_plane)
                        fprintf(outfile, "plane%d anop\n", ++last_plane);
                if (XID_Continue_Ranges[i].end >> 16 != last_plane) {
                        fprintf(stderr, "Range spans multiple planes\n");
                        return EXIT_FAILURE;
                }
                fprintf(outfile, "         dc    i2'$%04lx,$%04lx'\n",
                        XID_Continue_Ranges[i].start & 0xFFFF,
                        XID_Continue_Ranges[i].end & 0xFFFF);
        }
        while (last_plane < MAX_PLANE + 1)
                fprintf(outfile, "plane%d anop\n", ++last_plane);
        fprintf(outfile, "\n");
        fprintf(outfile, "XID_Continue_PlaneStart entry\n");
        for (i = 0; i <= MAX_PLANE + 1; i++) {
                fprintf(outfile, "         dc    i2'(plane%d-plane0)/4'\n", i);
        }
        fprintf(outfile, "         end\n");

        if (ferror(infile) || ferror(outfile)) {
                fclose(infile);
                fclose(outfile);
                remove(OUTPUT_FILE);
                fprintf(stderr, "I/O error\n");
                return EXIT_FAILURE;
        }
        
        fclose(infile);
        fclose(outfile);
}