resource "aws_security_group" "app_sg" {
  name        = "${var.env}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
OBOBOB    to_port     = 22
    protocol    = "tcp"
OBOBOB    cidr_blocks = ["0.0.0.0/0"]
  }
OBOBOBOBOBOB
  ingress {
    from_port   = 80
OBOBOB    to_port     = 80
OBOBOB    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
OBOBOB
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
