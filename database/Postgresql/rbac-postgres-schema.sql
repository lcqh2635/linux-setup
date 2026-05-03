-- ============================================================================
-- PostgreSQL 版本的 Vue 博客系统数据库脚本（兼容 PostgreSQL 12+）
-- 注意：PostgreSQL 与 MySQL 在语法、权限模型、数据类型、默认值等方面存在显著差异。
-- 此脚本已针对 PostgreSQL 做出如下调整：
-- 1. 使用 CREATE DATABASE + CREATE USER + GRANT 替代 MySQL 的 GRANT 创建用户语法
-- 2. 使用 SERIAL / BIGSERIAL 实现自增主键（或 IDENTITY 列，推荐）
-- 3. DATETIME(3) → TIMESTAMP(3) WITH TIME ZONE（建议使用带时区时间）
-- 4. TINYINT → SMALLINT（PostgreSQL 无 TINYINT）
-- 5. JSON → JSONB（推荐使用 JSONB 以支持索引和高效查询）
-- 6. 索引使用 CREATE INDEX 语法（无 KEY / UNIQUE KEY 简写）
-- 7. COMMENT 使用 COMMENT ON 语句单独添加
-- 8. 移除 ENGINE、CHARSET、COLLATE 等 MySQL 特有属性（PostgreSQL 由数据库创建时指定编码）
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 第一步：创建数据库（需在 psql 或其他客户端中以 superuser 身份执行）
-- PostgreSQL 的数据库编码建议在创建时指定为 UTF8（默认通常已是）
-- 注意：PostgreSQL 不支持在 SQL 脚本内“动态创建数据库并立即使用”，
--       因此实际执行时通常先创建数据库，再连接到该数据库执行后续建表语句。
-- 此处仅保留创建语句供参考，实际部署需分步操作。
-- ----------------------------------------------------------------------------

-- 创建数据库（UTF8 编码，时区建议在连接参数中设置，见下方注释）
-- 注意：此语句不能在已连接到目标数据库的会话中执行，需在 template1 或其他数据库中运行
-- CREATE DATABASE vue_blog
--     ENCODING 'UTF8'
--     LC_COLLATE 'zh_CN.UTF-8'   -- 可选：若系统支持中文排序
--     LC_CTYPE 'zh_CN.UTF-8'
--     TEMPLATE template0;

-- PostgreSQL 的 JDBC 连接 URL 示例（对比 MySQL）：
-- jdbc:postgresql://localhost:5432/vue_blog?stringtype=unspecified&ApplicationName=VueBlog
-- 时区建议通过 JVM 或连接参数设置：?options=-c%20timezone=Asia/Shanghai

-- ----------------------------------------------------------------------------
-- 第二步：创建用户并授权（需 superuser 权限）
-- PostgreSQL 使用 CREATE ROLE 创建用户，LOGIN 表示可登录
-- ----------------------------------------------------------------------------
-- CREATE ROLE blog_admin WITH LOGIN PASSWORD '479368';
-- GRANT ALL PRIVILEGES ON DATABASE vue_blog TO blog_admin;

-- ----------------------------------------------------------------------------
-- 第三步：连接到 vue_blog 数据库后，执行以下建表语句
-- （以下所有语句均在 vue_blog 数据库上下文中执行）
-- ----------------------------------------------------------------------------

