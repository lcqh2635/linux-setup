-- =============================================================
-- RBAC 示例数据初始化脚本
-- 适用于 auth_center 数据库
-- 业务场景：人身保险系统（保单管理、理赔审核等）
-- =============================================================

-- 设置当前会话时区（可选，确保时间一致）
SET time_zone = '+08:00';

-- =============================================================
-- 1. 插入示例用户
-- =============================================================
INSERT INTO `user` (
  `username`, `email`, `phone`, `full_name`,
  `password_hash`, `status`, `tenant_id`,
  `created_by`, `updated_by`
) VALUES
-- 系统管理员（root 用户，ID=1）
('admin', 'admin@insure.com', '13800138001', '系统管理员',
 '$2a$10$XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', -- 实际应为 BCrypt 哈希
 1, 'default', 1, 1),

-- 保单专员（ID=2）
('policy_agent', 'agent@insure.com', '13800138002', '张保单',
 '$2a$10$XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
 1, 'default', 1, 1),

-- 理赔审核员（ID=3）
('claim_approver', 'approver@insure.com', '13800138003', '李理赔',
 '$2a$10$XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
 1, 'default', 1, 1);

-- 注：实际密码哈希应由应用生成（如 Spring Security 的 BCryptPasswordEncoder）
-- 此处占位符仅用于结构演示，实际部署时需替换或通过应用注册

-- =============================================================
-- 2. 插入示例角色
-- =============================================================
INSERT INTO `role` (
  `role_code`, `role_name`, `description`, `tenant_id`,
  `created_by`, `updated_by`
) VALUES
('SYS_ADMIN', '系统管理员', '拥有全部权限', 'default', 1, 1),
('POLICY_AGENT', '保单专员', '可创建、查询保单', 'default', 1, 1),
('CLAIM_APPROVER', '理赔审核员', '可审核理赔申请', 'default', 1, 1);

-- =============================================================
-- 3. 插入示例权限（贴合人身保险业务）
-- =============================================================
INSERT INTO `permission` (
  `perm_code`, `perm_name`, `resource_type`, `description`,
  `tenant_id`, `created_by`, `updated_by`
) VALUES
-- 保单相关权限
('policy:create', '创建保单', 'API', '允许创建新的人身保险保单', 'default', 1, 1),
('policy:read', '查询保单', 'API', '允许查询保单详情', 'default', 1, 1),
('policy:update', '修改保单', 'API', '允许修改保单信息', 'default', 1, 1),
('policy:delete', '删除保单', 'API', '允许删除保单（谨慎）', 'default', 1, 1),

-- 理赔相关权限
('claim:read', '查询理赔', 'API', '允许查询理赔申请', 'default', 1, 1),
('claim:approve', '审核理赔', 'API', '允许审核并批准理赔', 'default', 1, 1),
('claim:reject', '拒绝理赔', 'API', '允许拒绝理赔申请', 'default', 1, 1),

-- 用户管理权限（仅管理员）
('user:manage', '管理用户', 'API', '允许增删改用户', 'default', 1, 1),

-- 角色管理权限
('role:manage', '管理角色', 'API', '允许配置角色权限', 'default', 1, 1);

-- =============================================================
-- 4. 用户-角色关联
-- =============================================================
INSERT INTO `user_role` (`user_id`, `role_id`, `tenant_id`, `created_by`) VALUES
-- admin 拥有 SYS_ADMIN 角色
(1, 1, 'default', 1),

-- policy_agent 拥有 POLICY_AGENT 角色
(2, 2, 'default', 1),

-- claim_approver 拥有 CLAIM_APPROVER 角色
(3, 3, 'default', 1);

-- =============================================================
-- 5. 角色-权限关联
-- =============================================================
-- SYS_ADMIN 拥有所有权限
INSERT INTO `role_permission` (`role_id`, `permission_id`, `tenant_id`, `created_by`)
SELECT 1, id, 'default', 1 FROM `permission`;

-- POLICY_AGENT 拥有保单相关权限（不含删除）
INSERT INTO `role_permission` (`role_id`, `permission_id`, `tenant_id`, `created_by`)
SELECT 2, id, 'default', 1 FROM `permission`
WHERE perm_code IN ('policy:create', 'policy:read', 'policy:update');

-- CLAIM_APPROVER 拥有理赔审核权限
INSERT INTO `role_permission` (`role_id`, `permission_id`, `tenant_id`, `created_by`)
SELECT 3, id, 'default', 1 FROM `permission`
WHERE perm_code LIKE 'claim:%';

-- =============================================================
-- 6. 审计日志示例（模拟关键操作）
-- =============================================================
INSERT INTO `audit_log` (
  `op_type`, `target_type`, `target_id`,
  `operator_id`, `operator_name`,
  `details`, `ip_address`, `tenant_id`, `created_at`
) VALUES
-- 模拟创建用户
('CREATE', 'USER', 2, 1, 'admin',
  JSON_OBJECT('username', 'policy_agent', 'full_name', '张保单'),
  '127.0.0.1', 'default', NOW(3)),

-- 模拟分配角色
('ASSIGN_ROLE', 'USER_ROLE', 1, 1, 'admin',
  JSON_OBJECT('user_id', 2, 'role_code', 'POLICY_AGENT'),
  '127.0.0.1', 'default', NOW(3)),

-- 模拟授予权限
('GRANT_PERM', 'ROLE_PERMISSION', 1, 1, 'admin',
  JSON_OBJECT('role_code', 'POLICY_AGENT', 'perm_code', 'policy:create'),
  '127.0.0.1', 'default', NOW(3));
