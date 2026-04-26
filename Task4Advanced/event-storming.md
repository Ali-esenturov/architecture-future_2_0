# Event Storming — «Будущее 2.0»

> Событийный штурм (Event Storming) — техника визуализации бизнес-потоков через доменные события.  
> Документ моделирует три ключевых бизнес-сценария системы.

## Условные обозначения

| Обозначение | Тип | Описание |
|---|---|---|
| `([Событие])` | **Domain Event** (оранжевый) | Факт, произошедший в прошлом |
| `[Команда]` | **Command** (синий) | Намерение изменить состояние системы |
| `{Агрегат}` | **Aggregate** (жёлтый) | Агрегат, обрабатывающий команду и публикующий событие |
| `[[Политика]]` | **Policy / Reaction** (фиолетовый) | Автоматическая реакция на событие |
| `>Актор]` | **Actor** | Пользователь или система, инициирующие команду |
| `[(Внешняя)]` | **External System** (розовый) | Внешняя система |

---

## Сценарий 1: Визит пациента → лаборатория → фармация → оплата

Полный цикл от записи пациента до оплаты назначенного лечения.

```mermaid
flowchart LR
    classDef event fill:#FF9900,color:#000,stroke:#CC7700,rx:20
    classDef command fill:#3366FF,color:#fff,stroke:#1144CC
    classDef aggregate fill:#FFFF00,color:#000,stroke:#CCCC00
    classDef policy fill:#9933FF,color:#fff,stroke:#7711CC
    classDef actor fill:#CCCCCC,color:#000,stroke:#999
    classDef external fill:#FF6666,color:#fff,stroke:#CC3333

    A1>Врач]:::actor --> C1[ScheduleAppointment]:::command
    C1 --> AG1{Appointment}:::aggregate
    AG1 --> E1([AppointmentScheduled]):::event

    A1 --> C2[StartVisit]:::command
    C2 --> AG2{MedicalVisit}:::aggregate
    AG2 --> E2([VisitCompleted]):::event
    AG2 --> E3([DiagnosisSet]):::event
    AG2 --> E4([PrescriptionIssued]):::event
    AG2 --> E5([LabTestOrdered]):::event

    E5 --> P1[[Lab: создать заказ]]:::policy
    P1 --> C3[CreateLabOrder]:::command
    C3 --> AG3{LabOrder}:::aggregate
    AG3 --> E6([LabOrderCreated]):::event

    EXT1[(Лаб. система)]:::external --> C4[RegisterSampleReceived]:::command
    C4 --> AG3
    AG3 --> E7([SampleReceived]):::event

    EXT1 --> C5[PublishResult]:::command
    C5 --> AG4{LabResult}:::aggregate
    AG4 --> E8([LabResultReady]):::event

    E8 --> P2[[Clinic: уведомить врача]]:::policy

    E4 --> P3[[Pharmacy: принять рецепт]]:::policy
    P3 --> C6[FulfillPrescription]:::command
    C6 --> AG5{Prescription}:::aggregate
    AG5 --> E9([PrescriptionFulfilled]):::event

    E9 --> P4[[Fintech: инициировать платёж]]:::policy
    P4 --> C7[InitiatePayment]:::command
    C7 --> AG6{Transaction}:::aggregate
    AG6 --> E10([PaymentProcessed]):::event
    AG6 --> E11([PaymentFailed]):::event

    E10 --> P5[[Regulatory: зафиксировать транзакцию]]:::policy
    E10 --> P6[[Analytics: обновить дата-продукт]]:::policy
```

---

## Сценарий 2: Финтех — кредитный договор и платёжные операции

```mermaid
flowchart LR
    classDef event fill:#FF9900,color:#000,stroke:#CC7700,rx:20
    classDef command fill:#3366FF,color:#fff,stroke:#1144CC
    classDef aggregate fill:#FFFF00,color:#000,stroke:#CCCC00
    classDef policy fill:#9933FF,color:#fff,stroke:#7711CC
    classDef actor fill:#CCCCCC,color:#000,stroke:#999
    classDef external fill:#FF6666,color:#fff,stroke:#CC3333

    A2>Клиент финтех]:::actor --> C10[OpenAccount]:::command
    C10 --> AG10{Account}:::aggregate
    AG10 --> E20([AccountOpened]):::event

    A2 --> C11[ApplyCreditContract]:::command
    C11 --> AG11{CreditContract}:::aggregate
    AG11 --> E21([CreditContractSigned]):::event

    E21 --> P10[[Regulatory: уведомить ЦБ РФ]]:::policy
    E21 --> P11[[Analytics: обновить портфель]]:::policy

    A2 --> C12[InitiatePayment]:::command
    C12 --> AG12{Transaction}:::aggregate
    AG12 --> E22([PaymentRequested]):::event
    E22 --> P12[[Fintech: проверить баланс и лимиты]]:::policy
    P12 --> C13[ProcessPayment]:::command
    C13 --> AG12
    AG12 --> E23([PaymentProcessed]):::event
    AG12 --> E24([PaymentFailed]):::event

    EXT2[(Банковские сети\nМИР / SWIFT)]:::external --> C13

    E23 --> P13[[Regulatory: отчётность по транзакции]]:::policy
    E24 --> P14[[Clinic: уведомить о неоплате]]:::policy
```