-- ============================================================================
-- 用户表（user）
-- 注意：user 是 PostgreSQL 的保留关键字，必须用双引号转义
-- ============================================================================
CREATE TABLE IF NOT EXISTS "user"
(
    id            BIGSERIAL PRIMARY KEY,                          -- 自增主键（等价于 MySQL 的 AUTO_INCREMENT）
    username      VARCHAR(64) NOT NULL,                           -- 用户名
    email         VARCHAR(128),                                   -- 邮箱（允许 NULL）
    phone         VARCHAR(20),                                    -- 手机号
    full_name     VARCHAR(64) NOT NULL,                           -- 用户真实姓名
    password_hash VARCHAR(255) NOT NULL,                         -- 密码哈希（如 BCrypt）
    status        SMALLINT NOT NULL DEFAULT 1,                    -- 状态：1-启用，0-禁用（PostgreSQL 无 TINYINT，用 SMALLINT）
    tenant_id     VARCHAR(64),                                    -- 租户ID（多租户支持）
    is_deleted    SMALLINT NOT NULL DEFAULT 0,                    -- 逻辑删除：0-未删，1-已删
    created_by    BIGINT NOT NULL,                                -- 创建人ID
    created_at    TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),  -- 创建时间（带毫秒和时区）
    updated_by    BIGINT NOT NULL,                                -- 最后更新人ID
    updated_at    TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3)   -- 最后更新时间
        -- 注意：PostgreSQL 不支持 ON UPDATE CURRENT_TIMESTAMP，
        -- 需通过触发器（trigger）实现自动更新 updated_at（见下方说明）
);

-- 自动更新 updated_at 字段的触发器函数（PostgreSQL 特有）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP(3);
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- 为 user 表创建触发器
CREATE TRIGGER trigger_user_updated_at
    BEFORE UPDATE ON "user"
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 添加唯一约束和普通索引
-- 注意：PostgreSQL 使用 CREATE UNIQUE INDEX 和 CREATE INDEX
CREATE UNIQUE INDEX IF NOT EXISTS uk_username ON "user" (username);
CREATE UNIQUE INDEX IF NOT EXISTS uk_email ON "user" (email) WHERE email IS NOT NULL;  -- 排除 NULL 的唯一约束
CREATE INDEX IF NOT EXISTS idx_tenant ON "user" (tenant_id);
CREATE INDEX IF NOT EXISTS idx_status ON "user" (status);

-- 添加表和字段注释（PostgreSQL 使用 COMMENT ON）
COMMENT ON TABLE "user" IS '用户表：存储系统用户基本信息，支持多租户与逻辑删除';
COMMENT ON COLUMN "user".id IS '用户ID，主键';
COMMENT ON COLUMN "user".username IS '用户名，唯一';
COMMENT ON COLUMN "user".email IS '邮箱';
COMMENT ON COLUMN "user".phone IS '手机号';
COMMENT ON COLUMN "user".full_name IS '用户真实姓名';
COMMENT ON COLUMN "user".password_hash IS '密码哈希值（使用 BCrypt 等安全算法加密存储）';
COMMENT ON COLUMN "user".status IS '状态：1-启用，0-禁用';
COMMENT ON COLUMN "user".tenant_id IS '租户ID（用于多租户架构，可为空表示公共用户，可选）';
COMMENT ON COLUMN "user".is_deleted IS '逻辑删除标识：0-未删除，1-已删除';
COMMENT ON COLUMN "user".created_by IS '创建人用户ID';
COMMENT ON COLUMN "user".created_at IS '创建时间，精确到毫秒';
COMMENT ON COLUMN "user".updated_by IS '最后更新人用户ID';
COMMENT ON COLUMN "user".updated_at IS '最后更新时间，自动更新，精确到毫秒';

-- ============================================================================
-- 角色表（role）
-- ============================================================================
CREATE TABLE IF NOT EXISTS "role"
(
    id            BIGSERIAL PRIMARY KEY,
    role_code     VARCHAR(64) NOT NULL,
    role_name     VARCHAR(64) NOT NULL,
    description   VARCHAR(255),
    tenant_id     VARCHAR(64),
    is_deleted    SMALLINT NOT NULL DEFAULT 0,
    created_by    BIGINT NOT NULL,
    created_at    TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_by    BIGINT NOT NULL,
    updated_at    TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
);

