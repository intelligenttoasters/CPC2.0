default: real

go: com real

com:
	gcc -o cmodem main.c cmodem.c

run:
	./cmodem test /dev/ptmx | od -tx1a

real:
	./cmodem CPC2.rbf /dev/ttyS7


