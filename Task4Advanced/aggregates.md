# Агрегаты доменной модели — «Будущее 2.0»

> Агрегат — кластер объектов с единым корнем (Aggregate Root), изменяемый как единое целое. Все внешние обращения проходят через корень; инварианты гарантированы внутри границы агрегата.

---

## Clinic (Клиника)

### Patient
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root |
| **Идентификатор** | `patient_id: UUID` (генерируется системой при первичной регистрации) |
| **Инварианты** | — Уникальность по СНИЛС и/или паспорту<br>— Дата рождения обязательна<br>— Хотя бы один контактный канал (телефон или email)<br>— Данные хранятся в шифрованном виде (ФЗ-152) |
| **Ключевые команды** | `RegisterPatient`, `UpdateContactInfo`, `MergePatientRecords` |
| **Публикуемые события** | `PatientRegistered`, `PatientDataUpdated` |
| **Ограничение** | Медицинские записи (диагнозы, назначения) хранятся в `MedicalRecord`, не в `Patient` — разные жизненные циклы |

---

### Appointment
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root |
| **Идентификатор** | `appointment_id: UUID` |
| **Инварианты** | — Один врач не может иметь двух пересекающихся записей<br>— Время записи не может быть в прошлом<br>— Пациент должен существовать в системе (`patient_id` валиден)<br>— Статус-машина: `SCHEDULED → CONFIRMED → COMPLETED / CANCELLED` |
| **Ключевые команды** | `ScheduleAppointment`, `ConfirmAppointment`, `CancelAppointment`, `RescheduleAppointment` |
| **Публикуемые события** | `AppointmentScheduled`, `AppointmentCancelled`, `AppointmentConfirmed` |

---

### MedicalVisit
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root |
| **Идентификатор** | `visit_id: UUID` |
| **Инварианты** | — Визит привязан к существующему `Appointment` и `Patient`<br>— Статус `COMPLETED` требует хотя бы одного диагноза по МКБ-10<br>— Рецепт может быть выписан только завершённым визитом<br>— Статус-машина: `OPEN → IN_PROGRESS → COMPLETED` |
| **Ключевые команды** | `StartVisit`, `SetDiagnosis`, `IssuePrescription`, `OrderLabTest`, `CompleteVisit` |
| **Публикуемые события** | `VisitCompleted`, `DiagnosisSet`, `PrescriptionIssued`, `LabTestOrdered` |

---

### MedicalRecord
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root (долгоживущий) |
| **Идентификатор** | `patient_id: UUID` (один рекорд на пациента) |
| **Инварианты** | — Содержит историю всех визитов, диагнозов, рецептов, результатов анализов пациента<br>— Только добавление (append-only), удаление запрещено<br>— Версионирован: каждое изменение сохраняет автора и временну́ю метку |
| **Ключевые команды** | `AppendVisitSummary`, `AttachLabResult`, `UpdateDiagnosis` |
| **Публикуемые события** | `MedicalRecordUpdated` |

---

## Laboratory (Лаборатория)

### LabOrder
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root |
| **Идентификатор** | `order_id: UUID` |
| **Инварианты** | — Привязан к `visit_id` и `patient_id`<br>— Содержит хотя бы один тест<br>— Каждый тест имеет коды по классификатору (LOINC)<br>— Статус-машина: `CREATED → SAMPLE_RECEIVED → IN_PROGRESS → RESULTED` |
| **Ключевые команды** | `CreateLabOrder`, `RegisterSampleReceived`, `MarkResultReady` |
| **Публикуемые события** | `LabOrderCreated`, `SampleReceived`, `LabResultReady` |

---

### LabResult
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root (создаётся по завершении `LabOrder`) |
| **Идентификатор** | `result_id: UUID` |
| **Инварианты** | — Все тесты из `LabOrder` должны иметь результат или быть помечены как невыполненные<br>— Числовые результаты сопровождаются единицами измерения и референсными значениями<br>— Результат подписан лаборантом (user_id) |
| **Ключевые команды** | `RecordTestResult`, `SignResult`, `PublishResult` |
| **Публикуемые события** | `LabResultPublished` |

---

## Pharmacy (Фармация)

### Prescription
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root |
| **Идентификатор** | `prescription_id: UUID` |
| **Инварианты** | — Выписывается только врачом с соответствующей лицензией<br>— Срок действия не более 1 года (для обычных), 30 дней (для ПКУ-препаратов)<br>— Доза не превышает предельные нормы (справочник РЛС)<br>— Статус: `ISSUED → ACTIVE → FULFILLED / EXPIRED / CANCELLED` |
| **Ключевые команды** | `AcceptPrescription`, `FulfillPrescription`, `CancelPrescription` |
| **Публикуемые события** | `PrescriptionAccepted`, `PrescriptionFulfilled`, `PrescriptionExpired` |

---

