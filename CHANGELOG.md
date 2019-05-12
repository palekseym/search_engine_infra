# Changelog

## 2019-05-13

### Добавлено
- Создал dashboard для отображения метрик приложения и kubernetes кластера
- Добавил шаблоны dashboard для grafana
- В скрипт установки сервиса мониторинга `kubernetes/install-monitoring.sh` добавил автоматический импорт dashboard
### Удалено
- Удалил роль `gitlab-runner` и плейбук `install-gitlab-runner` ansible для развертывания gitlab-runner, так как это перенесено на установке через helm


## 2019-05-12

### Добавлено
- Скрипт для автоматического развертывания окружения `makemyhappy.sh`
- Скрипты для установки в кластер kubernetes:
  - `kubernetes/install-gitlab_runner.sh` - установка gitlab-runner
  - `kubernetes/install-helm-to-cluster.sh` - установка helm
  - `kubernetes/install-monitoring.sh` - установка мониторинга

## 2019-05-02

### Добавлено
- Автоматичекая регистрация docker-runner в gitlab-ci
- Устновка helm в клюстер kubernetes

### Изменено
- gitlab-runner перенес внуторь kubernetes

## 2019-04-28

### Добавлено
- Ansible
  - Добавил роли:
    - `grafana` - для устновки https://grafana.com/
  - Добавил playbooks:
    - `install-grafana.yml` - для устновки роли grafana

## 2019-04-24

### Добавлено
- Ansible 
  - Добавил роли:
    - `greerlingguy.docker` - для установки докера
    - `gitlab-ci` - для установки Gitlab-CI
    - `gitlab-runner` - для установки gitlab-runner
  - Добавил playbooks:
    - `init-python.yml` - для установки python необходимый ansible
    - `install-gitlab.yml` - для установки роли gitlab-ci
    - `install-gitlab-runner.yml` - для установки роли gitlab-runner

- Добавил описание необходимых виртуальных машин с помощью Terraform.
