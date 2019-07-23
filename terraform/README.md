# Terraform mini how-to

Pre-cond (samples): `pwd` is this directory

Create docker registry:

    cd dockerregistry
    ./setup.sh
    cd ..

Build and push version1:

    cd ..
    ./mvn-clean-install-dockerbuild.sh
    ./terraform-docker-tag-push.sh version1
    cd terraform

Run service(version1) in dev environment:

    cd fargateservice
    ./setup.sh dev version1
    cd ..
    
Test service(version1) in dev:

    cd ..
    ./terraform-curl-loop.sh
    cd terraform

Run service(version1) in test environment:

    cd fargateservice
    ./setup.sh test version1
    cd ..

Build and push version2:

    cd ..
    ./mvn-clean-install-dockerbuild.sh
    ./terraform-docker-tag-push.sh version2
    cd terraform

Deploy service(version2) in dev:

    cd fargateservice
    terraform workspace select dev
    ./apply.sh version2
    cd ..

Test service(new version2) in dev and service(old verison1) in test:

    cd ..
    echo $(cd terraform/fargateservice && terraform workspace select dev)
    ./terraform-curl-loop.sh
    
    echo $(cd terraform/fargateservice && terraform workspace select test)
    ./terraform-curl-loop.sh
    cd terraform

...
