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