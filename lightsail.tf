## refere-se a ~/.aws/credenciais. Credenciais AWS CLI
provider "aws" {
  profile = "default"
  region  = "us-west-2"
}
## Cria uma Instância AWS Lightsail.
resource "aws_lightsail_instance" "gitlab_test" {
  name              = "custom_gitlab"
  availability_zone = "us-west-1a"
  blueprint_id      = "string"
  bundle_id         = "string"
  key_pair_name     = "some_key_name"
  tags = {
    foo = "bar"
  }
}
## Cria um endereço IP público estático no Lightsail
resource "aws_lightsail_static_ip" "test" {
  name = "example"
}

## Anexar endereço IP estático à instância de Lightsail
resource "aws_lightsail_static_ip_attachment" "test" {
  static_ip_name = aws_lightsail_static_ip.test.id
  instance_name  = aws_lightsail_instance.test.id
}

## Cria uma nova Rota53 Zona alojada Pública. Incompreensão abaixo se não tiver uma zona alojada existente.
## recurso "aws_route53_zone" "hosted_zone" {#
## nome = "example.com" ## Introduza aqui o seu nome de domínio
## }

## Pontos para a sua actual zona de alojamento público da Rota 53. 
## Remova isto se estiver a criar uma nova Zona Alojada Pública

resource "aws_route53_zone" "primary" {
  name = "example.com" ## Introduzir aqui o seu nome de domínio
}

## Cria um registo da Rota 53 para o seu endereço IP Lightsail estático sem www
resource "aws_route53_record" "no_www" {
  zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}" ## Apagar "dados", se estiver a criar uma nova zona alojada
  name    = "${data.aws_route53_zone.hosted_zone.name}"    ## Apagar "dados", se estiver a criar uma nova zona alojada
  type    = "A"
  ttl     = "300"
  records = ["${aws_lightsail_static_ip.static_ip.ip_address}"]
}

## Cria um registo da Rota 53 para o seu endereço IP Lightsail estático com www.
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.example.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.lb.public_ip]
  
}
