job "redis-cache" {

  group "cache" {
    count = 1
    task "redis" {
      driver = "docker"
      config {
        image = "redis:latest"
        ports = ["db"]
      }
      service {
        name = "fun-redis"
        port = "db"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    network {
      port "db" {
        to           = 6379
        host_network = "private"
      }
    }
  }
}