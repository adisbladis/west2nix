#include <zephyr/kernel.h>

#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(main, CONFIG_APP_LOG_LEVEL);

int main(void)
{
	printk("Zephyr Example Application\n");

	while (1) {
        printk("Loop\n");

		k_sleep(K_MSEC(1000));
	}

	return 0;
}
