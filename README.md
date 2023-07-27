This is Wordpress dynamique website launched using terraform
we have 1 ec2 web server launched in a public subnet 
we have 2 private subnet (because we need at least 2 to form a database subnet group)
We have our RDS Mysql database in one of the private subnets
we use the userdata to past the application code
NB : You must use am Amazon linux 2 ami, not an Amazon linux ami. If not it won't work
mysql work with an Amazon Linux 2 ami