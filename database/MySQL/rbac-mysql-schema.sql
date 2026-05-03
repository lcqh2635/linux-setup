-- 数据库 jdbc 连接地址参考 
-- jdbc:mysql://localhost:3306/vue_blog?useUnicode=true&characterEncoding=utf8mb4&connectionCollation=utf8mb4_unicode_ci&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true

-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS `vue_blog`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 2. 创建用户（如果不存在）
CREATE USER IF NOT EXISTS 'blog_admin'@'%' IDENTIFIED BY '479368';

-- 3. 授权用户对数据库的所有权限
GRANT ALL PRIVILEGES ON `vue_blog`.* TO 'blog_admin'@'%';

-- 4. 刷新权限
FLUSH PRIVILEGES;

-- 5. 使用数据库
USE `vue_blog`;

-- 6. 创建数据表

-- ----------------------------
-- 用户表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user`
(
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID，主键',
  `username` VARCHAR(64) NOT NULL COMMENT '用户名，唯一',
  `email` VARCHAR(128) DEFAULT NULL COMMENT '邮箱',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `full_name` VARCHAR(64) NOT NULL COMMENT '用户真实姓名',
  `password_hash` VARCHAR(255) NOT NULL COMMENT '密码哈希值（使用 BCrypt 等安全算法加密存储）',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `tenant_id` VARCHAR(64) DEFAULT NULL COMMENT '租户ID（用于多租户架构，可为空表示公共用户，可选）',
  `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除标识：0-未删除，1-已删除',
  `created_by` BIGINT NOT NULL COMMENT '创建人用户ID',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间，精确到毫秒',
  `updated_by` BIGINT NOT NULL COMMENT '最后更新人用户ID',
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '最后更新时间，自动更新，精确到毫秒',
  PRIMARY KEY (`id`) COMMENT '主键，自增用户ID',
  UNIQUE KEY `uk_username` (`username`) COMMENT '唯一索引：确保用户名全局唯一',
  UNIQUE KEY `uk_email` (`email`) COMMENT '唯一索引：确保邮箱地址全局唯一（允许 NULL）',
  KEY `idx_tenant` (`tenant_id`) COMMENT '普通索引：用于按租户ID快速查询用户',
  KEY `idx_status` (`status`) COMMENT '普通索引：用于按用户状态（启用/禁用）快速筛选'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表：存储系统用户基本信息，支持多租户与逻辑删除';

