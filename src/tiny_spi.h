/*!
 * @file
 * @brief
 */

#ifndef tiny_spi_h
#define tiny_spi_h

#include "hal/i_tiny_spi.h"
#include "hardware/spi.h"

typedef struct
{
  i_tiny_spi_t interface;
  spi_inst_t* spi;
} tiny_spi_t;

void tiny_spi_init(
  tiny_spi_t* self,
  spi_inst_t* spi,
  unsigned baudrate,
  spi_cpha_t cpha,
  spi_cpol_t cpol,
  spi_order_t order);

#endif
