# This is where you can define values to be accessed elsewhere 

output "db_private_ip" {
    description = "private ip of db instance"
    value = aws_instance.nodejs_db_instance.private_ip
}