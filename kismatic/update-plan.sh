#!/usr/bin/env bash

source env.cfg

sed -e "s/%deploy_name%/${deploy_name}/g;
  s/%aws_user%/${instance_user}/g;
  s/%master_ip%/${master_ip}/g;
  s/%master_pubip%/${master_pubip}/g;
  s/%master_pubdns%/${master_pubdns}/g;
  s/%master_host%/${master_prvdns}/g;
  s/%worker1_ip%/${worker1_ip}/g;
  s/%worker1_pubip%/${worker1_pubip}/g;
  s/%worker1_host%/${worker1_prvdns}/g;
  s/%worker2_ip%/${worker2_ip}/g;
  s/%worker2_pubip%/${worker2_pubip}/g;
  s/%worker2_host%/${worker2_prvdns}/g;
  s/%ingress_ip%/${ingress_ip}/g;
  s/%ingress_pubip%/${ingress_pubip}/g;
  s/%ingress_host%/${ingress_prvdns}/g;
  s#%workdir%#${PWD}#g" \
  cluster.yaml.tpl > ${deploy_name}-cluster.yaml

sed -e "s/%deploy_name%/${deploy_name}/g;
  s/%aws_zone%/${kube_zone}/g" \
  aws-cloud-provider.conf.tpl > ${deploy_name}-aws.conf
