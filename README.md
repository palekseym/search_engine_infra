# Финальный проект курса DevOPS

## Предварительная подготовка
Необходимо иметь аккаунты на GCP http://cloud.google.com, https://hub.docker.com/ и https://github.com

На рабочей машине должны быть установлены следующие инструменты:
- ansible https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
- gcloud https://cloud.google.com/sdk/docs/
- terraform https://www.terraform.io/
- kubectl https://kubernetes.io/docs/tasks/tools/install-kubectl/

Используемы версии:
Ansible
```
$ ansible --version

ansible 2.7.6
  python version = 2.7.15+ (default, Oct  2 2018, 22:12:08) [GCC 8.2.0]
```

Gcloud
```
$ gcloud version

Google Cloud SDK 228.0.0
alpha 2018.12.07
beta 2018.12.07
bq 2.0.39
core 2018.12.07
gsutil 4.34
kubectl 2018.12.07
```

Terraform
```
$ terraform --version

Terraform v0.11.11
```

Kubectl
```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.0", GitCommit:"0ed33881dc4355495f623c6f22e7dd0b7632b7c0", GitTreeState:"clean", BuildDate:"2018-09-27T17:05:32Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
```

Необходимо иметь сгенерированный ssh ключ котороый будет применять для подключения к созданных виртуальным машинам и при конфигурированни через ansible.
## Создание инфраструктуры
Необходимо указать свои значения переменных в файле `terraform.tfvars.example` переименовать его в `terraform.tfvars`

Создать кластер kubernetes и вм под gitlab выполнив команду в папке infrastructure

```
terraform init && terraform apply -auto-approve
```

На выходе получим несколько переменных которые будут использоваться далее в настройки gitlab
cluster_master_node - внешний ip адрес ноды через которую можно управлять кластером
gitlab_ci_external_ip = внешний ip адрес виртуальной машнины на которую будем устанавливать gitlab

## Развернем gitlab через ansible
### Установка Gitlab-ci
Необходимо указать внешний ip адрес, полученные из переменной gitlab_ci_external_ip на этапе создания инфраструктуры, в инвентаризацонном файле ansible/inventory

<details><summary>ansible/inventory</summary>

```
[gitlab-ci]
34.66.192.37
```
</details>

Для установки gitlab-ci в папке ansible выполним команду:
```
ansible-playbook -i inventory playbooks/install-gitlab.yml
```

После завершеня прелбука необходимо дождать пару минут пока gitlab инициализируется.
При вервом воходе нобходимо задать новый пароль.
### Установка Gitlab-runner <- еще не работает, приходится раннер регистрировать вручную

Перед установкой gitlab-runner необходимо получить токен для регистрации. Токен можно взять из web интерфейса gitlab Admin Aria->Overview->Runners

<details><summary>Token</summary>

![reddit](https://i.imgur.com/kWdrz6T.png)
</details>

Токен необходимо указать как переменную в ansible/inventory

<details><summary>ansible/inventory</summary>

```
[gitlab-ci]
34.66.192.37

[gitlab-ci:vars]
gitlab_tocken=ZvPqqknwAgTy-7puWZ4T
```
</details>

Для установки, в папке ansible, выполнить команду:
```
ansible-playbook -i inventory playbooks/install-gitlab
```

Необходимо вручную зарегистрировать раннер подключившись в запущенный контейнер и выполнив
```
gitlab-runner register \
  --non-interactive \
  --url "http://34.66.192.37/" \
  --registration-token "ZvPqqknwAgTy-7puWZ4T" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "docker-runner-01" \
  --tag-list "docker" \
  --run-untagged="true" \
  --locked="false" \
  --docker-privileged
```
## Создание репозиториев\проектов в Gitlab

### Содание группы
Необходимо создать группу, через веб интерфейс в gitlab, c именем аналогичным учетной записи на hub.docker.com. Имена для контейнеров будут строится по шаблону <имя_группы>/<имя_проекта>

### Создание необходимых переменных

Для того чтобы можно было пушить получившиеся образа контейнеров в hub.docker.com - необходимо на уровне группы создать переменные для аутентификации

Сделать это можно перейдя в проект и нажав Settings->CI/CD->Variables

И создать переменные:

- CI_REGISTRY_USER - логин для доступа к ub.docker.com
- CI_REGISTRY_PASSWORD - пароль от логина

### Импорт репозиториев из github в развернутый gitlab

Необходимо сделать форк в свой профиль на github репозитории (либо использовать из примера если только для запуска):
- https://github.com/palekseym/search_engine_rabbitmq
- https://github.com/palekseym/search_engine_monitoring
- https://github.com/palekseym/search_engine_deploy
- https://github.com/palekseym/search_engine_ui
- https://github.com/palekseym/search_engine_crawler

Перейдя по ссылке http://34.66.192.37/projects/new можно импортировать репозитории из github в gitlab, но для этого необходимо указать токен для доступа к github.

Токен можно получить тут https://github.com/settings/tokens. При генерации токена дат права на repo, repo:status, repo_deployment, public_repo, repo:invite

В процессе импорта запустится pipeline который соберет контейнеры и запушит их на hub.docker.com

## Развернуть приложение
Находясь в папке репозитория search_engine_deploy

Необходимо подключиться к ранее созданному кластеру через gcloud, выполнив команду:
```
gcloud container clusters get-credentials crawler-cluster --zone us-central1-a --project <имя_нашего_проекта_в_gcp>
```
развернуть приложение выполнив:
```
kubectl apply -f deploy/.
```

## Проверка работы

Узнать внешний ip адрес командой
```
get service --selector=component=ui
$ kubectl get service --selector=component=ui

NAME   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
ui     LoadBalancer   10.19.245.128   35.224.30.237   80:32731/TCP   3m
```

Отрыв 35.224.30.237 можно попробовать что-то поискать

## Удаление

Чтобы удалить кластер kubernetes и виртуальную машину с gitlab нужно выполнить в папке infrastructure:
```
terraform destroy -auto-approve
```

