/***************************************************************************
 *   Copyright 2019 by Davide Bettio <davide@uninstall.it>                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Lesser General Public License as        *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "spi_driver.h"

#include <string.h>

#include <driver/spi_master.h>

#include <freertos/FreeRTOS.h>
#include <freertos/task.h>

#include "atom.h"
#include "bif.h"
#include "context.h"
#include "debug.h"
#include "defaultatoms.h"
#include "platform_defaultatoms.h"
#include "globalcontext.h"
#include "interop.h"
#include "mailbox.h"
#include "module.h"
#include "utils.h"
#include "scheduler.h"
#include "term.h"

#include "trace.h"

#include "sys.h"
#include "esp32_sys.h"

#include "spi_device_driver.h"

static void spi_consume_mailbox(Context *ctx);

void spi_init(Context *ctx, term opts)
{
    ctx->native_handler = spi_consume_mailbox;
    ctx->platform_data = NULL;

    term miso_io_num_term = interop_proplist_get_value(opts, MISO_IO_NUM_ATOM);
    term mosi_io_num_term = interop_proplist_get_value(opts, MOSI_IO_NUM_ATOM);
    term sclk_io_num_term = interop_proplist_get_value(opts, SCLK_IO_NUM_ATOM);

    spi_bus_config_t buscfg;
    memset(&buscfg, 0, sizeof(spi_bus_config_t));
    buscfg.miso_io_num = term_to_int32(miso_io_num_term);
    buscfg.mosi_io_num = term_to_int32(mosi_io_num_term);
    buscfg.sclk_io_num = term_to_int32(sclk_io_num_term);
    buscfg.quadwp_io_num = -1;
    buscfg.quadhd_io_num = -1;

    int ret = spi_bus_initialize(HSPI_HOST, &buscfg, 1);

    if (ret == ESP_OK) {
        TRACE("initialized SPI\n");
    } else {
        TRACE("spi_bus_initialize return code: %i\n", ret);
    }
}

static term spi_open_device(Context *ctx, term req)
{
    GlobalContext *glb = ctx->global;

    //cmd is at index 0
    term opts = term_get_tuple_element(req, 1);

    Context *new_ctx = context_new(glb);
    spi_device_init(new_ctx, opts);
    scheduler_make_waiting(glb, new_ctx);

    return term_from_local_process_id(new_ctx->process_id);
}

static void spi_consume_mailbox(Context *ctx)
{
    Message *message = mailbox_dequeue(ctx);
    term msg = message->message;
    term pid = term_get_tuple_element(msg, 0);
    term ref = term_get_tuple_element(msg, 1);
    term req = term_get_tuple_element(msg, 2);

    term cmd = term_get_tuple_element(req, 0);

    int local_process_id = term_to_local_process_id(pid);
    Context *target = globalcontext_get_process(ctx->global, local_process_id);

    term ret;

    switch (cmd) {
        case OPEN_DEVICE_ATOM:
            TRACE("spi: open device.\n");
            ret = spi_open_device(ctx, req);
            break;

        default:
            fprintf(stderr, "spi: error: unrecognized command.\n");
            term_display(stderr, msg, ctx);
            fprintf(stderr, "\n");
            ret = ERROR_ATOM;
    }

    free(message);

    UNUSED(ref);
    mailbox_send(target, ret);
}
