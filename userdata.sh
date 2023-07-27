#!/bin/bash
yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo "WELCOME TO TERRAFORM CLASS coding with Terraform!" > /var/www/html/index.html

# sudo yum install httpd php mysql -y
# sudo yum install php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip,common,pear}  -y
# sudo wget https://wordpress.org/latest.tar.gz
# sudo tar -xvf latest.tar.gz
# sudo cp -r wordpress/* /var/www/html/
# sudo chown apache:apache -R /var/www/html
# sudo amazon-linux-extras enable php7.4
# sudo yum clean metadata
# sudo yum install php php-common php-pear -y
# sudo systemctl enable httpd
# sudo systemctl start httpd






