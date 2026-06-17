# pupils-bachelor-openstack-service

REST-сервис на Flask для отбора студентов, претендующих на получение диплома бакалавра. Разработан в рамках лабораторной работы по дисциплине «Облачные технологии (OpenStack)».

## Структура проекта

```
pupils-bachelor-openstack-service/
├── app.py                         # Flask REST API
├── students.json                  # База данных студентов
├── requirements.txt               # Зависимости Python
├── Dockerfile                     # Контейнеризация приложения
├── .dockerignore
├── .gitignore
├── DEFENSE.md                     # Гайд по защите
├── screenshots/                   # Скриншоты демонстрации
├── terraform-openstack/           # IaC для OpenStack
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── k8s/                           # Kubernetes манифесты
    ├── deployment.yaml
    └── service.yaml
```

## Условия отбора (`/bachelor`)

| Поле | Условие | Описание |
|------|---------|----------|
| `grade` | `>= 4` | Средний балл не ниже 4 |
| `course` | `>= 3` | Курс обучения — 3-й или выше |
| `attended_labs` | `>= 75` | Посещаемость лабораторных — 75% и выше ✨ |

> **Добавленное условие:** `attended_labs >= 75` — студент с высоким баллом, но систематически пропускающий практику, не допускается к защите диплома.

## API

| Метод | Эндпоинт | Описание |
|-------|----------|----------|
| GET | `/students` | Все студенты |
| GET | `/bachelor` | Кандидаты на бакалавра |
| GET | `/health` | Проверка состояния сервиса |

## Запуск

### Локально

```bash
pip install -r requirements.txt
python app.py
# Сервис доступен на http://localhost:5000
```

### Docker

```bash
docker build -t bachelor-service .
docker run -d -p 5000:5000 bachelor-service
```

### Проверка

```bash
curl http://localhost:5000/health
curl http://localhost:5000/students
curl http://localhost:5000/bachelor
```

## Деплой в OpenStack через Terraform

```bash
cd terraform-openstack
cp terraform.tfvars.example terraform.tfvars
# заполнить terraform.tfvars своими данными OpenStack

terraform init
terraform plan
terraform apply
```

Terraform автоматически создаёт: сеть, подсеть, роутер, security group, VM с Ubuntu, floating IP и запускает Docker-контейнер на VM.

```bash
# Удалить все ресурсы
terraform destroy
```

## Kubernetes

```bash
cd k8s
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

kubectl get pods
kubectl get services
```

Деплоится 2 реплики с health check'ами (`/health`).

## Формат данных студента

```json
{
  "id": 1,
  "name": "Иванов Иван Иванович",
  "course": 4,
  "grade": 4.5,
  "attended_labs": 90
}
```
