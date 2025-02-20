
job "MyCoolWebPHPPage" {

  group "php" {

    vault {
      /* In order to load secrets from Vault, we must indicate which policies are needed */
      policies = ["consumer-demo"]
    }
    task "php" {
      driver = "docker"
      config {
        image = "davidlublink/hashitalks:6"
        ports = ["web"]
      }
     /* Configure PHP script to use no password + certificates for authentication */
      env {
        MYSQL_DB      = "hashitalk2025"
        /* provide trusted certificate roots */
        SSL_CA_PATH   = "/local/database.ca"
        /* Provider client cert+key pair for authentication to server */
        SSL_CERT_PATH = "/local/database.crt"
        SSL_KEY_PATH  = "/secrets/database.key"

        MYSQL_USER     = "application"
        MYSQL_PASSWORD = ""
      }
/* Use Consul service catalog to lookup 'database' service and provision our PHP service */
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
  /* publish our service to Consul with 'web-application' */
      service {
        name = "web-application"
        port = "web"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

/* This stanza is writing a private key to our job that is pulled from Vault */
      template {
        data        = <<EOH
{{ with secret "pki_demo/issue/consumer" "ttl=8h" "common_name=database-consumer.service.consul" }}
{{- .Data.private_key }}    
{{- end }}
EOH
        destination = "secrets/database.key"

      }
/* Load up the CA that's signing certificates */
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
/* This stanza is writing a private key to our job that is pulled from Vault */
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

/* Port 80 is web */
    network {
      port "web" {
        to           = 80
      }
    }
  }
}
