Lesson 9: CI/CD Pipeline для Django App in Kubernetes

Цей проект демонструє повний цикл CI/CD: від розгортання інфраструктури за допомогою Terraform до автоматичного оновлення додатків у Kubernetes через Jenkins та Argo CD.

1. Як застосувати Terraform

Усю інфраструктуру (VPC, EKS, ECR) описано модульно.

Перейдіть до директорії : cd lesson-9

Ініціалізуйте Terraform: terraform init

Перевірте план змін: terraform plan

Використовуйте конфігурацію: terraform apply

Примітка: Під час налаштування було додано політику AmazonEC2ContainerRegistryPowerUserдля IAM ролі нод кластера, щоб дозволити Jenkins-агентам (Kaniko) пушити образи в ECR.

2. Як перевірити Jenkins Job

Пайплайн налаштований як Jenkins Pipeline script from SCM .

Відкрийте Jenkins на адресу вашого LoadBalancer.

Оберіть Job lesson-9-pipeline.

У налаштуваннях ( Configure ) перевірте:

Branch Specifier: */lesson-9

Script Path: lesson-9/Jenkinsfile

Натисніть Build Now .

Етапи виконання:

Build & Push: Використовується Kaniko для складання Docker-образу без доступу до Docker Socket.

Update Helm Tag: Jenkins автоматично оновлює тег образу lesson-9/charts/django-app/values.yamlта пушить зміни назад у репозиторій.

3. Як побачити результат в Argo CD
Argo CD синхронізує стан кластера із Helm-чартом у Git.

Відкрийте інтерфейс Argo CD.

Знайдіть додаток django-app.

Після успішного завершення Jenkins Job, Argo CD побачити зміну тегу values.yaml(наприклад, з v1.0.15на v1.0.16).

Натисніть Refresh/Sync , якщо автоматична синхронізація не активована.

Перевірте статус Pods: додаток має оновитися за стратегією RollingUpdate.