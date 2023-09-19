/*
 * External_Timer.c
 *
 * Created: 2023-08-15 8:43:36 PM
 * Author : Mark McCoy
 */ 

// Timing code taken from ECED 3204 Lab 5

#define F_CPU 16000000UL

#include <stdio.h>
#include <avr/io.h> 
#include <avr/pgmspace.h> 
#include <avr/sfr_defs.h>
#include <util/delay.h>
#include <avr/interrupt.h>

static int uart_putchar(char c, FILE *stream); 
static int uart_getchar(FILE *stream); 
FILE mystdout = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE); 
FILE mystdin = FDEV_SETUP_STREAM(NULL, uart_getchar, _FDEV_SETUP_READ);


static int uart_putchar(char c, FILE *stream) { 
	loop_until_bit_is_set(UCSR0A, UDRE0); 
	UDR0 = c; 
	return 0; 
}

static int uart_getchar(FILE *stream) { 
	loop_until_bit_is_set(UCSR0A, RXC0); // Wait until data exists 
	return UDR0; 
}

void init_uart(void) { 
	UCSR0B = (1<<RXEN0) | (1<<TXEN0); 
	UBRR0 = 16; 
	stdout = &mystdout; 
	stdin = &mystdin; 
}

ISR()

int main(void) { 
	
	init_uart(); // Begin terminal dialog 
	
	DDRD = 1<<7; // Sets PORTD7 to output 
	PORTD = 0; // Outputs 1 on D7
	
	char run_option;
	int cont_exec = 0;
	int in_prog = 0;
	int number = 1; 
	
	printf("Welcome to the XM-23 External Clock Control Software\n");
	while (1) {
			printf("Select 'c' to enter continuous running mode\n");
			printf("Select 's' to enter step running mode\n");
			scanf("%c", &run_option);
			in_prog = 1;
			if (run_option == 'c') {
				cont_exec = 1;
			}
			else if (run_option == 's') {
				cont_exec = 0;
			}
			
			while (cont_exec && in_prog) {
				PORTD |= 1<<7;
				_delay_us(1);
				PORTD &= ~(1<<7);
				_delay_us(1);
			}
			while (!cont_exec && in_prog) {
				scanf("%d", &number);
				if(number == 1) {
					PORTD |= 1<<7;
					} else if (number == 0) {
					PORTD &= ~(1<<7);
				}
				printf("%d\n", number);
			}
	}
	
	int num_instr;
	printf("Number of Cycles: ");
	scanf("%d", &num_instr);
	/*
	for (int i = 0; i<num_instr; i++) {
		PORTD |= 1<<7;
		_delay_us(1);
		PORTD &= ~(1<<7);
		_delay_us(1);
	}*/
	printf("Ready");
	while (1) {
		scanf("%d", &number);
		if(number == 1) {
			PORTD |= 1<<7;
		} else if (number == 0) {
			PORTD &= ~(1<<7);
		}
		printf("%d\n", number);
	}
	
}

