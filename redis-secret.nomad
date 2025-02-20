
/* redis-cli -h 192.168.34.1 -p 26270 -a Oc-SE5EN-Kron-ag-DOLLAR_SIGN */

job "redis-cache-secure" {

  group "cache" {
    count = 1
    task "redis" {
      driver = "docker"
      config {
        image = "redis:latest"
        ports = ["db"]

        args = [
          "/local/redis.conf"
        ]

      }

      resources {
        memory = 1024
      }

      template {
        data = <<EOH
appendonly yes 
appendfsync everysec
requirepass "Oc-SE5EN-Kron-ag-DOLLAR_SIGN"
notify-keyspace-events AKE 
        EOH

        destination = "local/redis.conf"
      }



      service {
        name = "redis-secure"
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