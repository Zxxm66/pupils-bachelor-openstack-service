# Гайд по защите лабораторной работы

## Что нужно показать и рассказать

### 1. Архитектура проекта
- FastAPI REST API (`app.py`) — сервис отбора студентов-бакалавров, со встроенной Swagger-документацией (`/docs`)
- Docker — контейнеризация приложения
- Docker Hub — хранение готового образа
- OpenStack — облачная инфраструктура для деплоя
- Terraform — автоматизация создания инфраструктуры в OpenStack
- Kubernetes — оркестрация контейнеров

---

### 2. Запуск и демонстрация локально

```bash
pip install -r requirements.txt
python app.py
```

Открой `http://127.0.0.1:8000/docs` — это Swagger UI со списком всех эндпоинтов.

#### Проверка эндпоинтов
```bash
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/students
curl http://127.0.0.1:8000/bachelor
```

---

### 3. Объяснение условий отбора (`/bachelor`)

**Оригинальные условия:**
- `grade >= 4` — средний балл не ниже 4
- `course >= 3` — курс 3 или выше

**Добавленное условие:**
- `attended_labs >= 75` — посещаемость лабораторных занятий не менее 75%

> **Обоснование:** Студент с высоким баллом, но систематически пропускающий практические занятия, не должен быть допущен к защите диплома. Порог 75% — стандартный минимум посещаемости в большинстве вузов.

---

### 4. Docker — сборка и публикация

```bash
docker build -t pupils-bachelor-openstack-service .
docker run -d -p 8000:8000 --name pupils-bachelor pupils-bachelor-openstack-service
docker ps

docker login
docker tag pupils-bachelor-openstack-service DOCKERHUB_USERNAME/pupils-bachelor-openstack-service:latest
docker push DOCKERHUB_USERNAME/pupils-bachelor-openstack-service:latest
```

---

### 5. Terraform — создание инфраструктуры в OpenStack

```bash
cd terraform-openstack
cp terraform.tfvars.example terraform.tfvars
# отредактировать terraform.tfvars

terraform init
terraform plan
terraform apply
```

**Что создаёт Terraform:**
- Security group с правилами для SSH (22) и сервиса (8000)
- Сеть и подсеть
- Роутер с выходом в публичную сеть
- VM с Ubuntu (flavor `m1.small`)
- SSH keypair
- Floating IP для доступа извне
- Автоматический запуск Docker-контейнера через `user_data`

```bash
terraform state list
terraform output
```

После — удалить ресурсы:
```bash
terraform destroy
```

---

### 6. Kubernetes — оркестрация

```bash
cd k8s
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

kubectl rollout status deployment/pupils-bachelor-deployment -n pupils-bachelor
kubectl get pods -n pupils-bachelor
kubectl get svc -n pupils-bachelor
kubectl get endpoints -n pupils-bachelor
```

Проверка через port-forward:
```bash
kubectl port-forward svc/pupils-bachelor-service -n pupils-bachelor 8000:8000
curl http://127.0.0.1:8000/bachelor
```

**Что делают манифесты:**
- `namespace.yaml` — изолированное пространство имён `pupils-bachelor`
- `deployment.yaml` — 2 реплики сервиса с health check'ами
- `service.yaml` — NodePort для доступа к сервису

---

### 7. Возможные вопросы на защите

**Q: Зачем нужен Docker?**
A: Изолирует приложение и его зависимости. Гарантирует одинаковое поведение на любой машине и в облаке.

**Q: Зачем публиковать образ в Docker Hub?**
A: Чтобы VM в OpenStack могла скачать готовый образ командой `docker pull`, не пересобирая его на сервере.

**Q: Чем Terraform лучше ручного создания ресурсов в OpenStack?**
A: Инфраструктура описана как код (IaC) — версионируется, воспроизводима, легко удаляется. `terraform destroy` — и все ресурсы удалены, нет утечки ресурсов в облаке.

**Q: Зачем Kubernetes, если есть один контейнер?**
A: K8s обеспечивает масштабирование (replicas), автоматический перезапуск при падении (liveness probe), балансировку нагрузки.

**Q: Почему порог посещаемости 75%?**
A: Это стандартный минимум допуска к зачёту/экзамену. Пропуск более 25% занятий означает пробелы в практических навыках.

**Q: Что вернёт `/bachelor`, если нет подходящих студентов?**
A: Вернёт `total_candidates: 0` и пустой массив `candidates: []`.
