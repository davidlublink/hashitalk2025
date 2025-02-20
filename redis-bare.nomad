/* redis-cli -h 192.168.34.1 -p 28107 */

job "redis-cache1" {

  group "cache" {

    network {
      port "db" {
        to           = 6379
        host_network = "private"
      }
    }

    task "redis" {
      driver = "docker"
      config {
        image = "redis:latest"
        ports = ["db"]
      }
      service {
        name = "redis"
        port = "db"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}