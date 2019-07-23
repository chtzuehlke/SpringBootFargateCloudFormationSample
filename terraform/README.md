...

Create service in dev:

    terraform init
    terraform workspace new dev
    ./apply.sh version1
    cd ..
    ./mvn-clean-install-dockerbuild.sh
    ./terraform-docker-tag-push.sh version1
    ./terraform-curl.sh
    
...

Create service in test:

    terraform workspace new test
    ./apply.sh version1
    cd ..
    ./mvn-clean-install-dockerbuild.sh
    ./terraform-docker-tag-push.sh version1
    ./terraform-curl.sh

...

Cleanup:

    terraform workspace select test
    ./destroy.sh
    terraform workspace select dev 
    ./destroy.sh

