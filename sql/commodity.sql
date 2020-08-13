# 商品信息

create database if not exists `market`;
use `market`;


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
