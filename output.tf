//By below code we can get the output of PublicIP and PrivateIP in terminal 

output "PublicIP" {
  value = aws_instance.tf-ec2.public_ip
}
output "PrivateIP" {
  value = aws_instance.tf-ec2.private_ip
}