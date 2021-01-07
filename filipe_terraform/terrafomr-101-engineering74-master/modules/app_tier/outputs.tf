# This is where you can define values to be accessed elsewhere 

output sg_app_id {
    description = "id of app security group"
    value = aws_security_group.sg_app.id
}