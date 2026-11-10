# Использование Terraform в команде

Выполнил Сергеев Антон. Terraform 1.12.0.

Ветка `terraform-04` сохраняет исходный коммит ДЗ 4 `7dc042d`. От неё создана `terraform-05`. Предыдущий отчёт доступен в ветке `terraform-04`.

## Задания 0–1

В первом сообщении сразу формулируйте запрос и давайте контекст, чтобы коллега мог ответить без дополнительного ожидания. [«Не привет»](https://neprivet.com/).

Проверены `04/src` и `04/demonstration1` без `terraform init`. Типы замечаний без дублей:

| Тип | Правила |
| --- | --- |
| Для провайдера не указан диапазон версий | TFLint `terraform_required_providers` |
| Переменная объявлена и не используется | TFLint `terraform_unused_declarations` |
| Удалённый модуль ссылается на изменяемую ветку `main` вместо фиксированной версии | TFLint `terraform_module_pinned_source`, Checkov `CKV_TF_1` и `CKV_TF_2` |

В `04/src` Checkov 3.4.3 не нашёл применимых проверок. В `04/demonstration1` обе проверки фиксации версии сработали на каждом из двух модулей. [Вывод аудита](evidence/upstream-audit.txt).

## Задание 2. S3 и блокировка

Создан приватный бакет Object Storage с версионированием. Отдельный сервисный аккаунт получил READ и WRITE через ACL этого бакета. Ключ S3 хранится во внешнем профиле AWS. [Настройки бакета](evidence/settings.png), [объект state](evidence/objects.png), [вывод YC CLI](evidence/bucket-settings.txt).

Для воспроизведения настройте свой приватный бакет и профиль, заполните имя бакета в `backend.s3.tfbackend` и перенесите параметры облака в `personal.auto.tfvars` из `terraform.tfvars.example`. Провайдер Yandex использует отдельный авторизованный ключ для чтения данных облака.

```bash
cp backend.s3.tfbackend.example backend.s3.tfbackend
cp terraform.tfvars.example personal.auto.tfvars
export AWS_PROFILE=terraform-05
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.config/terraform-team/credentials"
export TF_CLI_CONFIG_FILE="$PWD/.terraformrc"
terraform init -migrate-state -backend-config=backend.s3.tfbackend
terraform state list
```

В ДЗ 4 инфраструктура уже была удалена. Для миграции в локальном backend создан `terraform_data.backend_probe` через `terraform apply -target=terraform_data.backend_probe`. ID маркера совпал в локальной копии и удалённом state. [Скриншот миграции](evidence/migration.png), [журнал](evidence/state-migration.txt).

Файловая блокировка S3 появилась в Terraform 1.10. Объект блокировки для этого backend называется `terraform.tfstate.tflock`. [Релиз Terraform 1.10](https://github.com/hashicorp/terraform/releases/tag/v1.10.0), [документация S3 backend](https://developer.hashicorp.com/terraform/language/backend/s3).

```bash
# Терминал 1, удерживает lock
terraform console
# Терминал 2, тот же каталог
terraform apply -target=terraform_data.backend_probe -lock-timeout=0s -input=false
terraform force-unlock -force <LOCK_ID>
```

`apply` вернул `Error acquiring the state lock` и HTTP 412. После `force-unlock` первая консоль завершена, а повторный целевой план захватил блокировку и показал `No changes`. В командной работе принудительное снятие допустимо для блокировки, чей владелец больше не выполняет операцию. [Скриншот](evidence/lock.png), [ошибка](evidence/state-lock.txt), [снятие блокировки](evidence/force-unlock.txt).

## Задание 3. Hotfix

Исправления и результаты проверки находятся в ветке `terraform-hotfix`. Pull request направлен в `terraform-05`. Полный план оценивает конфигурацию ДЗ 4 с текущим state. Для проверки backend использован только локальный маркер Terraform.

## Задание 4. Валидация IP

`validation/variables.tf` проверяет отдельный IP через `can(cidrhost(...))`, а список через `alltrue` по всем элементам. Скрипт проверяет корректные defaults и подставляет по одному ошибочному default в временной копии.

```bash
bash validation/check-defaults.sh
```

Terraform Console выводит диагностику `Invalid value for variable` для обоих неверных defaults. Скрипт проверяет именно текст диагностики, поскольку консоль может завершиться с кодом 0. [Скриншот](evidence/validation.png), [вывод](evidence/ip-validation.txt).

Снимки CLI показывают фактический вывод команд в локальном просмотрщике.
