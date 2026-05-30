-- ODS - ods_sku_info_full - 商品表

DROP TABLE IF EXISTS ods_sku_info_full;
CREATE EXTERNAL TABLE ods_sku_info_full
(
    `id`                STRING COMMENT 'SKU_ID',
    `spu_id`           STRING COMMENT 'SPU_ID',
    `price`            DECIMAL(16, 2) COMMENT '价格',
    `sku_name`         STRING COMMENT 'SKU名称',
    `sku_desc`         STRING COMMENT 'SKU规格描述',
    `weight`           DECIMAL(16, 2) COMMENT '重量',
    `tm_id`             STRING COMMENT '品牌ID',
    `category3_id`     STRING COMMENT '三级品类ID',
    `sku_default_img` STRING COMMENT '默认显示图片地址',
    `is_sale`           STRING COMMENT '是否在售',
    `create_time`      STRING COMMENT '创建时间',
    `operate_time`     STRING COMMENT '修改时间'
) COMMENT '商品表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    NULL DEFINED AS ''
LOCATION '/warehouse/gmall/ods/ods_sku_info_full/'
TBLPROPERTIES ('compression.codec'='org.apache.hadoop.io.compress.GzipCodec');
