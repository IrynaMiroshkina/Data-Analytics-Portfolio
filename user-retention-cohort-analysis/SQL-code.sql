SELECT user_id, full_name, email, country, signup_datetime, signup_source, signup_device, promo_signup_flag
FROM project.cohort_users_raw;

SELECT event_id, user_id, event_datetime, event_type, revenue
FROM project.cohort_events_raw;

------------------------------------------------------------------------------------------------------------------------------------
---ОЧИЩЕННЯ ТА ТРАНСФОРМАЦІЯ ДАТ ДЛЯ project.cohort_users_raw
WITH cohort_users AS
    ( SELECT user_id, 
             full_name, 
             LOWER(email), 
             country, 
             signup_datetime,
             CASE 
                 -- Перевірка на порожнє значення або пробіли
                 WHEN signup_datetime IS NULL OR TRIM(signup_datetime) = '' THEN NULL
	             -- Якщо рік має 4 цифри (2025)
                 WHEN SPLIT_PART(TRIM(signup_datetime), ' ', 1) ~ '\d{4}$' 
                      THEN TO_TIMESTAMP(REGEXP_REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '[/.]', '-', 'g'), 'DD-MM-YYYY')
                 -- Якщо рік має 2 цифри (25)
                 ELSE TO_TIMESTAMP(REGEXP_REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '[/.]', '-', 'g'), 'DD-MM-YY')
             END AS signup_date,
             signup_source, 
             signup_device,      
             promo_signup_flag
     FROM project.cohort_users_raw
    )
SELECT *     
FROM cohort_users;

---ОЧИЩЕННЯ ТА ТРАНСФОРМАЦІЯ ДАТ ДЛЯ project.cohort_events_raw
WITH cohort_events AS
    ( SELECT event_id,    
             user_id, 
             event_datetime,
             CASE 
                 -- Перевірка на порожнє значення або пробіли
                 WHEN event_datetime IS NULL OR TRIM(event_datetime) = '' THEN NULL
	             -- Якщо рік має 4 цифри (2025)
                 WHEN SPLIT_PART(TRIM(event_datetime), ' ', 1) ~ '\d{4}$' 
                      THEN TO_TIMESTAMP(REGEXP_REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '[/.]', '-', 'g'), 'DD-MM-YYYY')
                 -- Якщо рік має 2 цифри (25)
                 ELSE TO_TIMESTAMP(REGEXP_REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '[/.]', '-', 'g'), 'DD-MM-YY')
             END AS event_date,
             NULLIF(TRIM(event_type), '') AS event_type, 
             revenue
     FROM project.cohort_events_raw
    )
SELECT *     
FROM cohort_events;

--------------------------------------------------------------------------
/*Замість того, щоб прописувати громіздкий блок CASE-WHEN-ELSE у кожному запиті, 
створимо функцію, яка буде виконувати очищення дати. Вхідними даними для функції
будуть "брудні" значення дати-часу raw_datetime (тип TEXT). Функція буде повертати 
дату (тип DATE) у форматі SQL YYYY-MM-DD.
Перед іменем функції вкажемо префікс public. У PostgreSQL назва схеми перед назвою функції
(наприклад, public.clear_date) відіграє роль "адреси" і вказує на місце зберігання об'єкта.
У нашому проекті робоча схема project є захищеною від запису (Error 42501). 
Схема public доступна для всіх користувачів бази, що дозволило створити функцію саме в ній.
Функції в схемі public видимі для запитів до будь-яких інших схем. Це означає, що їх можна 
використовувати як для таблиць схеми project., так і для будь-яких інших майбутніх таблиць 
у цій базі.
Можна додати, що використання функції створює єдине правило обробки даних. 
Якщо потрібно буде додати ще один формат з іншим роздільником дати (наприклад, дата з двокрапками),
тоді не доведеться шукати всі SQL-запити по всьому проекту. Достатньо змінити логіку лише в одному місці
— всередині функції public.clear_date, і всі звіти оновляться автоматично.
 */

CREATE OR REPLACE FUNCTION public.clear_date(raw_datetime TEXT)
RETURNS DATE 
AS $$
    SELECT CASE 
               -- Перевірка на порожнє значення або пробіли
               WHEN raw_datetime IS NULL OR TRIM(raw_datetime) = '' THEN NULL
               -- Якщо рік має 4 цифри (2025)
               WHEN SPLIT_PART(TRIM(raw_datetime), ' ', 1) ~ '\d{4}$' 
                    THEN TO_TIMESTAMP(REGEXP_REPLACE(SPLIT_PART(TRIM(raw_datetime), ' ', 1), '[/.]', '-', 'g'), 'DD-MM-YYYY')
               -- Якщо рік має 2 цифри (25)
               ELSE TO_TIMESTAMP(REGEXP_REPLACE(SPLIT_PART(TRIM(raw_datetime), ' ', 1), '[/.]', '-', 'g'), 'DD-MM-YY')
           END
$$ LANGUAGE sql;
/*
Для об'єднання таблиць використуємо LEFT JOIN, де лівою (першою) таблицею буде основна таблиця з користувачами (cohort_users).
Це можна аргументувати тим, що у когортному аналізі ми завжди йдемо від користувача до його дій.
В таблиці cohort_users кожний рядок — це унікальна людина.
Права (друга) таблиця cohort_events містить історію активності.
У одного користувача може бути 0 подій (зареєструвався і пішов), а може бути 100. Використання LEFT JOIN дозволить не загубити користувачів без подій.
Для розрахунку метрик нам важливо бачити всіх, хто зареєструвався.
 */
/*
cohort_base_table
 */
WITH cohort_users AS
     (SELECT user_id,
	         full_name,
	         LOWER(email) AS email,
	         country,
	         signup_datetime,
	         public.clear_date(signup_datetime) AS signup_date,-- функція зробила код красивим
	         signup_source, 
             signup_device,      
             promo_signup_flag
      FROM project.cohort_users_raw
     ), 
     cohort_events AS
     (SELECT event_id,    
             user_id, 
             event_datetime,
             public.clear_date(event_datetime) AS event_date,
             NULLIF(TRIM(event_type), '') AS event_type, 
             revenue
      FROM project.cohort_events_raw
     ),
     join_table AS 
     (SELECT u.user_id,
             u.full_name,
             u.email,
             u.country,
             DATE_TRUNC('month', u.signup_date) AS signup_month,
             u.signup_source, 
             u.signup_device,      
             u.promo_signup_flag,
             e.event_id,
             DATE_TRUNC('month', e.event_date) AS event_month,
             e.event_type, 
             e.revenue
      FROM cohort_users u
           LEFT JOIN cohort_events e ON u.user_id = e.user_id
     ),
     cohort_base_table AS 
     (SELECT user_id,
             full_name,
             email,
             country,
             signup_month,
             signup_source, 
             signup_device,      
             promo_signup_flag,
             event_id,
             event_month,
             EXTRACT(MONTH FROM AGE(event_month, signup_month)) AS month_offset,
             event_type, 
             revenue
      FROM join_table  
      WHERE (signup_month IS NOT NULL) AND (event_month IS NOT NULL)
            AND (event_type IS NOT NULL) AND (event_type != 'test_event')
      )
SELECT promo_signup_flag,
       signup_month::DATE AS cohort_month,
       month_offset,
       COUNT(DISTINCT user_id) AS users_total
FROM cohort_base_table
WHERE (signup_month::DATE BETWEEN '2025-01-01' AND '2025-06-01')
      AND (event_month::DATE  BETWEEN '2025-01-01' AND '2025-06-01')
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;
