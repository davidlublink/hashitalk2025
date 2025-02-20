job "MySQL-Secure-Demo" {

  group "mysql" {
/* We need to specify Vault policies that will allow us to get out certificates signed */
    vault { policies = ["database-demo"] }

    task "mysql" {
      driver = "docker"
      config {

        /* We're using mysql server */
        image = "mysql:latest"
        /* base.sql is from our template, we're dropping this into the folder mysql will read when starting the database */
        volumes = ["local/base.sql:/docker-entrypoint-initdb.d/base.sql"]
        /* Configure SSL and make it mandatory for all connections */
        args = [
          "--ssl-cert=/local/database.crt",
          "--ssl-key=/secrets/database.key",
          "--require-secure-transport=ON",
          "--ssl-ca=/local/database.ca"
        ]
        /* Publish our ports */
        ports = ["db"]
      }
      /* Publish DB port to database */
      service {
        name = "database"
        port = "db"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      /* Don't store passwords in Nomad files */
      env {
        MYSQL_RANDOM_ROOT_PASSWORD = "YES"
      }
      /* By default Nomad gives 300 megabytes, databases are memory hogs */
      resources {
        memory = 1024
      }
/* Generate a SQL file to run at first run */
      template {
        data        = <<EOH

-- Setup a demo database
CREATE DATABASE hashitalk2025;

-- Create the 'application' user that can only log in with client certificate.
CREATE user application REQUIRE x509;

-- Give new user access to new database
GRANT ALL PRIVILEGES ON hashitalk2025.* to application;

USE hashitalk2025;

-- setup table we can scrape for 
CREATE TABLE cooltable ( id BIGINT PRIMARY KEY AUTO_INCREMENT, Comment VARCHAR(100) default null );

-- data for demo 
INSERT INTO cooltable (comment) values("Hello");
INSERT INTO cooltable (comment) values("Hashitalks");
INSERT INTO cooltable (comment) values("2025");

EOH
        destination = "local/base.sql"

      }

/* Sign a certificate, drop the key in database.key */
      template {
        data        = <<EOH
{{ with secret "pki_demo/issue/database" "ttl=8h" "ip_sans=192.168.34.1" "common_name=database.service.consul" }}
{{- .Data.private_key }}    
{{- end }}
EOH
        destination = "secrets/database.key"

      }
/* get the certificate root and drop it in database.ca */
      template {
        data        = <<EOH
{{ with secret "pki_demo/issue/database" "ttl=8h" "ip_sans=192.168.34.1" "common_name=database.service.consul" }} 
{{- range $cert := .Data.ca_chain }}
{{- $cert }}
{{- end }}
{{- end }}
EOH
        destination = "local/database.ca"
/* Sign a certificate, drop the certficate in database.crt */
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

/* Port 3306 is DB */
    network {
      port "db" {
        to       = 3306
        
      }
    }
  }
}
