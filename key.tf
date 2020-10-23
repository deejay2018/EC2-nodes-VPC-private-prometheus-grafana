# -- Creating Key Pairs for grafana

resource "tls_private_key" "keyGR" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "keyLocal2" {
  content         = tls_private_key.keyGR.private_key_pem
  filename        = "grafana_key.pem"
  file_permission = 0400
}

resource "aws_key_pair" "key-gr" {
  key_name   = "grafana_key"
  public_key = tls_private_key.keyGR.public_key_openssh
}

# -- Creating Key Pairs for prometheus

resource "tls_private_key" "keyPR" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "keyLocal" {
  content         = tls_private_key.keyPR.private_key_pem
  filename        = "prometheus_key.pem"
  file_permission = 0400
}

resource "aws_key_pair" "key-pr" {
  key_name   = "prometheus_key"
  public_key = tls_private_key.keyPR.public_key_openssh
}
