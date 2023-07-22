/*
File Name: main.c
Purpose: Program to convert an S-Record to the memory text file
Date: February 12, 2023
Author: Mark McCoy
B00: 816309
Course: ECED 4900
*/

/* NOTE: Utilized most of code from my assignment from ECED 3403 */

#define MAX_LEN 128

#include <stdio.h>
#include <string.h>

unsigned short PC = 0;
unsigned char memory[0x10000];		// 64KiB of memory

/* Function Declarations */
int process_srec(unsigned char* srec);
unsigned char ascii2hexchar(unsigned char nib);
unsigned char hex2char(unsigned char nib1, unsigned char nib2);

int main(int argc, char* argv[])
{
	/*
	- Open the S-record for reading
	- Read a record
	- Decode the record including error checking
	- Print the values at memory locations 0x1025, 0x2004, and 0x3002
	*/

	FILE* infile;
	FILE* outfile;

	char record[MAX_LEN];
	int errors = 0;

	// Open the S-record file for reading (if possible)
	if (fopen_s(&infile, argv[1], "r") != 0)
	{
		printf("Unable to open file. File may not exist.\n");
		return -1;
	}

	printf("Starting decoding of S-records... \n\n");

	for (int i = 0; i < 0x10000; i++)
	{
		memory[i] = 0;
	}

	/* Read records until end of file */
	while (fgets(record, MAX_LEN, infile) > 0)
	{
		record[strlen(record) - 1] = '\0'; // Remove LF from record
		if ((record[0] == 'S') && ((record[1] == '0') || (record[1] == '1') || (record[1] == '9')))
		{
			errors += process_srec(record);
		}
		else
		{
			printf("Invalid S-record. Reason: Bad type. S-record: %s\n", record);
		}
	}
	printf("File read - %d errors detected. Starting address: %4.4X\n", errors, PC);
	fclose(infile);

	fopen_s(&outfile, "memory.txt", "w");
	
	for (int i = 0; i < 0x10000; i++)
	{
		fprintf(outfile, "\t%d : %2.2X;\n", i, memory[i]);
	}
	fclose(outfile);

	getchar();
	return 0;
}



/*
Function Name: process_srec
Purpose: Decode an S-record to obtain the desired quantities for the specific record
Inputs: One S-record to be processed
Output: The desired quantities parsed out
*/
int process_srec(unsigned char* srec)
{
	int i1 = 0, rec_len, error = 0;
	unsigned char byte_val, count, curr_count = 0, addrh, addrl, rec_type;
	char checksum, run_sum;
	unsigned short addr;

	rec_len = strlen(srec); // Get total record length
	checksum = hex2char(srec[rec_len - 2], srec[rec_len - 1]);
	curr_count = 1; // Checksum byte read
	rec_type = srec[1]; // Determine record type

	// Obtain address
	addrh = hex2char(srec[4], srec[5]);
	addrl = hex2char(srec[6], srec[7]);
	addr = (addrh << 8) + addrl;

	// Obtain the count byte
	count = hex2char(srec[2], srec[3]);
	run_sum = count;

	// Start scanning after the count byte
	for (int i = 4; i < (rec_len - 2); i = i + 2)
	{
		byte_val = hex2char(srec[i], srec[i + 1]);

		// After address bytes passed, begin collecting data bytes.
		if (i > 7)
		{
			if (rec_type == '1')
			{
				// Assign values to memory if S1 record
				memory[addr + i1] = byte_val;
			}
			i1++;
		}
		run_sum += byte_val;
		curr_count++;
	}

	/* Error checking messages */
	if ((checksum + run_sum) != -1)
	{
		printf("Invalid S-record. Reason: Bad checksum. S-record: %s\n", srec);
		error++;
	}
	if (count != curr_count)
	{
		printf("Invalid S-record. Reason: Bad count. S-record: %s\n", srec);
		error++;
	}

	if (!error && rec_type == '9')
	{
		PC = addr;
	}

	return error;
}

/*
Function Name: ascii2hexchar
Purpose: Convert an ASCII hex nibble into its equivalent numeric value
Input: A hex nibble
Output: The numeric equivalent of the ASCII hex nibble
*/
unsigned char ascii2hexchar(unsigned char nib)
{
	if (nib >= '0' && nib <= '9')
	{
		return nib - '0';
	}
	else if (nib >= 'A' && nib <= 'F')
	{
		return nib - 'A' + 10;
	}
}

/*
Function Name: hex2char
Purpose: Combine two hex nibbles into a char
Inputs: Two ASCII hex nibbles
Output: The numeric equivalent of the ASCII hex nibbles combined
*/
unsigned char hex2char(unsigned char nib1, unsigned char nib2)
{
	int val1, val2;
	val1 = ascii2hexchar(nib1);
	val2 = ascii2hexchar(nib2);
	return (val1 << 4) + val2;
}