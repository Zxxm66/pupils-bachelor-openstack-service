# pupils-bachelor-openstack-service

Учебный FastAPI-сервис для определения студентов, которые могут стать бакалаврами. Разработан в рамках лабораторной работы по дисциплине «Облачные технологии (OpenStack)».

## Структура проекта

```
pupils-bachelor-openstack-service/
├── app.py                         # FastAPI приложение
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
    ├── namespace.yaml
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
| GET | `/` | Информация о сервисе |
| GET | `/health` | Проверка состояния сервиса |
| GET | `/students` | Все студенты |
| GET | `/student/{name}` | Один студент по имени |
| GET | `/bachelor` | Кандидаты на бакалавра |

Документация Swagger доступна на `/docs`.

---

## Пошаговая инструкция (для отчёта со скриншотами)

### 1. Запуск локально

```bash
pip install -r requirements.txt
python app.py
```

Открой в браузере `http://127.0.0.1:8000/docs` — это и есть скриншот Swagger UI.

### 2. Сборка Docker-образа

```bash
docker build -t pupils-bachelor-openstack-service .
```

### 3. Запуск контейнера локально

```bash
docker run -d -p 8000:8000 --name pupils-bachelor pupils-bachelor-openstack-service
docker ps
```

### 4. Проверка API в контейнере

```powershell
curl.exe http://127.0.0.1:8000/health
curl.exe http://127.0.0.1:8000/bachelor
```

### 5. Публикация образа в Docker Hub

```bash
docker login
docker tag pupils-bachelor-openstack-service DOCKERHUB_USERNAME/pupils-bachelor-openstack-service:latest
docker push DOCKERHUB_USERNAME/pupils-bachelor-openstack-service:latest
```

Зайди на `https://hub.docker.com/repositories/DOCKERHUB_USERNAME` — увидишь опубликованный образ.

### 6. Деплой в OpenStack через Terraform

```bash
cd terraform-openstack
cp terraform.tfvars.example terraform.tfvars
# заполнить terraform.tfvars данными доступа к OpenStack

terraform init
terraform plan
terraform apply
```

После `apply` Terraform выведет `public_ip` и `service_url` — публичный IP созданной VM с уже запущенным контейнером.

```bash
terraform state list
terraform output
```

### 7. Проверка инстанса в OpenStack Dashboard (Horizon)

Зайди в веб-интерфейс OpenStack → Проект → Вычислительные ресурсы → Инстансы — там будет видна созданная VM со статусом "Активен" и публичным IP.

### 8. Проверка API по публичному IP

```powershell
curl.exe http://PUBLIC_IP:8000/health
curl.exe http://PUBLIC_IP:8000/bachelor
```

### 9. Проверка контейнера на самой VM

```bash
ssh ubuntu@PUBLIC_IP
sudo docker ps
sudo docker logs pupils-bachelor
```

### 10. Деплой в Kubernetes (например, через minikube)

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

kubectl rollout status deployment/pupils-bachelor-deployment -n pupils-bachelor
kubectl get pods -n pupils-bachelor
kubectl get svc -n pupils-bachelor
kubectl get endpoints -n pupils-bachelor
```

### 11. Проверка через port-forward

```bash
kubectl port-forward svc/pupils-bachelor-service -n pupils-bachelor 8000:8000
curl http://127.0.0.1:8000/bachelor
```

### 12. Удаление ресурсов после демонстрации

```bash
terraform destroy
kubectl delete namespace pupils-bachelor
docker rm -f pupils-bachelor
```

## Формат данных студента

```json
{
  "name": "Ivan Petrov",
  "course": 4,
  "grade": 5,
  "attended_labs": 90,
  "specialization": "Protected Automated Systems"
}
```