### PharmacyOrder
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root |
| **Идентификатор** | `order_id: UUID` |
| **Инварианты** | — Создаётся при нехватке препарата в наличии<br>— Заказ размещается только у зарегистрированного Partner<br>— Статус-машина: `CREATED → CONFIRMED → SHIPPED → DELIVERED` |
| **Ключевые команды** | `PlacePharmacyOrder`, `ConfirmDelivery`, `CancelOrder` |
| **Публикуемые события** | `PharmacyOrderPlaced`, `DrugDelivered`, `DrugBackOrdered` |

---

## Fintech (Финтех)

### Account
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root |
| **Идентификатор** | `account_id: UUID`; банковский номер счёта по стандарту |
| **Инварианты** | — Баланс не может быть отрицательным (если нет кредитной линии)<br>— Счёт привязан к верифицированному `User`<br>— Состояние: `ACTIVE / FROZEN / CLOSED` |
| **Ключевые команды** | `OpenAccount`, `FreezeAccount`, `CloseAccount` |
| **Публикуемые события** | `AccountOpened`, `AccountFrozen`, `AccountClosed` |

---

### Transaction
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root (неизменяемый после завершения) |
| **Идентификатор** | `transaction_id: UUID` |
| **Инварианты** | — Сумма > 0<br>— Счёт источника должен иметь достаточный баланс<br>— Идемпотентность: повторный запрос с тем же `idempotency_key` не создаёт новую транзакцию<br>— Статус: `PENDING → PROCESSING → COMPLETED / FAILED / REVERSED` |
| **Ключевые команды** | `InitiatePayment`, `ProcessPayment`, `ReverseTransaction` |
| **Публикуемые события** | `PaymentRequested`, `PaymentProcessed`, `PaymentFailed`, `TransactionReversed` |

---

### CreditContract
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root |
| **Идентификатор** | `contract_id: UUID` |
| **Инварианты** | — Одобрен при кредитном скоре выше порогового значения<br>— Процентная ставка в диапазоне, допустимом ЦБ РФ<br>— Срок не может превышать максимальный по типу продукта<br>— Статус: `PENDING → APPROVED / REJECTED → ACTIVE → CLOSED` |
| **Ключевые команды** | `ApplyCreditContract`, `ApproveCredit`, `SignContract`, `CloseContract` |
| **Публикуемые события** | `CreditContractSigned`, `CreditContractClosed`, `CreditApplicationRejected` |

---

## Partner Integration (Партнёры)

### Partner
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root |
| **Идентификатор** | `partner_id: UUID` |
| **Инварианты** | — Тип партнёра: `PHARMA / MEDICAL_DEVICE / LAB_EQUIPMENT`<br>— Наличие подписанного API-контракта (Partner Agreement)<br>— Активный статус обязателен для обмена данными |
| **Ключевые команды** | `RegisterPartner`, `ActivatePartner`, `SuspendPartner`, `UpdatePartnerContract` |
| **Публикуемые события** | `PartnerConnected`, `PartnerSuspended` |

---

### DeviceTelemetry
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root (batch) |
| **Идентификатор** | `telemetry_batch_id: UUID` |
| **Инварианты** | — Привязан к зарегистрированному устройству и Partner<br>— Временны́е метки в пакете монотонно возрастают<br>— Пакет принимается только от активного Partner |
| **Ключевые команды** | `IngestTelemetryBatch`, `ValidateTelemetry` |
| **Публикуемые события** | `TelemetryReceived`, `TelemetryValidationFailed` |

---

## Identity & Access (Идентификация)

### User
| Атрибут | Значение |
|---|---|
| **Роль** | Aggregate Root |
| **Идентификатор** | `user_id: UUID` |
| **Инварианты** | — Уникальность по email<br>— Хотя бы одна роль назначена<br>— Пароль хранится в виде bcrypt-хеша (cost ≥ 12)<br>— Статус: `ACTIVE / SUSPENDED / DELETED` |
| **Ключевые команды** | `CreateUser`, `AssignRole`, `DeactivateUser`, `ResetPassword` |
| **Публикуемые события** | `UserCreated`, `UserDeactivated`, `RoleAssigned` |

---

## Сводная таблица агрегатов

| Агрегат | Контекст | Идентификатор | Критичность |
|---|---|---|---|
| Patient | Clinic | patient_id | Критическая (ФЗ-152) |
| Appointment | Clinic | appointment_id | Высокая |
| MedicalVisit | Clinic | visit_id | Критическая |
| MedicalRecord | Clinic | patient_id | Критическая (append-only) |
| LabOrder | Laboratory | order_id | Высокая |
| LabResult | Laboratory | result_id | Высокая |
| Prescription | Pharmacy | prescription_id | Высокая (ПКУ) |
| PharmacyOrder | Pharmacy | order_id | Средняя |
| Account | Fintech | account_id | Критическая (ЦБ РФ) |
| Transaction | Fintech | transaction_id | Критическая (идемпотентность) |
| CreditContract | Fintech | contract_id | Высокая |
| Partner | Partner Integration | partner_id | Средняя |
| DeviceTelemetry | Partner Integration | telemetry_batch_id | Низкая |
| User | Identity | user_id | Высокая |
