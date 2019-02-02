/*
 * config.h - Manages the config settings
 *
 *
 * Part of the CPC2 project: http://intelligenttoasters.blog
 * Copyright (C)2018  Intelligent.Toasters@gmail.com
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


#ifndef INCLUDE_CONFIG_H_
#define INCLUDE_CONFIG_H_

#define CONFIG_SIGNATURE 0xba1dfeed

#define CONFIG 				globals()->config
#define CONFIG_UPDATE		fatPutConfig((char*) &globals()->config, sizeof(struct config))

struct config
{
	uint32_t signature;
	Bool ready;
	uint16_t roms[65];		// Bit 15 indicates ASMI(0) or eMMC (1)
};

void configInit(void);
void configNew(struct config *);

#endif /* INCLUDE_CONFIG_H_ */
