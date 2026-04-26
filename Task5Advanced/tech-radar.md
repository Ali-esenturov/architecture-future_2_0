# Технический радар — «Будущее 2.0»

> Статусы: **Adopt** — применять сейчас · **Trial** — проверить в проекте · **Assess** — изучить · **Hold** — не использовать / выводить

---

## Платформы и инфраструктура

| Технология | Статус | Обоснование |
|---|---|---|
| Apache Kafka (Managed) | **Adopt** | Целевая шина событий. Yandex Managed Kafka снижает операционную нагрузку. |
| Kubernetes (Managed K8s) | **Adopt** | Стандарт оркестрации. Горизонтальное масштабирование доменных сервисов. |
| ClickHouse | **Adopt** | OLAP-хранилище для near-real-time аналитики. Высокая скорость агрегаций. |
| PostgreSQL | **Adopt** | Оперативные БД доменных сервисов (Clinic, Fintech, Pharmacy). |
| Yandex Cloud (Object Storage, VPC, IAM) | **Adopt** | Основной облачный провайдер. Соответствие ФЗ-152 и требованиям ЦБ РФ. |
| Apache Flink | **Trial** | Потоковая обработка событий для real-time метрик. Проверить на пилоте Analytics. |
| Apache Iceberg (Data Lakehouse) | **Assess** | Перспективный формат для долгосрочного хранения исторических событий. |
| SQL Server 2008 | **Hold** | Выходит из эксплуатации. End-of-support с 2019 г. Миграция — приоритет 1. |

---

## Инструменты и практики

| Технология / Инструмент | Статус | Обоснование |
|---|---|---|
| Terraform | **Adopt** | IaC для всей облачной инфраструктуры. Remote state в Yandex Object Storage. |
| GitHub Actions | **Adopt** | CI/CD пайплайны. Plan-on-PR + apply-on-approval (см. Task2Advanced). |
| Confluent Schema Registry (Avro) | **Adopt** | Обязательно для управления схемами событий. Backward-compatibility enforcement. |
| Grafana + Prometheus | **Adopt** | Мониторинг Kafka consumer lag, SLO доменных сервисов. |
| dbt (data build tool) | **Trial** | Трансформации данных в аналитических витринах. Заменяет ручные SQL ETL-скрипты. |
| OpenTelemetry | **Trial** | Distributed tracing для отладки цепочек событий между доменами. |
| MLflow | **Assess** | Платформа для ML-экспериментов (AI-диагностика). Оценить при запуске AI-домена. |
| Apache Camel ESB | **Hold** | Временный Legacy Adapter. Полностью вывести к концу Этапа 2. |
| PowerBuilder | **Hold** | UI клиник. Заменить на React/Vue в рамках миграции Clinic Domain. |

---

## Архитектурные паттерны

| Паттерн | Статус | Обоснование |
|---|---|---|
| Event-Driven Architecture (EDA) | **Adopt** | Целевой стиль интеграции всех доменов через Kafka. |
| Domain-Driven Design (DDD) | **Adopt** | Основа декомпозиции системы. Bounded contexts, агрегаты, события. |
| Strangler Fig (миграция DWH) | **Adopt** | Постепенная замена DWH без остановки бизнеса. Новые функции — только в новых сервисах. |
| Anti-Corruption Layer (ACL) | **Adopt** | Для изоляции legacy ESB/DWH и внешних партнёров. |
| CQRS | **Adopt** | Read/Write разделение для финтех-операций с предсказуемой задержкой. |
| Data Mesh | **Trial** | Доменное владение данными. Pilot: Clinic Domain как первый Data Product Owner. |
| Self-service BI | **Trial** | Портал аналитиков поверх ClickHouse + Data Products. Проверить спрос бизнеса. |
| Blue/Green Deployment | **Adopt** | Безопасный rollout критических сервисов (клиники 24/7). |
| Batch ETL (ночные джобы) | **Hold** | Заменяется потоковой обработкой (Kafka + Flink). Допустим только для архивных задач. |
| Stored procedures как бизнес-логика | **Hold** | Бизнес-логика переносится в доменные сервисы. Хранимые процедуры — только для миграции. |
