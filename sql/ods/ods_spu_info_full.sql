-- ODS - ods_spu_info_full - SPU表

DROP TABLE IF EXISTS ods_spu_info_full;
CREATE EXTERNAL TABLE ods_spu_info_full
(
    `id`              STRING COMMENT 'SPU_ID',
    `spu_name`       STRING COMMENT 'SPU名称',
    `description`   STRING COMMENT '描述信息',
    `category3_id`  STRING COMMENT '三级品类ID',
    `tm_id`           STRING COMMENT '品牌ID',
    `create_time`    STRING COMMENT '创建时间',
    `operate_time`   STRING COMMENT '修改时间'
) COMMENT 'SPU表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    NULL DEFINED AS ''
LOCATION '/warehouse/gmall/ods/ods_spu_info_full/'
TBLPROPERTIES ('compression.codec'='org.apache.hadoop.io.compress.GzipCodec');
