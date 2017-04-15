/*
 * menu.h
 *
 * Created: 26/12/2016 7:45:03 PM
 *  Author: paul
 */ 


#ifndef MENU_H_
#define MENU_H_

void menu(void);

#define CLS 0
#define CURSOR 1
#define SGI 2
#define CLREOL 3
#define UP 4
#define DOWN 5
#define LEFT 6
#define RIGHT 7
#define SAVE 8
#define REST 9

#define NORM 0
#define INVERSE 7

#define GRA(CODE) printf(codes[CODE])
#define GRA1(CODE,P) printf(codes[CODE],P)
#define GRA2(CODE,X,Y) printf(codes[CODE],X,Y)

#define ATTR(X) printf(codes[SGI],X)
#define LOCATE(Y, X) printf(codes[CURSOR],X+1,Y)

#define M(X) printf(messages[X])

void process_events(void);
void finished_option_hold(void);

#endif /* MENU_H_ */