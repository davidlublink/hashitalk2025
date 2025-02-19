
job "MyCoolWebPHPPage" {

  group "php" {
    count = 1

    vault {
      policies = ["consumer-demo"]
    }
    task "php" {
      driver = "docker"
      config {
        image = "davidlublink/hashitalks:6"
        ports = ["web"]
      }

      env {
        MYSQL_DB      = "hashitalk2025"
        SSL_CA_PATH   = "/local/database.ca"
        SSL_CERT_PATH = "/local/database.crt"
        SSL_KEY_PATH  = "/secrets/database.key"

        MYSQL_USER     = "application"
        MYSQL_PASSWORD = ""
      }

      template {
        env  = true
        data = <<EOH
         {{ range service "database" }}
MYSQL_HOST="{{ .Address }}"
MYSQL_PORT="{{ .Port }}"
         {{ end }}
EOH

        destination = "local/mysqlserver.env"
      }




      service {
        name = "web-application"
        port = "web"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }


      template {
        data        = <<EOH
{{ with secret "pki_demo/issue/consumer" "ttl=8h" "common_name=database-consumer.service.consul" }}
{{- .Data.private_key }}    
{{- end }}
EOH
        destination = "secrets/database.key"

      }

      template {
        data        = <<EOH
{{ with secret "pki_demo/issue/consumer" "ttl=8h" "common_name=database-consumer.service.consul" }} 
{{- range $cert := .Data.ca_chain }}
{{- $cert }}
{{- end }}
{{- end }}
EOH
        destination = "local/database.ca"

      }

      template {
        data        = <<EOH
{{- with secret "pki_demo/issue/consumer" "ttl=8h" "common_name=database-consumer.service.consul" }}
{{- .Data.certificate -}}
{{- range $cert := .Data.ca_chain }}
{{ $cert }}
{{- end }}
{{- end }}
EOH
        destination = "local/database.crt"

      }
    }
    network {
      port "web" {
        to           = 80
        host_network = "private"
      }
    }
  }
}