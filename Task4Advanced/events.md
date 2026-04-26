# Каталог доменных событий — «Будущее 2.0»

> Событие — факт изменения состояния системы в прошлом. Неизменяемо (immutable). Публикуется в Apache Kafka в формате Avro; схема управляется через Schema Registry.
>
> **Соглашение об именовании топиков:** `{domain}.{aggregate}.{event}` — например, `clinic.patient.registered`.

---

## Clinic (Клиника)

### PatientRegistered
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `clinic.patient.registered` |
| **Контекст-источник** | Clinic |
| **Триггер** | Выполнение команды `RegisterPatient` |
| **Потребители** | Analytics Platform, Identity & Access |
| **Семантика** | Новый пациент зарегистрирован в системе впервые. Создан `MedicalRecord`. |
| **Минимальный контракт** | `patient_id: UUID`, `registered_at: ISO8601`, `source_clinic_id: UUID`, `has_snils: bool` |
| **Конфиденциальность** | ФЗ-152: ПДн; полный профиль доступен только доменным сервисам Clinic |

---

### AppointmentScheduled
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `clinic.appointment.scheduled` |
| **Контекст-источник** | Clinic |
| **Триггер** | Команда `ScheduleAppointment` |
| **Потребители** | Analytics Platform |
| **Семантика** | Запись к врачу создана и подтверждена. |
| **Минимальный контракт** | `appointment_id: UUID`, `patient_id: UUID`, `doctor_id: UUID`, `scheduled_at: ISO8601`, `clinic_id: UUID`, `specialty: string` |

---

### AppointmentCancelled
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `clinic.appointment.cancelled` |
| **Контекст-источник** | Clinic |
| **Триггер** | Команда `CancelAppointment` |
| **Потребители** | Analytics Platform |
| **Семантика** | Запись отменена. |
| **Минимальный контракт** | `appointment_id: UUID`, `cancelled_at: ISO8601`, `cancellation_reason: enum[PATIENT, DOCTOR, SYSTEM]` |

---

### VisitCompleted
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `clinic.visit.completed` |
| **Контекст-источник** | Clinic |
| **Триггер** | Команда `CompleteVisit` |
| **Потребители** | Analytics Platform, Regulatory Reporting, Fintech (если платный приём) |
| **Семантика** | Визит к врачу завершён. Диагноз поставлен. Итоги зафиксированы в `MedicalRecord`. |
| **Минимальный контракт** | `visit_id: UUID`, `patient_id: UUID`, `doctor_id: UUID`, `clinic_id: UUID`, `completed_at: ISO8601`, `icd10_codes: string[]`, `is_paid: bool`, `service_cost_rub: decimal?` |

---

### DiagnosisSet
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `clinic.visit.diagnosis-set` |
| **Контекст-источник** | Clinic |
| **Триггер** | Команда `SetDiagnosis` в рамках активного визита |
| **Потребители** | Analytics Platform, Laboratory (при диагнозах, требующих мониторинга) |
| **Семантика** | Врач установил диагноз по МКБ-10 в ходе визита. |
| **Минимальный контракт** | `visit_id: UUID`, `patient_id: UUID`, `icd10_code: string`, `diagnosis_type: enum[MAIN, CONCOMITANT]`, `set_at: ISO8601` |

---

### PrescriptionIssued
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `clinic.visit.prescription-issued` |
| **Контекст-источник** | Clinic |
| **Триггер** | Команда `IssuePrescription` |
| **Потребители** | **Pharmacy** (основной потребитель), Analytics Platform |
| **Семантика** | Врач выписал рецепт в ходе визита. Pharmacy должна создать `Prescription`. |
| **Минимальный контракт** | `prescription_id: UUID`, `visit_id: UUID`, `patient_id: UUID`, `doctor_id: UUID`, `issued_at: ISO8601`, `drugs: [{drug_code: string, dosage: string, quantity: int, is_pku: bool}]`, `valid_until: date` |
| **Конфиденциальность** | Данные о препаратах — медицинская тайна; доступ только Pharmacy и Clinic |

