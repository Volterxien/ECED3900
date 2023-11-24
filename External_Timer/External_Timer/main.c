/*
 * External_Timer.c
 *
 * Created: 2023-08-15 8:43:36 PM
 * Author : Mark McCoy, Jacques Bosse, & Tori Ebanks
 * Purpose: This code is to allow a user to control the XM-23 clock through a PuTTY terminal.
 */ 

/* Delay code based on Aljendi (n.d.-a). UART code taken from Aljendi (n.d.-b).
*	Aljendi, S. (n.d.-a). ECED3204 – Lab #4 – Timers and Pulse width modulation [Class handout]. Dalhousie University, ECED 3204.
*	Aljendi, S. (n.d.-b). ECED3204 – Lab #5 serial communication (USART) [Class handout]. Dalhousie University, ECED 3204.
*/
#define F_CPU 16000000UL

#include <stdio.h>
#include <avr/io.h> 
#include <avr/pgmspace.h> 
#include <avr/sfr_defs.h>
#include <util/delay.h>

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

int update_in_prog(void) {
	if ((PINB & (1<<PINB0)) == (1<<PINB0)) { // Button not pressed
		return 1;
	}
	else {	// Button pressed, stop execution
		return 0;
	}
}

int main(void) { 
	
	init_uart(); // Begin terminal dialog 
	
	DDRD = 1<<7;	// Sets PORTD7 to output 
	PORTD = 0;		// Outputs 1 on D7
	
	DDRB = 0;		// Set all PORTB pins to input
	PORTB = 1<<PINB0;	// Enable pull-up resistor on B0
	
	char run_option[2];
	int cont_exec = 0;
	int in_prog = 0;
	int number = 1; 
	
	printf("Welcome to the XM-23 External Clock Control Software\n");
	while (1) {
			printf("Select 'c' to enter continuous running mode\n");
			printf("Select 's' to enter step running mode\n");
			printf("In step running mode: 0 = low, 1 = high, 5 = switch running mode\n");
			printf("Selection: ");
			scanf("%s", run_option);
			printf("%s\n", run_option);
			in_prog = 1;
			if (run_option[0] == 'c') {			// Enter continuous mode
				cont_exec = 1;
			}
			else if (run_option[0] == 's') {	// Enter step mode
				cont_exec = 0;
			}
			
			while (cont_exec && in_prog) {	// Continuous mode
				in_prog = update_in_prog();	// Stop the continuous execution if the push button is pressed
				PORTD |= 1<<7;
				_delay_us(1);
				PORTD &= ~(1<<7);
				_delay_us(1);
			}
			
			while (!cont_exec && in_prog) {	// Step mode
				scanf("%d", &number);
				if(number == 1) {
					PORTD |= 1<<7;
				} 
				else if (number == 0) {
					PORTD &= ~(1<<7);
				}
				else if (number == 5) {
					in_prog = 0;	// Switch mode
				}
				printf("%d\n", number);
			}
	}	
}

