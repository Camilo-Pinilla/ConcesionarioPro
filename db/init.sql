-- ============================================================
-- CONCESIONARIO - Script de inicialización de base de datos
-- Se ejecuta automáticamente al levantar el contenedor de Postgres
-- Ubicar en: ./db/init.sql y mapear a /docker-entrypoint-initdb.d/
-- ============================================================

-- ==================== ESQUEMA ====================

CREATE TABLE IF NOT EXISTS roles (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id         BIGSERIAL    PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    cedula     VARCHAR(20)  NOT NULL UNIQUE,
    email      VARCHAR(150) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    phone      VARCHAR(20),
    address    VARCHAR(255),
    is_active  BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS brands (
    id         BIGSERIAL    PRIMARY KEY,
    name       VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS vehicles (
    id          BIGSERIAL      PRIMARY KEY,
    brand_id    BIGINT         NOT NULL REFERENCES brands(id),
    model       VARCHAR(100)   NOT NULL,
    year        INT            NOT NULL,
    price       DECIMAL(15, 2) NOT NULL,
    color       VARCHAR(50),
    mileage     INT            NOT NULL DEFAULT 0,
    type        VARCHAR(10)    NOT NULL CHECK (type IN ('NUEVO', 'USADO')),
    status      VARCHAR(15)    NOT NULL DEFAULT 'DISPONIBLE'
                               CHECK (status IN ('DISPONIBLE', 'RESERVADO', 'VENDIDO')),
    image_url   VARCHAR(500),
    description TEXT,
    created_at  TIMESTAMP      NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP      NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS sales (
    id             BIGSERIAL      PRIMARY KEY,
    vehicle_id     BIGINT         NOT NULL REFERENCES vehicles(id),
    buyer_id       BIGINT         NOT NULL REFERENCES users(id),
    registered_by  BIGINT         NOT NULL REFERENCES users(id),
    sale_date      DATE           NOT NULL DEFAULT CURRENT_DATE,
    final_price    DECIMAL(15, 2) NOT NULL,
    payment_method VARCHAR(50)    NOT NULL CHECK (payment_method IN ('EFECTIVO', 'TARJETA_CREDITO', 'TARJETA_DEBITO', 'TRANSFERENCIA', 'FINANCIACION')),
    notes          TEXT,
    created_at     TIMESTAMP      NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS log_audit (
    id         BIGSERIAL    PRIMARY KEY,
    user_id    BIGINT       REFERENCES users(id),
    action     VARCHAR(50)  NOT NULL,
    entity     VARCHAR(100) NOT NULL,
    entity_id  BIGINT,
    details    TEXT,
    created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ==================== ÍNDICES ====================

CREATE INDEX idx_users_email        ON users(email);
CREATE INDEX idx_users_cedula       ON users(cedula);
CREATE INDEX idx_vehicles_brand     ON vehicles(brand_id);
CREATE INDEX idx_vehicles_status    ON vehicles(status);
CREATE INDEX idx_vehicles_type      ON vehicles(type);
CREATE INDEX idx_sales_vehicle      ON sales(vehicle_id);
CREATE INDEX idx_sales_buyer        ON sales(buyer_id);
CREATE INDEX idx_sales_date         ON sales(sale_date);
CREATE INDEX idx_log_audit_user     ON log_audit(user_id);
CREATE INDEX idx_log_audit_entity   ON log_audit(entity, entity_id);
CREATE INDEX idx_log_audit_created  ON log_audit(created_at);

-- ==================== DATOS INICIALES ====================

-- Roles base
INSERT INTO roles (name, description) VALUES
    ('ADMIN',   'Administrador del sistema con acceso total'),
    ('CLIENTE', 'Cliente que puede consultar vehículos y realizar compras');

-- Usuario admin por defecto (password: admin123 - CAMBIAR EN PRODUCCIÓN)
-- El hash corresponde a BCrypt, lo reemplazás cuando integres Spring Security
INSERT INTO users (first_name, last_name, cedula, email, password, phone) VALUES
    ('Admin', 'Sistema', '0000000000', 'admin@concesionario.com', '$2a$10$placeholder_hash_cambiar', '3000000000');

INSERT INTO user_roles (user_id, role_id) VALUES
    (1, 1);

-- Marcas iniciales
INSERT INTO brands (name) VALUES
    ('Toyota'),
    ('Chevrolet'),
    ('Mazda'),
    ('Renault'),
    ('Kia'),
    ('Hyundai'),
    ('Ford'),
    ('Nissan');

-- Vehículos de ejemplo
INSERT INTO vehicles (brand_id, model, year, price, color, mileage, type, status, description) VALUES
    (1, 'Corolla',    2024, 95000000.00,  'Blanco', 0,     'NUEVO', 'DISPONIBLE', 'Sedán confiable con excelente rendimiento de combustible'),
    (2, 'Onix',       2023, 62000000.00,  'Gris',   15000, 'USADO', 'DISPONIBLE', 'Compacto turbo en excelente estado'),
    (3, 'CX-5',       2024, 130000000.00, 'Rojo',   0,     'NUEVO', 'DISPONIBLE', 'SUV con tecnología Skyactiv'),
    (4, 'Duster',     2022, 72000000.00,  'Negro',  30000, 'USADO', 'DISPONIBLE', 'SUV versátil para ciudad y carretera'),
    (5, 'Sportage',   2024, 115000000.00, 'Azul',   0,     'NUEVO', 'RESERVADO',  'SUV premium con asistencias de conducción'),
    (6, 'Tucson',     2023, 108000000.00, 'Plata',  8000,  'USADO', 'DISPONIBLE', 'SUV moderna con bajo kilometraje');

RAISE NOTICE '✅ Base de datos del concesionario inicializada correctamente';