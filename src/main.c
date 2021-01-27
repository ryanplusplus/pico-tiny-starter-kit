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

static const unsigned LED_PIN = PICO_DEFAULT_LED_PIN;

static void blink(tiny_timer_group_t* group, void* context)
{
  (void)group;
  (void)context;
  static bool state;
  gpio_put(LED_PIN, state = !state);
}

int main()
{
  gpio_init(LED_PIN);
  gpio_set_dir(LED_PIN, GPIO_OUT);

  tiny_timer_group_t timer_group;
  tiny_timer_group_init(&timer_group, tiny_time_source_init());

  tiny_timer_t heartbeat_timer;
  tiny_timer_start_periodic(&timer_group, &heartbeat_timer, 500, blink, NULL);

  tiny_i2c_t i2c;
  tiny_i2c_init(&i2c, i2c0, 100 * 1000, 4, 5);

  uint8_t buffer[1];
  static volatile bool result;
  result = tiny_i2c_read(&i2c.interface, 0x53, false, buffer, sizeof(buffer));

  while(1) {
    tiny_timer_group_run(&timer_group);
  }
}
