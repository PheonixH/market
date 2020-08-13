create database if not exists `market`;
use `market`;

# 用户表
# 考虑到多种登录方式，应在数据表中涉及到微信的openid,unionid,支付宝、QQ的用户token等，这些要在前期就涉及进去，因后期用户量大了之后加一个字段简直是噩梦,用户状态status也必不可少，比较人也是分好坏，其次就是创建时间，登录时间等，用户表与用户信息表绝逼是绑定关系，这就不多言了。
create table `customer`
(
    `id`         int(10) unsigned                           not null auto_increment,
    `tel`        bigint(20)                                          default null comment '手机号码',
    `nick_name`  varchar(127) collate utf8mb4_unicode_ci             default null comment '用户昵称',
    `password`   varchar(555) collate utf8mb4_unicode_ci             default null comment '登录密码',
    `wec_token`  varchar(125) collate utf8mb4_unicode_ci             default null comment '微信token',
    `ali_token`  varchar(255) COLLATE utf8mb4_unicode_ci    NOT NULL COMMENT '支付宝token',
    `open_id`    varchar(125) collate utf8mb4_unicode_ci             default null,
    `status`     enum ('1','-1') collate utf8mb4_unicode_ci not null default '1' comment '账号状态',
    `created_at` timestamp                                  null     default null,
    `updated_at` timestamp                                  null     default null,
    primary key (`id`),
    unique key `member_tel_unique` (`tel`),
    unique key `member_wx_token_unique` (`wec_token`),
    unique key `member_wx_token_unique` (`ali_token`)
) engine = innodb
  auto_increment = 95
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# 收货地址表
# 收货地址与用户是一一相对的，在设计上增加需要的字段即可，例如 收货人、收货人手机号、城市、详细地址等
create table `member_address`
(
    `id`         int(10) unsigned                          not null auto_increment,
    `member_id`  int(11)                                   not null comment '用户编号',
    `nick_name`  varchar(255) collate utf8mb4_unicode_ci   not null comment '收货人姓名',
    `tel`        varchar(255) collate utf8mb4_unicode_ci   not null comment '手机号码',
    `prov`       int(11)                                            default null comment '省',
    `city`       int(11)                                   not null comment '市',
    `area`       int(11)                                            default null comment '区',
    `address`    varchar(255) collate utf8mb4_unicode_ci   not null default '' comment '街道地址',
    `number`     int(11)                                   not null comment '邮政编码',
    `default`    enum ('0','1') collate utf8mb4_unicode_ci not null default '0' comment '默认收货地址 1=>默认',
    `deleted_at` timestamp                                 null     default null,
    `created_at` timestamp                                 null     default null,
    `updated_at` timestamp                                 null     default null,
    primary key (`id`)
) engine = innodb
  auto_increment = 55
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# 银行卡表
# 用于用户提现的业务等，大致将银行卡所需的信息记录即可，例如持卡人、卡号、归属银行等
create table `member_card`
(
    `id`          int(10) unsigned                       not null auto_increment,
    `member_id`   int(11)                                not null comment '用户编码',
    `card_name`   varchar(25) collate utf8mb4_unicode_ci not null comment '持卡人姓名',
    `card_number` varchar(25) collate utf8mb4_unicode_ci not null comment '银行卡号',
    `created_at`  timestamp                              null default null,
    `updated_at`  timestamp                              null default null,
    primary key (`id`),
    unique key `member_card_card_number_unique` (`card_number`)
) engine = innodb
  auto_increment = 11
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# 购物车表
# 为何单独建这个表，也是又一定原因的，正常只需要member_cart_item表即可，根据实际下线的业务场景，正常购物到超市需要拿一个购物车，但这个购物车并非属于你，你使用之后，需要归还，他人可继续使用，将购物车公开化，并不是将购物车商品公开化。业务场景比较窄，例如京东到家和京东商城一样（我只是举例，并不清楚他们怎么做的），购物车不通用，那如何区分呢，是应该在购物车上区分还是在购物车商品上区分？我想你已经清楚了。
create table `member_cart`
(
    `id`         int(10) unsigned not null auto_increment,
    `member_id`  int(11)          not null comment '用户编码',
    `created_at` timestamp        null default null,
    `updated_at` timestamp        null default null,
    primary key (`id`),
    unique key `member_cart_member_id_unique` (`member_id`),
    key `member_cart_member_id_index` (`member_id`)
) engine = innodb
  auto_increment = 28
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# 购物车商品表
# 这块需要提的一点是 [并不是所有表的设计都是互相绑定,互相依赖的]，就例如购物车商品表，不仅仅将商品编码存储在内，还要将商品价格，商品的简介以及商品的规格(既SKU)存储，不能因卖家下架商品，而查询不到商品的存在，比较一切以用户为主，用户是上帝的原则，不能让商品悄悄的就消失了吧。所以在做购物车商品表查询时，切记不要使用join或者表关联查询
create table `member_cart_item`
(
    `id`           int(10) unsigned                        not null auto_increment,
    `cart_id`      int(11)                                 not null comment '购物车编码',
    `product_desc` varchar(255) collate utf8mb4_unicode_ci not null comment '商品sku信息',
    `product_img`  varchar(255) collate utf8mb4_unicode_ci not null comment '商品快照',
    `product_name` varchar(255) collate utf8mb4_unicode_ci not null comment '商品名称',
    `price`        decimal(8, 2)                           not null default '0.00' comment '价格',
    `product_id`   int(11)                                 not null comment '商品编码',
    `supplier_id`  int(11)                                 not null comment '店铺编码',
    `sku_id`       int(11)                                 not null comment '商品sku编码',
    `number`       int(11)                                 not null default '1' comment '商品数量',
    `created_at`   timestamp                               null     default null,
    `updated_at`   timestamp                               null     default null,
    primary key (`id`),
    key `member_cart_item_cart_id_product_id_supplier_id_index` (`cart_id`, `product_id`, `supplier_id`)
) engine = innodb
  auto_increment = 24
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# 用户搜索历史表
# 用户搜索的记录是一定要有的，为了未来的数据分析，智能推荐做准备
create table `member_query_history`
(
    `id`         int(10) unsigned                        not null auto_increment,
    `member_id`  int(11)                                 not null comment '用户编码',
    `keyword`    varchar(125) collate utf8mb4_unicode_ci not null comment '关键字',
    `created_at` timestamp                               null default null,
    `updated_at` timestamp                               null default null,
    primary key (`id`)
) engine = innodb
  auto_increment = 11
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# 商品表 (spu表)
create table `product`
(
    `id`            int(10) unsigned                          not null auto_increment,
    `name`          varchar(255) collate utf8mb4_unicode_ci   not null comment '商品标题',
    `category_id`   int(11)                                   not null comment '商品分类编号',
    `mer_id`        int(11)                                   not null comment '商家编号',
    `freight_id`    int(11)                                            default null,
    `type_id`       tinyint(4)                                not null comment '类型编号',
    `sketch`        varchar(255) collate utf8mb4_unicode_ci            default null comment '简述',
    `intro`         text collate utf8mb4_unicode_ci           not null comment '商品描述',
    `keywords`      varchar(255) collate utf8mb4_unicode_ci            default null comment '商品关键字',
    `tags`          varchar(255) collate utf8mb4_unicode_ci            default null comment '标签',
    `marque`        varchar(255) collate utf8mb4_unicode_ci   not null comment '商品型号',
    `barcode`       varchar(255) collate utf8mb4_unicode_ci   not null comment '仓库条码',
    `brand_id`      int(11)                                   not null comment '品牌编号',
    `virtual`       int(11)                                   not null default '0' comment '虚拟购买量',
    `price`         decimal(8, 2)                             not null comment '商品价格',
    `market_price`  decimal(8, 2)                             not null comment '市场价格',
    `integral`      int(11)                                   not null default '0' comment '可使用积分抵消',
    `stock`         int(11)                                   not null comment '库存量',
    `warning_stock` int(11)                                   not null comment '库存警告',
    `picture_url`   varchar(125) collate utf8mb4_unicode_ci   not null comment '封面图',
    `posters`       varchar(125) collate utf8mb4_unicode_ci            default null,
    `status`        tinyint(4)                                not null comment '状态 -1=>下架,1=>上架,2=>预售,0=>未上架',
    `state`         tinyint(4)                                not null default '0' comment '审核状态 -1 审核失败 0 未审核 1 审核成功',
    `is_package`    enum ('0','1') collate utf8mb4_unicode_ci not null default '0' comment '是否是套餐',
    `is_integral`   enum ('0','1') collate utf8mb4_unicode_ci not null default '0' comment '是否是积分产品',
    `sort`          int(11)                                   not null default '99' comment '排序',
    `deleted_at`    timestamp                                 null     default null,
    `created_at`    timestamp                                 null     default null,
    `updated_at`    timestamp                                 null     default null,
    primary key (`id`)
) engine = innodb
  auto_increment = 24
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# 系统属性表
create table `product_attribute_option`
(
    `id`      int(10) unsigned                        not null auto_increment,
    `name`    varchar(125) collate utf8mb4_unicode_ci not null comment '选项名称',
    `attr_id` int(11)                                 not null comment '属性编码',
    `sort`    int(11)                                 not null default '999' comment '排序',
    primary key (`id`),
    key `product_attribute_option_name_attr_id_index` (`name`, `attr_id`)
) engine = innodb
  auto_increment = 5
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# 规格属性绑定表
create table `product_attribute_and_option`
(
    `id`                 int(10) unsigned not null auto_increment,
    `sku_id`             int(11)          not null comment 'sku编码',
    `option_id`          int(11)          not null default '0' comment '属性选项编码',
    `attribute_id`       int(11)          not null comment '属性编码',
    `sort`               int(11)          not null default '999' comment '排序',
    `supplier_option_id` int(11)                   default null,
    primary key (`id`),
    key `product_attribute_and_option_sku_id_option_id_attribute_id_index` (`sku_id`, `option_id`, `attribute_id`)
) engine = innodb
  auto_increment = 6335
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# 自定义规格表
create table `product_attribute`
(
    `id`         int(10) unsigned                        not null auto_increment,
    `product_id` int(11)                                 not null comment '商品编码',
    `name`       varchar(125) collate utf8mb4_unicode_ci not null comment '规格名称',
    `sort`       int(11)                                 not null default '999' comment '排序',
    primary key (`id`),
    key `product_supplier_attribute_name_product_id_index` (`name`, `product_id`)
) engine = innodb
  auto_increment = 40
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;
# 专辑
# 在淘宝的逻辑中,商家可为商品添加视频和图片，可为每个sku添加图片。我们称为专辑。将一组图片及视频类似歌手作家出专辑一样，绑定到商品表和sku表上
create table `product_album`
(
    `id`         int(10) unsigned                        not null auto_increment,
    `product_id` int(11)                                 not null comment '商品编号',
    `name`       varchar(25) collate utf8mb4_unicode_ci  not null comment '商品名称',
    `url`        varchar(45) collate utf8mb4_unicode_ci           default null comment '图片地址',
    `size`       int(11)                                          default null comment '视频大小',
    `intro`      varchar(255) collate utf8mb4_unicode_ci not null comment '图片介绍',
    `sort`       int(11)                                 not null default '999' comment '排序',
    `status`     tinyint(4)                              not null default '0' comment '图片状态',
    `state`      tinyint(4)                              not null default '0' comment '资源类型 0=>图片 1=>视频',
    `created_at` timestamp                               null     default null,
    `updated_at` timestamp                               null     default null,
    primary key (`id`)
) engine = innodb
  auto_increment = 60
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# 品牌
# 每个商品都归属与一个品牌，例如iphonex归属与苹果公司,小米8归属与小米公司一样。品牌无需关联到sku内，道理很简单，当前的sku是iphonex归属与苹果公司，自然而然iphonex下面的规格都属于苹果了。
create table `product_brand`
(
    `id`                  int(10) unsigned                        not null auto_increment,
    `product_category_id` int(11)                                 not null comment '商品类别编号',
    `name`                varchar(25) collate utf8mb4_unicode_ci  not null comment '品牌名称',
    `image_url`           varchar(125) collate utf8mb4_unicode_ci not null comment '图片url',
    `sort`                int(11)                                 not null default '999' comment '排列次序',
    `status`              tinyint(4)                              not null comment '状态',
    `created_at`          timestamp                               null     default null,
    `updated_at`          timestamp                               null     default null,
    primary key (`id`),
    unique key `product_brand_name_unique` (`name`)
) engine = innodb
  auto_increment = 4
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# 类目
# 有时品牌不仅仅归属与一个类目，还是以iphonex举例，他是一部手机又是苹果产品但他又是一个音乐播放器。注意，这个时候不要将当前品牌绑定到三个类目上，如果你这样做了，未来的可维护性会很低。应该每个类目中绑定相同的品牌名称，你一定会问那这样数据垃圾不就产生了吗？我没有具体数据给你展现这样做的好处。
# 但从业务说起，现在我需要统计每个类目下商品的购买数去做用户画像，你时你要如何区分当前这个商品到底是哪个类目下呢？无法区分，因为你将品牌绑定到了3个类目下，不知用户到底是通过哪个类目点击进去购买的。
# 再者很多品牌公司不仅仅是做一个商品，类似索尼做mp3也做电视，手机，游戏机等。所以类目对应多个品牌，品牌应对应多个类目并非关联多个类目
create table `product_category`
(
    `id`                 int(10) unsigned                        not null auto_increment,
    `name`               varchar(255) collate utf8mb4_unicode_ci not null comment '分类表',
    `pid`                int(11)                                 not null comment '父分类编号',
    `cover`              varchar(255) collate utf8mb4_unicode_ci          default null comment '封面图',
    `index_block_status` tinyint(4)                              not null default '0' comment '首页块级状态 1=>显示',
    `status`             tinyint(4)                              not null default '1' comment '状态 1=>正常',
    `sort`               int(11)                                 not null default '999' comment '排序',
    `created_at`         timestamp                               null     default null,
    `updated_at`         timestamp                               null     default null,
    primary key (`id`)
) engine = innodb
  auto_increment = 26
  default charset = utf8mb4
  collate = utf8mb4_unicode_ci;

