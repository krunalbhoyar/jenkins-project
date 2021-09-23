#!/bin/bash
sudo docker stop $(sudo docker container ls | grep spring-petclinic-angular-app | awk '{print $1}') | xargs docker rm
