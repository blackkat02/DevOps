# 1. Використовуємо офіційний образ Python (версія 3.12-slim для економії місця)
FROM python:3.12-slim

# 2. Налаштовуємо змінні середовища, щоб Python не створював .pyc і лог йшов одразу в консоль
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 3. Встановлюємо робочу директорію всередині контейнера
WORKDIR /app

# 4. Встановлюємо системні залежності для PostgreSQL (якщо знадобляться для psycopg2)
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 5. Копіюємо requirements.txt та встановлюємо залежності
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# 6. Копіюємо весь код нашого проекту
COPY . /app/

# 7. Запускаємо сервер (використовуємо 0.0.0.0, щоб порт був доступний ззовні)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]