# order 订单表
CREATE TABLE `order`
(
    `id`                      int(10) unsigned                          NOT NULL AUTO_INCREMENT,
    `order_no`                varchar(100) COLLATE utf8mb4_unicode_ci   NOT NULL COMMENT '订单编号',
    `order_sn`                varchar(100) COLLATE utf8mb4_unicode_ci   NOT NULL COMMENT '交易号',
    `member_id`               int(11)                                   NOT NULL COMMENT '客户编号',
    `supplier_id`             int(11)                                            DEFAULT '0' COMMENT '商户编码',
    `supplier_name`           varchar(255) COLLATE utf8mb4_unicode_ci            DEFAULT NULL COMMENT '商户名称',
    `order_status`            tinyint(4)                                NOT NULL DEFAULT '0' COMMENT '订单状态 0未付款,1已付款,2已发货,3已签收,-1退货申请,-2退货中,-3已退货,-4取消交易 -5撤销申请',
    `after_status`            tinyint(4)                                NOT NULL DEFAULT '0' COMMENT '用户售后状态 0 未发起售后 1 申请售后 -1 售后已取消 2 处理中 200 处理完毕',
    `product_count`           int(11)                                   NOT NULL DEFAULT '0' COMMENT '商品数量',
    `product_amount_total`    decimal(12, 4)                            NOT NULL COMMENT '商品总价',
    `order_amount_total`      decimal(12, 4)                            NOT NULL DEFAULT '0.0000' COMMENT '实际付款金额',
    `logistics_fee`           decimal(12, 4)                            NOT NULL COMMENT '运费金额',
    `address_id`              int(11)                                   NOT NULL COMMENT '收货地址编码',
    `pay_channel`             tinyint(4)                                NOT NULL DEFAULT '0' COMMENT '支付渠道 0余额 1微信 2支付宝',
    `out_trade_no`            varchar(255) COLLATE utf8mb4_unicode_ci            DEFAULT NULL COMMENT '订单支付单号',
    `escrow_trade_no`         varchar(255) COLLATE utf8mb4_unicode_ci            DEFAULT NULL COMMENT '第三方支付流水号',
    `pay_time`                int(11)                                   NOT NULL DEFAULT '0' COMMENT '付款时间',
    `delivery_time`           int(11)                                   NOT NULL DEFAULT '0' COMMENT '发货时间',
    `order_settlement_status` tinyint(4)                                NOT NULL DEFAULT '0' COMMENT '订单结算状态 0未结算 1已结算',
    `order_settlement_time`   int(11)                                   NOT NULL DEFAULT '0' COMMENT '订单结算时间',
    `is_package`              enum ('0','1') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT '是否是套餐',
    `is_integral`             enum ('0','1') COLLATE utf8mb4_unicode_ci          DEFAULT '0' COMMENT '是否是积分产品',
    `created_at`              timestamp                                 NULL     DEFAULT NULL,
    `updated_at`              timestamp                                 NULL     DEFAULT NULL,
    `deleted_at`              timestamp                                 NULL     DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `order_order_sn_member_id_order_status_out_trade_no_index` (`order_sn`, `member_id`, `order_status`, `out_trade_no`(191))
) ENGINE = InnoDB
  AUTO_INCREMENT = 114
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

