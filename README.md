# Centro de Salud — Skill MySQL I

Base de datos para almacenar y gestionar la información de **médicos, empleados y pacientes** de un centro de salud: personal médico (titulares, interinos y sustitutos) con sus horarios de consulta, sustituciones, vacaciones (planificadas y disfrutadas) y la relación de cada paciente con su médico asignado.

## Contenido del repositorio

| Archivo | Descripción |
|---|---|
| `estructura.sql` | Crea la base de datos `centro_salud`, las tablas, llaves primarias y foráneas. Ejecutable en MySQL sin errores. |
| `datos.sql` | Inserta datos de prueba realistas suficientes para que las 10 consultas devuelvan resultados. |
| `README.md` | Este documento: modelo de datos, pasos de ejecución y las 10 consultas con su explicación. |

## Cómo ejecutar

Requiere **MySQL 8.x** (se usan restricciones `CHECK`, que MySQL sí aplica desde la versión 8).

Desde la terminal:

```bash
mysql -u root -p < estructura.sql
mysql -u root -p < datos.sql
```

O dentro del cliente de MySQL / Workbench, ejecutando primero `estructura.sql` y luego `datos.sql`.

Después ya se pueden correr las consultas de la sección final sobre la base `centro_salud`.


### Tablas

- **persona** — datos comunes de toda persona del sistema.
- **medico** — `especialidad` y `tipo` (`titular` / `interino` / `sustituto`). PK/FK hacia `persona`.
- **empleado** — `cargo` (`ATS` / `auxiliar de enfermería` / `celador` / `administrativo`) y `turno`. PK/FK hacia `persona`.
- **horario_consulta** — franja de consulta de un médico: `dia_semana`, `hora_inicio`, `hora_fin`. Un médico puede tener varias filas (varios días).
- **sustitucion** — un `medico_sustituto` cubre a un `medico_sustituido` en un periodo (`fecha_inicio`–`fecha_fin`). Cada sustitución es una fila; un sustituto puede cubrir a varios médicos.
- **paciente** — datos del paciente y su `medico_asignado`.
- **vacaciones** — periodo de vacaciones de una `persona`, con `estado` (`planificada` / `disfrutada`).

Se añadieron `CHECK` para validar rangos (`hora_fin > hora_inicio`, `fecha_fin >= fecha_inicio`), además de índices sobre las claves foráneas más consultadas.

---

# Consultas

### 1. Número de pacientes atendidos por cada médico

Cuenta, por cada médico, cuántos pacientes lo tienen asignado. Se usa `LEFT JOIN` para incluir también a los médicos con 0 pacientes.

```sql
SELECT  pe.documento, pe.nombre, pe.apellidos,
        COUNT(pa.documento) AS num_pacientes
FROM medico m
JOIN persona pe        ON pe.documento = m.documento
LEFT JOIN paciente pa  ON pa.medico_asignado_documento = m.documento
GROUP BY pe.documento, pe.nombre, pe.apellidos
ORDER BY num_pacientes DESC;
```

### 2. Número de médicos que están actualmente en sustitución

Médicos que hoy están **siendo cubiertos**: existe una sustitución donde figuran como `medico_sustituido` y la fecha de hoy cae dentro del periodo. Se cuentan sin repetir con `DISTINCT`.

```sql
SELECT COUNT(DISTINCT s.medico_sustituido_documento) AS medicos_en_sustitucion
FROM sustitucion s
WHERE CURDATE() BETWEEN s.fecha_inicio AND s.fecha_fin;
```

### 4. Médicos que actualmente están realizando una sustitución

El lado contrario a la consulta 2: médicos que hoy figuran como `medico_sustituto` en un periodo vigente. `DISTINCT` evita duplicados si cubren a varios a la vez.

```sql
SELECT DISTINCT pe.documento, pe.nombre, pe.apellidos, m.especialidad
FROM sustitucion s
JOIN medico m    ON m.documento = s.medico_sustituto_documento
JOIN persona pe  ON pe.documento = m.documento
WHERE CURDATE() BETWEEN s.fecha_inicio AND s.fecha_fin;
```

### 5. Médicos con mayor cantidad de horas de consulta en la semana

Suma la duración de todas las franjas de cada médico. Con `TIMEDIFF` se obtiene la diferencia entre horas y con `TIME_TO_SEC(...) / 3600` se convierte a horas. Se ordena de mayor a menor.

```sql
SELECT  pe.documento, pe.nombre, pe.apellidos,
        SUM(TIME_TO_SEC(TIMEDIFF(hc.hora_fin, hc.hora_inicio))) / 3600 AS horas_semana
FROM medico m
JOIN persona pe          ON pe.documento = m.documento
JOIN horario_consulta hc ON hc.medico_documento = m.documento
GROUP BY pe.documento, pe.nombre, pe.apellidos
ORDER BY horas_semana DESC;
```

> Para quedarse solo con el máximo, añade `LIMIT 1` (o compara contra el `MAX` en una subconsulta si puede haber empates).

### 6. Horas totales de consulta por médico por día de la semana

Igual que la anterior, pero agrupando además por `dia_semana`, de modo que cada fila es un médico en un día concreto.

```sql
SELECT  pe.documento, pe.nombre, pe.apellidos, hc.dia_semana,
        SUM(TIME_TO_SEC(TIMEDIFF(hc.hora_fin, hc.hora_inicio))) / 3600 AS horas
FROM medico m
JOIN persona pe          ON pe.documento = m.documento
JOIN horario_consulta hc ON hc.medico_documento = m.documento
GROUP BY pe.documento, pe.nombre, pe.apellidos, hc.dia_semana
ORDER BY pe.apellidos, FIELD(hc.dia_semana,'lunes','martes','miércoles','jueves','viernes','sábado','domingo');
```

### 7. Número de sustituciones realizadas por cada médico sustituto

Cuenta las filas de `sustitucion` agrupadas por el médico que cubre. Cada fila es una sustitución distinta.

```sql
SELECT  pe.documento, pe.nombre, pe.apellidos,
        COUNT(*) AS num_sustituciones
FROM sustitucion s
JOIN medico m    ON m.documento = s.medico_sustituto_documento
JOIN persona pe  ON pe.documento = m.documento
GROUP BY pe.documento, pe.nombre, pe.apellidos
ORDER BY num_sustituciones DESC;
Médicos con el mayor número de pacientes actualmente en sustitución

De los médicos que hoy están siendo cubiertos (consulta 2), cuenta sus pacientes y los ordena de mayor a menor, quedando arriba el que más tiene.

```


### 10. Total de horas de consulta por especialidad y día de la semana

Suma las horas de todas las franjas agrupando por `especialidad` y `dia_semana`. Útil para ver la carga asistencial de cada especialidad día a día.

```sql
SELECT  m.especialidad, hc.dia_semana,
        SUM(TIME_TO_SEC(TIMEDIFF(hc.hora_fin, hc.hora_inicio))) / 3600 AS horas
FROM medico m
JOIN horario_consulta hc ON hc.medico_documento = m.documento
GROUP BY m.especialidad, hc.dia_semana
ORDER BY m.especialidad,
         FIELD(hc.dia_semana,'lunes','martes','miércoles','jueves','viernes','sábado','domingo');
```
