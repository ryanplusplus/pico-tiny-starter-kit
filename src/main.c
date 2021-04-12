/*!
 * @file
 * @brief
 */

#include <stddef.h>
#include <stdbool.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include "tiny_time_source.h"
#include "tiny_timer.h"
#include "tiny_i2c.h"
#include "heartbeat.h"

int main()
{
  tiny_timer_group_t timer_group;
  tiny_timer_group_init(&timer_group, tiny_time_source_init());

  heartbeat_init(&timer_group);

  while(1) {
    tiny_timer_group_run(&timer_group);
  }
}
