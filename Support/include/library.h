/*
 * library.h
 *
 * General library header
 * Part of the CPC2 project: http://intelligenttoasters.blog
 * Copyright (C)2017  Intelligent.Toasters@gmail.com
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, you can find a copy here:
 * https://www.gnu.org/licenses/gpl-3.0.en.html
 *
 */

#ifndef INCLUDE_LIBRARY_H_
#define INCLUDE_LIBRARY_H_

#define _CRLF_ "\n\r"
#define _CR_ '\r'
#define _LF_ '\n'
#define _STD_WIDTH_ 80

#define min( x, y ) (( x>=y ) ? y : x)
#define max( x, y ) (( x>=y ) ? x : y)

inline struct global_vars * globals(void);
inline void processEvents(void);
void console(char *);
void ul(void);

#endif /* INCLUDE_LIBRARY_H_ */
