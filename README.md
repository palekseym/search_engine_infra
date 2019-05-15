# Финальный проект курса DevOPS

## Что сделано

Созданы репозитории:
- https://github.com/palekseym/search_engine_infra - скрипты создания инфраструктуры
- https://github.com/palekseym/search_engine_ui - web интерфейс приложения
- https://github.com/palekseym/search_engine_crawler - backend приложения
- https://github.com/palekseym/search_engine_deploy - для деплоя приложения на stage и prod среду
- https://github.com/palekseym/search_engine_rabbitmq - для создания контейнера с rabbitmq

Настроен gitlab-ci, kubernetes, мониторинг метрик приложения и кластера kubernetes с отображением в grafana.

Pipeline для search_engine_ui и search_engine_crawler включает стадии сборки, тестов, и подготовки версии для релиза.

Pipeline для search_engine_deploy содержит стадии публикации на stage и prod окружение.

## Что Используется:
- Terraform - для создания инфраструктуры (виртуальных машин, кластер kubernetes)
- Ansible - для управления и конфигурацией виртуальнымых машинам
- Gitlab-CI - для CI/CD
- Prometheus - для сбора метрик
- Grafana - для визуализации метрик
- kubernetes - как среда запуска образов для подготовки, тестирования и публикации приложения в stage и prod

## Предварительная подготовка

### Регистрация на внешних ресурсах

Нужно зарегистрироваться на:
- http://cloud.google.com
- https://hub.docker.com
- https://github.com

### Необходимые инструменты

На рабочей машине должны быть установлены следующие инструменты:
- ansible https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
- gcloud https://cloud.google.com/sdk/docs/
- terraform https://www.terraform.io/
- kubectl https://kubernetes.io/docs/tasks/tools/install-kubectl/

Используемы версии:

<details><summary>Ansible</summary>

```
$ ansible --version

ansible 2.7.6
  python version = 2.7.15+ (default, Oct  2 2018, 22:12:08) [GCC 8.2.0]
```
</details>

<details><summary>Gcloud</summary>

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
</details>

<details><summary>Terraform</summary>

```
$ terraform --version

Terraform v0.11.11
```
</details>

<details><summary>Kubectl</summary>

```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.0", GitCommit:"0ed33881dc4355495f623c6f22e7dd0b7632b7c0", GitTreeState:"clean", BuildDate:"2018-09-27T17:05:32Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
```
</details>

### Ключ SSH

Необходимо сгенерировать ssh ключ, который будет применяться для подключения к созданным виртуальным машинам и при конфигурировании через ansible.

SSH ключ должен располагаться тут:
  - `~/.ssh/appuser` - приватный ключ
  - `~/.ssh/appuser.pub` - открытый ключ

## Создание инфраструктуры
Указать свои значения переменных в файле `terraform.tfvars.example` переименовать его в `terraform.tfvars`
Запустить создание инфраструктуры можно выполнив в корне репозитория скрипт:
```
./makemyhappy.sh
```
<details><summary>Пример реквизитов для подключения</summary>

```
Web site Gitlab-ci: http://35.193.235.156
Web site Grafana htpp://35.193.235.156:3000
Web site Prometheuse http://104.198.75.32
```

Логины и пароли:

- gitlab-ci - `root:P@ssword`
- grafana - `admin:secret`
</details>

В результате подымется:
- Gitlab-ci
- Кластер kubernetes
- Grafana
- Мониторинг на prometheus

## Создание репозиториев\проектов в Gitlab

### Содание группы
Необходимо создать группу, через веб интерфейс в gitlab, c именем аналогичным учетной записи на hub.docker.com. Имена для контейнеров будут строится по шаблону <имя_группы>/<имя_проекта>

### Создание необходимых переменных

Для того чтобы можно было пушить получившиеся образа контейнеров в hub.docker.com - необходимо на уровне группы создать переменные для аутентификации

Сделать это можно перейдя в проект и нажав Settings->CI/CD->Variables

И создать переменные:

- CI_REGISTRY_USER - логин для доступа к hub.docker.com
- CI_REGISTRY_PASSWORD - пароль для доступа к hub.docker.com

### Импорт репозиториев из github в развернутый gitlab

Сделать форк в свой профиль на github репозитории:
- https://github.com/palekseym/search_engine_rabbitmq
- https://github.com/palekseym/search_engine_deploy
- https://github.com/palekseym/search_engine_ui
- https://github.com/palekseym/search_engine_crawler

#### Создать токен в github для импорта репозиториев в gitlab

В настройка своего профиля https://github.com/settings/applications -> Developer settings -> Personal access tokens -> Generate new token
Этот токен понядобиться при импорте репозиториев в gitlab

#### Импорт репозиториев в Gitlab

При создании проекта в Gitlab есть возможность нажать Import project -> github
В появившемся списке выбрать репозитории для импорта:

- search_engine_rabbitmq
- search_engine_deploy
- search_engine_ui
- search_engine_crawler

Импортировать нужно в группу созданную ранее в gitlab <имя_группы>, на шаге `создание грауппы`

### Деплой приложения

На stage окружение можно публиковаться из pipeline'ов приложений search_engine_ui и search_engine_crawler
![reddit](https://i.imgur.com/Ma4nOz3.png)


Публиковаться на prod окружение можно после сборки всех зависимостей в проекте search_engine_deploy
![reddit](https://i.imgur.com/AQfKHUz.png)

