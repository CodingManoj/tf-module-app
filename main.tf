resource "aws_instance" "main" {
  ami                    = data.aws_ami.main.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "${var.name}-${var.env}"
  }
}

# Creates DNS Record
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.name}-${var.env}.expense.internal"
  type    = "A"
  ttl     = 10
  records = [aws_instance.main.private_ip]
}

# Local Provisioner
# resource "null_resource" "app" {
#   depends_on = [aws_route53_record.main, aws_instance.main]

#   triggers = {
#     always_run = true
#   }
#   provisioner "local-exec" {
#     command = "sleep 50; cd /home/ec2-user/ansible ; ansible-playbook -i inv-dev  -e ansible_user=ec2-user -e ansible_password=DevOps321 -e COMPONENT=${var.name} -e ENV=${var.env} -e PWD=${var.pwd} expense.yml"
#   }
# }

resource "null_resource" "app" {
  depends_on = [aws_route53_record.main, aws_instance.main]

  triggers = { # Provisioners are by default create-time, that means they would only run during the infra provisioning and to make them run all the time, we are adding triggers
    always_run = true
  }
  connection { # Enables connection to the remote host
    host     = aws_instance.main.private_ip
    user     = "ec2-user"
    password = "DevOps321"
    type     = "ssh"
  }
  provisioner "remote-exec" { # This let's the execution to happen on the remote node
    inline = [
      "ansible-pull -U https://github.com/B58-CloudDevOps/ansible.git  -e COMPONENT=${var.name} -e ENV=${var.env} -e PWD=${var.pwd} expense-pull.yml"
    ]
  }
}
