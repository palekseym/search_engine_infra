# Changelog

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