---

### LabTestOrdered
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `clinic.visit.lab-test-ordered` |
| **Контекст-источник** | Clinic |
| **Триггер** | Команда `OrderLabTest` |
| **Потребители** | **Laboratory** (основной потребитель) |
| **Семантика** | Врач назначил лабораторные тесты. Laboratory должна создать `LabOrder`. |
| **Минимальный контракт** | `order_id: UUID`, `visit_id: UUID`, `patient_id: UUID`, `ordered_at: ISO8601`, `tests: [{loinc_code: string, priority: enum[ROUTINE, URGENT, STAT]}]` |

---

## Laboratory (Лаборатория)

### LabOrderCreated
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `lab.order.created` |
| **Контекст-источник** | Laboratory |
| **Триггер** | Обработка события `LabTestOrdered` от Clinic |
| **Потребители** | Analytics Platform |
| **Семантика** | Лабораторный заказ принят к исполнению. |
| **Минимальный контракт** | `order_id: UUID`, `patient_id: UUID`, `created_at: ISO8601`, `lab_id: UUID`, `test_count: int` |

---

### SampleReceived
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `lab.order.sample-received` |
| **Контекст-источник** | Laboratory |
| **Триггер** | Физическое получение биоматериала и регистрация в ЛИС |
| **Потребители** | Analytics Platform |
| **Семантика** | Биологический образец получен лабораторией. |
| **Минимальный контракт** | `order_id: UUID`, `received_at: ISO8601`, `sample_type: string` |

---

### LabResultReady
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `lab.result.ready` |
| **Контекст-источник** | Laboratory |
| **Триггер** | Команда `PublishResult` после подписания лаборантом |
| **Потребители** | **Clinic** (врач должен получить уведомление), Analytics Platform, Regulatory Reporting |
| **Семантика** | Результаты всех тестов в заказе верифицированы и опубликованы. |
| **Минимальный контракт** | `result_id: UUID`, `order_id: UUID`, `patient_id: UUID`, `published_at: ISO8601`, `result_summary_url: string`, `has_critical_values: bool` |
| **Примечание** | Полные результаты не передаются в событии (чувствительные данные) — только ссылка и флаг критичности |

---

## Pharmacy (Фармация)

### PrescriptionFulfilled
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `pharmacy.prescription.fulfilled` |
| **Контекст-источник** | Pharmacy |
| **Триггер** | Команда `FulfillPrescription` |
| **Потребители** | **Fintech** (инициация платежа), Clinic, Analytics Platform |
| **Семантика** | Рецепт полностью отпущен пациенту. |
| **Минимальный контракт** | `prescription_id: UUID`, `patient_id: UUID`, `fulfilled_at: ISO8601`, `total_cost_rub: decimal`, `pharmacy_id: UUID` |

---

### DrugBackOrdered
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `pharmacy.drug.back-ordered` |
| **Контекст-источник** | Pharmacy |
| **Триггер** | Нехватка препарата на складе при попытке отпуска |
| **Потребители** | Partner Integration (инициация заказа), Analytics Platform |
| **Семантика** | Препарат отсутствует. Необходим заказ у партнёра. |
| **Минимальный контракт** | `prescription_id: UUID`, `drug_code: string`, `quantity_needed: int`, `expected_delivery_date: date?` |

---

### PharmacyOrderPlaced
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `pharmacy.order.placed` |
| **Контекст-источник** | Pharmacy |
| **Триггер** | Команда `PlacePharmacyOrder` |
| **Потребители** | Partner Integration, Analytics Platform |
| **Семантика** | Аптека разместила заказ на поставку у фарм-партнёра. |
| **Минимальный контракт** | `order_id: UUID`, `partner_id: UUID`, `placed_at: ISO8601`, `drugs: [{drug_code: string, quantity: int}]` |

---

## Fintech (Финтех)

