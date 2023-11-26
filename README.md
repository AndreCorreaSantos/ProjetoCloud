# ProjetoCloud


# VPC

Para iniciar o projeto, foi criada uma VPC na qual todos os recursos utilizados foram instanciados. Essa VPC foi configurada no bloco de CIDR `10.0.0.0/16`. Toda a infraestrutura mencionada a partir deste ponto está contida dentro dessa VPC.

## Subnets

Para possibilitar a criação de um Elastic Load Balancer, torna-se necessária a presença de duas redes públicas. Para atender a essa necessidade, foram instanciadas duas redes públicas, com blocos de CIDR equivalentes a `10.0.1.0/24` e `10.0.2.0/24`, em regiões diferentes para garantir alta disponibilidade. Essas redes foram associadas a um Internet Gateway utilizando uma tabela de roteamento, com uma associação de tabela de roteamento para cada sub-rede. As sub-redes mencionadas e a tabela de roteamento foram criadas dentro do módulo VPC; o Load Balancer foi criado dentro do módulo LB. Além disso, para atender às necessidades do RDS, foram criadas duas sub-redes privadas dentro da VPC. É importante notar que essas sub-redes não têm contato com as redes públicas, e seus blocos de CIDR são, respectivamente, `10.0.3.0/24` e `10.0.4.0/24`.

## Auto Scaling Group

Para garantir que a infraestrutura tenha poder computacional para atender picos de demanda e, ao mesmo tempo, seja financeiramente eficiente, foi criado um Auto Scaling Group com alarmes de tráfego e utilização de CPU. Esse grupo aumenta e diminui a quantidade de máquinas alocadas de forma proporcional à demanda. Esse Auto Scaling Group cria instâncias EC2 dentro das redes públicas alocadas, e as instâncias são criadas dentro do Target Group do Load Balancer. Dessa forma, toda nova instância já é capaz de receber tráfego do mesmo.

## Aplicação

A aplicação que roda dentro de todas as máquinas é um CRUD básico que está em um repositório público, clonado por todo novo EC2 no startup. Todos os comandos necessários para rodar a aplicação estão dentro do "user_data", definido no launch template.

## Banco de dados (RDS)

O banco de dados utilizado pelas aplicações é um RDS associado às duas sub-redes privadas mencionadas.

## Locust

Para testar toda a infraestrutura e, principalmente, se o Auto Scaling Group responde de forma adequada à demanda variada, um EC2 foi alocado em uma das subnets públicas, fora do Auto Scaling Group. Esse EC2 contém um "user_data" que inicializa o Locust, uma aplicação capaz de realizar testes de carga e fornecer dados relevantes relacionados às respostas da infraestrutura.


## Repositórios auxiliares

A aplicação utilizada no projeto está presente em https://github.com/AndreCorreaSantos/simple_python_crud.git e o locust está contido em https://github.com/AndreCorreaSantos/locust.


## Execução


Para executar a infraestrutura, é necessário possuir a AWS CLI instalada e exportar suas credenciais da AWS como variáveis de ambiente:

```bash
export AWS_ACCESS_KEY_ID=**************
export AWS_SECRET_ACCESS_KEY=************
export AWS_DEFAULT_REGION=*****************
```

Também é necessário ter um bucket S3 de nome "andrebucket" criado para guardar o backend do Terraform. Em seguida, basta rodar os seguintes comandos:

```bash
terraform init
terraform apply
```

Para utilizar a aplicação, é necessário saber o endereço do DNS. Para obtê-lo, execute o seguinte comando:

```bash
terraform state show module.lb.aws_lb.web_lb
```

O endereço relevante está na variável `dns_name` do output. Agora, podemos acessar a aplicação inserindo o seguinte URL no navegador:

```
dns_name/docs
```

Substitua `dns_name` pelo valor obtido anteriormente.

# Locust

Para rodar os testes de carga, basta inserir o IP público da instância que contém o Locust no navegador e acessar sua porta 8089.



Para encontrar o IP público, podemos executar o seguinte comando:



```bash

terraform state show module.ec2.aws_instance.locust

```



A variável `public_ip` armazena o endereço público dessa instância. Portanto, basta digitar o seguinte no navegador:



```

public_ip:8089

```



Substitua `public_ip` pelo valor obtido anteriormente. Isso permitirá acessar a interface do Locust e executar os testes de carga.


# Diagrama da infraestrutura

![Diagrama](Diagrama.jpg)
