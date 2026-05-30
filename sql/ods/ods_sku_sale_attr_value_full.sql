-- ODS - ods_sku_sale_attr_value_full - SKU销售属性值表

DROP TABLE IF EXISTS ods_sku_sale_attr_value_full;
CREATE EXTERNAL TABLE ods_sku_sale_attr_value_full
(
    `id`                      STRING COMMENT '编号',
    `sku_id`                 STRING COMMENT 'SKU_ID',
    `spu_id`                 STRING COMMENT 'SPU_ID',
    `sale_attr_value_id`   STRING COMMENT '销售属性值ID',
    `sale_attr_id`          STRING COMMENT '销售属性ID',
    `sale_attr_name`        STRING COMMENT '销售属性名称',
    `sale_attr_value_name` STRING COMMENT '销售属性值名称',
    `create_time`            STRING COMMENT '创建时间',
    `operate_time`           STRING COMMENT '修改时间'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    NULL DEFINED AS ''
LOCATION '/warehouse/gmall/ods/ods_sku_sale_attr_value_full/'
TBLPROPERTIES ('compression.codec'='org.apache.hadoop.io.compress.GzipCodec');
