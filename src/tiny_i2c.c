/*!
 * @file
 * @brief
 */

#include "tiny_i2c.h"
#include "hardware/gpio.h"
#include "tiny_utils.h"

static bool write(
  i_tiny_i2c_t* _self,
  uint8_t address,
  bool prepare_for_restart,
  const void* buffer,
  uint16_t buffer_size)
{
  reinterpret(self, _self, tiny_i2c_t*);

  int result = i2c_write_blocking(
    self->i2c,
    address,
    (const uint8_t*)buffer,
    buffer_size,
    prepare_for_restart);

  return result == buffer_size;
}

static bool read(
  i_tiny_i2c_t* _self,
  uint8_t address,
  bool prepare_for_restart,
  void* buffer,
  uint16_t buffer_size)
{
  reinterpret(self, _self, tiny_i2c_t*);

  int result = i2c_read_blocking(
    self->i2c,
    address,
    (uint8_t*)buffer,
    buffer_size,
    prepare_for_restart);

  return result == buffer_size;
}

static void reset(i_tiny_i2c_t* _self)
{
  reinterpret(self, _self, tiny_i2c_t*);
  i2c_init(self->i2c, self->baudrate);
}

static const i_tiny_i2c_api_t api = { write, read, reset };

void tiny_i2c_init(
  tiny_i2c_t* self,
  i2c_inst_t* i2c,
  unsigned baudrate,
  unsigned sda,
  unsigned scl)
{
  self->i2c = i2c;
  self->baudrate = baudrate;
  self->interface.api = &api;

  gpio_set_function(sda, GPIO_FUNC_I2C);
  gpio_pull_up(sda);

  gpio_set_function(scl, GPIO_FUNC_I2C);
  gpio_pull_up(scl);

  reset(&self->interface);
}
