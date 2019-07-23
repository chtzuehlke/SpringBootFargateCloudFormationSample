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

    cd dockerregistry
    ./setup.sh dev version1
    cd ..
    
Test service(version1) in dev:

    cd ..
    ./terraform-curl-loop.sh
    cd terraform

...
