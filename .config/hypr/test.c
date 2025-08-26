#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <unistd.h>

int main(void) {
  char *sig = getenv("HYPRLAND_INSTANCE_SIGNATURE");
  char *runtime_dir = getenv("XDG_RUNTIME_DIR");
  struct sockaddr_un addr;
  int sockfd;
  if (!sig) {
    printf("HYPRLAND_INSTANCE_SIGNATURE not set\n");
    return 1;
  }
  if (!runtime_dir) {
    printf("XDG_RUNTIME_DIR not set\n");
    return 1;
  }
  char *path;
  asprintf(&path, "%s/hypr/%s/.socket.sock", runtime_dir, sig);
  printf("Opening %s\n", path);
  if ((sockfd = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
    perror("socket");
    return 1;
  }
  memset(&addr, 0, sizeof(struct sockaddr_un));
  addr.sun_family = AF_UNIX;
  strncpy(addr.sun_path, path, sizeof(addr.sun_path) - 1);

  if (connect(sockfd, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
    perror("connect");
    close(sockfd);
    return 1;
  }
  printf("Connected to %s\n", path);
  char* command = "monitors";
  write(sockfd, command, strlen(command));
  char buf[1024];
  while (1) {
    int n = read(sockfd, buf, sizeof(buf) - 1);
    if (n <= 0)
      break;
    buf[n] = '\0';
    printf("%s", buf);
  }
  close(sockfd);
}
