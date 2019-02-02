/*
 * config.c - Manages the run time configuration of the CPC
 *
 * Manages configuration settings like ROM config, default disks etc
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

#include "include.h"
#include "string.h"

void configInit()
{
	struct config * p = &globals()->config;

	// Initial value
	p->ready = false;

	if( !fatGetConfig((char *)p, sizeof(struct config)))
		console("Failed to get configuration");
	else
		console("Retrieved configuration");

	if( p->signature != CONFIG_SIGNATURE )
	{
		console("Invalid config, creating default");
		configNew(p);
		fatPutConfig((char*) p, sizeof(struct config));
	}
}

void configNew( struct config * p)
{
	// Default to all 1's
	memset(p, 255, sizeof( struct config) );

	// Set signature
	p->signature = CONFIG_SIGNATURE;

	// Set ROM configuration
	p->roms[ROM_LOWER] 	= ROMMGR_ASMI | ROM_464;
	p->roms[0]			= ROMMGR_ASMI | ROM_BASIC10;

	// Set ready flag
	p->ready = true;
}
