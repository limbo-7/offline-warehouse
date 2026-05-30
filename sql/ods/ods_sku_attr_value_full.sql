-- ODS - ods_sku_attr_value_full - SKU属性值表

DROP TABLE IF EXISTS ods_sku_attr_value_full;
CREATE EXTERNAL TABLE ods_sku_attr_value_full
(
    `id`              STRING COMMENT '编号',
    `attr_id`        STRING COMMENT '平台属性ID',
    `value_id`       STRING COMMENT '平台属性值ID',
    `sku_id`         STRING COMMENT 'SKU_ID',
    `attr_name`      STRING COMMENT '平台属性名称',
    `value_name`     STRING COMMENT '平台属性值名称',
    `create_time`    STRING COMMENT '创建时间',
    `operate_time`   STRING COMMENT '修改时间'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    NULL DEFINED AS ''
LOCATION '/warehouse/gmall/ods/ods_sku_attr_value_full/'
TBLPROPERTIES ('compression.codec'='org.apache.hadoop.io.compress.GzipCodec');