### AccountOpened
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `fintech.account.opened` |
| **Контекст-источник** | Fintech |
| **Триггер** | Команда `OpenAccount` |
| **Потребители** | Analytics Platform, Regulatory Reporting |
| **Семантика** | Новый финансовый счёт открыт для клиента. |
| **Минимальный контракт** | `account_id: UUID`, `user_id: UUID`, `opened_at: ISO8601`, `account_type: enum[CURRENT, SAVINGS, CREDIT]`, `currency: string` |

---

### PaymentRequested
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `fintech.transaction.payment-requested` |
| **Контекст-источник** | Fintech |
| **Триггер** | Событие `PrescriptionFulfilled` (policy) или явная команда `InitiatePayment` |
| **Потребители** | Fintech (internal: обработчик платежей) |
| **Семантика** | Инициирован платёж за услугу/товар. |
| **Минимальный контракт** | `transaction_id: UUID`, `idempotency_key: UUID`, `from_account_id: UUID`, `to_account_id: UUID`, `amount_rub: decimal`, `reason: string`, `reference_id: UUID` |

---

### PaymentProcessed
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `fintech.transaction.processed` |
| **Контекст-источник** | Fintech |
| **Триггер** | Успешное завершение платёжной транзакции |
| **Потребители** | Analytics Platform, Regulatory Reporting, Clinic |
| **Семантика** | Платёж успешно завершён. Средства переведены. |
| **Минимальный контракт** | `transaction_id: UUID`, `processed_at: ISO8601`, `amount_rub: decimal`, `from_account_id: UUID`, `to_account_id: UUID`, `bank_reference: string` |

---

### PaymentFailed
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `fintech.transaction.failed` |
| **Контекст-источник** | Fintech |
| **Триггер** | Ошибка при обработке платёжной транзакции |
| **Потребители** | Clinic (уведомить о неоплате), Analytics Platform |
| **Семантика** | Платёж не прошёл. Причина зафиксирована. |
| **Минимальный контракт** | `transaction_id: UUID`, `failed_at: ISO8601`, `failure_reason: enum[INSUFFICIENT_FUNDS, BANK_REJECTION, TIMEOUT, FRAUD_DETECTED]` |

---

### CreditContractSigned
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `fintech.credit.contract-signed` |
| **Контекст-источник** | Fintech |
| **Триггер** | Команда `SignContract` |
| **Потребители** | Analytics Platform, Regulatory Reporting |
| **Семантика** | Кредитный договор подписан клиентом. Лимит активирован. |
| **Минимальный контракт** | `contract_id: UUID`, `user_id: UUID`, `signed_at: ISO8601`, `credit_limit_rub: decimal`, `rate_percent: decimal`, `term_months: int` |

---

## Partner Integration (Партнёры)

### PartnerConnected
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `partner.integration.connected` |
| **Контекст-источник** | Partner Integration |
| **Триггер** | Завершение онбординга нового партнёра |
| **Потребители** | Analytics Platform |
| **Семантика** | Новый партнёр прошёл онбординг и готов к обмену данными. |
| **Минимальный контракт** | `partner_id: UUID`, `partner_type: enum[PHARMA, MEDICAL_DEVICE, LAB_EQUIPMENT]`, `connected_at: ISO8601`, `api_version: string` |

---

### PharmaCatalogUpdated
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `partner.pharma.catalog-updated` |
| **Контекст-источник** | Partner Integration |
| **Триггер** | Получение обновлённого каталога от фарм-партнёра |
| **Потребители** | **Pharmacy** (обновление справочника препаратов) |
| **Семантика** | Каталог лекарственных препаратов партнёра обновлён. |
| **Минимальный контракт** | `partner_id: UUID`, `updated_at: ISO8601`, `changed_drugs_count: int`, `catalog_version: string` |

---

