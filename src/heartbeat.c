/*!
 * @file
 * @brief
 */

#include "heartbeat.h"
#include "pico/stdlib.h"

static void blink(tiny_timer_group_t* group, void* context)
{
  (void)group;
  (void)context;
  static bool state;
  gpio_put(PICO_DEFAULT_LED_PIN, state = !state);
}

void heartbeat_init(tiny_timer_group_t* timer_group)
{
  gpio_init(PICO_DEFAULT_LED_PIN);
  gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);

  static tiny_timer_t heartbeat_timer;
  tiny_timer_start_periodic(timer_group, &heartbeat_timer, 500, NULL, blink);
}