-- ----------------------------
-- 角色表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `role`
(
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID，主键，自增唯一标识',
  `role_code` VARCHAR(64) NOT NULL COMMENT '角色编码，用于程序逻辑识别（如 ADMIN、OPERATOR），同一租户内唯一',
  `role_name` VARCHAR(64) NOT NULL COMMENT '角色显示名称，用于前端展示（如 系统管理员、运营人员）',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '角色描述，说明该角色的职责或权限范围',
  `tenant_id` VARCHAR(64) DEFAULT NULL COMMENT '租户ID，用于多租户隔离；NULL 表示平台级全局角色',
  `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除标识：0-未删除，1-已删除',
  `created_by` BIGINT NOT NULL COMMENT '创建人用户ID',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间，精确到毫秒',
  `updated_by` BIGINT NOT NULL COMMENT '最后更新人用户ID',
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '最后更新时间，自动更新，精确到毫秒',
  PRIMARY KEY (`id`) COMMENT '主键：角色唯一标识',
  UNIQUE KEY `uk_role_code_tenant` (`role_code`, `tenant_id`) COMMENT '唯一索引：确保同一租户内角色编码唯一（租户ID为NULL时视为全局租户）',
  KEY `idx_tenant` (`tenant_id`) COMMENT '普通索引：加速按租户ID查询角色列表'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表：存储系统角色信息，支持多租户与逻辑删除，用于权限控制体系';


-- ----------------------------
-- 权限（资源）表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `permission`
(
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '权限ID，主键，自增唯一标识',
  `perm_code` VARCHAR(128) NOT NULL COMMENT '权限编码，用于程序鉴权（如 user:read、order:delete），格式建议为 resource:action',
  `perm_name` VARCHAR(64) NOT NULL COMMENT '权限显示名称，用于前端或管理界面展示（如 查看用户、删除订单）',
  `resource_type` VARCHAR(32) NOT NULL COMMENT '资源类型，标识权限所属资源类别：MENU-菜单、API-接口、BUTTON-按钮等',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '权限描述，说明该权限的具体作用或适用场景',
  `tenant_id` VARCHAR(64) DEFAULT NULL COMMENT '租户ID，用于多租户隔离；NULL 表示平台级全局权限',
  `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除标识：0-未删除，1-已删除',
  `created_by` BIGINT NOT NULL COMMENT '创建人用户ID',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间，精确到毫秒',
  `updated_by` BIGINT NOT NULL COMMENT '最后更新人用户ID',
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '最后更新时间，自动更新，精确到毫秒',
  PRIMARY KEY (`id`) COMMENT '主键：权限的唯一标识',
  UNIQUE KEY `uk_perm_code_tenant` (`perm_code`, `tenant_id`) COMMENT '唯一索引：确保同一租户内权限编码唯一（tenant_id 为 NULL 时视为全局权限，允许多个 NULL 但 perm_code 仍需全局唯一）',
  KEY `idx_tenant` (`tenant_id`) COMMENT '普通索引：加速按租户ID查询权限列表'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='权限表（最小权限单元）：存储系统中可被分配的原子权限，支持多租户与逻辑删除，用于 RBAC 或 ABAC 权限模型';

-- ----------------------------
-- 用户-角色关联表（多对多）
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_role`
(
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID，自增唯一标识（主要用于审计或日志追踪，业务上以联合唯一键为准）',
  `user_id` BIGINT NOT NULL COMMENT '用户ID，关联 user 表的 id 字段',
  `role_id` BIGINT NOT NULL COMMENT '角色ID，关联 role 表的 id 字段',
  `tenant_id` VARCHAR(64) DEFAULT NULL COMMENT '租户ID，用于多租户数据隔离；NULL 表示该用户-角色绑定属于平台级（全局）',
  `created_by` BIGINT NOT NULL COMMENT '创建人用户ID（通常与 user_id 一致，也可为管理员代分配）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间，精确到毫秒',
  PRIMARY KEY (`id`) COMMENT '主键：自增ID，便于日志记录和唯一引用',
  UNIQUE KEY `uk_user_role_tenant` (`user_id`, `role_id`, `tenant_id`) COMMENT '唯一索引：确保同一租户下用户与角色的绑定关系唯一（tenant_id 为 NULL 时视为全局租户，同一用户不能重复绑定同一全局角色）',
  KEY `idx_user` (`user_id`) COMMENT '普通索引：加速根据用户ID查询其所有角色',
  KEY `idx_role` (`role_id`) COMMENT '普通索引：加速根据角色ID查询绑定的所有用户'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户与角色关联表：实现用户-角色多对多关系，支持多租户隔离与权限分配审计';

-- ----------------------------
-- 角色-权限关联表（多对多）
-- ----------------------------
CREATE TABLE IF NOT EXISTS `role_permission`
(
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID，自增唯一标识（便于审计、日志追踪及 ORM 操作）',
  `role_id` BIGINT NOT NULL COMMENT '角色ID，关联 role 表的 id 字段',
  `permission_id` BIGINT NOT NULL COMMENT '权限ID，关联 permission 表的 id 字段',
  `tenant_id` VARCHAR(64) DEFAULT NULL COMMENT '租户ID，用于多租户数据隔离；NULL 表示该角色-权限绑定为平台级（全局）',
  `created_by` BIGINT NOT NULL COMMENT '创建人用户ID（通常为管理员或系统用户）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间，精确到毫秒',
  PRIMARY KEY (`id`) COMMENT '主键：自增ID，作为关联记录的唯一标识',
  UNIQUE KEY `uk_role_perm_tenant` (`role_id`, `permission_id`, `tenant_id`) COMMENT '唯一索引：确保同一租户内一个角色不能重复绑定同一权限（tenant_id 为 NULL 时视为全局绑定，全局角色-权限组合也必须唯一）',
  KEY `idx_role` (`role_id`) COMMENT '普通索引：加速根据角色ID查询其拥有的所有权限（权限校验高频路径）',
  KEY `idx_permission` (`permission_id`) COMMENT '普通索引：加速根据权限ID反查哪些角色拥有该权限（用于权限影响分析或管理后台展示）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色与权限关联表：实现角色-权限多对多关系，支撑 RBAC 权限模型，支持多租户隔离与灵活授权';

-- ----------------------------
-- 审计日志表（记录所有权限变更操作）
-- ----------------------------
CREATE TABLE IF NOT EXISTS `audit_log`
(
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID，主键，自增唯一标识',
  `op_type` VARCHAR(32) NOT NULL COMMENT '操作类型，标识具体行为：CREATE-创建、UPDATE-更新、DELETE-删除、ASSIGN_ROLE-分配角色、REVOKE_ROLE-撤销角色、GRANT_PERM-授予权限、REVOKE_PERM-撤销权限',
  `target_type` VARCHAR(32) NOT NULL COMMENT '操作目标类型：USER-用户、ROLE-角色、PERMISSION-权限、USER_ROLE-用户角色关联、ROLE_PERMISSION-角色权限关联',
  `target_id` BIGINT NOT NULL COMMENT '目标实体的主键ID（如 user.id、role.id 等），用于关联被操作的具体记录',
  `operator_id` BIGINT NOT NULL COMMENT '操作人用户ID，关联 user 表的 id 字段',
  `operator_name` VARCHAR(64) NOT NULL COMMENT '操作人用户名（冗余存储，避免用户删除后无法追溯）',
  `details` JSON DEFAULT NULL COMMENT '操作详情，以 JSON 格式记录变更内容，例如：{"old": {"status": 0}, "new": {"status": 1}}；对于创建操作可仅存 "new"，删除操作可仅存 "old"',
  `ip_address` VARCHAR(45) DEFAULT NULL COMMENT '操作发起的客户端IP地址，VARCHAR(45) 可完整容纳 IPv4（如 192.168.1.1）和 IPv6（如 2001:db8::1）',
  `user_agent` VARCHAR(512) DEFAULT NULL COMMENT '客户端 User-Agent 信息，用于识别操作终端（如浏览器、移动端、API客户端）',
  `tenant_id` VARCHAR(64) DEFAULT NULL COMMENT '租户ID，标识操作发生的租户上下文；NULL 表示平台级操作',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '操作发生时间，精确到毫秒，用于审计时间线追溯',
  PRIMARY KEY (`id`) COMMENT '主键：审计日志的唯一标识',
  KEY `idx_operator` (`operator_id`) COMMENT '普通索引：加速按操作人查询其所有审计记录（用于用户行为追踪）',
  KEY `idx_target` (`target_type`, `target_id`) COMMENT '联合索引：高效查询某实体（如某用户、某角色）的所有操作历史（用于实体变更追溯）',
  KEY `idx_tenant` (`tenant_id`) COMMENT '普通索引：支持按租户隔离审计日志，便于多租户环境下的数据查询与合规审查',
  KEY `idx_created_at` (`created_at`) COMMENT '普通索引：支持按时间范围快速检索日志（如“查询最近7天的操作”），适用于高频审计报表场景'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='权限操作审计日志表：记录所有关键权限相关操作的完整审计轨迹，满足安全合规、问题排查与操作追溯需求';
