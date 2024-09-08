data "aws_route53_zone" "main" {
  name         = "expense.internal"
  private_zone = true
}

data "aws_ami" "main" {
  most_recent = true
  # name_regex  = "DevOps-LabImage-RHEL9"
  name_regex = "b58-golden-image"
  owners     = ["355449129696"]
}

