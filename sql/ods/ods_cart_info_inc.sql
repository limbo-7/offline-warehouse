-- ODS - ods_cart_info_inc - 购物车增量表

DROP TABLE IF EXISTS ods_cart_info_inc;
CREATE EXTERNAL TABLE ods_cart_info_inc
(
    `type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<id :STRING,
        user_id :STRING,
        sku_id :STRING,
        cart_price :DECIMAL(16, 2),
        sku_num :BIGINT,
        img_url :STRING,
        sku_name :STRING,
        is_checked :STRING,
        create_time :STRING,
        operate_time :STRING,
        is_ordered :STRING,
        order_time:STRING> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
LOCATION '/warehouse/gmall/ods/ods_cart_info_inc/'
TBLPROPERTIES ('compression.codec'='org.apache.hadoop.io.compress.GzipCodec');
