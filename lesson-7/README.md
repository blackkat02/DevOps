# Lesson 7: Deployment of Django App to AWS EKS using Terraform and Helm

Цей проект реалізує повний цикл розгортання веб-застосунку в хмарі AWS з використанням підходу Infrastructure as Code (Terraform) та менеджеру пакетів Helm.

## 🏗 Що було зроблено:

1. **Infrastructure (Terraform):**
   - Створено VPC з публічними та приватними підмережами.
   - Розгорнуто кластер **Amazon EKS** (версія 1.31) з однією керованою групою нод (`t3.small`).
   - Створено репозиторій **Amazon ECR** для зберігання Docker-образів.
2. **CI/CD & Docker:**
   - Docker-образ Django-застосунку адаптовано для Production (заміна `runserver` на `gunicorn`).
   - Образ зібрано, теговано та завантажено до ECR.
3. **Orchestration (Helm):**
   - Створено кастомний Helm-чарт `django-app`.
   - Реалізовано **Deployment** з 2 репліками та **Horizontal Pod Autoscaler (HPA)**.
   - Налаштовано **Service (LoadBalancer)** для зовнішнього доступу.
   - Конфігурацію (ENV) винесено в **ConfigMap** та **Secrets**.

##  Команди для запуску

### 1. Розгортання інфраструктури

```bash
terraform init
terraform apply -auto-approve

### 2. Авторизація в ECR та Push образу

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com
docker build -t lesson-7-ecr ./app
docker tag lesson-7-ecr:latest <YOUR_ACCOUNT_ID>[.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr:latest](https://.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr:latest)
docker push <YOUR_ACCOUNT_ID>[.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr:latest](https://.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr:latest)

### 3. Деплой застосунку через Helm

aws eks update-kubeconfig --region us-west-2 --name django-cluster
helm install django-app ./charts/django-app

### 4. Моніторинг

Перевірка статусів подів: kubectl get pods

Отримання адреси застосунку: kubectl get svc django-app

Стан автоскейлінгу: kubectl get hpa

Note: Проект створено у навчальних цілях. Паролі values.yaml залишено відкрито як демонстрацію роботи з Secret-ресурсами (у реальному проекті використовуються --set або Secrets Manager). 


Посилання на фінальні скріншоти AWS та WSL https://docs.google.com/document/d/1NsGb0xeRPVxPyfT7xJNwH1MSxqweHTJFmEP3dbWGeBI/edit?tab=t.0