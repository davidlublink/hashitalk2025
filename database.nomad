job "MySQL-Secure-Demo" {

  group "mysql" {

    vault { policies = ["database-demo"] }

    task "mysql" {
      driver = "docker"
      config {
        image = "mysql:latest"

        volumes = ["local/base.sql:/docker-entrypoint-initdb.d/base.sql"]

        args = [
          "--ssl-cert=/local/database.crt",
          "--ssl-key=/secrets/database.key",
          "--require-secure-transport=ON",
          "--ssl-ca=/local/database.ca"
        ]
        ports = ["db"]
      }
      service {
        name = "database"
        port = "db"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      env {
        MYSQL_ROOT_PASSWORD = "F1VE-Glak-ofs-C0L0N"
      }

      resources {
        memory = 1024
      }

      template {
        data        = <<EOH
CREATE DATABASE hashitalk2025;

CREATE user application REQUIRE x509;

GRANT ALL PRIVILEGES ON hashitalk2025.* to application;

USE hashitalk2025;

CREATE TABLE cooltable ( id BIGINT PRIMARY KEY AUTO_INCREMENT, Comment VARCHAR(100) default null );

INSERT INTO cooltable (comment) values("Hello");
INSERT INTO cooltable (comment) values("Hashitalks");
INSERT INTO cooltable (comment) values("2025");

EOH
        destination = "local/base.sql"

      }


      template {
        data        = <<EOH
{{ with secret "pki_demo/issue/database" "ttl=8h" "ip_sans=192.168.34.1" "common_name=database.service.consul" }}
{{- .Data.private_key }}    
{{- end }}
EOH
        destination = "secrets/database.key"

      }

      template {
        data        = <<EOH
{{ with secret "pki_demo/issue/database" "ttl=8h" "ip_sans=192.168.34.1" "common_name=database.service.consul" }} 
{{- range $cert := .Data.ca_chain }}
{{- $cert }}
{{- end }}
{{- end }}
EOH
        destination = "local/database.ca"

      }

      template {
        data        = <<EOH
{{- with secret "pki_demo/issue/database" "ttl=8h" "ip_sans=192.168.34.1" "common_name=database.service.consul" }}
{{- .Data.certificate -}}
{{- end }}
EOH
        destination = "local/database.crt"

      }
    }
    network {
      port "db" {
        to       = 3306
        host_network = "private"
      }
    }
  }
}