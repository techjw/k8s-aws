DEPLOY=kube

prepare-instances:
	test -d ssh || mkdir ssh
	cd ssh && ssh-keygen -t rsa -f cluster.pem -N "" -C "k8s-aws-key"
	chmod 600 ssh/cluster.pem
	cd terraform && terraform init && terraform plan

create-instances:
	cd terraform && terraform init && terraform apply

destroy-instances:
	cd terraform && terraform init && terraform destroy --force
	cd terraform && rm terraform.tfstate terraform.tfstate.backup
	rm ssh/cluster.pem ssh/cluster.pem.pub && rmdir ssh
	rm kismatic/generated/kubeconfig && rm -rf kismatic/generated/keys
	rm kismatic/env.cfg kismatic/$(DEPLOY)-cluster.yaml kismatic/$(DEPLOY)-aws.conf

install-kismatic:
	cd kismatic && ./ket.sh install

remove-kismatic:
	cd kismatic && ./ket.sh remove

prepare-kubernetes:
	cd terraform && terraform output |grep -v kube_login |sed -e "s/\ =\ /=/g" > ../kismatic/env.cfg
	echo deploy_name=$(DEPLOY) >> kismatic/env.cfg
	cd kismatic && ./update-plan.sh
	cd kismatic && ./kismatic install validate -f $(DEPLOY)-cluster.yaml

install-kubernetes:
	cd kismatic && ./kismatic install apply -f $(DEPLOY)-cluster.yaml
	test -d ~/.kube || mkdir ~/.kube/
	test -f ~/.kube/config && cp -p ~/.kube/config ~/.kube/config.$(DEPLOY)-backup
	cp kismatic/generated/kubeconfig ~/.kube/config
