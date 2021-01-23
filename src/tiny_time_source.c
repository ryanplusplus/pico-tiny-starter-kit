/*!
 * @file
 * @brief
 */

#include "pico/time.h"
#include "tiny_time_source.h"

static tiny_time_source_ticks_t ticks(i_tiny_time_source_t* self)
{
  return (tiny_time_source_ticks_t)us_to_ms(time_us_64());
}

static const i_tiny_time_source_api_t api = { ticks };

i_tiny_time_source_t* tiny_time_source_init(void)
{
  static i_tiny_time_source_t self;
  self.api = &api;
  return &self;
}
