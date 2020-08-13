# 运费信息

create database if not exists `market`;
use `market`;

# 主表
# 本次对运费模板上的设计，采用一主表一子表的方式来做。
# 主表则是由简单的模板名称，是否包邮，创建时间构成，表结构如下
CREATE TABLE `product_template`
(
    `id`         int(10) unsigned                        NOT NULL AUTO_INCREMENT,
    `title`      varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模板名称',
    `type`       tinyint(4)                              NOT NULL DEFAULT '0' COMMENT '类型 0 自定义运费 1 包邮',
    `created_at` timestamp                               NULL     DEFAULT NULL,
    `updated_at` timestamp                               NULL     DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 33
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

# 子表：运费规则表
# 而子表为运费规则表，也是运费模板的核心灵魂，直接决定了是否会简化增删改查的复杂度。我以一对多的方式来设计规则表。将默认运费与指定运费合并在一个表内，表结构如下
CREATE TABLE `product_template_rule`
(
    `id`             int(10) unsigned NOT NULL AUTO_INCREMENT,
    `template_id`    int(11)          NOT NULL COMMENT '模板编码',
    `city`           text COLLATE utf8mb4_unicode_ci COMMENT '城市',
    `default_number` int(11)          NOT NULL DEFAULT '0' COMMENT '默认数量',
    `default_price`  decimal(12, 2)   NOT NULL DEFAULT '0.00' COMMENT '默认运费',
    `create_number`  int(11)          NOT NULL DEFAULT '0' COMMENT '新增数量',
    `create_price`   decimal(12, 2)   NOT NULL DEFAULT '0.00' COMMENT '新增运费',
    `created_at`     timestamp        NULL     DEFAULT NULL,
    `updated_at`     timestamp        NULL     DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 58
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;