...

Create service in dev:

    terraform init
    terraform workspace new dev
    ./apply.sh
    
    cd ..
    ./terraform-docker-tag-push.sh 
    
    ./terraform-curl.sh
    
...

