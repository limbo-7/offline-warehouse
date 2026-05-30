-- ODS - ods_order_detail_inc - 订单明细增量表

DROP TABLE IF EXISTS ods_order_detail_inc;
CREATE EXTERNAL TABLE ods_order_detail_inc
(
    `type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<id :STRING,
        order_id :STRING,
        sku_id :STRING,
        sku_name :STRING,
        img_url :STRING,
        order_price:DECIMAL(16, 2),
        sku_num :BIGINT,
        create_time :STRING,
        source_type :STRING,
        source_id :STRING,
        split_total_amount:DECIMAL(16, 2),
        split_activity_amount :DECIMAL(16, 2),
        split_coupon_amount:DECIMAL(16, 2),
        operate_time :STRING> COMMENT '数据',
    `old`  MAP<STRING,
    STRING> COMMENT '旧值'
) COMMENT '订单明细表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
LOCATION '/warehouse/gmall/ods/ods_order_detail_inc/'
TBLPROPERTIES ('compression.codec'='org.apache.hadoop.io.compress.GzipCodec');