# order_detail 订单详情
CREATE TABLE `order_detail`
(
    `id`                  int(10) unsigned                          NOT NULL AUTO_INCREMENT,
    `order_id`            int(11)                                   NOT NULL COMMENT '订单编码',
    `product_id`          int(11)                                   NOT NULL COMMENT '商品编码',
    `product_name`        varchar(255) COLLATE utf8mb4_unicode_ci   NOT NULL COMMENT '商品名称',
    `product_price`       decimal(12, 4)                            NOT NULL COMMENT '商品价格',
    `product_sku`         int(11)                                   NOT NULL COMMENT '商品SKU',
    `product_picture_url` varchar(255) COLLATE utf8mb4_unicode_ci            DEFAULT NULL,
    `product_mode_desc`   varchar(255) COLLATE utf8mb4_unicode_ci   NOT NULL COMMENT '商品型号信息',
    `product_mode_params` int(11)                                            DEFAULT NULL COMMENT '商品型号参数',
    `discount_rate`       tinyint(4)                                NOT NULL DEFAULT '0' COMMENT '折扣比例',
    `discount_amount`     decimal(12, 4)                            NOT NULL DEFAULT '0.0000' COMMENT '折扣比例',
    `number`              int(11)                                   NOT NULL DEFAULT '1' COMMENT '购买数量',
    `subtotal`            decimal(12, 4)                            NOT NULL COMMENT '小计金额',
    `is_product_exists`   enum ('0','1') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT '商品是否有效 1失效',
    `remark`              text COLLATE utf8mb4_unicode_ci COMMENT '客户商品备注',
    `created_at`          timestamp                                 NULL     DEFAULT NULL,
    `updated_at`          timestamp                                 NULL     DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `order_detail_order_id_index` (`order_id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 118
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

# order_returns 订单退换货
CREATE TABLE `order_returns`
(
    `id`                          int(10) unsigned                        NOT NULL AUTO_INCREMENT,
    `returns_no`                  varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '退货编号 供客户查询',
    `order_id`                    int(11)                                 NOT NULL COMMENT '订单编号',
    `express_no`                  varchar(255) COLLATE utf8mb4_unicode_ci          DEFAULT NULL COMMENT '物流单号',
    `consignee_realname`          varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货人姓名',
    `consignee_telphone`          varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '联系电话',
    `consignee_telphone2`         varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '备用联系电话',
    `consignee_address`           varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货地址',
    `consignee_zip`               varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮政编码',
    `logistics_type`              varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物流方式',
    `logistics_fee`               decimal(12, 2)                          NOT NULL COMMENT '物流发货运费',
    `order_logistics_status`      int(11)                                          DEFAULT NULL COMMENT '物流状态',
    `logistics_settlement_status` int(11)                                          DEFAULT NULL COMMENT '物流结算状态',
    `logistics_result_last`       varchar(255) COLLATE utf8mb4_unicode_ci          DEFAULT NULL COMMENT '物流最后状态描述',
    `logistics_result`            varchar(255) COLLATE utf8mb4_unicode_ci          DEFAULT NULL COMMENT '物流描述',
    `logistics_create_time`       int(11)                                          DEFAULT NULL COMMENT '发货时间',
    `logistics_update_time`       int(11)                                          DEFAULT NULL COMMENT '物流更新时间',
    `logistics_settlement_time`   int(11)                                          DEFAULT NULL COMMENT '物流结算时间',
    `returns_type`                tinyint(4)                              NOT NULL DEFAULT '0' COMMENT '0全部退单 1部分退单',
    `handling_way`                varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'PUPAWAY:退货入库;REDELIVERY:重新发货;RECLAIM-REDELIVERY:不要求归还并重新发货; REFUND:退款; COMPENSATION:不退货并赔偿',
    `returns_amount`              decimal(8, 2)                           NOT NULL COMMENT '退款金额',
    `return_submit_time`          int(11)                                 NOT NULL COMMENT '退货申请时间',
    `handling_time`               int(11)                                 NOT NULL COMMENT '退货处理时间',
    `remark`                      text COLLATE utf8mb4_unicode_ci         NOT NULL COMMENT '退货原因',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

# order_returns_apply 售后申请
CREATE TABLE `order_returns_apply`
(
    `id`              int(10) unsigned                        NOT NULL AUTO_INCREMENT,
    `order_no`        varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单单号',
    `order_detail_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '子订单编码',
    `return_no`       varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '售后单号',
    `member_id`       int(11)                                 NOT NULL COMMENT '用户编码',
    `state`           tinyint(4)                              NOT NULL COMMENT '类型 0 仅退款 1退货退款',
    `product_status`  tinyint(4)                              NOT NULL DEFAULT '0' COMMENT '货物状态 0:已收到货 1:未收到货',
    `why`             varchar(255) COLLATE utf8mb4_unicode_ci          DEFAULT NULL COMMENT '退换货原因',
    `status`          tinyint(4)                              NOT NULL DEFAULT '0' COMMENT '审核状态 -1 拒绝 0 未审核 1审核通过',
    `audit_time`      int(11)                                 NOT NULL DEFAULT '0' COMMENT '审核时间',
    `audit_why`       varchar(255) COLLATE utf8mb4_unicode_ci          DEFAULT NULL COMMENT '审核原因',
    `note`            text COLLATE utf8mb4_unicode_ci COMMENT '备注',
    `created_at`      timestamp                               NULL     DEFAULT NULL,
    `updated_at`      timestamp                               NULL     DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 5
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

# 交易表
CREATE TABLE `transaction`
(
    `id`              int(10) unsigned                        NOT NULL AUTO_INCREMENT,
    `order_sn`        varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '交易单号',
    `member_id`       bigint(20)                              NOT NULL COMMENT '交易的用户ID',
    `amount`          decimal(8, 2)                           NOT NULL COMMENT '交易金额',
    `integral`        int(11)                                 NOT NULL DEFAULT '0' COMMENT '使用的积分',
    `pay_state`       tinyint(4)                              NOT NULL COMMENT '支付类型 0:余额 1:微信 2:支付宝 3:xxx',
    `source`          varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付来源 wx app web wap',
    `status`          tinyint(4)                              NOT NULL DEFAULT '0' COMMENT '支付状态 -1：取消 0 未完成 1已完成 -2:异常',
    `completion_time` int(11)                                 NOT NULL COMMENT '交易完成时间',
    `note`            varchar(255) COLLATE utf8mb4_unicode_ci          DEFAULT NULL COMMENT '备注',
    `created_at`      timestamp                               NULL     DEFAULT NULL,
    `updated_at`      timestamp                               NULL     DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `transaction_order_sn_member_id_pay_state_source_status_index` (`order_sn`(191), `member_id`, `pay_state`, `source`(191), `status`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 36
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

# 支付记录表
CREATE TABLE `transaction_record`
(
    `id`         int(10) unsigned                        NOT NULL AUTO_INCREMENT,
    `order_sn`   varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    `events`     text COLLATE utf8mb4_unicode_ci         NOT NULL COMMENT '事件详情',
    `result`     text COLLATE utf8mb4_unicode_ci COMMENT '结果详情',
    `created_at` timestamp                               NULL DEFAULT NULL,
    `updated_at` timestamp                               NULL DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 36
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

# 评价数据表
CREATE TABLE `order_appraise`
(
    `id`             int(10) unsigned                               NOT NULL AUTO_INCREMENT,
    `order_id`       int(11)                                        NOT NULL COMMENT '订单编码',
    `info`           text COLLATE utf8mb4_unicode_ci                NOT NULL COMMENT '评论内容',
    `level`          enum ('-1','0','1') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '级别 -1差评 0中评 1好评',
    `desc_star`      tinyint(4)                                     NOT NULL COMMENT '描述相符 1-5',
    `logistics_star` tinyint(4)                                     NOT NULL COMMENT '物流服务 1-5',
    `attitude_star`  tinyint(4)                                     NOT NULL COMMENT '服务态度 1-5',
    `created_at`     timestamp                                      NULL DEFAULT NULL,
    `updated_at`     timestamp                                      NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `order_appraise_order_id_index` (`order_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

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