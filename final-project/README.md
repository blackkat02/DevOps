# 🗄️ RDS & Aurora Infrastructure Module

Terraform-модуль для розгортання реляційних баз даних в AWS. Підтримує два режими роботи: **стандартний Amazon RDS** (одиночний інстанс) та **Amazon Aurora Cluster** — перемикання між ними здійснюється однією змінною `use_aurora`.

## 📋 Зміст

- [Приклад використання](#-приклад-використання)
- [Опис змінних](#%EF%B8%8F-опис-змінних)
- [Як керувати модулем](#-як-керувати-модулем)
- [Ресурси, що створюються](#-ресурси-що-створюються)

## 🚀 Приклад використання

module "rds" {
  source = "./modules/rds"

  # Вибір типу БД: true — Aurora Cluster, false — Single RDS Instance
  use_aurora = false

  # Основні параметри
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password  # Мінімум 8 символів

  # Мережеві налаштування
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.cluster_primary_security_group_id

  # Конфігурація двигуна
  engine         = "postgres"
  engine_version = "15"           # Автоматично обирає останню мінорну версію
  instance_class = "db.t3.micro"
  db_family      = "postgres15"
  db_port        = 5432
}

## ⚙️ Опис змінних

| Змінна | Тип | Опис |

| `use_aurora` | `bool` | Ключовий перемикач. `true` — активує Aurora Cluster, `false` — Single RDS Instance |
| `db_name` | `string` | Назва бази даних та префікс для ресурсів AWS |
| `db_user` | `string` | Ім'я адміністратора бази даних |
| `db_password` | `string` | Пароль *(sensitive)*. Має бути не менше 8 символів |
| `vpc_id` | `string` | ID вашої VPC для створення Security Group |
| `private_subnet_ids` | `list(string)` | Список ID приватних підмереж для DB Subnet Group |
| `eks_security_group_id` | `string` | ID Security Group кластера EKS — тільки з неї дозволено вхідний трафік до БД |
| `engine` | `string` | Тип СУБД: `postgres`, `mysql`, `aurora-postgresql` тощо |
| `engine_version` | `string` | Версія двигуна. Рекомендовано вказувати мажорну версію, наприклад `"15"` |
| `instance_class` | `string` | Тип інстансу: `db.t3.micro` для dev, `db.r5.large` для prod |
| `db_family` | `string` | Сімейство Parameter Group, наприклад `postgres15` |
| `db_port` | `number` | Порт бази даних: `5432` для PostgreSQL, `3306` для MySQL |

## 🛠 Як керувати модулем

### 1. Зміна типу бази даних

За режим розгортання відповідає змінна `use_aurora`:

| Середовище | Значення | Результат |

| **Dev / Test** | `use_aurora = false` | Один інстанс RDS — мінімальна вартість |
| **Production** | `use_aurora = true` | `aws_rds_cluster` + `aws_rds_cluster_instance` — висока доступність |

### 2. Зміна версії двигуна або класу інстансу

Змініть відповідні значення у виклику модуля:

engine_version = "16"           # Оновлення мажорної версії PostgreSQL
instance_class = "db.r5.large"  # Зміна потужності інстансу

> ⚠️ **Важливо:** Зміна `engine_version` або певних параметрів у Parameter Group може потребувати перезавантаження бази даних (статус `pending-reboot`). Плануйте такі оновлення у вікні технічного обслуговування.

### 3. Налаштування Parameter Group

Модуль автоматично створює Parameter Group залежно від типу розгортання:

| `use_aurora` | Ресурс Parameter Group | Область дії |

| `false` | `aws_db_parameter_group` | Одиночний RDS-інстанс |
| `true` | `aws_rds_cluster_parameter_group` + `aws_db_parameter_group` | Весь кластер + кожен інстанс окремо |

При `use_aurora = true` обидва ресурси створюються з `count = var.use_aurora ? 1 : 0`, що гарантує застосування параметрів (зокрема `max_connections`) на рівні всього кластера, а не лише окремого інстансу.

У файлі `shared.tf` вже налаштовані базові параметри продуктивності:

| Параметр | Значення | Опис |

| `max_connections` | `100` | Максимальна кількість одночасних з'єднань |
| `log_statement` | `all` | Логування всіх SQL-запитів |
| `work_mem` | *(задано)* | Оптимізація пам'яті для сортувань та агрегацій |

Для зміни параметрів відредагуйте блок `parameter` у відповідному ресурсі в `shared.tf`.

## 🏗 Ресурси, що створюються

Незалежно від значення `use_aurora`, модуль **завжди** створює такі спільні ресурси:

| Ресурс | Призначення |

| `aws_db_subnet_group` | Ізолює базу даних у приватних підмережах VPC |
| `aws_security_group` | Дозволяє вхідний трафік на порт БД виключно з Security Group кластера EKS |
| `aws_db_parameter_group` | Налаштування параметрів продуктивності для інстансу |

Залежно від значення `use_aurora` додатково створюються:

| `use_aurora` | Ресурси |

| `false` | `aws_db_instance` — одиночний RDS-інстанс |
| `true` | `aws_rds_cluster` + `aws_rds_cluster_instance` + `aws_rds_cluster_parameter_group` |