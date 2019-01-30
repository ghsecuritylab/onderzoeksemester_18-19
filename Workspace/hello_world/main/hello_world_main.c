/* Hello World Example

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
#include <stdio.h>
#include "esp_log.h"
#include "esp_system.h"
#include "esp_spi_flash.h"
#include <unistd.h>


int main()
{
	ESP_LOGI("FFF","Hello world!\n");

	for(int i = 0; i < 3000000; i++)
	{
		if(i%1000000==0)
			ESP_LOGI("FFF","%d",(3-i));
		
		usleep(1);
	}
    printf("Restarting now.\n");
    fflush(stdout);
    esp_restart();
	return 0;
}

