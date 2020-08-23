# API Gateway + Vue JS + Express + PostgreSQL 

This repository showcases an API gateway fronting an app that uses Vue JS, Express and PostgreSQL. Each piece of architecture is running isolated on their own container.

## How it looks like in local

![Local Stack Diagram](https://github.com/allanchua101/api-gateway-vue-express-pg/blob/master/VueJS%20Express%20Ocelot%20Local%20(1).png "Local Stack Diagram")

## How it will look like in AWS

![Stack Diagram](https://github.com/allanchua101/api-gateway-vue-express-pg/blob/master/Stack%20Diagram.png "Stack Diagram")

## Pre-requisites

The following items should be installed on your machine:

:heavy_check_mark: Docker          (Containerization)  
:heavy_check_mark: Docker Compose  (Service Orchestration Locally)  
:heavy_check_mark: NodeJS          (API and GUI Development)  
:heavy_check_mark: .NET Core       (API Gateway Development)  

## Technology Stack

:heavy_check_mark: .NET Core  
:heavy_check_mark: Node JS  
:heavy_check_mark: VueJS  
:heavy_check_mark: Express JS  
:heavy_check_mark: Ocelot  
:heavy_check_mark: PostgreSQL  

## Running Application

Run the following on the project root directory:

```sh
docker-compose up
```

## Access GUI Locally

To access GUI, navigate to [http://localhost:52793](http://localhost:52793)  

To hit an API, navigate to [http://localhost:52793/v1/api/users/list](http://localhost:52793/v1/api/users/list)

### TLDR;
I'm writing about API gateways in my blog @ [https://www.pogsdotnet.com](https://www.pogsdotnet.com)
