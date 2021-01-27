/*!
 * @file
 * @brief
 */

#ifndef tiny_i2c_h
#define tiny_i2c_h

#include "hal/i_tiny_i2c.h"
#include "hardware/i2c.h"

typedef struct
{
  i_tiny_i2c_t interface;
  i2c_inst_t* i2c;
  unsigned baudrate;
} tiny_i2c_t;

void tiny_i2c_init(
  tiny_i2c_t* self,
  i2c_inst_t* i2c,
  unsigned baudrate,
  unsigned sda,
  unsigned scl);

#endif
