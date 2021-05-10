/*!
 * @file
 * @brief
 */

#include "tiny_spi.h"
#include "tiny_utils.h"

static void transfer(
  i_tiny_spi_t* _self,
  const void* _write_buffer,
  void* _read_buffer,
  uint16_t buffer_size)
{
  reinterpret(self, _self, tiny_spi_t*);
  reinterpret(write_buffer, _write_buffer, const uint8_t*);
  reinterpret(read_buffer, _read_buffer, uint8_t*);

  if(read_buffer && write_buffer) {
    (void)spi_write_read_blocking(self->spi, write_buffer, read_buffer, buffer_size);
  }
  else if(write_buffer) {
    (void)spi_write_blocking(self->spi, write_buffer, buffer_size);
  }
  else if(read_buffer) {
    (void)spi_read_blocking(self->spi, 0, read_buffer, buffer_size);
  }
}

static const i_tiny_spi_api_t api = { transfer };

void tiny_spi_init(
  tiny_spi_t* self,
  spi_inst_t* spi,
  unsigned baudrate,
  spi_cpha_t cpha,
  spi_cpol_t cpol,
  spi_order_t order)
{
  self->spi = spi;
  self->interface.api = &api;

  spi_init(spi, baudrate);
  spi_set_format(spi, 8, cpol, cpha, order);
}