-- 触发器：自动更新 updated_at
CREATE TRIGGER trigger_role_updated_at
    BEFORE UPDATE ON "role"
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 唯一约束：role_code + tenant_id（注意：NULL 视为相等，PostgreSQL 中 (code, NULL) 只能出现一次）
CREATE UNIQUE INDEX IF NOT EXISTS uk_role_code_tenant ON "role" (role_code, tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenant_role ON "role" (tenant_id);

COMMENT ON TABLE "role" IS '角色表：存储系统角色信息，支持多租户与逻辑删除，用于权限控制体系';
COMMENT ON COLUMN "role".id IS '角色ID，主键，自增唯一标识';
COMMENT ON COLUMN "role".role_code IS '角色编码，用于程序逻辑识别（如 ADMIN、OPERATOR），同一租户内唯一';
COMMENT ON COLUMN "role".role_name IS '角色显示名称，用于前端展示（如 系统管理员、运营人员）';
COMMENT ON COLUMN "role".description IS '角色描述，说明该角色的职责或权限范围';
COMMENT ON COLUMN "role".tenant_id IS '租户ID，用于多租户隔离；NULL 表示平台级全局角色';
COMMENT ON COLUMN "role".is_deleted IS '逻辑删除标识：0-未删除，1-已删除';
COMMENT ON COLUMN "role".created_by IS '创建人用户ID';
COMMENT ON COLUMN "role".created_at IS '创建时间，精确到毫秒';
COMMENT ON COLUMN "role".updated_by IS '最后更新人用户ID';
COMMENT ON COLUMN "role".updated_at IS '最后更新时间，自动更新，精确到毫秒';

-- ============================================================================
-- 权限表（permission）
-- ============================================================================
CREATE TABLE IF NOT EXISTS "permission"
(
    id             BIGSERIAL PRIMARY KEY,
    perm_code      VARCHAR(128) NOT NULL,
    perm_name      VARCHAR(64) NOT NULL,
    resource_type  VARCHAR(32) NOT NULL,
    description    VARCHAR(255),
    tenant_id      VARCHAR(64),
    is_deleted     SMALLINT NOT NULL DEFAULT 0,
    created_by     BIGINT NOT NULL,
    created_at     TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_by     BIGINT NOT NULL,
    updated_at     TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
);

CREATE TRIGGER trigger_permission_updated_at
    BEFORE UPDATE ON "permission"
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE UNIQUE INDEX IF NOT EXISTS uk_perm_code_tenant ON "permission" (perm_code, tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenant_permission ON "permission" (tenant_id);

COMMENT ON TABLE "permission" IS '权限表（最小权限单元）：存储系统中可被分配的原子权限，支持多租户与逻辑删除，用于 RBAC 或 ABAC 权限模型';
COMMENT ON COLUMN "permission".id IS '权限ID，主键，自增唯一标识';
COMMENT ON COLUMN "permission".perm_code IS '权限编码，用于程序鉴权（如 user:read、order:delete），格式建议为 resource:action';
COMMENT ON COLUMN "permission".perm_name IS '权限显示名称，用于前端或管理界面展示（如 查看用户、删除订单）';
COMMENT ON COLUMN "permission".resource_type IS '资源类型，标识权限所属资源类别：MENU-菜单、API-接口、BUTTON-按钮等';
COMMENT ON COLUMN "permission".description IS '权限描述，说明该权限的具体作用或适用场景';
COMMENT ON COLUMN "permission".tenant_id IS '租户ID，用于多租户隔离；NULL 表示平台级全局权限';
COMMENT ON COLUMN "permission".is_deleted IS '逻辑删除标识：0-未删除，1-已删除';
COMMENT ON COLUMN "permission".created_by IS '创建人用户ID';
COMMENT ON COLUMN "permission".created_at IS '创建时间，精确到毫秒';
COMMENT ON COLUMN "permission".updated_by IS '最后更新人用户ID';
COMMENT ON COLUMN "permission".updated_at IS '最后更新时间，自动更新，精确到毫秒';

-- ============================================================================
-- 用户-角色关联表（user_role）
-- ============================================================================
CREATE TABLE IF NOT EXISTS "user_role"
(
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,   -- 建议添加外键约束
    role_id    BIGINT NOT NULL REFERENCES "role"(id) ON DELETE CASCADE,
    tenant_id  VARCHAR(64),
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
    -- 无 updated_at，因关联表通常只增不改（或直接删除重建）
);

-- 联合唯一约束：确保 (user_id, role_id, tenant_id) 唯一
-- 注意：PostgreSQL 允许多个 NULL，但在唯一索引中，(1,2,NULL) 和 (1,2,NULL) 被视为相同
CREATE UNIQUE INDEX IF NOT EXISTS uk_user_role_tenant ON "user_role" (user_id, role_id, tenant_id);
CREATE INDEX IF NOT EXISTS idx_user_role_user ON "user_role" (user_id);
CREATE INDEX IF NOT EXISTS idx_user_role_role ON "user_role" (role_id);

COMMENT ON TABLE "user_role" IS '用户与角色关联表：实现用户-角色多对多关系，支持多租户隔离与权限分配审计';
COMMENT ON COLUMN "user_role".id IS '主键ID，自增唯一标识（主要用于审计或日志追踪，业务上以联合唯一键为准）';
COMMENT ON COLUMN "user_role".user_id IS '用户ID，关联 user 表的 id 字段';
COMMENT ON COLUMN "user_role".role_id IS '角色ID，关联 role 表的 id 字段';
COMMENT ON COLUMN "user_role".tenant_id IS '租户ID，用于多租户数据隔离；NULL 表示该用户-角色绑定属于平台级（全局）';
COMMENT ON COLUMN "user_role".created_by IS '创建人用户ID（通常与 user_id 一致，也可为管理员代分配）';
COMMENT ON COLUMN "user_role".created_at IS '创建时间，精确到毫秒';

-- ============================================================================
-- 角色-权限关联表（role_permission）
-- ============================================================================
CREATE TABLE IF NOT EXISTS "role_permission"
(
    id             BIGSERIAL PRIMARY KEY,
    role_id        BIGINT NOT NULL REFERENCES "role"(id) ON DELETE CASCADE,
    permission_id  BIGINT NOT NULL REFERENCES "permission"(id) ON DELETE CASCADE,
    tenant_id      VARCHAR(64),
    created_by     BIGINT NOT NULL,
    created_at     TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
);

CREATE UNIQUE INDEX IF NOT EXISTS uk_role_perm_tenant ON "role_permission" (role_id, permission_id, tenant_id);
CREATE INDEX IF NOT EXISTS idx_role_permission_role ON "role_permission" (role_id);
CREATE INDEX IF NOT EXISTS idx_role_permission_perm ON "role_permission" (permission_id);

COMMENT ON TABLE "role_permission" IS '角色与权限关联表：实现角色-权限多对多关系，支撑 RBAC 权限模型，支持多租户隔离与灵活授权';
COMMENT ON COLUMN "role_permission".id IS '主键ID，自增唯一标识（便于审计、日志追踪及 ORM 操作）';
COMMENT ON COLUMN "role_permission".role_id IS '角色ID，关联 role 表的 id 字段';
COMMENT ON COLUMN "role_permission".permission_id IS '权限ID，关联 permission 表的 id 字段';
COMMENT ON COLUMN "role_permission".tenant_id IS '租户ID，用于多租户数据隔离；NULL 表示该角色-权限绑定为平台级（全局）';
COMMENT ON COLUMN "role_permission".created_by IS '创建人用户ID（通常为管理员或系统用户）';
COMMENT ON COLUMN "role_permission".created_at IS '创建时间，精确到毫秒';

-- ============================================================================
-- 审计日志表（audit_log）
-- ============================================================================
CREATE TABLE IF NOT EXISTS "audit_log"
(
    id            BIGSERIAL PRIMARY KEY,
    op_type       VARCHAR(32) NOT NULL,            -- 操作类型
    target_type   VARCHAR(32) NOT NULL,            -- 目标类型
    target_id     BIGINT NOT NULL,                 -- 目标实体ID
    operator_id   BIGINT NOT NULL,
    operator_name VARCHAR(64) NOT NULL,            -- 冗余存储用户名
    details       JSONB,                           -- 使用 JSONB 而非 JSON（支持索引和高效查询）
    ip_address    VARCHAR(45),                     -- 支持 IPv4 和 IPv6
    user_agent    VARCHAR(512),
    tenant_id     VARCHAR(64),
    created_at    TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
);

-- 为高频查询字段添加索引
CREATE INDEX IF NOT EXISTS idx_audit_operator ON "audit_log" (operator_id);
CREATE INDEX IF NOT EXISTS idx_audit_target ON "audit_log" (target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_audit_tenant ON "audit_log" (tenant_id);
CREATE INDEX IF NOT EXISTS idx_audit_created_at ON "audit_log" (created_at);

-- 可选：为 JSONB 字段 details 创建 GIN 索引（如需按内容查询）
-- CREATE INDEX IF NOT EXISTS idx_audit_details ON "audit_log" USING GIN (details);

COMMENT ON TABLE "audit_log" IS '权限操作审计日志表：记录所有关键权限相关操作的完整审计轨迹，满足安全合规、问题排查与操作追溯需求';
COMMENT ON COLUMN "audit_log".id IS '日志ID，主键，自增唯一标识';
COMMENT ON COLUMN "audit_log".op_type IS '操作类型，标识具体行为：CREATE-创建、UPDATE-更新、DELETE-删除、ASSIGN_ROLE-分配角色、REVOKE_ROLE-撤销角色、GRANT_PERM-授予权限、REVOKE_PERM-撤销权限';
COMMENT ON COLUMN "audit_log".target_type IS '操作目标类型：USER-用户、ROLE-角色、PERMISSION-权限、USER_ROLE-用户角色关联、ROLE_PERMISSION-角色权限关联';
COMMENT ON COLUMN "audit_log".target_id IS '目标实体的主键ID（如 user.id、role.id 等），用于关联被操作的具体记录';
COMMENT ON COLUMN "audit_log".operator_id IS '操作人用户ID，关联 user 表的 id 字段';
COMMENT ON COLUMN "audit_log".operator_name IS '操作人用户名（冗余存储，避免用户删除后无法追溯）';
COMMENT ON COLUMN "audit_log".details IS '操作详情，以 JSON 格式记录变更内容，例如：{"old": {"status": 0}, "new": {"status": 1}}；对于创建操作可仅存 "new"，删除操作可仅存 "old"';
COMMENT ON COLUMN "audit_log".ip_address IS '操作发起的客户端IP地址，VARCHAR(45) 可完整容纳 IPv4（如 192.168.1.1）和 IPv6（如 2001:db8::1）';
COMMENT ON COLUMN "audit_log".user_agent IS '客户端 User-Agent 信息，用于识别操作终端（如浏览器、移动端、API客户端）';
COMMENT ON COLUMN "audit_log".tenant_id IS '租户ID，标识操作发生的租户上下文；NULL 表示平台级操作';
COMMENT ON COLUMN "audit_log".created_at IS '操作发生时间，精确到毫秒，用于审计时间线追溯';

-- ============================================================================
-- 补充说明
-- ============================================================================
-- 1. 时区处理建议：
--    PostgreSQL 推荐使用 TIMESTAMP WITH TIME ZONE（timestamptz），
--    数据以 UTC 存储，按客户端时区转换显示。
--    连接时可设置：SET timezone = 'Asia/Shanghai';
--    或在 JDBC URL 中通过 options 参数设置。

-- 2. 逻辑删除：
--    PostgreSQL 不支持 MySQL 的虚拟列或生成列语法，
--    需在应用层或查询时显式添加 WHERE is_deleted = 0。

-- 3. 外键约束：
--    为保证数据一致性，建议启用外键（如上所示）。
--    删除用户时自动清理关联记录（ON DELETE CASCADE）。

-- 4. 性能优化：
--    对于高频权限校验场景，可考虑缓存角色-权限映射，而非每次都查表。

-- 5. 部署建议：
--    在生产环境中，应使用迁移工具（如 Flyway、Liquibase）管理数据库变更，
--    而非直接执行完整建库脚本。
