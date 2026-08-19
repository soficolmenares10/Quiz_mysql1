
--  EXAMEN MySQL
--  datos.sql — Inserts de prueba con datos realistas
--  Requiere haber ejecutado antes estructura.sql

-- Limpieza (por si se reejecuta). Se desactivan las FK temporalmente.
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE vacaciones;
TRUNCATE TABLE sustitucion;
TRUNCATE TABLE horario_consulta;
TRUNCATE TABLE paciente;
TRUNCATE TABLE empleado;
TRUNCATE TABLE medico;
TRUNCATE TABLE persona;
SET FOREIGN_KEY_CHECKS = 1;

-- PERSONAS (base de médicos y empleados)

INSERT INTO persona (documento, nombre, apellidos) VALUES
-- Médicos
('1001','Ana','Gómez Ruiz'),
('1002','Carlos','Pérez Díaz'),
('1003','Lucía','Fernández Soto'),
('1004','Miguel','Torres Vega'),
('1005','Sofía','Ramírez León'),
('1006','Javier','Moreno Cano'),
('1007','Elena','Navarro Gil'),
('1008','Pablo','Herrera Ortiz'),
-- Empleados
('2001','Marta','Ruiz Blanco'),
('2002','Jorge','Sanz Marín'),
('2003','Beatriz','Molina Rey'),
('2004','Raúl','Castro Vidal'),
('2005','Nuria','Ibáñez Prado');

-- MÉDICOS

INSERT INTO medico (documento, especialidad, tipo) VALUES
('1001','Medicina General','titular'),
('1002','Pediatría','titular'),
('1003','Cardiología','titular'),
('1004','Medicina General','interino'),
('1005','Dermatología','titular'),
('1006','Medicina General','sustituto'),
('1007','Pediatría','sustituto'),
('1008','Pediatría','interino');

-- EMPLEADOS

INSERT INTO empleado (documento, cargo, turno) VALUES
('2001','ATS','mañana'),
('2002','auxiliar de enfermería','tarde'),
('2003','administrativo','mañana'),
('2004','celador','noche'),
('2005','auxiliar de enfermería','mañana');

-- HORARIOS DE CONSULTA
--  Ana (1001) acumula muchas horas -> encabeza la consulta 5.

INSERT INTO horario_consulta (medico_documento, dia_semana, hora_inicio, hora_fin) VALUES
-- 1001 Ana · Medicina General · 27 h/semana
('1001','lunes','08:00:00','14:00:00'),
('1001','martes','08:00:00','14:00:00'),
('1001','miércoles','08:00:00','13:00:00'),
('1001','jueves','08:00:00','14:00:00'),
('1001','viernes','08:00:00','12:00:00'),
-- 1002 Carlos · Pediatría · 12 h/semana
('1002','lunes','09:00:00','13:00:00'),
('1002','miércoles','09:00:00','13:00:00'),
('1002','viernes','09:00:00','13:00:00'),
-- 1003 Lucía · Cardiología · 8 h/semana
('1003','martes','10:00:00','14:00:00'),
('1003','jueves','10:00:00','14:00:00'),
-- 1004 Miguel · Medicina General · 12 h/semana
('1004','lunes','14:00:00','18:00:00'),
('1004','martes','14:00:00','18:00:00'),
('1004','miércoles','14:00:00','18:00:00'),
-- 1005 Sofía · Dermatología · 8 h/semana
('1005','miércoles','08:00:00','12:00:00'),
('1005','viernes','08:00:00','12:00:00'),
-- 1006 Javier · Medicina General (sustituto) · 12 h/semana
('1006','lunes','08:00:00','14:00:00'),
('1006','martes','08:00:00','14:00:00'),
-- 1007 Elena · Pediatría (sustituto) · 8 h/semana
('1007','lunes','09:00:00','13:00:00'),
('1007','miércoles','09:00:00','13:00:00'),
-- 1008 Pablo · Pediatría · 8 h/semana
('1008','martes','08:00:00','12:00:00'),
('1008','jueves','08:00:00','12:00:00');

-- PACIENTES
--  Ana (1001) tiene 6 pacientes -> cumple la consulta 8 (> 5).

INSERT INTO paciente (documento, nombre, apellidos, fecha_nacimiento, telefono, medico_asignado_documento) VALUES
('P001','Andrés','López Marín','1985-04-12','3001112201','1001'),
('P002','Carmen','Ortega Ruiz','1990-11-30','3001112202','1001'),
('P003','David','Ríos Salas','1978-02-05','3001112203','1001'),
('P004','Elisa','Vargas Peña','2001-07-19','3001112204','1001'),
('P005','Fernando','Cano Gil','1965-09-23','3001112205','1001'),
('P006','Gloria','Méndez Rojas','1995-12-01','3001112206','1001'),
('P007','Hugo','Silva Nieto','2015-03-14','3001112207','1002'),
('P008','Inés','Prieto Lara','2018-06-22','3001112208','1002'),
('P009','Julián','Bravo Costa','2012-10-08','3001112209','1002'),
('P010','Karla','Suárez Vega','1970-01-17','3001112210','1003'),
('P011','Leo','Aguilar Mesa','1959-08-03','3001112211','1003'),
('P012','María','Duarte Pinto','1988-05-27','3001112212','1004'),
('P013','Nicolás','Flores Rey','1993-03-09','3001112213','1004'),
('P014','Olga','Campos Vera','1982-12-15','3001112214','1005');

-- SUSTITUCIONES
--  ACTIVAS (fechas relativas a hoy):
--    1006 cubre a 1001  |  1007 cubre a 1002
--  PASADAS (fechas fijas):
--    1006 cubrió a 1003 y a 1002  |  1007 cubrió a 1005
--  Totales por sustituto -> consulta 7: 1006 = 3, 1007 = 2

INSERT INTO sustitucion (medico_sustituto_documento, medico_sustituido_documento, fecha_inicio, fecha_fin) VALUES
('1006','1001', DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 15 DAY)),  -- ACTIVA
('1007','1002', DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_ADD(CURDATE(), INTERVAL 10 DAY)),  -- ACTIVA
('1006','1003', '2025-01-10','2025-01-25'),  -- pasada
('1006','1002', '2025-06-01','2025-06-10'),  -- pasada
('1007','1005', '2025-03-01','2025-03-15');  -- pasada

-- VACACIONES
--  Empleada 2001 acumula 17 días disfrutados -> consulta 3 (> 10).
--  Se incluye una vacación ACTIVA (médico 1005) para la consulta bonus
--  de "situación de una persona en una fecha dada".

INSERT INTO vacaciones (persona_documento, fecha_inicio, fecha_fin, estado) VALUES
-- Empleados
('2001','2025-07-01','2025-07-10','disfrutada'),   -- 10 días
('2001','2025-12-20','2025-12-26','disfrutada'),   -- 7 días  => total 17 (> 10)
('2002','2025-08-01','2025-08-05','disfrutada'),   -- 5 días
('2003','2025-04-10','2025-04-22','disfrutada'),   -- 13 días (> 10)
('2004','2026-08-01','2026-08-10','planificada'),
('2005','2025-05-05','2025-05-09','disfrutada'),   -- 5 días
-- Médicos
('1002','2025-02-01','2025-02-14','disfrutada'),
('1004','2026-09-01','2026-09-15','planificada'),
('1005', DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'planificada'); -- ACTIVA