### TelemetryReceived
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `partner.device.telemetry-received` |
| **Контекст-источник** | Partner Integration |
| **Триггер** | Получение телеметрии от медицинского оборудования (MQTT → нормализация) |
| **Потребители** | Analytics Platform, Laboratory (для устройств, генерирующих результаты) |
| **Семантика** | Пакет телеметрии от устройства получен и нормализован. |
| **Минимальный контракт** | `telemetry_batch_id: UUID`, `device_id: UUID`, `partner_id: UUID`, `received_at: ISO8601`, `metrics_count: int`, `device_type: string` |

---

## Identity & Access (Идентификация)

### UserCreated
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `identity.user.created` |
| **Контекст-источник** | Identity & Access |
| **Триггер** | Команда `CreateUser` |
| **Потребители** | Analytics Platform |
| **Семантика** | Новый пользователь системы зарегистрирован. |
| **Минимальный контракт** | `user_id: UUID`, `created_at: ISO8601`, `role: string`, `domain: enum[CLINIC, LAB, PHARMACY, FINTECH, ANALYTICS, ADMIN]` |

---

### UserDeactivated
| Атрибут | Значение |
|---|---|
| **Kafka-топик** | `identity.user.deactivated` |
| **Контекст-источник** | Identity & Access |
| **Триггер** | Команда `DeactivateUser` |
| **Потребители** | Все контексты (invalidation кешей, сессий) |
| **Семантика** | Учётная запись пользователя деактивирована. Все активные сессии должны быть завершены. |
| **Минимальный контракт** | `user_id: UUID`, `deactivated_at: ISO8601`, `reason: string` |

---

## Сводная таблица событий

| # | Событие | Топик | Источник | Ключевые потребители |
|---|---|---|---|---|
| 1 | PatientRegistered | clinic.patient.registered | Clinic | Analytics |
| 2 | AppointmentScheduled | clinic.appointment.scheduled | Clinic | Analytics |
| 3 | AppointmentCancelled | clinic.appointment.cancelled | Clinic | Analytics |
| 4 | VisitCompleted | clinic.visit.completed | Clinic | Analytics, Regulatory, Fintech |
| 5 | DiagnosisSet | clinic.visit.diagnosis-set | Clinic | Analytics, Lab |
| 6 | PrescriptionIssued | clinic.visit.prescription-issued | Clinic | **Pharmacy** |
| 7 | LabTestOrdered | clinic.visit.lab-test-ordered | Clinic | **Laboratory** |
| 8 | LabOrderCreated | lab.order.created | Laboratory | Analytics |
| 9 | SampleReceived | lab.order.sample-received | Laboratory | Analytics |
| 10 | LabResultReady | lab.result.ready | Laboratory | **Clinic**, Analytics, Regulatory |
| 11 | PrescriptionFulfilled | pharmacy.prescription.fulfilled | Pharmacy | **Fintech**, Clinic, Analytics |
| 12 | DrugBackOrdered | pharmacy.drug.back-ordered | Pharmacy | Partner Integration, Analytics |
| 13 | PharmacyOrderPlaced | pharmacy.order.placed | Pharmacy | Partner Integration, Analytics |
| 14 | AccountOpened | fintech.account.opened | Fintech | Analytics, Regulatory |
| 15 | PaymentRequested | fintech.transaction.payment-requested | Fintech | Fintech (internal) |
| 16 | PaymentProcessed | fintech.transaction.processed | Fintech | Analytics, **Regulatory**, Clinic |
| 17 | PaymentFailed | fintech.transaction.failed | Fintech | Clinic, Analytics |
| 18 | CreditContractSigned | fintech.credit.contract-signed | Fintech | Analytics, Regulatory |
| 19 | PartnerConnected | partner.integration.connected | Partner Integration | Analytics |
| 20 | PharmaCatalogUpdated | partner.pharma.catalog-updated | Partner Integration | **Pharmacy** |
| 21 | TelemetryReceived | partner.device.telemetry-received | Partner Integration | Analytics, Lab |
| 22 | UserCreated | identity.user.created | Identity | Analytics |
| 23 | UserDeactivated | identity.user.deactivated | Identity | Все контексты |
