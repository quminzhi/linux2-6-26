#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mount.h>


int main(void) {
  // Mount the proc and sys filesystems
  if (mount("proc", "/proc", "proc", 0, NULL) < 0) {
    perror("mount /proc");
    return 1;
  }
  if (mount("sysfs", "/sys", "sysfs", 0, NULL) < 0) {
    perror("mount /sys");
    return 1;
  }
  
  // Print a message
  printf("Booting minimal root filesystem\n");

  while (1) {
    printf("hello kernel!\n");
    sleep(3);
  }

  return 1;
}
    
