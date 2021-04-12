/*!
 * @file
 * @brief
 */

#include "heartbeat.h"
#include "pico/stdlib.h"

enum {
  red_pin = 18,
  green_pin = 19,
  blue_pin = 20,
};

static void blink(tiny_timer_group_t* group, void* context)
{
  (void)group;
  (void)context;
  static bool state;
  gpio_put(red_pin, state = !state);
}

void heartbeat_init(tiny_timer_group_t* timer_group)
{
  gpio_init(red_pin);
  gpio_init(green_pin);
  gpio_init(blue_pin);
  gpio_set_dir(red_pin, GPIO_OUT);
  gpio_set_dir(green_pin, GPIO_OUT);
  gpio_set_dir(blue_pin, GPIO_OUT);
  gpio_put(red_pin, 1);
  gpio_put(green_pin, 1);
  gpio_put(blue_pin, 1);

  static tiny_timer_t heartbeat_timer;
  tiny_timer_start_periodic(timer_group, &heartbeat_timer, 500, blink, NULL);
}
