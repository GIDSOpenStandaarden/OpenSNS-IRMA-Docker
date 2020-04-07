# IRMA Docker deployment for GIDS
The project contains the containerized deployment of the irmago server. This project contains:

1. The `entrypoint.bash` that configures the server based on the environment variables.
1. The `Dockerfile` that builds the irmago server in a Docker container.

## Assumptions
1. SSL offloading is not part of this docker container

# Running

## Running on Docker and Docker compose

### Running up this container locally with ngrok
1. Create a ngrok account [here](https://dashboard.ngrok.com/get-started) .
1. Start the ngrok server with the following command
      
       ngrok http 8081
      
1. Copy the https URL from the  output, in this example the https url is **https://41bd98bc.ngrok.io**:
        
        ngrok by @inconshreveable                                                                                                                                                                                                                                                                                                                            (Ctrl+C to quit)
                                                                                                                                                                                                                                                                                                                                                                             
        Session Status                online                                                                                                                                                                                                                                                                                                                                 
        Account                       Roland Groen (Plan: Free)                                                                                                                                                                                                                                                                                                              
        Version                       2.3.35                                                                                                                                                                                                                                                                                                                                 
        Region                        United States (us)                                                                                                                                                                                                                                                                                                                     
        Web Interface                 http://127.0.0.1:4040                                                                                                                                                                                                                                                                                                                  
        Forwarding                    http://41bd98bc.ngrok.io -> http://localhost:8081                                                                                                                                                                                                                                                                                      
        Forwarding                    https://41bd98bc.ngrok.io -> http://localhost:8081                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                                                                                             
        Connections                   ttl     opn     rt1     rt5     p50     p90                                                                                                                                                                                                                                                                                            
                                      0       0       0.00    0.00    0.00    0.00 


### Setting up the .env file for docker and docker compose

This project is configured with environment variables.
Default values are provided in the `.env.dist` file.
The following values can be manually set:

1. `HOST_URL`, if you use ngrok to expose the container to the public internet, make sure to
set the value of the HOST_URL to the URL printed in the output of the ngrok command. If you configure the
container behind a reverse proxy, please configure the public URL here. Please make sure that any URL you use is 
an https URL. 

1. `CLIENT_SECRET`, any random string works. You can use openssl for generating a string

       openssl rand -hex 32
1. `JWT_PUBLIC_KEY`/`JWT_PRIVATE_KEY`. Generate a keypair in the ./configuration directory by running

       cd ./configuration
       ../tools/keygen.sh
       cd ..
1. Copy the `.env.dist` file to `.env` and add the following values

       HOST_URL=.. the URL from ngrok or the public URL for this service.
       CLIENT_SECRET=... the result of 1)
       JWT_PUBLIC_KEY_FILE=/configuration/public_key.pem
       JWT_PRIVATE_KEY_FILE=/configuration/private_key.pem
       DEBUG=1

## Docker
To start the server with the default configuration, run. 
```shell script
docker build . -t irma_server
docker run -p 8081:8080 --env-file=.env --name irma_server irma_server
```

## Docker compose
```shell script
docker-compose build && docker-compose up
```

## Testing the installation.

The container should be available on localhost with the following URL:

[http://localhost:8081/publickey](http://localhost:8081/publickey)

When running with ngrok, the installation can be tested with adding /publickey to the ngrok URL, for example:

[http://41bd98bc.ngrok.io/publickey](http://41bd98bc.ngrok.io/publickey)

The page should display the public key of the server.


# Configuration

## Environment variables

| Variable | default | remark |
| ---: | --- | :--- |
| HOST_URL             | https://localhost:8081/    | The external URL on which the container is hosted. |
| JWT_ISSUER           | gids                      | The issuer of the JWT message |
| JWT_PUBLIC_KEY       | \[generated if absent]    | If JWT_PRIVATE_KEY not present, and no file is added to the container and set in JWT_PRIVATE_KEY_FILE, this value will be generated on startup of the container. The generated key is printed to the console. |
| JWT_PUBLIC_KEY_FILE  |                           | Optional method of referring to a public key file added to the container. |
| JWT_PRIVATE_KEY      | \[generated if absent]    | If JWT_PRIVATE_KEY not present, and no file is added to the container and set in JWT_PRIVATE_KEY_FILE, this value will be generated on startup of the container. |
| JWT_PRIVATE_KEY_FILE |                           | Optional method of referring to a private key file added to the container. |
| CLIENT_KEY           | testsp                    | The key of the connecting client. |
| CLIENT_SECRET        | \[generated if absent]    | The secret of the connecting client, generated and printed to the console if absent. |
| SCHEMES              | https://privacybydesign.foundation/schememanager/pbdf | Space separated list of scheme URLs |
| DEBUG                | 0                         | If 0 debugging is disabled. To enable debug info: 1=normal, 2=high |
