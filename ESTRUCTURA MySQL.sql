DROP DATABASE IF EXISTS centro_salud;
CREATE DATABASE centro_salud
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE centro_salud;

CREATE TABLE persona (
    documento VARCHAR(20) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    CONSTRAINT pk_persona PRIMARY KEY (documento)
);

CREATE TABLE medico (
    documento VARCHAR(20) NOT NULL,
    especialidad VARCHAR(60) NOT NULL,
    tipo ENUM('titular','interino','sustituto') NOT NULL,
    CONSTRAINT pk_medico PRIMARY KEY (documento),
    CONSTRAINT fk_medico_persona
        FOREIGN KEY (documento) REFERENCES persona(documento)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE empleado (
    documento VARCHAR(20) NOT NULL,
    cargo ENUM('ATS','auxiliar de enfermería','celador','administrativo') NOT NULL,
    turno ENUM('mañana','tarde','noche') NOT NULL,
    CONSTRAINT pk_empleado PRIMARY KEY (documento),
    CONSTRAINT fk_empleado_persona
        FOREIGN KEY (documento) REFERENCES persona(documento)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE horario_consulta (
    id INT NOT NULL AUTO_INCREMENT,
    medico_documento VARCHAR(20) NOT NULL,
    dia_semana ENUM('lunes','martes','miércoles','jueves','viernes','sábado','domingo') NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    CONSTRAINT pk_horario PRIMARY KEY (id),
    CONSTRAINT fk_horario_medico
        FOREIGN KEY (medico_documento) REFERENCES medico(documento)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_horario_franja CHECK (hora_fin > hora_inicio)
);

CREATE TABLE sustitucion (
    id INT NOT NULL AUTO_INCREMENT,
    medico_sustituto_documento VARCHAR(20) NOT NULL,
    medico_sustituido_documento VARCHAR(20) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CONSTRAINT pk_sustitucion PRIMARY KEY (id),
    CONSTRAINT fk_sust_sustituto
        FOREIGN KEY (medico_sustituto_documento) REFERENCES medico(documento),
    CONSTRAINT fk_sust_sustituido
        FOREIGN KEY (medico_sustituido_documento) REFERENCES medico(documento),
    CONSTRAINT chk_sust_fechas CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT chk_sust_distinto CHECK (medico_sustituto_documento <> medico_sustituido_documento)
);

CREATE TABLE paciente (
    documento VARCHAR(20) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    fecha_nacimiento DATE,
    telefono VARCHAR(20),
    medico_asignado_documento VARCHAR(20),
    CONSTRAINT pk_paciente PRIMARY KEY (documento),
    CONSTRAINT fk_paciente_medico
        FOREIGN KEY (medico_asignado_documento) REFERENCES medico(documento)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE vacaciones (
    id INT NOT NULL AUTO_INCREMENT,
    persona_documento VARCHAR(20) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('planificada','disfrutada') NOT NULL,
    CONSTRAINT pk_vacaciones PRIMARY KEY (id),
    CONSTRAINT fk_vacaciones_persona
        FOREIGN KEY (persona_documento) REFERENCES persona(documento)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_vac_fechas CHECK (fecha_fin >= fecha_inicio)
);

CREATE INDEX idx_paciente_medico ON paciente(medico_asignado_documento);
CREATE INDEX idx_horario_medico ON horario_consulta(medico_documento);
CREATE INDEX idx_sust_sustituido ON sustitucion(medico_sustituido_documento);
CREATE INDEX idx_sust_sustituto ON sustitucion(medico_sustituto_documento);
CREATE INDEX idx_vacaciones_persona ON vacaciones(persona_documento);
