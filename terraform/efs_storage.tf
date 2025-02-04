resource "aws_ebs_volume" "elasticsearch" {
  availability_zone = "us-east-1a"
  size              = 50
  type              = "gp3"
  encrypted         = true
}

resource "aws_ebs_volume" "kibana" {
  availability_zone = "us-east-1a"
  size              = 20
  type              = "gp3"
  encrypted         = true
}
