-- ODS - ods_promotion_pos_full - 营销坑位表

DROP TABLE IF EXISTS ods_promotion_pos_full;
CREATE EXTERNAL TABLE ods_promotion_pos_full
(
    `id`                   STRING COMMENT '营销坑位ID',
    `pos_location`       STRING COMMENT '营销坑位位置',
    `pos_type`            STRING COMMENT '营销坑位类型：banner,宫格,列表,瀑布',
    `promotion_type`     STRING COMMENT '营销类型：算法、固定、搜索',
    `create_time`         STRING COMMENT '创建时间',
    `operate_time`        STRING COMMENT '修改时间'
) COMMENT '营销坑位表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    NULL DEFINED AS ''
LOCATION '/warehouse/gmall/ods/ods_promotion_pos_full/'
TBLPROPERTIES ('compression.codec'='org.apache.hadoop.io.compress.GzipCodec');