---

## Сценарий 3: Интеграция партнёров — телеметрия и фарм-каталог

```mermaid
flowchart LR
    classDef event fill:#FF9900,color:#000,stroke:#CC7700,rx:20
    classDef command fill:#3366FF,color:#fff,stroke:#1144CC
    classDef aggregate fill:#FFFF00,color:#000,stroke:#CCCC00
    classDef policy fill:#9933FF,color:#fff,stroke:#7711CC
    classDef actor fill:#CCCCCC,color:#000,stroke:#999
    classDef external fill:#FF6666,color:#fff,stroke:#CC3333

    EXT3[(Медицинское\nоборудование\nMQTT)]:::external --> C20[IngestTelemetryBatch]:::command
    C20 --> AG20{DeviceTelemetry}:::aggregate
    AG20 --> E30([TelemetryReceived]):::event

    E30 --> P20[[Analytics: обогатить дата-продукт]]:::policy
    E30 --> P21[[Lab: если анализатор — обновить LabOrder]]:::policy

    EXT4[(Фарм. партнёры\nREST API)]:::external --> C21[UpdatePharmaCatalog]:::command
    C21 --> AG21{Partner}:::aggregate
    AG21 --> E31([PharmaCatalogUpdated]):::event

    E31 --> P22[[Pharmacy: синхронизировать справочник препаратов]]:::policy

    A3>Оператор]:::actor --> C22[RegisterPartner]:::command
    C22 --> AG21
    AG21 --> E32([PartnerConnected]):::event
    E32 --> P23[[Analytics: зафиксировать нового партнёра]]:::policy
```

---

## Сводная карта событий по доменам

```mermaid
graph TD
    subgraph CLINIC["Clinic"]
        direction TB
        E_C1([PatientRegistered])
        E_C2([AppointmentScheduled])
        E_C3([AppointmentCancelled])
        E_C4([VisitCompleted])
        E_C5([DiagnosisSet])
        E_C6([PrescriptionIssued])
        E_C7([LabTestOrdered])
    end

    subgraph LAB["Laboratory"]
        direction TB
        E_L1([LabOrderCreated])
        E_L2([SampleReceived])
        E_L3([LabResultReady])
    end

    subgraph PHARMACY["Pharmacy"]
        direction TB
        E_P1([PrescriptionFulfilled])
        E_P2([DrugBackOrdered])
        E_P3([PharmacyOrderPlaced])
    end

    subgraph FINTECH["Fintech"]
        direction TB
        E_F1([AccountOpened])
        E_F2([PaymentProcessed])
        E_F3([PaymentFailed])
        E_F4([CreditContractSigned])
    end

    subgraph PARTNER["Partner Integration"]
        direction TB
        E_PR1([PartnerConnected])
        E_PR2([PharmaCatalogUpdated])
        E_PR3([TelemetryReceived])
    end

    subgraph CONSUMERS["Потребители событий"]
        ANALYTICS["Analytics Platform"]
        REGULATORY["Regulatory Reporting"]
    end

    E_C6 -->|PrescriptionIssued| PHARMACY
    E_C7 -->|LabTestOrdered| LAB
    E_L3 -->|LabResultReady| CLINIC
    E_P1 -->|PrescriptionFulfilled| FINTECH
    E_P2 -->|DrugBackOrdered| PARTNER
    E_PR2 -->|PharmaCatalogUpdated| PHARMACY

    E_C4 --> ANALYTICS
    E_C4 --> REGULATORY
    E_L3 --> ANALYTICS
    E_P1 --> ANALYTICS
    E_F2 --> ANALYTICS
    E_F2 --> REGULATORY
    E_F4 --> REGULATORY
    E_PR3 --> ANALYTICS
```

---

## Ключевые политики (реакции на события)

| Событие-триггер | Политика | Действие | Исполнитель |
|---|---|---|---|
| `LabTestOrdered` | Lab: создать заказ | `CreateLabOrder` | Laboratory |
| `LabResultReady` | Clinic: уведомить врача | Push-уведомление / обновление карты | Clinic |
| `PrescriptionIssued` | Pharmacy: принять рецепт | `AcceptPrescription` | Pharmacy |
| `DrugBackOrdered` | Partner: заказать препарат | `PlacePharmacyOrder` → партнёру | Partner Integration |
| `PrescriptionFulfilled` | Fintech: инициировать платёж | `InitiatePayment` | Fintech |
| `PaymentFailed` | Clinic: уведомить о неоплате | Изменение статуса визита | Clinic |
| `PaymentProcessed` | Regulatory: зафиксировать | Добавить в отчёт ЦБ РФ | Regulatory |
| `CreditContractSigned` | Regulatory: уведомить ЦБ РФ | Отчётная форма | Regulatory |
| `PharmaCatalogUpdated` | Pharmacy: синхронизировать | Обновить локальный справочник | Pharmacy |
| `TelemetryReceived` | Analytics: обогатить | Обновить data product устройств | Analytics |
| `UserDeactivated` | Все: инвалидировать сессии | Отзыв JWT-токенов | Identity → все |
